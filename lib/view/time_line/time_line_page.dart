import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_originalproduct/model/account.dart';
import 'package:flutter_originalproduct/model/post.dart';
import 'package:flutter_originalproduct/utils/authentication.dart';
import 'package:flutter_originalproduct/utils/firestore/posts.dart';
import 'package:flutter_originalproduct/utils/firestore/users.dart';
import 'package:flutter_originalproduct/view/time_line/post_page.dart';
import 'package:intl/intl.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {

  Account myAccount = Authentication.myAccount!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        //title: Text('タイムライン'),
        //title: Icon(Icons.flash_on_outlined,color: Colors.amber,),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 15,
              foregroundImage: NetworkImage(myAccount.imagePath),
            ),
            Expanded(child: Icon(Icons.flash_on_outlined,color: Colors.amber,),),
            SizedBox(width: 20,)
            // Container(
            //   child: Icon(Icons.flash_on_outlined,color: Colors.amber,),
            // ),
            // Icon(Icons.flash_on_outlined,color: Colors.amber,),
          ],
        ),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: PostFirestore.posts.orderBy('created_time', descending: true).limit(20).snapshots(),
        //追加されるたびに動いてくれるようになる
        builder: (context, postsnapshot) {
          if(postsnapshot.hasData){
            List<String> postAccountIds = [];
            postsnapshot.data!.docs.forEach((doc){
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if(!postAccountIds.contains(data['post_account_id'])){
                postAccountIds.add(data['post_account_id']);
              }
            });
            return FutureBuilder<Map<String, Account>?>(
              future: UserFirestore.getPostUserMap(postAccountIds),
              builder: (context, userSnapshot) {
                //取得が完了していたらif分に入る
                if(userSnapshot.hasData && userSnapshot.connectionState == ConnectionState.done){
                  return ListView.builder(
                    itemCount: postsnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = postsnapshot.data!.docs[index].data() as Map<String, dynamic>;
                      Post post = Post(
                        id: postsnapshot.data!.docs[index].id,
                        content: data['content'],
                        postAccountId: data['post_account_id'],
                        createdTime: data['created_time']
                      );
                      Account postAccount = userSnapshot.data![post.postAccountId]!;
                      return Container(
                        decoration: BoxDecoration(
                          border: index == 0 ? Border(
                            top: BorderSide(color: Colors.grey, width: 0),
                            bottom: BorderSide(color: Colors.grey, width: 0),
                          ) : Border(bottom: BorderSide(color: Colors.grey, width: 0),)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              foregroundImage: NetworkImage(postAccount.imagePath),
                            ),
                            SizedBox(width: 8,),
                            Expanded(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(postAccount.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            Text('@${postAccount.userId}', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                        Text(DateFormat('yyyy/M/d H:mm').format(post.createdTime!.toDate())),
                                      ],
                                    ),
                                    Text(post.content, style: TextStyle(fontSize: 15),),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }else{
                  return Container();
                }
              }
            );
          }else{
            return Container();
          }
        }
      ),
    );
  }
}
