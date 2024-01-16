import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flix_id/data/firebase/firebase_user_repository.dart';
import 'package:flix_id/data/repositories/transaction_repository.dart';
import 'package:flix_id/domain/entities/result.dart';
import 'package:flix_id/domain/entities/transaction.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final firestore.FirebaseFirestore _firebaseFirestore;

  FirebaseTransactionRepository(
      {firestore.FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore =
            firebaseFirestore ?? firestore.FirebaseFirestore.instance;

  @override
  Future<Result<Transaction>> createTransaction(
      {required Transaction transaction}) async {
    firestore.CollectionReference<Map<String, dynamic>> transactions =
        _firebaseFirestore.collection('transaction');

    try {
      var balanaceResult =
          await FirebaseUserRepository().getUserBalance(uid: transaction.uid);

      if (balanaceResult.isSucces) {
        int previousBalance = balanaceResult.resultValue!;

        if (previousBalance - transaction.total >= 0) {
          await transactions.doc(transaction.id).set(transaction.toJson());
          var result = await transactions.doc(transaction.id).get();

          if (result.exists) {
            await FirebaseUserRepository().updateUserBalance(
              uid: transaction.uid,
              balance: previousBalance - transaction.total,
            );
            return Result.succes(Transaction.fromJson(result.data()!));
          } else {
            return const Result.failed('Failed to create transaction data');
          }
        } else {
          return const Result.failed('Insufficient balance');
        }
      } else {
        return const Result.failed('Failed to create transaction data');
      }
    } catch (e) {
      return const Result.failed('Failed to create transaction data');
    }
  }

  @override
  Future<Result<List<Transaction>>> getUserTransaction(
      {required String uid}) async {
    firestore.CollectionReference<Map<String, dynamic>> transactions =
        _firebaseFirestore.collection('transaction');

    try {
      var result = await transactions.where('uid', isEqualTo: uid).get();

      if (result.docs.isNotEmpty) {
        return Result.succes(
            result.docs.map((e) => Transaction.fromJson(e.data())).toList());
      } else {
        return const Result.succes([]);
      }
    } catch (e) {
      return const Result.failed('Failed to get user transaction');
    }
  }
}
