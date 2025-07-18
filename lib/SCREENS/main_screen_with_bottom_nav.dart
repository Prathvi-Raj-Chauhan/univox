import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../PAGES/add_post_page.dart';
import '../PAGES/home_page.dart';
import '../PAGES/my_account_page.dart';
import '../PROVIDERS/bottom_navbar.dart';

class MainScreenWithNavBar extends StatefulWidget {
  final String? token;
  const MainScreenWithNavBar({super.key, required this.token});

  @override
  State<MainScreenWithNavBar> createState() => _MainScreenWithNavBarState();
}

class _MainScreenWithNavBarState extends State<MainScreenWithNavBar> {


  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomePage(token: widget.token),
      addPost(token: widget.token),
      AccountPage(token: widget.token),
    ];
    return Consumer<BottomNavProvider>(
      builder: (BuildContext context, navprovider, child) { // this navprovider will work as a model now we could have given it any name using this we can access the bottomnavbarprovider class
        child:
        return Scaffold(

          body: screens[navprovider.selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_sharp), label: 'Add Post',),
              BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account',),

            ],
            currentIndex: navprovider.selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: navprovider.changeIndex,
          ),
        );
      },
    );
  }
}
