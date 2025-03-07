import 'package:flutter/material.dart';
import 'tutor_reviews.dart';
import 'tutor_reviews.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TutorApp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.blue.shade900),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.blue.shade900),
            onPressed: () {
              // Navegar a la página de perfil
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
              color: Colors.purple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TutorProfile()),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blue.shade900,
                        child: Text('A', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    title: Text('Alejandro Hernandez', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    height: 100,
                    color: Colors.grey.shade300, // Imagen de placeholder
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Programming tutoring', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Computer Science student', style: TextStyle(color: Colors.grey)),
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
                        child: Text('Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
