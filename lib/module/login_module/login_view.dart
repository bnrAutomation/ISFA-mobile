import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/device_registration_module/device_unauthorized_dialog.dart';
import 'package:i_densfa/module/login_module/bloc/login_bloc.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/credential_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:upgrader/upgrader.dart';
import 'login_repository.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  bool rememberMe = false;
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedCredentials());
  }

  Future<void> _loadSavedCredentials() async {
    if (usernameController.text.isNotEmpty ||
        passwordController.text.isNotEmpty) {
      return;
    }

    final token = ++_loadToken;
    final saved = await CredentialStorage.loadSaved();
    if (!mounted || token != _loadToken || !saved.remember) return;

    setState(() {
      rememberMe = true;
      if (saved.username != null && saved.username!.isNotEmpty) {
        usernameController.text = saved.username!;
      }
      if (saved.password != null && saved.password!.isNotEmpty) {
        passwordController.text = saved.password!;
      }
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                  child: Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        ImageConstants.pinBack,
                        fit: BoxFit.cover,
                      ))),
              Positioned.fill(
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.6))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RepositoryProvider(
                  create: (context) => LoginRepository(),
                  child: BlocProvider(
                    create: (context) => LoginBloc(context.read()),
                    child: BlocConsumer<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is LoginDeviceUnauthorizedState) {
                          showDeviceUnauthorizedDialog(
                            context,
                            username: state.username,
                            message: state.message,
                          );
                        } else if (state is LoginedSuccesfullState) {
                          Future.delayed(const Duration(seconds: 1), () {
                            if (context.mounted) {
                              context.hideKeyboard();
                              context.go(AppPaths.tabbar);
                            }
                          });
                        } else if (state is MoveToSetPinState) {
                          context.push(AppPaths.pinset,
                              extra: context.read<LoginBloc>());
                        }
                      },
                      builder: (context, state) {
                        var bloc = context.read<LoginBloc>();
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 1.sh),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(ImageConstants.denSfa),
                                SizedBox(height: 30.h),
                                Image.asset(ImageConstants.poweredBy),
                                SizedBox(height: 60.h),
                                const SizedBox(height: 10),
                                if (state is LogInErrorState)
                                  Text(
                                    state.errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                const SizedBox(height: 10),
                                TextField(
                                  textInputAction: TextInputAction.next,
                                  enableInteractiveSelection: false,
                                  controller: usernameController,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(" ")
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Username",
                                    labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: ColorConstants.amber,
                                      fontSize: 14.0,
                                    ),
                                    hintStyle:
                                        const TextStyle(color: Colors.white),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50.w),
                                        borderSide: const BorderSide(
                                            color: ColorConstants.amber)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50.w),
                                        borderSide: const BorderSide(
                                            color: Colors.white54)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  textInputAction: TextInputAction.done,
                                  enableInteractiveSelection: false,
                                  controller: passwordController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(" ")
                                  ],
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: !context
                                      .read<LoginBloc>()
                                      .isShowingPassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: ColorConstants.amber,
                                      fontSize: 14.0,
                                    ),
                                    hintStyle:
                                        const TextStyle(color: Colors.white),
                                    suffixIcon: IconButton(
                                      onPressed: () => bloc
                                          .add(LoginShowPasswordButtonEvent()),
                                      icon: Icon(
                                        state is LoginShowPasswordState
                                            ? state.visible
                                                ? Icons.visibility
                                                : Icons.visibility_off
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50.w),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50.w),
                                        borderSide: const BorderSide(
                                            color: Colors.white54)),
                                    counterText: '',
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CheckboxListTile(
                                        
                                        value: rememberMe,
                                        onChanged: (value) => setState(
                                            () => rememberMe = value ?? false),
                                        title: Text(
                                          'Remember Me',
                                          style: GoogleFonts.metrophobic(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: const EdgeInsets.all(0),
                                        activeColor: ColorConstants.amber,
                                        checkColor: Colors.black,
                                        dense: true,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        context.hideKeyboard();
                                        context.pushNamed(AppPaths.forgotpass);
                                      },
                                      child: Text(
                                        "Forgot Password?",
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.metrophobic(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                             SizedBox(height: 20.h),
                                CustomButton(
                                  buttonText: "LOGIN",
                                  onPressed: () {
                                    if (state is! LogInLoadingState) {
                                      context.hideKeyboard();
                                      bloc.add(LoginSubmitEvent(
                                        usernameController.text,
                                        passwordController.text,
                                        rememberMe: rememberMe,
                                      ));
                                    }
                                  },
                                  isLoading: state is LogInLoadingState,
                                  isSuccess: state is LoginedSuccesfullState,
                                ),
                                // TextButton(
                                //   onPressed: () {
                                //     context.hideKeyboard();
                                //     context.pushNamed(
                                //       AppPaths.deviceRegistration,
                                //       extra: {
                                //         'username': usernameController.text,
                                //       },
                                //     );
                                //   },
                                //   child: Text(
                                //     'Request device change',
                                //     style: GoogleFonts.metrophobic(
                                //       fontSize: 12.sp,
                                //       color: Colors.white70,
                                //       fontWeight: FontWeight.w500,
                                //     ),
                                //   ),
                                // ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
