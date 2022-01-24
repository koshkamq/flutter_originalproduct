import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_originalproduct/model/account.dart';
import 'package:flutter_originalproduct/utils/authentication.dart';
import 'package:flutter_originalproduct/utils/firestore/users.dart';
import 'package:flutter_originalproduct/utils/function_utils.dart';
import 'package:flutter_originalproduct/utils/widget_utils.dart';
import 'package:flutter_originalproduct/view/start_up/login_page.dart';
import 'package:image_picker/image_picker.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({Key? key}) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {

  Account myAccount = Authentication.myAccount!;

  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  File? image;

  ImageProvider getImage() {
    if(image == null){
      return NetworkImage(myAccount.imagePath);
    }else{
      return FileImage(image!);
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: myAccount.name);
    userIdController = TextEditingController(text: myAccount.userId);
    selfIntroductionController = TextEditingController(text: myAccount.selfIntroduction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('プロフィール編集'),
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
                  if(result != null) {
                    setState(() {
                      image = File(result.path);
                    });
                  }
                },
                child: CircleAvatar(
                  foregroundImage: getImage(),
                  radius: 40,
                  child: Icon(Icons.add),
                ),
              ),
              Container(
                width: 300,
                alignment: Alignment.centerLeft,
                child: Text('名前',style: TextStyle(fontSize: 13),),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: '名前',
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                width: 300,
                alignment: Alignment.centerLeft,
                child: Text('ユーザーID',style: TextStyle(fontSize: 13),),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    hintText: 'ユーザーID',
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                width: 300,
                alignment: Alignment.centerLeft,
                child: Text('自己紹介文',style: TextStyle(fontSize: 13),),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: selfIntroductionController,
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
                        && selfIntroductionController.text.isNotEmpty){
                      showProgressDialog(context);
                      await Future<dynamic>.delayed(Duration(seconds: 1));
                      String imagePath = '';
                      if(image == null){
                        imagePath = myAccount.imagePath;
                      }else{
                        var result = await FunctionUtils.uploadImage(myAccount.id, image!);
                        imagePath = result;
                      }
                      Account updateAccount = Account(
                        id: myAccount.id,
                        name: nameController.text,
                        userId: userIdController.text,
                        selfIntroduction: selfIntroductionController.text,
                        imagePath: imagePath,
                      );
                      Authentication.myAccount = updateAccount;
                      var result = await UserFirestore.updateUser(updateAccount);
                      if(result == true){
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pop(context, true);
                      }
                    }
                    },
                  child: Text('更新'),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () {
                    Authentication.signOut();
                    //元の画面に戻れる状況なら戻る
                    while(Navigator.canPop(context)){
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('ログアウト')
              ),
              Container(
                height: 120,
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red
                  ),
                    onPressed: () {
                      UserFirestore.deleteUser(myAccount.id);
                      Authentication.deleteAuth();
                      //元の画面に戻れる状況なら戻る
                      while(Navigator.canPop(context)){
                        Navigator.pop(context);
                      }
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text('アカウント削除')),
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
