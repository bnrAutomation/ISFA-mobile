import 'package:flutter/material.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';

class AnalyticsView extends StatelessWidget {
  final int? forUserId;
  const AnalyticsView({super.key, this.forUserId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: forUserId != null ? AppBar(title: const Text('Analytics')) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xff959595), Color(0xff636363)])),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Align(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        borderedBox(
                          child: const SizedBox(
                            width: 80,
                            height: 80,
                            child: ColoredBox(color: Colors.red),
                          ),
                        ),
                        Text('Abhay Gupta',
                            style: textTheme.bodyLarge
                                ?.copyWith(color: Colors.white)),
                        Text('TSI| Self & Team',
                            style: textTheme.bodySmall
                                ?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {},
                      color: Colors.white,
                      iconSize: 30,
                      icon: const Icon(Icons.replay_circle_filled_rounded),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              height: 70,
              child: CustomMaterialButton(
                buttonText: "Change Date",
                onPressed: () {
                  final selectedDate = showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  debugPrint(selectedDate.toString());
                },
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(color: ColorConstants.amber),
                    boxShadow: const [
                      BoxShadow(
                        color: ColorConstants.amber,
                        blurRadius: 1,
                        spreadRadius: 0.5,
                      )
                    ]),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Coverage",
                          style: textTheme.titleLarge,
                        ),
                        Text(
                          "Target",
                          style: textTheme.titleSmall,
                        ),
                        Text(
                          "1,00,000",
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          "Target",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          "1,00,000",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: 75.5 / 100,
                            backgroundColor: Color(0xffededee),
                            strokeWidth: 12,
                            color: ColorConstants.amber,
                          ),
                        ),
                        Text("75.5%")
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget borderedBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.amber),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
    );
  }

  Widget shadowBox({required Widget child}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: ColorConstants.amber, blurRadius: 2, spreadRadius: 2)
            ]),
        child: child);
  }
}
