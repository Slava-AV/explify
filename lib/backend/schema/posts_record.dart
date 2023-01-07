import 'package:cloud_firestore/cloud_firestore.dart';

class Element {
  String text;
  int id;

  Element({this.text, this.id});

  Element.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['id'] = this.id;
    return data;
  }
}

class PostsRecord {

  PostsRecord({
    this.imageUrl,
    this.createdTime,
    this.user,
    this.username,
    this.title,
    this.tag,
    this.text,
    this.simplified,
    this.bullets,
    this.tests,
  });
  String imageUrl;
  String createdTime;
  String user;
  String username;
  String title;
  String tag;
  List<dynamic> text;
  List<dynamic> simplified;
  List<dynamic> bullets;
  List<dynamic> tests;

  PostsRecord.fromJson(Map<String, dynamic> json) {
    imageUrl = json['image_url'];
    createdTime = json['created_time'];
    user = json['user'];
    username = json['username'];
    title = json['title'];
    tag = json['tag'];
    text = List.castFrom<dynamic, dynamic>(json['text']);
    simplified = List.castFrom<dynamic, dynamic>(json['simplified']);
    bullets = List.castFrom<dynamic, dynamic>(json['bullets']);
    tests = List.castFrom<dynamic, dynamic>(json['tests']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image_url'] = imageUrl;
    _data['created_time'] = createdTime;
    _data['user'] = user;
    _data['username'] = username;
    _data['title'] = title;
    _data['tag'] = tag;
    _data['text'] = text;
    _data['simplified'] = simplified;
    _data['bullets'] = bullets;
    _data['tests'] = tests;
    return _data;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('pages');
}