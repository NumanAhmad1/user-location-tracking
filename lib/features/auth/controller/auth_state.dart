import 'package:location_tracker_app/features/auth/model/user_model.dart';

class AuthState {
  final bool isloading;
  final bool isSignInLoading;
  final String fullName;
  final String email;
  final String password;
  final String age;
  final String phoneNumber;

  final UserModel? user;
  final bool isGettingUser;

  AuthState({
    this.isloading = false,
    this.isSignInLoading = false,
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.age = '',
    this.phoneNumber = '',
    this.user,
    this.isGettingUser = false,
  });

  AuthState copyWith({
    bool? isloading,
    bool? isSignInLoading,
    String? fullName,
    String? email,
    String? password,
    String? age,
    String? phoneNumber,

    UserModel? user,
    bool? isGettingUser,
  }) {
    return AuthState(
      isloading: isloading ?? this.isloading,
      isSignInLoading: isSignInLoading ?? this.isSignInLoading,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      user: user ?? this.user,
      isGettingUser: isGettingUser ?? this.isGettingUser,
    );
  }
}
