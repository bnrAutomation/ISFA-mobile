import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/survey_module/bloc/survey_bloc.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/utility/extensions.dart';

class SurveyScheduleVisitView extends StatefulWidget {
  const SurveyScheduleVisitView({super.key});

  @override
  State<SurveyScheduleVisitView> createState() =>
      _SurveyScheduleVisitViewState();
}

class _SurveyScheduleVisitViewState extends State<SurveyScheduleVisitView> {
  var visitDate = DateTime.now();
  String? clientName;
  var agendaTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final SurveyBloc bloc = context.read();
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Visit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Visit date*",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      InputDecorator(
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: visitDate.toStringFormat('dd/MM/yyyy')),
                          onTap: () async {
                            final now = DateTime.now();
                            final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: now,
                                lastDate: DateTime(now.year, 12, 31));
                            if (selectedDate != null) {
                              visitDate = selectedDate;
                              setState(() {});
                            }
                          },
                          decoration: const InputDecoration(
                              enabledBorder: InputBorder.none,
                              suffixIcon: Icon(Icons.calendar_month_outlined),
                              hintText: 'DD/MM/YYYY'),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: selectStore(context))
                ],
              ),
            ),
            const Text(
              "Agenda",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            InputDecorator(
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
              child: TextField(
                minLines: 5,
                maxLines: 10,
                maxLength: 256,
                controller: agendaTextEditingController,
                onTapOutside: (event) {
                  context.hideKeyboard();
                },
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: 'Type here (max 256 characters allowed)'),
              ),
            ),
            const SizedBox(height: 20),
            BlocConsumer<SurveyBloc, SurveyState>(
              listener: (context, state) {
                if (state is SurveyScheduleSuccessState) {
                  context.pop();
                }
              },
              builder: (context, state) {
                return CustomButton(
                  buttonText: "Save",
                  onPressed: () {
                    if (agendaTextEditingController.text.trim().isEmpty) {
                      context.showSnackBarMessage("Please enter agenda");
                      return;
                    } else if (clientName?.trim().isEmpty ?? true) {
                      context.showSnackBarMessage("Please select Client Name");
                      return;
                    }
                    context.hideKeyboard();
                    bloc.add(CreateSurveyVisitEvent(clientName!, visitDate,
                        agendaTextEditingController.text));
                  },
                  isLoading: state is SurveyScheduleLoadingState,
                  isSuccess: state is SurveyScheduleSuccessState,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  UnderlineInputBorder underLineBorder() {
    return UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade500, width: 0.5));
  }

  Column selectStore(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Client*",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        InputDecorator(
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              borderRadius: BorderRadius.circular(10),
              value: clientName,
              items: context
                  .read<SurveyBloc>()
                  .surveyClientList
                  .toSet()
                  .map((value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? val) {
                if (val != null) {
                  clientName = val;
                  setState(() {});
                }
              },
              icon: const Icon(Icons.keyboard_arrow_down),
              hint: const Text(
                'Select Store',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
