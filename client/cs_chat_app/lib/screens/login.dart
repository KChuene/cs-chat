import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(minWidth: 500),
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                height: 128,
                width: 128,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset("assets/images/network-smashicons.png"),
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                constraints: BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(.9),
                    spreadRadius: .8,
                    blurRadius: 1
                  )]
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Username",
                    hintStyle: TextStyle(color: Colors.grey),
                    icon: Icon(Icons.person_2_rounded),
                    border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                constraints: BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(.9),
                    spreadRadius: .8,
                    blurRadius: 1
                  )]
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey),
                    icon: Icon(Icons.lock),
                    border: InputBorder.none
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {}, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15)
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25
                  )
                )
              )
            ]
          ),
        ),
      ),
    );
  }
}