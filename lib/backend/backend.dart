import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../flutter_flow/flutter_flow_util.dart';

import 'schema/users_record.dart';
// import 'schema/follows_record.dart';
import 'schema/posts_record.dart';
// import 'schema/serializers.dart';

export 'package:cloud_firestore/cloud_firestore.dart';
export 'schema/users_record.dart';
export 'schema/follows_record.dart';
export 'schema/posts_record.dart';

import 'dart:developer';

Stream<QuerySnapshot> queryUsersRecord(
        {Query Function(Query) queryBuilder,
        int limit = -1,
        bool singleRecord = false}) =>
    queryCollection(UsersRecord.collection, UsersRecord.serializer,
        queryBuilder: queryBuilder, limit: limit, singleRecord: singleRecord);

Stream<QuerySnapshot> queryPostsRecord(
        {Query Function(Query) queryBuilder,
        int limit = -1,
        bool singleRecord = false}) =>
    queryCollection(PostsRecord.collection, null,
        queryBuilder: queryBuilder, limit: limit, singleRecord: singleRecord);

Stream<QuerySnapshot> queryBooksRecord(
        {Query Function(Query) queryBuilder,
        int limit = -1,
        bool singleRecord = false}) =>
    queryCollection(FirebaseFirestore.instance.collection('books'), null,
        queryBuilder: queryBuilder, limit: limit, singleRecord: singleRecord);

Stream<QuerySnapshot> queryFavouritsRecord(
        {Query Function(Query) queryBuilder,
        int limit = -1,
        bool singleRecord = false}) =>
    queryCollection(FirebaseFirestore.instance.collection('favourits'), null,
        queryBuilder: queryBuilder, limit: limit, singleRecord: singleRecord);

Stream<QuerySnapshot> queryCollection<T>(
    CollectionReference collection, Serializer<T> serializer,
    {Query Function(Query) queryBuilder,
    int limit = -1,
    bool singleRecord = false}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0 || singleRecord) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  // final resp = query.snapshots();
  log(query.parameters.toString());
  log(query.snapshots().toString());
  return query.snapshots();
}

// Creates a Firestore record representing the logged in user if it doesn't yet exist
Future maybeCreateUser(User user) async {
  final userRecord = UsersRecord.collection.doc(user.uid);
  final userExists = await userRecord.get().then((u) => u.exists);
  if (userExists) {
    return;
  }

  final userData = createUsersRecordData(
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    uid: user.uid,
    createdTime: getCurrentTimestamp,
  );

  await userRecord.set(userData);
}
