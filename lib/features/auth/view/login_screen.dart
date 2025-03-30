import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location_tracker_app/core/const/string_const.dart';
import 'package:location_tracker_app/core/shared_pref/shared_pref.dart';
import 'package:location_tracker_app/features/auth/controller/auth_cubit.dart';
import 'package:location_tracker_app/features/auth/controller/auth_state.dart';
import 'package:location_tracker_app/features/auth/view/signup_screen.dart';
import 'package:location_tracker_app/features/home/view/bottom_bar.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 5.h,
            children: [
              100.verticalSpace,
              Text(
                "Please login",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              TextField(
                onTapOutside: (e) {
                  FocusScope.of(context).unfocus();
                },
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
              ),
              SizedBox(height: 20.h),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () async {
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in both fields.'),
                          ),
                        );
                        return;
                      }

                      final bool success = await context
                          .read<AuthCubit>()
                          .signIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                      if (success) {
                        await SharedPreferencesHelper().saveData(
                          StringConst.isLogin,
                          "true",
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BottomBarScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid email or password.')),
                        );
                      }
                    },
                    child:
                        state.isSignInLoading
                            ? const CircularProgressIndicator()
                            : const Text("Login"),
                  );
                },
              ),
              Text("Don't have an account?"),
              TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
