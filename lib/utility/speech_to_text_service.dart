import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Shared speech-to-text helper for form fields across the app.
class SpeechToTextService {
  SpeechToTextService._();
  static final SpeechToTextService instance = SpeechToTextService._();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  String _lastRecognized = '';
  void Function(String status)? _onStatus;

  Future<bool> ensureInitialized() async {
    if (_initialized) return _speech.isAvailable;
    _initialized = await _speech.initialize(
      onError: (error) {
        if (kDebugMode) {
          debugPrint('SpeechToText error: ${error.errorMsg}');
        }
      },
      onStatus: (status) {
        if (kDebugMode) {
          debugPrint('SpeechToText status: $status');
        }
        _onStatus?.call(status);
      },
    );
    return _initialized && _speech.isAvailable;
  }

  bool get isListening => _speech.isListening;

  String get lastRecognized => _lastRecognized;

  /// Starts listening; returns false if speech is unavailable.
  Future<bool> startListening({
    void Function(String text, bool isFinal)? onResult,
    void Function(String status)? onStatus,
    String? localeId,
  }) async {
    if (!await ensureInitialized()) return false;
    if (_speech.isListening) return true;

    _onStatus = onStatus;
    _lastRecognized = '';
    await _speech.listen(
      onResult: (result) {
        _lastRecognized = result.recognizedWords;
        onResult?.call(_lastRecognized, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 4),
        localeId: localeId,
        cancelOnError: true,
        partialResults: true,
        // Optional:
        // onDevice: false,
        // listenMode: ListenMode.dictation,
        // sampleRate: 16000,
      ),
    );
    return _speech.isListening;
  }

  /// Stops listening and returns the last recognized phrase.
  Future<String?> stopListening() async {
    _onStatus = null;
    if (!_speech.isListening) {
      final text = _lastRecognized.trim();
      return text.isEmpty ? null : _lastRecognized;
    }
    await _speech.stop();
    final text = _lastRecognized.trim();
    return text.isEmpty ? null : _lastRecognized;
  }

  Future<void> cancel() async {
    _onStatus = null;
    _lastRecognized = '';
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}
