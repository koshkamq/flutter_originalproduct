import 'package:flutter/material.dart';
import 'package:flutter_originalproduct/model/account.dart';
import 'package:flutter_originalproduct/model/post.dart';
import 'package:flutter_originalproduct/utils/authentication.dart';
import 'package:flutter_originalproduct/utils/firestore/posts.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  TextEditingController contentController = TextEditingController();
  Account myAccount = Authentication.myAccount!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規投稿'),
        //iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      foregroundImage: NetworkImage(myAccount.imagePath),
                    ),
                    SizedBox(width: 5,),
                    Text(myAccount.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                    Text('@${myAccount.userId}', style: TextStyle(color: Colors.grey),),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              TextField(
                controller: contentController,
                maxLines: null,
                minLines: 10,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  //filled: true,
                  hintText: '今何してる？',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    if(contentController.text.isNotEmpty){
                      showProgressDialog(context);
                      Post newPost = Post(
                        content: contentController.text,
                        postAccountId: Authentication.myAccount!.id,
                      );
                      var result = await PostFirestore.addPost(newPost);
                      Navigator.of(context, rootNavigator: true).pop();
                      if(result == true){
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('投稿')
              )
            ],
          ),
        ),
      ),
    );
  }
}

void showProgressDialog(context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: Duration.zero,
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (BuildContext context, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}
