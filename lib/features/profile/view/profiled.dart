import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/core/const/string_const.dart';
import 'package:location_tracker_app/core/shared_pref/shared_pref.dart';
import 'package:location_tracker_app/features/auth/controller/auth_cubit.dart';
import 'package:location_tracker_app/features/auth/controller/auth_state.dart';
import 'package:location_tracker_app/features/auth/view/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AuthCubit>().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return state.isGettingUser
              ? const CircularProgressIndicator()
              : SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Name: ${state.user?.fullName}',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Email: ${state.user?.email}',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Phone: ${state.user?.phoneNumber}',
                      style: TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 5),
                    Text(
                      'Age: ${state.user?.age}',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 60),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        context.read<AuthCubit>().signOut();
                        await SharedPreferencesHelper().removeData(
                          StringConst.isLogin,
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              );
        },
      ),
    );
  }
}
