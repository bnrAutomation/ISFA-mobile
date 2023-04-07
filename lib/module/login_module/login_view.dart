import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/login_module/bloc/login_bloc.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import '../ui/background.dart';
import 'login_repository.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          const Background(false),
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1.0, // soften the shadow
                      spreadRadius: 1.0, //extend the shadow
                      offset: Offset(
                        1.0, // Move to right 5  horizontally
                        1.0, // Move to bottom 5 Vertically
                      ))
                ],
              ),
              width: 0.9.sw >= 0.9.sh ? 0.9.sh : 0.9.sw,
              // height: 0.7.sw >= 0.7.sh ? 0.7.sh:0.7.sw,
              padding: const EdgeInsets.all(6),
              child: RepositoryProvider(
                create: (context) => LoginRepository(),
                child: BlocProvider(
                  create: (context) => LoginBloc(context.read()),
                  child: BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      var bloc = context.read<LoginBloc>();
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Image.asset(
                            ImageConstants.logo,
                            width: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                            // height: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                          ),
                          const SizedBox(height: 10),
                          state is LogInErrorState
                              ? Text(
                                  state.errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 10),
                          TextField(
                            controller: usernameController,
                            onChanged: (change) {
                              BlocProvider.of<LoginBloc>(context).add(
                                  LoginTextChangeEvent(usernameController.text,
                                      passwordController.text));
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(74, 158, 158, 158),
                              hintText: "Email Id",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: passwordController,
                            onChanged: (change) {
                              bloc.add(LoginTextChangeEvent(
                                  usernameController.text,
                                  passwordController.text));
                            },
                            obscureText:
                                context.read<LoginBloc>().isShowingPassword,
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () =>
                                    {bloc.add(LoginShowPasswordButtonEvent())},
                                child: Container(
                                  color: Colors.transparent,
                                  child: Icon(
                                    state is LoginShowPasswordState
                                        ? state.visible
                                            ? Icons.visibility
                                            : Icons.visibility_off
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(74, 158, 158, 158),
                              hintText: "Password",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                context.pushNamed(AppPaths.forgotpass);
                              },
                              child: Text(
                                "Forgot Password?",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.metrophobic(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          BlocConsumer<LoginBloc, LoginState>(
                            listener: (context, state) {
                              if (state is LoginedSuccesfullState) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                context.go(AppPaths.tabbar);
                              }
                            },
                            builder: (context, state) {
                              return SizedBox(
                                width: 1.sw,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: CustomMaterialButton(
                                    onPressed: () {
                                      if (state is! LogInLoadingState) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        bloc.add(LoginSubmitEvent(
                                            usernameController.text,
                                            passwordController.text));
                                      }
                                    },
                                    buttonText: state is LogInLoadingState
                                        ? "Loading..."
                                        : 'Login',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10)
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
