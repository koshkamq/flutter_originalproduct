import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規投稿'),
        //iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
                    Post newPost = Post(
                      content: contentController.text,
                      postAccountId: Authentication.myAccount!.id,
                    );
                    var result = await PostFirestore.addPost(newPost);
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
    );
  }
}
