import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/my_activity_module/myActivity/my_activity_bloc.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_repository.dart';
import 'package:i_densfa/utility/extensions.dart';

class MyActivityView extends StatelessWidget {
  const MyActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "My Activity",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: RepositoryProvider(
        create: (context) => MyActivityRepository(),
        child: BlocProvider(
          create: (context) =>
              MyActivityBloc(context.read())..add(GetMyAcivityEvent()),
          child: BlocConsumer<MyActivityBloc, MyActivityState>(
            listenWhen: (previous, current) => current is MyActivityShowSnack,
            listener: (context, state) {
              if (state is MyActivityShowSnack) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                ));
              }
            },
            buildWhen: (previous, current) => current is! MyActivityShowSnack,
            builder: (context, state) {
              var bloc = context.read<MyActivityBloc>();
              return Column(
                children: [
                  Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 1.0, // soften the shadow
                            spreadRadius: 1.0, //extend the shadow
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bloc.selected.toStringFormat("dd MMMM"),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                final now = DateTime.now();
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: DateTime(now.year),
                                  lastDate: DateTime(now.year + 1),
                                );
                                if (date != null && context.mounted) {
                                  bloc.add(MyActivityChangeMonth(date));
                                }
                              },
                              icon: const Icon(
                                Icons.calendar_month,
                                color: Colors.blue,
                              )),
                        ],
                      )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
