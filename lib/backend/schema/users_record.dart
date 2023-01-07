import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
// import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'schema_util.dart';
import 'serializers.dart';

part 'users_record.g.dart';

abstract class UsersRecord implements Built<UsersRecord, UsersRecordBuilder> {
  static Serializer<UsersRecord> get serializer => _$usersRecordSerializer;

  @nullable
  String get email;

  @nullable
  String get username;

  @nullable
  @BuiltValueField(wireName: 'display_name')
  String get displayName;

  @nullable
  @BuiltValueField(wireName: 'profile_pic_url')
  String get profilePicUrl;

  @nullable
  String get bio;

  @nullable
  String get website;

  @nullable
  @BuiltValueField(wireName: 'created_time')
  Timestamp get createdTime;

  @nullable
  @BuiltValueField(wireName: 'photo_url')
  String get photoUrl;

  @nullable
  String get uid;

  @nullable
  int get pageLimit;

  @nullable
  @BuiltValueField(wireName: kDocumentReferenceField)
  DocumentReference get reference;

  static void _initializeBuilder(UsersRecordBuilder builder) => builder
    ..email = ''
    ..username = ''
    ..displayName = ''
    ..profilePicUrl = ''
    ..bio = ''
    ..website = ''
    ..photoUrl = ''
    ..pageLimit = 0
    ..uid = '';

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) => ref
      .snapshots()
      .map((s) => serializers.deserializeWith(serializer, serializedData(s)));

  UsersRecord._();
  factory UsersRecord([void Function(UsersRecordBuilder) updates]) =
      _$UsersRecord;
}

Map<String, dynamic> createUsersRecordData({
  String email,
  String username,
  String displayName,
  String profilePicUrl,
  String bio,
  String website,
  Timestamp createdTime,
  String photoUrl,
  String uid,
  int pageLimit,
}) =>
    serializers.serializeWith(
        UsersRecord.serializer,
        UsersRecord((u) => u
          ..email = email
          ..username = username
          ..displayName = displayName
          ..profilePicUrl = profilePicUrl
          ..bio = bio
          ..website = website
          ..createdTime = createdTime
          ..photoUrl = photoUrl
          ..pageLimit = pageLimit
          ..uid = uid));