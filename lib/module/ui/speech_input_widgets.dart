import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/speech_to_text_service.dart';

/// Handles listen/stop and live updates for a single text field.
class SpeechFieldLogic {
  SpeechFieldLogic({
    required this.textController,
    this.onTextChanged,
    required this.onListeningChanged,
    required this.showMessage,
  });

  final TextEditingController textController;
  final ValueChanged<String>? onTextChanged;
  final VoidCallback onListeningChanged;
  final void Function(String message) showMessage;

  final _speech = SpeechToTextService.instance;
  bool listening = false;
  String _prefixAtSessionStart = '';

  Future<void> toggleListening() async {
    if (listening) {
      await stopListening(userInitiated: true);
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    _prefixAtSessionStart = textController.text;
    final started = await _speech.startListening(
      onResult: _onSpeechResult,
      onStatus: _onSpeechStatus,
    );
    if (!started) {
      showMessage('Speech input is not available on this device');
      return;
    }
    listening = true;
    onListeningChanged();
    showMessage('Listening… Speak now. Tap the mic again to stop.');
  }

  Future<void> stopListening({required bool userInitiated}) async {
    if (!listening && !_speech.isListening) return;

    final lastWords = await _speech.stopListening();
    listening = false;
    onListeningChanged();

    if (lastWords != null && lastWords.trim().isNotEmpty) {
      _applyRecognizedText(lastWords.trim());
      if (userInitiated) {
        showMessage('Speech added to the field');
      }
      return;
    }

    if (textController.text.trim().isEmpty ||
        textController.text == _prefixAtSessionStart) {
      showMessage("Couldn't hear anything. Try again.");
    } else if (userInitiated) {
      showMessage('Stopped listening');
    }
  }

  void _onSpeechResult(String text, bool isFinal) {
    final spoken = text.trim();
    if (spoken.isEmpty) return;
    _applyRecognizedText(spoken);
    if (isFinal) {
      listening = false;
      _speech.stopListening();
      onListeningChanged();
      showMessage('Speech added to the field');
    }
  }

  void _onSpeechStatus(String status) {
    if ((status == 'done' || status == 'notListening') && listening) {
      listening = false;
      onListeningChanged();
    }
  }

  void _applyRecognizedText(String spoken) {
    final prefix = _prefixAtSessionStart.trim();
    final updated =
        prefix.isEmpty ? spoken : '$prefix $spoken';
    textController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
    );
    onTextChanged?.call(updated);
  }

  Future<void> dispose() async {
    if (listening || _speech.isListening) {
      final lastWords = await _speech.stopListening();
      listening = false;
      if (lastWords != null && lastWords.trim().isNotEmpty) {
        _applyRecognizedText(lastWords.trim());
      }
    }
  }
}

class _SpeechMicButton extends StatelessWidget {
  final bool listening;
  final bool enabled;
  final Animation<double> pulse;
  final VoidCallback onPressed;

  const _SpeechMicButton({
    required this.listening,
    required this.enabled,
    required this.pulse,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.error;

    Widget icon = Icon(
      listening ? Icons.mic : Icons.mic_none_outlined,
      color: enabled
          ? (listening ? activeColor : theme.colorScheme.primary)
          : theme.disabledColor,
    );

    if (listening) {
      icon = ScaleTransition(
        scale: pulse,
        child: icon,
      );
    }

    return IconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: listening ? 'Stop listening' : 'Tap to speak',
      icon: icon,
    );
  }
}

/// Wraps a text field with speech UI: live text, listening banner, mic pulse.
class _SpeechFieldShell extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onTextChanged;
  final bool enabled;
  final bool speechEnabled;
  final InputDecoration decoration;
  final Widget Function(InputDecoration decoration) fieldBuilder;

  const _SpeechFieldShell({
    required this.controller,
    this.onTextChanged,
    required this.enabled,
    required this.speechEnabled,
    required this.decoration,
    required this.fieldBuilder,
  });

  @override
  State<_SpeechFieldShell> createState() => _SpeechFieldShellState();
}

class _SpeechFieldShellState extends State<_SpeechFieldShell>
    with SingleTickerProviderStateMixin {
  late final SpeechFieldLogic _logic;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _logic = SpeechFieldLogic(
      textController: widget.controller,
      onTextChanged: widget.onTextChanged,
      onListeningChanged: () {
        if (mounted) setState(() {});
        if (_logic.listening) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.value = 1;
        }
      },
      showMessage: (msg) {
        if (mounted) context.showSnackBarMessage(msg);
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _logic.dispose();
    super.dispose();
  }

  InputDecoration _decorate(InputDecoration base) {
    if (!widget.speechEnabled) return base;

    final theme = Theme.of(context);
    var result = base.copyWith(
      suffixIcon: _buildSuffix(base.suffixIcon),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
    );

    if (_logic.listening) {
      final highlight = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      );
      result = result.copyWith(
        enabledBorder: highlight,
        focusedBorder: highlight,
        fillColor: theme.colorScheme.error.withValues(alpha: 0.06),
      );
    }

    return result;
  }

  Widget? _buildSuffix(Widget? existing) {
    if (!widget.speechEnabled) return existing;

    final mic = _SpeechMicButton(
      listening: _logic.listening,
      enabled: widget.enabled,
      pulse: _pulseAnimation,
      onPressed: _logic.toggleListening,
    );

    if (existing == null) return mic;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [existing, mic],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = widget.decoration;
    final decorated = _decorate(base);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.fieldBuilder(decorated),
        if (_logic.listening && widget.speechEnabled) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Icon(
                    Icons.mic,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Listening… Tap the red mic to stop',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

InputDecoration mergeSpeechSuffix(
  InputDecoration decoration,
  TextEditingController controller, {
  ValueChanged<String>? onTextChanged,
  bool speechEnabled = true,
  bool fieldEnabled = true,
}) {
  return decoration;
}

/// [TextField] with speech-to-text, live partial results, and listening UI.
class SpeechEnabledTextField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool speechEnabled;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;

  const SpeechEnabledTextField({
    super.key,
    required this.controller,
    this.decoration,
    this.onChanged,
    this.enabled = true,
    this.speechEnabled = true,
    this.minLines,
    this.maxLines,
    this.keyboardType,
    this.autofocus = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return _SpeechFieldShell(
      controller: controller,
      onTextChanged: onChanged,
      enabled: enabled,
      speechEnabled: speechEnabled,
      decoration: decoration ?? const InputDecoration(),
      fieldBuilder: (decorated) => TextField(
        controller: controller,
        autofocus: autofocus,
        enabled: enabled,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        decoration: decorated,
      ),
    );
  }
}

/// [TextFormField] with speech-to-text; owns a controller when none is passed.
class SpeechEnabledTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool speechEnabled;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  const SpeechEnabledTextFormField({
    super.key,
    this.controller,
    this.decoration,
    this.onChanged,
    this.enabled = true,
    this.speechEnabled = true,
    this.minLines,
    this.maxLines,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
  });

  @override
  State<SpeechEnabledTextFormField> createState() =>
      _SpeechEnabledTextFormFieldState();
}

class _SpeechEnabledTextFormFieldState extends State<SpeechEnabledTextFormField> {
  TextEditingController? _ownedController;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SpeechFieldShell(
      controller: _controller,
      onTextChanged: widget.onChanged,
      enabled: widget.enabled,
      speechEnabled: widget.speechEnabled,
      decoration: widget.decoration ?? const InputDecoration(),
      fieldBuilder: (decorated) => TextFormField(
        controller: _controller,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
        decoration: decorated,
      ),
    );
  }
}
