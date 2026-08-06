import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/module/ui/speech_input_widgets.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'bloc/schedule_visit_call_bloc.dart';

class ScheduleVisitView extends StatefulWidget {
  const ScheduleVisitView({super.key});

  @override
  State<ScheduleVisitView> createState() => _ScheduleVisitViewState();
}

class _ScheduleVisitViewState extends State<ScheduleVisitView> {
  late final TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final initial = context.read<ScheduleVisitCallBloc>().remark;
      if (initial.isNotEmpty) {
        _remarkController.text = initial;
      }
    });
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ScheduleVisitCallBloc>();
    final type = bloc.schedulingFor;
    final isVisit = type == SchuduleType.visit;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(isVisit ? 'Schedule Visit' : 'Schedule Call'),
        backgroundColor: ColorConstants.amber,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: BlocListener<ScheduleVisitCallBloc, ScheduleVisitCallState>(
          listenWhen: (previous, current) =>
              current is ScheduleVisitCallSnackBar ||
              current is ScheduleVisitCallSuccessState,
          listener: (context, state) {
            if (state is ScheduleVisitCallSnackBar) {
              context.showSnackBarMessage(state.message);
            } else if (state is ScheduleVisitCallSuccessState) {
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(
              //   width: double.infinity,
              //   child: CupertinoSlidingSegmentedControl(
              //       padding: const EdgeInsets.all(0),
              //       thumbColor: Theme.of(context).colorScheme.background,
              //       groupValue: context.select(
              //           (ScheduleVisitCallBloc value) => value.schedulingFor),
              //       children: const {
              //         SchuduleType.visit: Center(child: Text("VISIT")),
              //         SchuduleType.call: Center(child: Text("CALL"))
              //       },
              //       onValueChanged: (val) {
              //         if (val != null) {
              //           context
              //               .read<ScheduleVisitCallBloc>()
              //               .add(ScheduleTypeChangeEvent(val));
              //         }
              //       }),
              // ),
              Material(
                color: Colors.white,
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _PickerField(
                              label: isVisit ? 'Visit date' : 'Call date',
                              isRequired: true,
                              value: context.select(
                                (ScheduleVisitCallBloc value) =>
                                    bloc.selectedDate
                                        ?.toStringFormat('dd/MM/yyyy'),
                              ),
                              hintText: 'DD/MM/YYYY',
                              icon: Icons.calendar_month_outlined,
                              onTap: () async {
                                final now = DateTime.now();
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: now,
                                  lastDate: DateTime(now.year, 12, 31),
                                );
                                if (selectedDate != null) {
                                  bloc.add(ScheduleVisitChangeDateEvent(
                                      selectedDate));
                                }
                              },
                            ),
                          ),
                          if (isVisit) ...[
                            const SizedBox(width: 10),
                            Expanded(child: _selectStore(context)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _SectionLabel(
                        text: 'Agenda',
                        isRequired: false,
                      ),
                      const SizedBox(height: 6),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: scheme.outlineVariant
                                .withValues(alpha: 0.70),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: TapRegion(
                            onTapOutside: (_) => context.hideKeyboard(),
                            child: SpeechEnabledTextField(
                              controller: _remarkController,
                              minLines: 4,
                              maxLines: 8,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(256),
                              ],
                              onChanged: (value) {
                                bloc.add(ScheduleVisitChangeRemarkEvent(value));
                              },
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintText:
                                    'Type or tap mic (max 256 characters)',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              BlocBuilder<ScheduleVisitCallBloc, ScheduleVisitCallState>(
                builder: (context, state) {
                  return CustomButton(
                    buttonText: "Save",
                    onPressed: () {
                      context.hideKeyboard();
                      if (state is! ScheduleVisitCallLoadingState) {
                        bloc.add(ScheduleVisitSaveEvent());
                      }
                    },
                    isLoading: state is ScheduleVisitCallLoadingState,
                    isSuccess: state is ScheduleVisitCallSuccessState,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  UnderlineInputBorder underLineBorder() {
    return UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade500, width: 0.5));
  }

  Column _selectStore(BuildContext context) {
    final ScheduleVisitCallBloc bloc = context.read();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: "Select Store", isRequired: true),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.70),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                value: context.select(
                  (ScheduleVisitCallBloc value) => value.selectedStore.storeName,
                ),
                items: bloc.beatPlans
                    .map((e) => e.storeName)
                    .toSet()
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (String? val) {
                  if (val != null) {
                    bloc.add(ScheduleVisitChangeStore(val));
                  }
                },
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                hint: const Text(
                  'Select Store',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.isRequired});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            )
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.isRequired,
    required this.value,
    required this.hintText,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool isRequired;
  final String? value;
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: label, isRequired: isRequired),
        const SizedBox(height: 6),
        Material(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.70),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      (value == null || value!.isEmpty) ? hintText : value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: (value == null || value!.isEmpty)
                            ? Colors.black38
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(icon, color: Colors.black54),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
