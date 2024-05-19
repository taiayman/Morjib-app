import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthUser;
import 'package:business_management_app/models/user.dart';

class UserService {
  final FirebaseAuthUser.FirebaseAuth _auth = FirebaseAuthUser.FirebaseAuth.instance;
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  Future<User> getCurrentUser() async {
    final firebaseUser = _auth.currentUser!;
    final userData = await _userCollection.doc(firebaseUser.uid).get();
    return User.fromMap(userData.data() as Map<String, dynamic>);
  }

  Future<void> addUser(User user) async {
    await _userCollection.doc(user.id).set(user.toMap());
  }

  Future<User> getUser(String userId) async {
    final userData = await _userCollection.doc(userId).get();
    return User.fromMap(userData.data() as Map<String, dynamic>);
  }

  Future<void> updateUser(User user) async {
    await _userCollection.doc(user.id).update(user.toMap());
  }

  Future<List<User>> getAllCEOs() async {
    QuerySnapshot querySnapshot = await _userCollection.where('role', isEqualTo: 'CEO').get();
    return querySnapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
