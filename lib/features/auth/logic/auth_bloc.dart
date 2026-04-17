import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? "Login Failed"));
      } catch (e) {
        emit(AuthFailure("An unexpected error occurred"));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        
        try {
          await _db.collection('users').doc(userCredential.user!.uid).set({
            'name': event.name,
            'email': event.email,
            'uid': userCredential.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
        
        await _auth.signOut();
        
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? "Registration Failed"));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          emit(AuthInitial());
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName ?? "Google User",
          'email': userCredential.user!.email,
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure("Google Sign-In failed: ${e.toString()}"));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        await _auth.signOut();
        await GoogleSignIn().signOut();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure("Logout failed"));
      }
    });
  }
}