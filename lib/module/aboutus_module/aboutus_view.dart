import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 1.sw,
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              ImageConstants.logo,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => launchUrlString('https://www.denave.com/about-us/'),
            child: Text(
              'About Us',
              style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.blue,
                  decorationColor: Colors.blue,
                  decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 10),
          const Spacer(),
          FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final packageInfo = snapshot.data!;
                  String version = packageInfo.version;
                  String code = packageInfo.buildNumber;
                  return Text('Version: $version ($code)');
                } else {
                  return const SizedBox();
                }
              }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
