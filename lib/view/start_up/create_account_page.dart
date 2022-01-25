import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_originalproduct/model/account.dart';
import 'package:flutter_originalproduct/utils/authentication.dart';
import 'package:flutter_originalproduct/utils/firestore/users.dart';
import 'package:flutter_originalproduct/utils/function_utils.dart';
import 'package:flutter_originalproduct/utils/widget_utils.dart';
import 'package:image_picker/image_picker.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('新規登録'),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 30),
              //押せないウィジェットを押せるようにしてくれる
              GestureDetector(
                onTap: () async {
                  var result = await FunctionUtils.getImageFromCallery();
                  if(result != null){
                    setState(() {
                      image = File(result.path);
                    });
                  }
                },
                child: CircleAvatar(
                  foregroundImage: image == null ? null : FileImage(image!),
                  radius: 40,
                  child: Icon(Icons.add),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: 300,
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: '名前',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: userIdController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: 'ユーザーID',
                    ),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if(!value!.contains('@')){
                      return 'アットマーク「＠」がありません。';
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'メールアドレス',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  width: 300,
                  child: TextFormField(
                    controller: passController,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if(value!.length < 6){
                        return '6文字以上！';
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'パスワード',
                    ),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: selfIntroductionController,
                  maxLines: null,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: '自己紹介',
                  ),
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () async {
                    if(nameController.text.isNotEmpty
                        && userIdController.text.isNotEmpty
                        && selfIntroductionController.text.isNotEmpty
                        && emailController.text.isNotEmpty
                        && passController.text.isNotEmpty
                        && image != null){

                      showProgressDialog(context);
                      await Future<dynamic>.delayed(Duration(seconds: 1));

                      var result = await Authentication.signUp(email: emailController.text, pass: passController.text);

                      if(result is UserCredential){
                        String imagePath = await FunctionUtils.uploadImage(result.user!.uid, image!);
                        Account newAccount = Account(
                          id: result.user!.uid,
                          name: nameController.text,
                          userId: userIdController.text,
                          selfIntroduction: selfIntroductionController.text,
                          imagePath: imagePath,
                        );
                        var _result = await UserFirestore.setUser(newAccount);
                        if(_result == true){
                          //元の画面に戻る
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('登録完了！ログインしてみてください！')));
                        }
                      }else if(result == '[firebase_auth/email-already-in-use] The email address is already in use by another account.'){
                        Navigator.of(context, rootNavigator: true).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('すでに同じメールアドレスが登録されています！')));
                      }else{
                        Navigator.of(context, rootNavigator: true).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('アカウント作成失敗...')));
                      }
                    }else {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              content: Text('入力していない箇所があります！'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("OK"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            );
                          }
                      );
                    }
                  },
                  child: Text('アカウントを作成')
              ),
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
