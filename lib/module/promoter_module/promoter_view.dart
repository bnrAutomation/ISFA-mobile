import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/campaign_module/campaign_view/campain_list.dart';
import 'package:i_densfa/module/inventory_module/inventory_view.dart';
import 'package:i_densfa/module/ui/custom_image_button.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';

class PromoterView extends StatelessWidget {
  const PromoterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0XFF003D5B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Promoter",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: Column(children: [
        const SizedBox(
          height: 5,
        ),
        Card(
          color: const Color(0xffBFD1DF),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 5,
          child: Column(
            children: [
              Container(
                  height: 0.2.sh,
                  decoration: const BoxDecoration(
                    color: Color(0xffBFD1DF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),

                      //Radius.circular(20)
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Image.network(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpo1BfypXH0JcsdyjZI_w3rK-T4utQ_RAVjBx5ELNHpuN9fUdPBNuwjLjSxaVfCpXhsRQ&usqp=CAU",
                    fit: BoxFit.fitWidth,
                  )),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Color(0xffBFD1DF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),

                    //Radius.circular(20)
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Chroma Store",
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                            onPressed: () => {},
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ))
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.person, size: 12),
                        const SizedBox(width: 8),
                        Text('Retailer', style: GoogleFonts.inter(fontSize: 10))
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.placemark, size: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              '9, 6 Number Bus stop, No 6 Locality, Shiv Nagar, Bhopal, Madhya Pradesh 462011, India, Bhopal, MP',
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                              style: GoogleFonts.inter(fontSize: 10)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),

// Visible only one  either Check_in or Check-Out button.

                    CustomMaterialButton(
                        buttonText: "Check-In Store",
                        gradient: const LinearGradient(colors: <Color>[
                          Color(0XFF003D5B),
                          Color(0XFF278BBC),
                        ]),
                        onPressed: () => {}),

                    const SizedBox(height: 8),
                    CustomMaterialButton(
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0XFFC92434), Color(0XFF003D5B)],
                        ),
                        buttonText: "Check-Out Store",
                        onPressed: () => {})
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: CustomImageButton(
                  buttonText: "Sale Log",
                  onPressed: () => {},
                  image: SvgPicture.asset(
                    imageConstants.navigator,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomImageButton(
                  buttonText: "Inventory",
                  onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const InventoryView())))
                  },
                  image: SvgPicture.asset(
                    imageConstants.box,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomImageButton(
                  buttonText: "Start Campaign",
                  onPressed: () => {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return _openCampaignSheet(context);
                        })
                  },
                  image: SvgPicture.asset(
                    imageConstants.campaign,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomImageButton(
                  buttonText: "Feedback",
                  onPressed: () => {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return _openFeedbackSheet(context);
                        })
                  },
                  image: SvgPicture.asset(
                    imageConstants.feedback,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _openCampaignSheet(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: 20,
          width: 1.sw,
        ),
        SvgPicture.asset(
          imageConstants.line,
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 5,
                width: 1.sw,
              ),
              Text(
                "Campaign",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  shrinkWrap: true,
                  //padding: const EdgeInsets.all(5),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  itemBuilder: (context, index) => const CampaignList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _openFeedbackSheet(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: 20,
          width: 1.sw,
        ),
        SvgPicture.asset(
          imageConstants.line,
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 5,
                width: 1.sw,
              ),
              Text(
                "Take Feedback",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text("Neeraj Pan Bhandar,New Delhi.",
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(
                height: 5,
              ),
              Text("Select Purpose",
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: 1.sw,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  // value:
                  //     context.read<LeaveBloc>().selectLeaveType.isNotEmpty
                  //         ? context.read<LeaveBloc>().selectLeaveType
                  //         : null,
                  items: <String>[
                    'This is Dummy Purpose',
                    'This is Dummy Purpose',
                    'This is Dummy Purpose',
                    'Other'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // BlocProvider.of<LeaveBloc>(context)
                    //     .add(ChangeLeaveTypeEvent(value ?? ""));
                  },
                  hint: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Choose an option",
                      style: TextStyle(color: Colors.grey),
                      //textAlign: TextAlign.end,
                    ),
                  ),
                )),
              ),
              const SizedBox(
                height: 10,
              ),
              Text("Reason", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 8),
                      hintText: "Type your reason here..."),
                  // onTap: () => {},
                  minLines: 2,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  CircleAvatar(
                      // backgroundImage: AssetImage(imageConstants.scan),
                      backgroundColor: Colors.grey,
                      radius: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: SvgPicture.asset(imageConstants.scan),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: CustomMaterialButton(
                        buttonText: "Click Image",
                        onPressed: () => {Navigator.pop(context)}),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.black,
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              CustomMaterialButton(
                  buttonText: "Save Feedback",
                  onPressed: () => {Navigator.pop(context)}),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        )
      ],
    );
  }
}
