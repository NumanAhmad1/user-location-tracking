import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location_tracker_app/core/const/string_const.dart';
import 'package:location_tracker_app/core/shared_pref/shared_pref.dart';
import 'package:location_tracker_app/features/auth/controller/auth_cubit.dart';
import 'package:location_tracker_app/features/auth/controller/auth_state.dart';
import 'package:location_tracker_app/features/home/view/bottom_bar.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
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
                "Please Sign Up",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                onChanged:
                    (value) => context.read<AuthCubit>().updateName(value),
              ),
              10.verticalSpace,
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onChanged:
                    (value) => context.read<AuthCubit>().updateEmail(value),
              ),
              10.verticalSpace,
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                onChanged:
                    (value) => context.read<AuthCubit>().updateAge(value),
              ),
              10.verticalSpace,
              TextField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                onChanged:
                    (value) =>
                        context.read<AuthCubit>().updatePhoneNumber(value),
              ),
              10.verticalSpace,
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged:
                    (value) => context.read<AuthCubit>().updatePassword(value),
              ),
              10.verticalSpace,

              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () async {
                      if (state.fullName.isEmpty ||
                          state.email.isEmpty ||
                          state.age.isEmpty ||
                          state.phoneNumber.isEmpty ||
                          state.password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all the fields"),
                          ),
                        );
                        return;
                      }
                      final bool success =
                          await context.read<AuthCubit>().signUp();

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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sign Up Successful")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sign Up Failed")),
                        );
                      }
                    },
                    child:
                        state.isloading
                            ? const CircularProgressIndicator()
                            : const Text("Sign Up"),
                  );
                },
              ),
              Text("Already have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
