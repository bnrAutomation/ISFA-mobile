import 'package:flutter/material.dart';

class StoreListView extends StatelessWidget {
  const StoreListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.primary,
              )),
          trailing: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              )),
          title: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => DatePickerDialog(
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year),
                      lastDate: DateTime.now()),
                );
              },
              child: const Text('21 Feb 2023')),
        ),
        Expanded(
            child: ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: 10,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: CircleAvatar(radius: 25),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Store Name",
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text("21, address of location",
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text("Store tag#",
                              style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Text("12.47 km away",
                              style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 4),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ))
      ],
    );
  }
}
