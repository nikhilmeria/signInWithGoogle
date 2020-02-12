import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GoogleLogin(),
        title: 'Sign In with Google',
      ),
    );

class GoogleLogin extends StatefulWidget {
  @override
  _GoogleLoginState createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignInAccount googleAccount;
  GoogleSignIn googleSignIn = GoogleSignIn();
  bool loginStatus = false;

  Future<dynamic> handleGoogleSignIn() async {
    try {
      bool usrExits = await googleSignIn.isSignedIn();
      if (usrExits) {
        print('user already exists, auto signed in when app restarted ');
        FirebaseUser userUid = await auth.currentUser();
        print(userUid.uid);
        setState(() => loginStatus = true);
        return;
      } else {
        googleAccount = await googleSignIn.signIn();
        if (googleAccount == null) {
          print('login process terminated');
          return;
        } else {
          try {
            AuthResult result = await auth
                .signInWithCredential(GoogleAuthProvider.getCredential(
              idToken: (await googleAccount.authentication).idToken,
              accessToken: (await googleAccount.authentication).accessToken,
            ));
            print(result.additionalUserInfo.profile);
            print(result.user.uid);
            setState(() => loginStatus = true);
          } catch (err) {
            print(err);
          }
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<dynamic> handleSignOut() async {
    await googleSignIn.signOut();
    print('Signout done');
    setState(() => loginStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sign In with Google"),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: loginStatus
              ? MaterialButton(
                  color: Colors.lightBlue[200],
                  child: Text('Sign Out'),
                  onPressed: handleSignOut,
                )
              : MaterialButton(
                  color: Colors.orange[300],
                  child: Text('SignIn with Google'),
                  onPressed: handleGoogleSignIn,
                ),
        ),
      ),
    );
  }
}
