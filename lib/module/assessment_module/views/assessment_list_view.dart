import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/assessment_module/bloc/assessment_bloc.dart';
import 'package:i_densfa/routes.dart';

class AssessmentListView extends StatelessWidget {
  const AssessmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Assessment",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          )),
      body: ListView.separated(
        padding: EdgeInsets.all(10.w),
        itemCount: 10,
        separatorBuilder: (context, index) => SizedBox(height: 4.h),
        itemBuilder: (context, index) {
          final colors = [
            Theme.of(context).primaryColor,
            const Color(0xffDB4C5B),
            const Color(0xffEABB55),
            const Color(0xff464646),
          ];
          final colr = index < colors.length
              ? colors[index]
              : colors[index % colors.length];
          return Card(
            color: colr,
            child: ListTile(
              textColor: Colors.white,
              title: const Text("Scheme Update"),
              subtitle: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "15 Jan - 18 Jan 2023",
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
              onTap: () => context.pushNamed(AppPaths.assessment,
                  extra: context.read<AssessmentBloc>()),
            ),
          );
        },
      ),
    );
  }
}
