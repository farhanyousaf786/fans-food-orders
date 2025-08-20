import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  UserModel? _userModel;
  List<ShopModel> _userShops = [];
  bool _isLoading = false;

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _userModel = null;
      _userShops = [];
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  User? get user => _user;
  String? get userId => _user?.uid;
  UserModel? get userModel => _userModel;
  List<ShopModel> get userShops => _userShops;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isShopOwner => _userShops.isNotEmpty;

  Future<void> loadUserData() async {
    if (_user != null) {
      await _loadUserData(_user!.uid);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      print('🔍 Starting to load user data for UID: $uid');
      _isLoading = true;
      notifyListeners();
      
      // Get all shops where the user is an admin
      print('🔎 Querying shops collection for admin UID: $uid');
      final shopsSnapshot = await _firestore
          .collection('shops')
          .where('admins', arrayContains: uid)
          .get();

      print('📊 Found ${shopsSnapshot.docs.length} shops for this user');
      if (shopsSnapshot.docs.isNotEmpty) {
        print('🏪 Shop IDs found:');
        for (var doc in shopsSnapshot.docs) {
          print('   - ${doc.id}: ${doc.data()['name'] ?? 'Unnamed Shop'}');
        }
      }

      _userShops = shopsSnapshot.docs
          .map((doc) => ShopModel.fromFirestore(doc))
          .toList();

      print('🔄 Initializing FCM for ${_userShops.length} shops...');
      // Initialize FCM for each shop
      for (final shop in _userShops) {
        try {
          print('   ⚙️ Initializing FCM for shop: ${shop.id} (${shop.name})');
          await FirebaseService.initializeMessaging(
            stadiumId: shop.stadiumId,
            shopId: shop.id,
          );
          print('   ✅ Successfully initialized FCM for shop: ${shop.id}');
        } catch (e) {
          print('   ❌ Error initializing FCM for shop ${shop.id}: $e');
          // Continue with other shops even if one fails
        }
      }

      print('🏁 Finished loading shop data');
      notifyListeners();
    } catch (e) {
      print('🔥 CRITICAL ERROR loading shops: $e');
      print('Stack trace: ${e is Error ? (e as Error).stackTrace : 'No stack trace'}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadUserShops(String uid) async {
    try {
      _isLoading = true;
      _userShops = [];
      notifyListeners();
      
      final stadiumsSnapshot = await _firestore.collection('stadiums').get();
      
      for (var stadiumDoc in stadiumsSnapshot.docs) {
        final stadiumId = stadiumDoc.id;
        
        final shopQuery = await _firestore
            .collection('stadiums')
            .doc(stadiumId)
            .collection('shops')
            .where('admins', arrayContains: uid)
            .get();
            
        for (var shopDoc in shopQuery.docs) {
          final shop = ShopModel.fromFirestore(shopDoc);
          _userShops.add(shop);
          
          await FirebaseService.initializeMessaging(
            stadiumId: stadiumId,
            shopId: shop.id,
          );
          
          print('✅ Initialized FCM for shop: ${shop.id} under stadium: $stadiumId');
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading user shops: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _loadUserData(userCredential.user!.uid);
      }
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'Email is already registered.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak.';
        default:
          return 'Authentication failed. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
