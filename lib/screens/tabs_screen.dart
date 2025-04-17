import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/db_utils.dart';
import '../screens/favorite_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/start_screen.dart';

import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

int _selectedScreenIndex = 0;

class _TabsScreenState extends State<TabsScreen> {
  @override
  Widget build(BuildContext context) {
    // final Map<String, dynamic> userData =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final List<Map<String, Object>> _screens = [
      {
        "title": "Projects",
        "screen": ProjectsScreen(),
        "icon": const Icon(
          Icons.travel_explore,
          color: Colors.white,
          size: 20,
        )
      },
      {
        "title": "Favorite points",
        "screen": FavoriteScreen(),
        "icon": const Icon(
          Icons.star,
          color: Colors.white,
          size: 20,
        )
      },
      // {
      //   "title": "Classificação de Praias",
      //   "screen": BeachClassificationScreen()
      // },
    ];

    void _selectScreen(int index) {
      setState(() {
        _selectedScreenIndex = index;
      });
    }

    void showExportResult(BuildContext context, String filePath) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Export Successful"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Platform.isAndroid) ...[
                const Text("File saved to:"),
                GestureDetector(
                  onTap: () => OpenFile.open(filePath),
                  child: Text(
                    filePath,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
              if (Platform.isIOS)
                const Text("File saved to your app documents.\n"
                    "Use the Files app to access it."),
            ],
          ),
          actions: [
            if (Platform.isIOS)
              TextButton(
                onPressed: () => Share.shareXFiles([XFile(filePath)]),
                child: const Text("Share File"),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StartScreen()), // Pushes StartScreen()
            );
          },
        ),
        title: Column(
          children: [
            _screens[_selectedScreenIndex]["icon"] as Widget,
            Text(
              _screens[_selectedScreenIndex]['title'] as String,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final path = await DbUtils.downloadData();
                if (path != null) {
                  showExportResult(context, path);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No data to export")));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Export failed: ${e.toString()}")));
              }
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
          ),
        ],
      ),
      //drawer: const (),
      body: _screens[_selectedScreenIndex]['screen'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectScreen,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.blueGrey,
        selectedItemColor: Theme.of(context).primaryColor,
        currentIndex: _selectedScreenIndex,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star_border,
              color: _selectedScreenIndex != 0 ? Colors.amber : Colors.blueGrey,
            ),
            label: 'Favorite points',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.beach_access),
          //   label: 'Classificação de praias',
          // ),
        ],
      ),
    );
  }
}
