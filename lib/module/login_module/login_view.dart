import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/login_module/login/login_bloc.dart';
import 'package:i_densfa/module/tabber_module/tabber_view.dart';
import 'package:i_densfa/utility/image_constants.dart';
import '../forgot_password_module/forgot_password_view.dart';
import '../ui/background.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocProvider(
        create: (context) => LoginBloc(),
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return Stack(
              children: [
                const Background(false),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0)),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Image.asset(
                          imageConstants.logo,
                          width: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                          // height: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        state is LogInErrorState
                            ? Text(
                                state.errorMessage,
                                style: const TextStyle(color: Colors.red),
                              )
                            : Container(),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: usernameController,
                          onChanged: (change) {
                            BlocProvider.of<LoginBloc>(context).add(
                                LoginTextChangeEvent(usernameController.text,
                                    passwordController.text));
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(74, 158, 158, 158),
                            hintText: "User Id",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: passwordController,
                          onChanged: (change) {
                            BlocProvider.of<LoginBloc>(context).add(
                                LoginTextChangeEvent(usernameController.text,
                                    passwordController.text));
                          },
                          obscureText:
                              context.read<LoginBloc>().isShowingPassword,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () => {
                                BlocProvider.of<LoginBloc>(context)
                                    .add(LoginShowPasswordButtonEvent())
                              },
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
                            fillColor: const Color.fromARGB(74, 158, 158, 158),
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
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          ForgotPasswordView())))
                            },
                            child: Text(
                              "I've forgotten my password",
                              textAlign: TextAlign.right,
                              style: GoogleFonts.metrophobic(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        const SizedBox(
                          height: 10,
                        ),
                        BlocConsumer<LoginBloc, LoginState>(
                          listener: (context, state) {
                            if (state is LoginedSuccesfullState) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          const TabberView())));
                            }
                          },
                          builder: (context, state) {
                            return SizedBox(
                              width: 1.sw,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: MaterialButton(
                                  onPressed: () => {
                                    BlocProvider.of<LoginBloc>(context).add(
                                        LoginSubmitEvent(
                                            usernameController.text,
                                            passwordController.text))
                                  },
                                  elevation: 2,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  splashColor: Colors.red.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 25),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                  ),
                                  child: Text(
                                    state is LogInLoadingState
                                        ? "Loading..."
                                        : 'Login',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
