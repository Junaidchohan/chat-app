import 'dart:io';

import 'package:chat_app/widget/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/services/cloudinary_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {

final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthentecating = false;


  void _submit() async{
  final isValid = _formKey.currentState!.validate();

if(!isValid || !_isLogin && _selectedImage == null){
  // showing error message....if needed but we are save time in app
  return;
}

// combine in one check
// if(!_isLogin && _selectedImage == null){
//   return;
// }

  _formKey.currentState!.save();
  try{
  if(_isLogin)  {
    setState(() {
      _isAuthentecating = true;
    });
    final userCredentials = await _firebase.signInWithEmailAndPassword(
      email: _enteredEmail, password: _enteredPassword);
      
  }else{
    
           final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);


//**Firebase**//
      //   final storageRef = FirebaseStorage.instance.ref().child("user_images").child('${userCredentials.user}.jpg');
      //   await storageRef.putFile(_selectedImage!);
      //  final imageUrl = await storageRef.getDownloadURL();
      //   print(imageUrl);


    //**cloudinary**//






final cloudinary = CloudinaryService();
final imageUrl = await cloudinary.uploadImage(_selectedImage!);


if (imageUrl != null) {
  print("Image uploaded to Cloudinary: $imageUrl");

  //  Store user info in Firestore
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userCredentials.user!.uid) // use user's UID as document ID
      .set({
        'email': _enteredEmail,
        'image_url': imageUrl,
        'uid': userCredentials.user!.uid,
        'created_at': Timestamp.now(),
      });
}




    } 
  }on FirebaseAuthException catch (error){
      if(error.code == "email-already-in-use" ){
        // .....
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ??  'Authentication failed.')
      ),);
      setState(() {
      _isAuthentecating = false;
    });
    }
}

  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                       
                        mainAxisSize: MainAxisSize.min,
                        children: [ 
                          if(!_isLogin) UserImagePicker(onPickImage: (File pickedImage) { 
                            _selectedImage = pickedImage;  
                           },),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if(value == null || value.trim().isEmpty || !value.contains("@"))
                              {
                                return "Please enterd a valid email address.";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                               if(value == null || value.trim().length < 6)
                              {
                                return "Password must be at least 6 characters long.";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                           if(_isAuthentecating)
                           CircularProgressIndicator(),
                          if(!_isAuthentecating)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                           ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                           if(!_isAuthentecating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}