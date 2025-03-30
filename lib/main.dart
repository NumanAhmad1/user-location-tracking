import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location_tracker_app/core/const/string_const.dart';
import 'package:location_tracker_app/core/shared_pref/shared_pref.dart';
import 'package:location_tracker_app/features/auth/controller/auth_cubit.dart';
import 'package:location_tracker_app/features/auth/view/login_screen.dart';
import 'package:location_tracker_app/features/chat/controller/chat_cubit.dart';
import 'package:location_tracker_app/features/home/controller/home_cubit.dart';
import 'package:location_tracker_app/features/home/view/bottom_bar.dart';
import 'package:location_tracker_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreferencesHelper().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 667),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => HomeCubit()),
            BlocProvider(create: (context) => AuthCubit()),

            BlocProvider(create: (context) => ChatCubit()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Location Tracking app',
            home:
                SharedPreferencesHelper().getData(StringConst.isLogin) == "true"
                    ? const BottomBarScreen()
                    : LoginScreen(),
          ),
        );
      },
    );
  }
}
