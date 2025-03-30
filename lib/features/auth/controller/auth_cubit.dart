import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/features/auth/controller/auth_state.dart';
import 'package:location_tracker_app/features/auth/model/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void updateName(String name) {
    emit(state.copyWith(fullName: name));
  }

  void updateEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void updatePassword(String password) {
    emit(state.copyWith(password: password));
  }

  void updateAge(String age) {
    emit(state.copyWith(age: age));
  }

  void updatePhoneNumber(String phoneNumber) {
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  void clearFields() {
    emit(state.copyWith(fullName: '', email: '', password: '', age: ''));
  }

  Future<bool> signUp() async {
    emit(state.copyWith(isloading: true));

    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: state.email,
            password: state.password,
          );

      final User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': state.fullName,
          'email': state.email,
          'phoneNumber': state.phoneNumber,
          'age': state.age,
        });

        emit(state.copyWith(isloading: false));
        return true;
      } else {
        emit(state.copyWith(isloading: false));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(isloading: false));
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    emit(state.copyWith(isSignInLoading: true));

    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user != null) {
        emit(state.copyWith(isSignInLoading: false));
        return true;
      }
    } catch (e) {
      emit(state.copyWith(isSignInLoading: false));
    }
    return false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(
      state.copyWith(
        fullName: '',
        email: '',
        password: '',
        age: '',
        phoneNumber: '',
      ),
    );
  }

  Future<void> getUser() async {
    final User? user = _auth.currentUser;
    emit(state.copyWith(isGettingUser: true));

    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      final Map<String, dynamic>? data = userDoc.data();

      if (data != null) {
        final user = UserModel.fromJson(data);
        emit(state.copyWith(user: user));
      }
    }
    emit(state.copyWith(isGettingUser: false));
  }
}
