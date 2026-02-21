import 'package:flutter/material.dart';
import 'club_events.dart';

class ClubWorkshops extends StatelessWidget {
  const ClubWorkshops({super.key});

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body:  WorkshopCard(),
      ),
    ) ;
  }
}
class WorkshopCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white ,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color :Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20 , top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Basics of web development" ,
              softWrap: true ,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black ,
              fontSize: 20 ,
              fontWeight: FontWeight.bold ,
            ),
            ),
            SizedBox(height: 8,) ,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.person_2 ,
                color: Colors.grey,
                ) ,
                SizedBox(width: 15,) ,
                Text(
                  "Instructor : Mr Mohamed " ,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.calendar_month ,
                color: Colors.grey,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

