import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_view.dart';

import 'bloc/schedule_visit_call_bloc.dart';
import 'schedule_visit_view.dart';

class StoreListView extends StatelessWidget {
  const StoreListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(
          Icons.pending_actions,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                  create: (context) => ScheduleVisitCallBloc(),
                  child: const ScheduleVisitView()),
            ),
          );
        },
      ),
      body: Column(
        children: [
          ListTile(
            tileColor: const Color(0xff278BBC).withOpacity(0.2),
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
                style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    foregroundColor: Theme.of(context).colorScheme.primary),
                child: const Text('21 Feb 2023')),
          ),
          Expanded(
              child: ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: 10,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (c) => const StoreDetailView()));
                  },
                  child: const StoreCardView());
            },
          ))
        ],
      ),
    );
  }
}

class StoreCardView extends StatelessWidget {
  const StoreCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10.h, left: 40.w),
          decoration: BoxDecoration(
            color: const Color(0xffBFD1DF),
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              EdgeInsets.only(left: 45.w, top: 15.h, bottom: 15.h, right: 15.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gour pan sadan",
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      '6 No. Bus stop, Shiv Nagar, Madhya Pradesh 462011, India, Bhopal, MP',
                      style: GoogleFonts.inter(fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Beat Plan',
                          style: GoogleFonts.inter(
                              fontSize: 10.sp, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Text('45Km Away',
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                          style: GoogleFonts.inter(fontSize: 10.sp))
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Text('View Store',
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.white)),
                      ))
                ],
              )
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
              color: Color(0xffC92434)),
          child: Text(
            "Semi-urban",
            style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
                margin: EdgeInsets.only(top: 10.h),
                width: 80.w,
                height: 126.h,
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6.w)),
                alignment: Alignment.center,
                child: Image.network(
                    'https://media.istockphoto.com/id/912819604/vector/storefront-flat-design-e-commerce-icon.jpg?s=612x612&w=0&k=20&c=_x_QQJKHw_B9Z2HcbA2d1FH1U1JVaErOAp2ywgmmoTI=',
                    fit: BoxFit.fitWidth)),
          ),
        ),
      ],
    );
  }
}
