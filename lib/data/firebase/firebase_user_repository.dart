import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flix_id/data/repositories/user_repository.dart';
import 'package:flix_id/domain/entities/result.dart';
import 'package:flix_id/domain/entities/user.dart';
import 'package:path/path.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firebaseFirestore;

  FirebaseUserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<User>> createUser(
      {required String uid,
      required String email,
      required String name,
      String? photoUrl,
      int balance = 0}) async {
    CollectionReference<Map<String, dynamic>> users =
        _firebaseFirestore.collection('users');
    await users.doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'balance': balance,
    });

    DocumentSnapshot<Map<String, dynamic>> result = await users.doc(uid).get();

    if (result.exists) {
      return Result.succes(User.fromJson(result.data()!));
    } else {
      return const Result.failed('Failed to create user');
    }
  }

  @override
  Future<Result<User>> getUser({required String uid}) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        _firebaseFirestore.doc('users/$uid');
    DocumentSnapshot<Map<String, dynamic>> result =
        await documentReference.get();
    if (result.exists) {
      return Result.succes(User.fromJson(result.data()!));
    } else {
      return const Result.failed('User Not Found');
    }
  }

  @override
  Future<Result<int>> getUserBalance({required String uid}) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        _firebaseFirestore.doc('users/$uid');

    DocumentSnapshot<Map<String, dynamic>> result =
        await documentReference.get();

    if (result.exists) {
      return Result.succes(result.data()!['balance']);
    } else {
      return const Result.failed('User not found');
    }
  }

  @override
  Future<Result<User>> updateProfilePicture(
      {required User user, required File imageFile}) async {
    String fileName = basename(imageFile.path);
    Reference reference = FirebaseStorage.instance.ref().child(fileName);

    try {
      await reference.putFile(imageFile);
      String downloadUrl = await reference.getDownloadURL();

      var updateResult =
          await updateUser(user: user.copyWith(photoUrl: downloadUrl));

      if (updateResult.isSucces) {
        return Result.succes(updateResult.resultValue!);
      } else {
        return Result.failed(updateResult.errorMessage!);
      }
    } catch (e) {
      return const Result.failed('Failed update foto profile');
    }
  }

  @override
  Future<Result<User>> updateUser({required User user}) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/${user.uid}');
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();
      if (result.exists) {
        User updateUser = User.fromJson(result.data()!);
        if (updateUser == user) {
          return Result.succes(updateUser);
        } else {
          return const Result.failed('Failed to update user data');
        }
      } else {
        return const Result.failed('Failed to update user data');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update user data');
    }
  }

  @override
  Future<Result<User>> updateUserBalance(
      {required String uid, required int balance}) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        _firebaseFirestore.doc('users/$uid');

    DocumentSnapshot<Map<String, dynamic>> result =
        await documentReference.get();

    if (result.exists) {
      await documentReference.update({'balance': balance});

      DocumentSnapshot<Map<String, dynamic>> updateResult =
          await documentReference.get();

      if (updateResult.exists) {
        User updateUser = User.fromJson(result.data()!);
        if (updateUser.balance == balance) {
          return Result.succes(updateUser);
        } else {
          return const Result.failed('Failed to update user balance');
        }
      } else {
        return const Result.failed('Failed to retrive updated user balance');
      }
    } else {
      return const Result.failed('User not found');
    }
  }
}
