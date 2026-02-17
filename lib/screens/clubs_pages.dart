import 'package:flutter/material.dart';
class ClubsPages extends StatelessWidget {
  const ClubsPages({super.key});
  static final List<EventWidget> event = [
      EventWidget(
          Name: 'BootCamp',
          Description: "Flutter BootCamp for enstab students",
          Date: "18 Feb",
          Place: "Enstab",
          Time: "12 pm" ,
      ),
    EventWidget(
      Name: 'BootCamp',
      Description: "Flutter BootCamp for enstab students",
      Date: "18 Feb",
      Place: "Enstab",
      Time: "12 pm" ,
    ),
    EventWidget(
      Name: 'BootCamp',
      Description: "Flutter BootCamp for enstab students",
      Date: "18 Feb",
      Place: "Enstab",
      Time: "12 pm" ,
    ),
    EventWidget(
      Name: 'BootCamp',
      Description: "Flutter BootCamp for enstab students",
      Date: "18 Feb",
      Place: "Enstab",
      Time: "12 pm" ,
    ),

  ] ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: [
             Expanded(
               child: ListView.builder(
                 padding: const EdgeInsets.only(top: 10),
                 itemCount: event.length,
                 itemBuilder: (context ,index){
                   return EventWidgetCard(eventwidget: event[index]) ;
                 },
               ),
             )
            ],
          ),

        ),
    );
  }
}
class EventWidget {
  final String Name ;
  final String Description ;
  final String Date ;
  final String Place ;
  final String Time ;

  EventWidget({
    required this.Name ,
    required this.Description ,
    required this.Date ,
    required this.Place ,
    required this.Time ,
}) ;
}
class EventWidgetCard extends StatelessWidget {
  const EventWidgetCard({super.key , required this.eventwidget});
  final EventWidget eventwidget ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
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
      child: Row(
        children: [
          Container(
            height: 220,
            width: 100,
            padding: EdgeInsets.symmetric(horizontal: 15 ,vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFF9E0815) , 
              borderRadius: BorderRadius.circular(16)
            ),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(eventwidget.Date ,
                style: TextStyle(
                  color: Colors.white ,
                  fontWeight: FontWeight.bold
                ),
                ),
                const SizedBox(height: 20.0,) ,
                Icon(Icons.calendar_month,
                color: Colors.white,
                ),
              ],
            ),

          ),
        ],
      )
    );
  }
}

