import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          Iphone16Plus1(),
        ]),
      ),
    );
  }
}

class Iphone16Plus1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 430,
          height: 932,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: -8,
                child: Container(
                  width: 520,
                  height: 949,
                  decoration: BoxDecoration(color: const Color(0xFF141419)),
                ),
              ),
              Positioned(
                left: 0,
                top: -8,
                child: Container(
                  width: 520,
                  height: 949,
                  decoration: BoxDecoration(color: const Color(0xFF141419)),
                ),
              ),
              Positioned(
                left: 119,
                top: 872,
                child: Container(
                  width: 181,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFED6B26),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 151,
                top: 840,
                child: SizedBox(
                  width: 117,
                  height: 32,
                  child: Text(
                    'I Have an Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 119,
                top: 45,
                child: SizedBox(
                  width: 181,
                  height: 97.74,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: const Color(0xFFED6B26),
                      fontSize: 45,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 162,
                top: 123,
                child: SizedBox(
                  width: 121.82,
                  height: 39.11,
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 146,
                top: 116,
                child: Container(
                  width: 126,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFED6B26),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 39,
                top: 751,
                child: Container(
                  width: 333,
                  height: 69,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.00, 0.50),
                      end: Alignment(1.00, 0.50),
                      colors: [const Color(0xFFED6B26), const Color(0xFF873D15)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(130),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 162,
                top: 766,
                child: SizedBox(
                  width: 139.63,
                  height: 54.41,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 38.52,
                top: 455.30,
                child: Container(
                  width: 347,
                  height: 69,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF2C2E35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0xFFFFFFFF),
                        blurRadius: 19,
                        offset: Offset(1, 11),
                        spreadRadius: -19,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 38.52,
                top: 574.30,
                child: Container(
                  width: 347,
                  height: 69,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF2C2E35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0xFFFFFFFF),
                        blurRadius: 19,
                        offset: Offset(1, 11),
                        spreadRadius: -19,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 38.52,
                top: 336.30,
                child: Container(
                  width: 347,
                  height: 70,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF2C2E35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0xFFFFFFFF),
                        blurRadius: 19,
                        offset: Offset(1, 11),
                        spreadRadius: -19,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 38.52,
                top: 218.30,
                child: Container(
                  width: 347,
                  height: 70,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF2C2E35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0xFFFFFFFF),
                        blurRadius: 19,
                        offset: Offset(1, 11),
                        spreadRadius: -19,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 64.04,
                top: 237.48,
                child: SizedBox(
                  width: 94.85,
                  height: 29.85,
                  child: Text(
                    'Full Name',
                    style: TextStyle(
                      color: const Color(0xFF868585),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 64.04,
                top: 355.93,
                child: SizedBox(
                  width: 51.52,
                  height: 29.85,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      color: const Color(0xFF868585),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 64.04,
                top: 474.85,
                child: SizedBox(
                  width: 92.93,
                  height: 29.85,
                  child: Text(
                    'Password',
                    style: TextStyle(
                      color: const Color(0xFF868585),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 64.04,
                top: 593.78,
                child: SizedBox(
                  width: 144.44,
                  height: 29.85,
                  child: Text(
                    'Phone Number',
                    style: TextStyle(
                      color: const Color(0xFF868585),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}