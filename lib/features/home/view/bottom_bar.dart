import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:location_tracker_app/features/home/controller/home_cubit.dart';
import 'package:location_tracker_app/features/home/view/home.dart';
import 'package:location_tracker_app/features/profile/view/profiled.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List<Widget> screens = [HomeScreen(), const ProfileScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: context.select((HomeCubit cubit) => cubit.state.currentIndex),
          children: screens, // Keeps state alive
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: context.select(
          (HomeCubit cubit) => cubit.state.currentIndex,
        ),
        onTap: (index) {
          context.read<HomeCubit>().updateIndex(index);
          log(index.toString());
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
