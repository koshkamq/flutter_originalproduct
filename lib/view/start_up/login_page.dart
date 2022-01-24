import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_originalproduct/utils/authentication.dart';
import 'package:flutter_originalproduct/utils/firestore/users.dart';
import 'package:flutter_originalproduct/view/screen.dart';
import 'package:flutter_originalproduct/view/start_up/create_account_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 50),
                Text('Firework09(SK2A 水越)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                SizedBox(height: 50),
                Padding(
                  //上と下にpadding
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Container(
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
                ),
                Container(
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
                SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: 'アカウントを作成していない方は'),
                      TextSpan(text: 'こちら',
                        style: TextStyle(color: Colors.blue),
                        //タップしたときの処理が書ける
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                        }
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 70),
                ElevatedButton(
                    onPressed: () async {
                      if(emailController.text.isNotEmpty && passController.text.isNotEmpty){
                        showProgressDialog(context);
                        //await Future<dynamic>.delayed(Duration(seconds: 2));
                        var result = await Authentication.emailSignIn(email: emailController.text, pass: passController.text);
                        if(result is UserCredential){
                          var _result = await UserFirestore.getUser(result.user!.uid);
                          if(_result == true){
                            //ログインページを破棄して遷移
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Screen()));
                          }
                        }else{
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ログイン失敗...')));
                        }
                      }else{
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
                    child: Text('ログイン')
                ),
              ],
            ),
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
