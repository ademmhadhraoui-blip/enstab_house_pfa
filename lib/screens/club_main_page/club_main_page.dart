import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/event.dart';
import 'package:enstabhouse/models/workshop.dart';
import 'club_events.dart';
import 'club_workshops.dart';

class ClubMainPage extends StatefulWidget {
  const ClubMainPage({super.key});

  // 🔹 Données des événements
  static const List<Event> events = [
    Event(
      name: 'BootCamp',
      description: "Flutter BootCamp for enstab students",
      date: "18 Feb",
      place: "Enstab",
      time: "12 pm",
    ),
    Event(
      name: 'BootCamp',
      description: "Flutter BootCamp for enstab students",
      date: "18 Feb",
      place: "Enstab",
      time: "12 pm",
    ),
    Event(
      name: 'BootCamp',
      description: "Flutter BootCamp for enstab students",
      date: "18 Feb",
      place: "Enstab",
      time: "12 pm",
    ),
    Event(
      name: 'BootCamp',
      description: "Flutter BootCamp for enstab students",
      date: "18 Feb",
      place: "Enstab",
      time: "12 pm",
    ),
  ];

  // 🔹 Données des workshops
  static const List<Workshop> workshops = [
    Workshop(
      time: "Feb 8 , 12 pm",
      description: "welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor",
      place: "Enstab",
      name: "AI BOOTCAMP",
      instructor: "Mr Mohamed",
    ),
    Workshop(
      time: "Feb 8 , 12 pm",
      description: "welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor",
      place: "Enstab",
      name: "AI BOOTCAMP",
      instructor: "Mr Mohamed",
    ),
    Workshop(
      time: "Feb 8 , 12 pm",
      description: "welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor",
      place: "Enstab",
      name: "AI BOOTCAMP",
      instructor: "Mr Mohamed",
    ),
    Workshop(
      time: "Feb 8 , 12 pm",
      description: "welcome to AI Bootcamp where you will learn the fondamentals of ai with the best instructor",
      place: "Enstab",
      name: "AI BOOTCAMP",
      instructor: "Mr Mohamed",
    ),
  ];

  @override
  State<ClubMainPage> createState() => _ClubMainPageState();
}

class _ClubMainPageState extends State<ClubMainPage> {
  String selectedTab = "Feed";

  // 🔹 Construit le body selon le tab sélectionné
  Widget _buildBody() {
    switch (selectedTab) {
      case "Events":
        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: ClubMainPage.events.length,
          itemBuilder: (context, index) {
            return EventWidgetCard(event: ClubMainPage.events[index]);
          },
        );
      case "Workshops":
        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: ClubMainPage.workshops.length,
          itemBuilder: (context, index) {
            return WorkshopCard(workshop: ClubMainPage.workshops[index]);
          },
        );
      default: // "Feed" — affiche les deux
        return ListView(
          padding: const EdgeInsets.only(top: 10),
          children: [
            ...ClubMainPage.events.map(
              (e) => EventWidgetCard(event: e),
            ),
            ...ClubMainPage.workshops.map(
              (w) => WorkshopCard(workshop: w),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // 🔴 Header
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // ✅ Navigator.pop() pour revenir en arrière
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          "Photography Club",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 🟡 Chips de filtrage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChip("Feed"),
                        const SizedBox(width: 25),
                        _buildChip("Events"),
                        const SizedBox(width: 25),
                        _buildChip("Workshops"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 📄 Body dynamique
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // 🔹 Construit un chip de filtrage
  Widget _buildChip(String text) {
    final bool isSelected = selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryDarkColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
