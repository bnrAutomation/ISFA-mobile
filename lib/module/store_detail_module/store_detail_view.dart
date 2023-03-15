import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utility/app_constants.dart';

class StoreDetailView extends StatelessWidget {
  const StoreDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          size: 30.w,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.share)),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            headerImage(context),
            nameAddress(context),
            blueCard(context,
                leadingIcon: '',
                subtitle: 'Scheduled visits & Calls',
                title: '28 Feb 2023',
                trailingSVGImage: ''),
            blueCard(context,
                leadingIcon: '',
                subtitle: 'Available Credits',
                title: '₹ 500.0',
                trailingSVGImage: ''),
            blueCard(context,
                leadingIcon: '',
                subtitle: 'Notes of important discussion with the sub dealer',
                title: 'Recent Notes (2)',
                trailingSVGImage: ''),
            Row(
              children: [
                Expanded(
                  child: StoreDetailCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.stacked_line_chart_rounded),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Stage",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text("Select Stage",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        color: Theme.of(context).primaryColor)),
                          ],
                        ),
                        Icon(
                          Icons.border_color,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        )
                      ],
                    ),
                  ),
                ),
                // const SizedBox(width: 8),
                Expanded(
                  child: StoreDetailCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Class",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text("Other",
                                style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            StoreDetailCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.credit_card),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Available Credit",
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text("\$ 0.0",
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ],
              ),
            ),
            StoreDetailCard(
              child: ListTile(
                title: Text("Sub Dealer History",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).primaryColor)),
                subtitle: Row(
                  children: [
                    Text("Last Activity:",
                        style: Theme.of(context).textTheme.titleSmall),
                    Text("Compaign, 28 Feb 2023",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.grey)),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor),
              ),
            ),
            StoreDetailCard(
              child: ListTile(
                title: Text("More",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).primaryColor)),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding nameAddress(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Shree Sai Mangala Enterprise",
              style: GoogleFonts.inter(
                  fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 10.h),
          Text(
              "PLOT NO.77, BLOCK NO 179/1, SYNO-159/11, GABBARMATA MANDIR GALI, KADODARA, SURAT, Surat, Gujarat, Surat, Surat, India 123456",
              style: GoogleFonts.inter(
                  fontSize: 12.sp, fontWeight: FontWeight.w400)),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Beat Plan",
                style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                "7 km Away",
                style: GoogleFonts.inter(
                    fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Card blueCard(
    BuildContext context, {
    required String leadingIcon,
    required String title,
    required String subtitle,
    required String trailingSVGImage,
  }) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
            SizedBox(width: 10.w),
            SvgPicture.asset(
              imageConstants.scan,
              width: 65.w,
              height: 50.h,
            )
          ],
        ),
      ),
    );
  }

  AspectRatio headerImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
                imageUrl: 'https://picsum.photos/200/300',
                fit: BoxFit.fitWidth),
          ),
          Column(
            children: [
              SizedBox(height: 5.h),
              Container(
                margin: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                    color: const Color(0xffC92434),
                    borderRadius: BorderRadius.circular(5)),
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Text("Metro",
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () {},
                    icon: const Icon(
                      Icons.location_off_outlined,
                    )),
              ),
              SizedBox(height: 5.h),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () {},
                    icon: const Icon(
                      Icons.call,
                    )),
              ),
              SizedBox(height: 5.h),
            ],
          ),
        ],
      ),
    );
  }
}

class StoreDetailCard extends StatelessWidget {
  final Widget child;

  const StoreDetailCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12)
          ],
          borderRadius: BorderRadius.circular(7.w)),
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
