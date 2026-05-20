import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔥 LOGIN WITH ROLE FETCH
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        );
      }

      final uid = result.user!.uid;

      // 🔥 Fetch user document
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw FirebaseAuthException(
          code: 'no-user-data',
          message: 'User data not found in Firestore',
        );
      }

      final data = doc.data();

      if (data == null || !data.containsKey('role')) {
        throw FirebaseAuthException(
          code: 'missing-role',
          message: 'User role not assigned',
        );
      }

      return {
        'user': result.user,
        'role': data['role'], // 🔥 VERY IMPORTANT
      };

    } on FirebaseAuthException catch (e) {
      print("Login error: ${e.code}");
      rethrow;
    } catch (e) {
      print("Unknown login error: $e");
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Login failed',
      );
    }
  }

  /// 🔥 REGISTER WITH ROLE SAVE
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String role,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-created',
          message: 'User creation failed',
        );
      }

      final uid = result.user!.uid;

      // 🔥 Save user in Firestore
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': role, // Bidder / Seller
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'user': result.user,
        'role': role,
      };

    } on FirebaseAuthException catch (e) {
      print("Register error: ${e.code}");
      rethrow;
    } catch (e) {
      print("Unknown register error: $e");
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Registration failed',
      );
    }
  }

  /// 🔥 GET CURRENT USER ROLE (Auto login support)
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc =
        await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return doc.data()?['role'];
  }

  /// ✅ LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}