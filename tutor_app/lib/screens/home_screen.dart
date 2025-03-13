import 'package:flutter/material.dart';
import 'package:tutor_app/screens/connect_students_screen.dart';
import 'tutor_reviews.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TutorApp",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Color(0xFF192650)), // Ícono de campana
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectStudentsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Color(0xFF192650)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFF192650)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TutorProfile()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Color.fromARGB(221, 253, 247, 255),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TutorProfile()),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Color(0xFF192650),
                        child:
                            Text('A', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    title: Text('Alejandro Hernandez',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    height: 100,
                    color: Color(0xFFFFFFFF),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Programming tutoring',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Computer Science student',
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 5),
                        Text('I have been tutoring since 2018.'),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child:
                            Text('Book', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF192650),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
