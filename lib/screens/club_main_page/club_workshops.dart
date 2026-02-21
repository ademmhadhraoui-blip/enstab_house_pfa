import 'package:flutter/material.dart';
import 'club_events.dart';

class ClubWorkshops extends StatelessWidget {
  const ClubWorkshops({super.key});
  static List<WorkShopWidget> workshop = [
    WorkShopWidget(time: "Feb 8 , 12 pm",
        description:"welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor " ,
        place: "Enstab",
        name: "AI BOOTCAMP" ,
        instructor: "Mr Mohamed",
    ) ,
    WorkShopWidget(time: "Feb 8 , 12 pm",
      description:"welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor " ,
      place: "Enstab",
      name: "AI BOOTCAMP" ,
      instructor: "Mr Mohamed",
    ) ,
    WorkShopWidget(time: "Feb 8 , 12 pm",
      description:"welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor " ,
      place: "Enstab",
      name: "AI BOOTCAMP" ,
      instructor: "Mr Mohamed",
    ) ,
    WorkShopWidget(time: "Feb 8 , 12 pm",
      description:"welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor " ,
      place: "Enstab",
      name: "AI BOOTCAMP" ,
      instructor: "Mr Mohamed",
    ) ,
    
  ];

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: workshop.length,
                itemBuilder: (context ,index){
                  return WorkshopCard(workshopwidget  : workshop[index]) ;
                },
              ),
            )
          ]
        )  ,
      ),
    ) ;
  }
}
class WorkShopWidget {
  final String name ;
  final String description ;
  final String time ;
  final String place ;
  final String instructor ;
  WorkShopWidget({
    required this.time ,
    required this.description ,
    required this.place ,
    required this.name ,
    required this.instructor,
  }) ;
}
class WorkshopCard extends StatelessWidget {
  final WorkShopWidget workshopwidget ;
  const WorkshopCard({
    super.key,
    required this.workshopwidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                SizedBox(width: 15,) ,
                Text("Feb 8 * 12 am " ,
                style: TextStyle(
                  color: Colors.grey
                ) ,
                ) ,
              ],
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Expanded(
                child: Text("welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor " ,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.grey ,
                  ),
                ),
              ),
            ) ,
            SizedBox(height: 10,) ,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Container(
                    width: 250,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF9E0815),
                      borderRadius: BorderRadius.circular(10) ,
                    ),
                    child: Row(
                      mainAxisAlignment:  MainAxisAlignment.center,
                      children: [
                        Text("Register",
                        style: TextStyle(color: Colors.white,
                        ),
                        ),
                      ],
                    ),
                  )
                ),
                SizedBox(height: 100,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

