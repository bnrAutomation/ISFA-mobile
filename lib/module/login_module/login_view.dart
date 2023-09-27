import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/login_module/bloc/login_bloc.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'login_repository.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    ImageConstants.pinBack,
                    fit: BoxFit.cover,
                  ))),
          SizedBox(
              height: 1.sh,
              width: 1.sw,
              child: ColoredBox(color: Colors.black.withOpacity(0.6))),
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RepositoryProvider(
                  create: (context) => LoginRepository(),
                  child: BlocProvider(
                    create: (context) => LoginBloc(context.read()),
                    child: BlocConsumer<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is LoginedSuccesfullState) {
                          context.hideKeyboard();
                          context.go(AppPaths.tabbar);
                        } else if (state is MoveToSetPinState) {
                          context.push(AppPaths.pinset,
                              extra: context.read<LoginBloc>());
                        }
                      },
                      builder: (context, state) {
                        var bloc = context.read<LoginBloc>();
                        return Column(
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
                              enableInteractiveSelection: false,
                              controller: usernameController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(" ")
                              ],
                              onChanged: (change) {
                                BlocProvider.of<LoginBloc>(context).add(
                                    LoginTextChangeEvent(
                                        usernameController.text,
                                        passwordController.text));
                              },
                              decoration: InputDecoration(
                                hintText: "Email Id",
                                hintStyle: const TextStyle(color: Colors.white),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.w),
                                    borderSide: const BorderSide(
                                        color: ColorConstants.amber)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.w),
                                    borderSide: const BorderSide(
                                        color: Colors.white54)),
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              enableInteractiveSelection: false,
                              controller: passwordController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(" ")
                              ],
                              onChanged: (change) {
                                bloc.add(LoginTextChangeEvent(
                                    usernameController.text,
                                    passwordController.text));
                              },
                              keyboardType: TextInputType.visiblePassword,
                              obscureText:
                                  context.read<LoginBloc>().isShowingPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: const TextStyle(color: Colors.white),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      bloc.add(LoginShowPasswordButtonEvent()),
                                  icon: Icon(
                                    state is LoginShowPasswordState
                                        ? state.visible
                                            ? Icons.visibility
                                            : Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.w),
                                    borderSide: const BorderSide(
                                        color: ColorConstants.amber)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.w),
                                    borderSide: const BorderSide(
                                        color: Colors.white54)),
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
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
                            ),
                            SizedBox(height: 20.h),
                            MaterialButton(
                                minWidth: double.maxFinite,
                                color: ColorConstants.amber,
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.w)),
                                onPressed: () {
                                  if (state is! LogInLoadingState) {
                                    context.hideKeyboard();
                                    bloc.add(LoginSubmitEvent(
                                        usernameController.text,
                                        passwordController.text));
                                  }
                                },
                                child: Text(
                                  state is LogInLoadingState
                                      ? "Loading..."
                                      : 'LOGIN',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400),
                                )),
                            const SizedBox(height: 10)
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
