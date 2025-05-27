import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/search_feature/presentation/bloc/currentSongWidgetBloc/current_song_widget_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class MainNavigationWrapper extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainNavigationWrapper({
    Key? key,
    required this.child,
    required this.currentRoute,
  }) : super(key: key);

  @override
  _MainNavigationWrapperState createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(MainNavigationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateSelectedIndex();
    }
  }

  void _updateSelectedIndex() {
    switch (widget.currentRoute) {
      case Routes.homeScreen:
        _selectedIndex = 0;
        break;
      case Routes.searchScreen:
        _selectedIndex = 1;
        break;
      case Routes.libraryScreen:
        _selectedIndex = 2;
        break;
      default:
        break;
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    String route;
    switch (index) {
      case 0:
        route = Routes.homeScreen;
        break;
      case 1:
        route = Routes.searchScreen;
        break;
      case 2:
        route = Routes.libraryScreen;
        break;
      default:
        route = Routes.homeScreen;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Player


          // Bottom Navigation Bar
          BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Library',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
