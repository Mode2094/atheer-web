import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/utils/logger.dart';
import 'package:perfume/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get usersRef =>
      firestore.collection(AppConstants.usersCollection);
  CollectionReference<Map<String, dynamic>> get storesRef =>
      firestore.collection(AppConstants.storesCollection);
  CollectionReference<Map<String, dynamic>> get perfumesRef =>
      firestore.collection(AppConstants.perfumesCollection);
  CollectionReference<Map<String, dynamic>> get recommendationsRef =>
      firestore.collection(AppConstants.recommendationsCollection);
  CollectionReference<Map<String, dynamic>> get appConfigCollection =>
      firestore.collection(AppConstants.firebaseConfigCollection);

  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      AppLogger.i('Firebase initialized');
      return true;
    } catch (e, st) {
      AppLogger.e('Firebase initialization failed', e, st);
      return false;
    }
  }

  Future<User?> getCurrentUser() async => auth.currentUser;

  Future<void> signOut() async {
    await auth.signOut();
  }
}
