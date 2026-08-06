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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget accountSection() {
      return _InfoSectionCard(
        title: 'Account information',
        children: [
          _InfoRow(title: 'Name', info: profileDetail.fullName),
          _InfoRow(title: 'Role', info: profileDetail.role),
          _InfoRow(
            title: profileDetail.companyName.toLowerCase() == "contractor"
                ? 'Business Manager'
                : 'Reports To',
            info: profileDetail.reportTo,
          ),
          if (profileDetail.companyName.toLowerCase() != "contractor")
            _InfoRow(title: 'Designation', info: profileDetail.designation),
          _InfoRow(title: 'Email', info: profileDetail.email),
          _InfoRow(title: 'Mobile', info: profileDetail.mobile),
          _InfoRow(
            title: 'Create Date',
            info: profileDetail.createdDate.toStringFormat('dd MMM yy'),
          ),
          _InfoRow(
            title: profileDetail.companyName.toLowerCase() == "contractor"
                ? 'Start Date'
                : 'Date of joining',
            info: profileDetail.doj.toStringFormat('dd MMM yy'),
          ),
          _InfoRow(title: 'Status', info: profileDetail.userStatus),
        ],
      );
    }

    Widget deviceSection() {
      return _InfoSectionCard(
        title: 'Device information',
        children: [
          FutureBuilder<String>(
              future: deviceInfo.name(),
              builder: (context, snapshot) {
                return _InfoRow(
                  title: 'Device Model',
                  info: snapshot.data ?? '',
                );
              }),
          FutureBuilder<String>(
              future: deviceInfo.deviceOs(),
              builder: (context, snapshot) {
                return _InfoRow(
                  title: 'OS Version',
                  info: snapshot.data ?? '',
                );
              }),
          _InfoRow(
            title: 'Last Login',
            info: profileDetail.lastLogin?.toStringFormat('dd/MM/yy HH:mm') ??
                "",
          ),
          FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                return _InfoRow(
                  title: 'App Version',
                  info: snapshot.data?.version ?? '1.0',
                );
              }),
          _InfoRow(
            title: 'Device status',
            info: AppStorage().registeredDeviceFingerprint != null
                ? 'Registered on this device'
                : 'Not registered',
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 8.h),
          //   child: Align(
          //     alignment: Alignment.centerRight,
          //     child: TextButton.icon(
          //       onPressed: () {
          //         context.pushNamed(
          //           AppPaths.deviceRegistration,
          //           extra: {'username': profileDetail.username},
          //         );
          //       },
          //       icon: const Icon(Icons.phonelink_setup_rounded, size: 18),
          //       label: const Text('Request device change'),
          //     ),
          //   ),
          // ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Information'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 18.h),
            child: Column(
              children: [
                Material(
                  elevation: 0,
                  color: cs.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 22.sp,
                          color: theme.primaryColor,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Profile and device details used for your account and login.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.35,
                              color: cs.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                accountSection(),
                SizedBox(height: 12.h),
                deviceSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: 1.sw,
            color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
  const _InfoSectionCard({required this.title, required this.children});
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String info;
  const _InfoRow({required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.25)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 7,
            child: Text(
              info,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
