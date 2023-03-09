import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/common/dialogs.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/screens/product_overview_screen.dart';

enum AuthMode { signUp, login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.titleLarge?.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  var error = "";

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() == false) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    //if (_authMode == AuthMode.login) {
      try {
        await Provider.of<AuthProvider>(context, listen: false).authenticate(_authData['email']!, _authData['password']!, signUp: _authMode == AuthMode.signUp);
      } on HttpException catch (err) {
        error = err.message;
        showErrorDialog(error, context);
      } catch (err) {
        error = err.toString();
        showErrorDialog(error, context);
      }
    // } else {
    //   try {
    //     await Provider.of<AuthProvider>(context, listen: false).authenticate(_authData['email']!, _authData['password']!);
    //   } on HttpException catch (err) {
    //     error = err.message;
    //   } catch (err) {
    //     error = err.toString();
    //   } finally {
    //     showErrorDialog(error, context);
    //   }
    // }
    setState(() {
      _isLoading = false;
    });
  }

  late AnimationController _controller;
  late Animation<Size> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _heightAnimation = Tween(begin: const Size(double.infinity, 260), end: const Size(double.infinity, 320)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn)
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        height: _authMode == AuthMode.signUp ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.signUp ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        duration: const Duration(milliseconds: 300),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value??"";
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value != null && value.isEmpty || value!.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value??"";
                  },
                ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _authMode == AuthMode.signUp ? 60 : 0,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.signUp,
                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.signUp
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).primaryTextTheme.button?.color,
                    ),

                    child:
                        Text(_authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP'),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                      '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
