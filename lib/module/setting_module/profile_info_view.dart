import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_helper.dart';

class ProfileInfoview extends StatelessWidget {
  const ProfileInfoview({super.key});

  @override
  Widget build(BuildContext context) {
    final profileDetail = AppStorage().userDetail!;
    final deviceInfo = Device();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Information'),
        backgroundColor: ColorConstants.amber,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileInfoTitle(title: 'Account Information'),
            ProfileInfoDetailTitle(
                title: 'ID', info: profileDetail.id.toString()),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Emp-Role ID', info: profileDetail.roles
                //  .map((e) => e.id).join(', ')

                ),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(title: 'Role', info: profileDetail.roles
                //.map((e) => e.name).join(', ')

                ),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Reports To', info: profileDetail.supervisor),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Designation', info: profileDetail.designation),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(title: 'Email', info: profileDetail.email),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(title: 'Mobile', info: profileDetail.mobile),
            const Divider(height: 0.4),
            const ProfileInfoDetailTitle(title: 'Create Date', info: 'XXX'),
            const Divider(height: 0.4),
            const ProfileInfoDetailTitle(title: 'Date of joining', info: 'XXX'),
            const Divider(height: 0.4),
            const ProfileInfoDetailTitle(title: 'Status', info: 'XXX'),
            const Divider(height: 0.4),
            const ProfileInfoDetailTitle(title: 'Team Cluster', info: 'XXX'),
            const ProfileInfoTitle(title: 'Device Information'),
            FutureBuilder<String>(
                future: deviceInfo.deviceOs(),
                builder: (context, snapshot) {
                  return ProfileInfoDetailTitle(
                      title: 'OS Version', info: snapshot.data ?? '');
                }),
            const Divider(height: 0.4),
            FutureBuilder<String>(
                future: deviceInfo.deviceId(),
                builder: (context, snapshot) {
                  return ProfileInfoDetailTitle(
                      title: 'Device Model', info: snapshot.data ?? '');
                }),
            const Divider(height: 0.4),
            const ProfileInfoDetailTitle(title: 'Last Login', info: 'XXX'),
            const Divider(height: 0.4),
            const ProfileInfoDetailTitle(title: 'App Version', info: '1.0'),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoTitle extends StatelessWidget {
  final String title;
  const ProfileInfoTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      width: 1.sw,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class ProfileInfoDetailTitle extends StatelessWidget {
  final String title;
  final String info;
  const ProfileInfoDetailTitle(
      {super.key, required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
              child: Text(
            info,
            textAlign: TextAlign.right,
          ))
        ],
      ),
    );
  }
}
