import 'package:flutter/material.dart';
import 'package:gpa_calculator/splash_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:cross_file/cross_file.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GPA Calculator",
      theme: ThemeData(primaryColor: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: splashScreen(),
    );
  }
}

class firstScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return firstScreenState();
  }
}

class firstScreenState extends State<firstScreen> {
  TextEditingController courseController = TextEditingController();
  int numberOfCourses = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Course Requirements"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Container(
              child: Text(
                "Let's calculate your GPA!",
                style: TextStyle(fontSize: 35, fontFamily: 'Satisfy-Regular'),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 200,
              height: 400,
              child: Image.asset('lib/assets/pics/gpa pic 1.png'),
            ),
            SizedBox(height: 20),
            Container(
              child: Center(
                child: Text(
                  "Number of Courses",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Oswald'),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: TextField(
                controller: courseController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  label: Text(
                    "Write the no. of Courses here e.g. 4",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.only(left: 200),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 4),
                        blurRadius: 12.0
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    numberOfCourses = int.tryParse(courseController.text) ?? 0;

                    if (numberOfCourses > 0) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(seconds: 3), // Forward animation duration
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return secondScreen(courses: numberOfCourses);
                          },
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var begin = Offset(1.0, 0.0); // Start from the right
                            var end = Offset.zero; // End at the screen position
                            var curve = Curves.fastEaseInToSlowEaseOut;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text(
                              numberOfCourses == 0
                                  ? "Course no. cannot be 0 for GPA calculation"
                                  : "Please enter a valid Course number",
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Next",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Oswald'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


class secondScreen extends StatefulWidget {
  final int courses;

  secondScreen({required this.courses});

  @override
  State<secondScreen> createState() => _secondScreenState();
}

class _secondScreenState extends State<secondScreen> {
  List<TextEditingController> nameController = [];
  List<TextEditingController> creditController = [];
  List<TextEditingController> gradeController = [];

  Map<String, double> gradeValues = {
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'F': 0.0,
  };

  @override
  void initState() {
    super.initState();
    nameController =
        List.generate(widget.courses, (index) => TextEditingController());
    creditController =
        List.generate(widget.courses, (index) => TextEditingController());
    gradeController =
        List.generate(widget.courses, (index) => TextEditingController());
  }

  Map<String, dynamic> calculateGPA() {
    double totalGradePoints = 0.0;
    double totalCredit = 0.0;
    List<String> allCourses = [];
    List<String> allGrades = [];
    List<String> allCredits = [];

    for (int i = 0; i < widget.courses; i++) {
      String grade = gradeController[i].text.trim().toUpperCase();
      double gradeValue = gradeValues[grade] ?? 0.0;
      double creditValue = double.tryParse(creditController[i].text.trim()) ?? 0.0;

      totalGradePoints += (gradeValue * creditValue);
      totalCredit += creditValue;

      allCourses.add(nameController[i].text.trim());
      allGrades.add(grade);
      allCredits.add(creditController[i].text.trim());
    }

    double gpa = totalCredit > 0 ? totalGradePoints / totalCredit : 0.0;
    return {
      'gpa': gpa.toStringAsFixed(2),
      'allCourses': allCourses,
      'allGrades': allGrades,
      'allCredits': allCredits,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Grade Requirements"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.courses,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: 120,
                      decoration:BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25)
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Text(
                            "Course ${index + 1}",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Oswald'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 300,
                      child: TextField(
                        controller: nameController[index],
                        decoration: InputDecoration(
                          label: Text(
                            "Enter the Name of the course here e.g. Stats",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300,
                      child: TextField(
                        controller: gradeController[index],
                        decoration: InputDecoration(
                          label: Text(
                            "Enter the Grade of the course here e.g. B+",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300,
                      child: TextField(
                        controller: creditController[index],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text(
                            "Enter the Credit hours of the course here e.g. 4",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 40),
            Container(
              width: 150,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 4),
                        blurRadius: 12.0
                    )
                  ]
              ),
              child: ElevatedButton(
                onPressed: () {
                  bool fieldsFilled = true;

                  for (int i = 0; i < widget.courses; i++) {
                    if (nameController[i].text.trim().isEmpty ||
                        creditController[i].text.trim().isEmpty ||
                        gradeController[i].text.trim().isEmpty) {
                      fieldsFilled = false;
                      break;
                    }
                  }

                  if (fieldsFilled) {
                    var result = calculateGPA();

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(seconds: 3), // Forward animation duration
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return thirdScreen(
                            gpa: result['gpa'],
                            allCourses: result['allCourses'],
                            allGrades: result['allGrades'],
                            allCredits: result['allCredits'],
                          );
                        },
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          var begin = Offset(1.0, 0.0); // Start from the right
                          var end = Offset.zero; // End at the screen position
                          var curve = Curves.fastEaseInToSlowEaseOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text("Please fill in all fields."),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Oswald',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              )

            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}

class thirdScreen extends StatefulWidget {
  final String gpa;
  final List<String> allCourses;
  final List<String> allCredits;
  final List<String> allGrades;

  thirdScreen({
    required this.gpa,
    required this.allCourses,
    required this.allCredits,
    required this.allGrades,
  });

  @override
  State<thirdScreen> createState() => _thirdScreenState();
}

class _thirdScreenState extends State<thirdScreen> {
  GlobalKey _globalKey = GlobalKey();

  Future<void> _shareGPAReport() async {
    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/gpa_report.png').create();
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      print('Error sharing GPA report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("GPA Report"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 3.5
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          child: Text("GPA Report",style: TextStyle(
                            fontSize: 45,
                            fontFamily: 'Satisfy-Regular'
                          ),),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        'GPA: ${widget.gpa}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.allCourses.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course: ${widget.allCourses[index]}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Credits: ${widget.allCredits[index]}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Grade: ${widget.allGrades[index]}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: const Offset(0, 4),
                          blurRadius: 12.0
                      )
                    ]
                ),
                child: ElevatedButton.icon(
                  onPressed: _shareGPAReport,
                  icon: Icon(Icons.share),
                  label: Text("Share Report",style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Oswald'
                  ),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }
}
