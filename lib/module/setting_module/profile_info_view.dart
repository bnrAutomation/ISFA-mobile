import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileInfoview extends StatelessWidget {
  const ProfileInfoview({super.key});

  @override
  Widget build(BuildContext context) {
    final profileDetail = AppStorage().userDetail!;
    final deviceInfo = Device();
    return Scaffold(
      appBar: AppBar(title: const Text('Your Information')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileInfoTitle(title: 'Account Information'),
            ProfileInfoDetailTitle(title: 'Name', info: profileDetail.fullName),
            const Divider(height: 0.4),
            // ProfileInfoDetailTitle(
            //     title: 'Emp-Role ID', info: profileDetail.role),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(title: 'Role', info: profileDetail.role
                //.map((e) => e.name).join(', ')

                ),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Reports To', info: profileDetail.reportTo),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Designation', info: profileDetail.designation),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(title: 'Email', info: profileDetail.email),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(title: 'Mobile', info: profileDetail.mobile),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Create Date',
                info: profileDetail.createdDate.toStringFormat('dd MMM yy')),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Date of joining',
                info: profileDetail.doj.toStringFormat('dd MMM yy')),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Status', info: profileDetail.userStatus),
            const Divider(height: 0.4),
            // const ProfileInfoDetailTitle(title: 'Team Cluster', info: 'XXX'),
            const ProfileInfoTitle(title: 'Device Information'),
            FutureBuilder<String>(
                future: deviceInfo.name(),
                builder: (context, snapshot) {
                  return ProfileInfoDetailTitle(
                      title: 'Device Model', info: snapshot.data ?? '');
                }),
            const Divider(height: 0.4),
            FutureBuilder<String>(
                future: deviceInfo.deviceOs(),
                builder: (context, snapshot) {
                  return ProfileInfoDetailTitle(
                      title: 'OS Version', info: snapshot.data ?? '');
                }),
            const Divider(height: 0.4),
            ProfileInfoDetailTitle(
                title: 'Last Login',
                info: profileDetail.lastLogin.toStringFormat('dd/MM/yy HH:mm')),
            const Divider(height: 0.4),
            FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  return ProfileInfoDetailTitle(
                      title: 'App Version',
                      info: snapshot.data?.version ?? '1.0');
                }),
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
