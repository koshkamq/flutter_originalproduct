import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_originalproduct/model/diet.dart';
import 'package:flutter_originalproduct/model/post.dart';

class PostFirestore {
  //ユーザー全員の投稿を保存するコレクション
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference posts =
      _firestoreInstance.collection('posts');

  static Future<dynamic> addPost(Post newPost) async {
    try {
      //自分の投稿だけを保存
      final CollectionReference _userPosts = _firestoreInstance
          .collection('users')
          .doc(newPost.postAccountId)
          .collection('my_posts');
      var result = await posts.add({
        'content': newPost.content,
        'post_account_id': newPost.postAccountId,
        'created_time': Timestamp.now()
      });
      _userPosts
          .doc(result.id)
          .set({'post_id': result.id, 'created_time': Timestamp.now()});
      print('投稿完了');
      return true;
    } on FirebaseException catch (e) {
      print('投稿失敗: $e');
      return false;
    }
  }

  //自分の投稿mypostのデータを取ってきてpostと比較
  static Future<List<Post>?> getPostFromIds(List<String> ids) async {
    List<Post> postList = [];
    try {
      //送られてきたデータだけ処理を回す
      await Future.forEach(ids, (String id) async {
        var doc = await posts.doc(id).get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Post post = Post(
            id: doc.id,
            content: data['content'],
            postAccountId: data['post_account_id'],
            createdTime: data['created_time']);
        postList.add(post);
      });
      print('自分の投稿を取得');
      return postList;
    } on FirebaseException catch (e) {
      print('自分の投稿取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> deletePosts(String accountId) async {
    final CollectionReference _userPosts = _firestoreInstance
        .collection('users')
        .doc(accountId)
        .collection('my_posts');
    var snapshot = await _userPosts.get();
    snapshot.docs.forEach((doc) async {
      await posts.doc(doc.id).delete();
      _userPosts.doc(doc.id).delete();
    });
  }

  // static Future<dynamic> addDietRecord(WeightData newrecord) async {
  //   try {
  //     final CollectionReference _userrecord = _firestoreInstance
  //         .collection('users')
  //         .doc(newrecord.postAccountId)
  //         .collection('my_record');
  //     _userrecord.add({'weight': newrecord.weight, 'date': newrecord.date});
  //     return true;
  //   } on FirebaseException catch (e) {
  //     return null;
  //   }
  // }
}
