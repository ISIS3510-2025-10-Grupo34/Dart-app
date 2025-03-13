import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tutor_app/screens/write_review_screen.dart';
import 'add_course_screen.dart'; 

class TutorProfile extends StatelessWidget {
  const TutorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TutorApp",style: TextStyle( fontSize: 24,fontWeight: FontWeight.w500,)),
        backgroundColor:  Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:  Color(0xFF192650),
                    child: Text(
                      'A',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Alejandro Hernandez',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Universidad de los Andes',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  RatingBarIndicator(
                    rating: 4.0,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color:  Color(0xFF192650),
                    ),
                    itemCount: 5,
                    itemSize: 24.0,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(FontAwesomeIcons.whatsapp, color:  Color(0xFF192650)),
                SizedBox(width: 10),
                Text('3045748603', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.book, color:  Color(0xFF192650)),
                    SizedBox(width: 10),
                    Text('Moviles', style: TextStyle(fontSize: 16)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add, color:  Color(0xFF192650)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddCourseScreen()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:  Color(0xFF192650),
                      child: Text('A', style: TextStyle(color: Colors.white)),
                    ),
                    title: RatingBarIndicator(
                      rating: 4.0,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color:  Color(0xFF192650),
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                    ),
                    subtitle: Text('Supporting line text lorem ipsum dolor sit amet, consectetur.'),
                  );
                },
              ),
            ),
            Center(
              child:
              //Navegar a la página de agregar review
               ElevatedButton(            
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WriteReviewScreen()),
                  );
                },
                child: Text('Write a review' ,style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF192650),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
