import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'bloc/notification_bloc.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: BlocProvider(
        lazy: false,
        create: (context) => NotificationBloc(),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final notifcations = context.read<NotificationBloc>().notifcations;
            final textTheme = Theme.of(context).textTheme;
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              itemCount: notifcations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  textColor: Colors.black,
                  isThreeLine: true,
                  title: Text(notifcations[index].title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notifcations[index].message,
                          style: textTheme.titleMedium
                              ?.copyWith(color: Colors.black)),
                      Text(
                        notifcations[index]
                            .createdDate
                            .toStringFormat('dd-MM-yyyy hh:mma'),
                        style: textTheme.labelSmall
                            ?.copyWith(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
