import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/campaign_module/campaign_view/campain_list.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';
import 'package:i_densfa/module/dynamic_questions_module/views/dynamic_questions_view.dart';
import 'package:i_densfa/module/inventory_module/inventory_view.dart';
import 'package:i_densfa/module/ui/custom_image_button.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_pop_view.dart';

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
                    ImageConstants.navigator,
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
                    ImageConstants.box,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomImageButton(
                  buttonText: "Start\nCampaign",
                  onPressed: () {
                    AppPopup.showAppBottomSheet(
                        context: context, child: _openCampaignSheet(context));
                  },
                  image: SvgPicture.asset(
                    ImageConstants.campaign,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomImageButton(
                  buttonText: "Feedback",
                  onPressed: () {
                    AppPopup.showAppBottomSheet(
                        context: context, child: _openFeedbackSheet(context));
                  },
                  image: SvgPicture.asset(
                    ImageConstants.feedback,
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
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Campaign",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      AppPopup.showAppBottomSheet(
                        context: context,
                        child: salesLogForm(textTheme),
                      );
                    },
                    child: const CampaignList())),
          ),
        ],
      ),
    );
  }

  Widget salesLogForm(TextTheme textTheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sales Log Form",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                DynamicQuestionsView(questions: dummySalesLogFormList),
              ],
            ),
          ),
          Container(
            color: const Color(0xff278bbc).withOpacity(0.2),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customer Details",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                DynamicQuestionsView(questions: dummyCustomerDetails),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: DynamicQuestionsView(questions: dummyOtherInfo),
          ),
          CustomMaterialButton(buttonText: "Submit", onPressed: () {}),
        ],
      ),
    );
  }

  Widget _openFeedbackSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Take Feedback",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Neeraj Pan Bhandar,New Delhi.",
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 5),
              Text("Select Purpose",
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 5),
              AppPopup.dropDownMenu(
                options: [
                  'This is Dummy Purpose',
                  'This is Dummy Purpose',
                  'This is Dummy Purpose',
                  'Other'
                ],
                placeholder: "Choose an option",
                onChanged: (p0) {},
              ),
              const SizedBox(height: 10),
              Text("Reason", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 5),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                      // backgroundImage: AssetImage(ImageConstants.scan),
                      backgroundColor: Colors.grey,
                      radius: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: SvgPicture.asset(ImageConstants.scan),
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
          )
        ],
      ),
    );
  }
}
