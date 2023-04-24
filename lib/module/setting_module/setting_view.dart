import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Settings",
            style: textTheme.titleSmall?.copyWith(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      // color: Theme.of(context).backgroundColor,
                      width: 1.sw,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35.0,
                            backgroundImage: const NetworkImage(
                                'https://tastevibe.web.app/assets/images/placeholder-user.png'),
                            backgroundColor: Colors.grey.withOpacity(0.2),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${AppStorage().userDetail?.username ?? ""}(${AppStorage().userDetail?.designation ?? ""})",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.mail,
                                      color: Colors.black,
                                      size: 14,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      AppStorage().userDetail?.email ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontSize: 14.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.phone_circle,
                                      color: Colors.black,
                                      size: 14,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      AppStorage().userDetail?.mobile ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontSize: 14.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CupertinoIcons
                                          .line_horizontal_3_decrease_circle,
                                      color: Colors.black,
                                      size: 14,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Company : ${AppStorage().userDetail?.companyName ?? ""}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontSize: 14.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      )),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'General',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      context.pushNamed(AppPaths.changePass);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,

                            offset: const Offset(
                                0, 0.1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: const ListTile(
                        title: Text("Change Password",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: 16)),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      context.pushNamed(AppPaths.policy);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            offset: const Offset(0, 0.1),
                          ),
                        ],
                      ),
                      child: const ListTile(
                        title: Text("Policy",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: 16)),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.pushNamed(AppPaths.aboutUs),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            offset: const Offset(0, 0.1),
                          ),
                        ],
                      ),
                      child: const ListTile(
                        title: Text("About Us",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: 16)),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ])));
  }
}
