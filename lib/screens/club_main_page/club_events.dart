import 'package:flutter/material.dart';
import 'package:enstabhouse/screens/home_feed_screen.dart';
class ClubsPages extends StatelessWidget {
  const ClubsPages({super.key});
  static final List<EventWidget> event = [
      EventWidget(
          name: 'BootCamp',
          description: "Flutter BootCamp for enstab students",
          date: "18 Feb",
          place: "Enstab",
          time: "12 pm" ,
      ),
    EventWidget(
      name: 'BootCamp',
      description: "Flutter BootCamp for enstab students",
      date: "18 Feb",
      place: "Enstab",
      time: "12 pm" ,
    ),
    EventWidget(
      name: 'BootCamp',
      description: "Flutter BootCamp for enstab students",
      date: "18 Feb",
      place: "Enstab",
      time: "12 pm" ,
    ),
    EventWidget(
      name: 'BootCamp',
      description: "Flutter BootCamp for enstab students",
      date: "18 Feb",
      place: "Enstab",
      time: "12 pm" ,
    ),

  ] ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF9E0815) ,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20 , top: 20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeFeedScreen())
                              );
                            },
                            child: Icon(Icons.arrow_back ,
                            color: Colors.white,
                              size: 35,
                            ),
                          ),
                          SizedBox(width: 20,) ,
                          Text("Photography Club",
                            style: TextStyle(
                              color: Colors.white ,
                              fontSize: 23
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30,) ,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20,),
                          SelectedChipWidget(text: "Feed", selected: false, ) ,
                          SizedBox(width: 25,),
                          SelectedChipWidget(text: "Events", selected: true) ,
                          SizedBox(width: 25,),
                          SelectedChipWidget(text: "Workshops", selected: false, ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
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
  final String name ;
  final String description ;
  final String date ;
  final String place ;
  final String time ;

  EventWidget({
    required this.name ,
    required this.description ,
    required this.date ,
    required this.place ,
    required this.time ,
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
          Padding(
            padding: const EdgeInsets.only(left: 20.0) ,
            child: Container(
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
                  Text(eventwidget.date ,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
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
          ),
          SizedBox(width: 12.0,) ,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventwidget.name ,
                  style: TextStyle(
                    fontSize: 25,
                      fontWeight: FontWeight.bold ,
                      color: Colors.black
                  ),
                  ),
                  Text(eventwidget.time ,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey ,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.place_outlined),
                      Text(eventwidget.place ,
                        softWrap: true ,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey ,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 10,) ,
                  Text(eventwidget.description,
                    softWrap: true ,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey ,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
class SelectedChipWidget extends StatelessWidget {
  final String text ;
  final bool selected ;


  SelectedChipWidget ({
    required this.text ,
    required this.selected ,

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        } ,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Color(0xFF7d1616) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    ) ;
  }
}


