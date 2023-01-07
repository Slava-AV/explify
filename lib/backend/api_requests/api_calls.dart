import 'api_manager.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explify/auth/auth_util.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

Future<dynamic> processTextCall({
  String text = '',
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'processText',

      apiDomain: 'xxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/processText',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'text': text,
      },
      returnResponse: true,
    );

Future<dynamic> getWordDefinition({
  String text = '',
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'getWordDefinition',

      apiDomain: 'api.dictionaryapi.dev',
      apiEndpoint: 'api/v2/entries/en' + '/' + text,
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnResponse: true,
    );

Future<dynamic> processImageCall({
  String imageUrl = '',
  String pageUID = '',
  String user = '',
  String userUid = '',
  String accessType = '',
  int limit = 0,
  String base64Img = '',
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'processImage',
      apiDomain: 'xxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/processImage',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'imageUrl': imageUrl,
        'pageUID': pageUID,
        'user': user,
        'userUid': userUid,
        'accessType': accessType,
        'limit': limit,
        'base64Img': base64Img,
      },
      returnResponse: true,
    );

Future<dynamic> processImagesBulkCall({
  List<String> imageUrls,
  String title = '',
  String bookId = '',
  String user = '',
  String userUid = '',
  String accessType = '',
  int limit = 0,
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'processImage',
      apiDomain: 'xxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/processImageBulk',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'imageUrls': imageUrls,
        'title': title,
        'bookId': bookId,
        'user': user,
        'userUid': userUid,
        'accessType': accessType,
        'limit': limit,
      },
      returnResponse: true,
    );

Future<dynamic> sendFeedbackCall({
  String comment = '',
  String generation = '',
  String sourceBlock = '',
  String postId = '',
  String user = '',
  String type = '',
  bool hasError = false,
  bool hasOffensive = false,
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'sendFeedback',
      apiDomain: 'xxxxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/sendFeedback',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'comment': comment,
        'generation': generation,
        'sourceBlock': sourceBlock,
        'postId': postId,
        'user': currentUserReference.toString(),
        'flags': hasError ? 'hasError' : ''
      },
      returnResponse: false,
    );

Future<dynamic> addCredits({
  String userUid = '',
  String email = '',
  String promoCode = '',
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'sendFeedback',
      apiDomain: 'xxxxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/addCredits',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'userUid': userUid,
        'email': email,
        'reason': "New user",
        'promoCode': promoCode,
      },
      returnResponse: true,
    );

Future<dynamic> saveOptions({
  String userUid = '',
  String email = '',
  List<dynamic> voices,
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'saveOptions',
      apiDomain: 'xxxxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/saveOptions',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'userUid': userUid,
        'email': email,
        'voices': voices,
      },
      returnResponse: true,
    );

Future<dynamic> completePostCreation({
  String postId = '',
  String title = '',
  String page = '',
  String user = '',
  String bookTitle = '',
  bool isNewBook = false,
  String bookId = '',
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'completePostCreation',
      apiDomain: 'xxxxxxxxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/completePostCreation',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'postId': postId,
        'title': title,
        'pageNo': page,
        'bookTitle': bookTitle,
        'isNewBook': isNewBook,
        'bookId': bookId,
        'user': currentUserReference.toString(),
        'userId': currentUserUid,
      },
      returnResponse: false,
    );
Future<dynamic> deletePage({
  String postId = '',
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'deletePage',
      apiDomain: 'xxxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/deletePage',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'postId': postId,
        'user': currentUserReference.toString(),
      },
      returnResponse: false,
    );

Future<dynamic> getDataForMemo({
  String text = '',
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'getDataForMemo',
      // apiDomain: 'or6ess8v6l.execute-api.us-east-1.amazonaws.com',
      // apiEndpoint: 'dev1/processImage',
      apiDomain: 'xxxxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/getDataForMemo',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        "userId": currentUserUid,
        "text": text,
      },
      returnResponse: true,
    );

Future<dynamic> createFavourite({
  String postId = '',
  String bookTitle = '',
  String pageTitle = '',
  String pageId = '',
  String bookId = '',
  String text = '',
  String sourceType = '',
  String imgUrl = '',
  int capPos = 0,
  String capText = '',
  int color = 0,
  List<dynamic> excludedVoices,
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'createFavourite',
      apiDomain: 'xxxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/createFavourite',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        "uid": uuid.v4(),
        "userId": currentUserUid,
        "userEmail": currentUserEmail,
        "bookTitle": bookTitle,
        "pageTitle": pageTitle,
        "pageId": pageId,
        "bookId": bookId,
        "text": text,
        "sourceType": sourceType,
        "imgUrl": imgUrl,
        "capPos": capPos,
        "color": color,
        "capText": capText,
        "excludedVoices": excludedVoices,
      },
      returnResponse: false,
    );

Future<dynamic> deleteFavourite({
  String uid = '',
}) =>
    ApiManager.instance.makeApiCall(
      callName: 'deleteFavourite',
      apiDomain: 'xxxxxxxxxx.execute-api.us-east-1.amazonaws.com',
      apiEndpoint: 'dev1/deleteFavourite',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'uid': uid,
        'user': currentUserReference.toString(),
      },
      returnResponse: false,
    );
