import 'package:flutter/material.dart';
class reg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        child: Center(
            child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      flex: 2,
                      child: TextFormField(
                        initialValue: "name",
                      )
                  ),
                  Flexible(
                      flex: 2,
                      child:TextFormField(
                        initialValue: "confirm password",
                      )
                  ),
                  Flexible(
                    flex: 2,
                    child: ElevatedButton(
                        onPressed: () {

                        },
                        child: Text("register")
                    ),
                  ),

                ]
            )

        ),
      ),
    );
  }

}