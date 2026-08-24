import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Knead to Know"),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(child: Text("Dashboard")),
              ListTile(title: Text("News")),
              ListTile(title: Text("Gallery")),
              ListTile(title: Text("Contact")),
              ListTile(title: Text("ContactInfo")),
              ListTile(title: Text("Logout")),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
