import 'package:flutter/material.dart';

import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../models/point.dart';
import '../models/point_list.dart';
import '../models/project.dart';

import '../utils/routes.dart';
import '../utils/db_utils.dart';

import '../components/point_item.dart';

class PointsScreen extends StatefulWidget {
  final Project project;

  const PointsScreen({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  PointList pointList = PointList();
  dynamic pointData;
  Point? newPoint;

  bool toBoolean(String str, [bool strict = false]) {
    if (strict == true) return str == '1' || str == 'true';
    return str != '0' && str != 'false' && str != '';
  }

  getPoints() async {
    pointList.clear();
    setState(() => pointList = PointList());

    pointData = await DbUtils.getData("points");
    if (pointData.isEmpty) return;

    pointData.forEach((point) {
      Point newPoint = Point(
        id: int.tryParse(point["id"]?.toString() ?? '') ?? 0,
        user_id: int.tryParse(point["user_id"]?.toString() ?? '') ?? 0,
        project_id: int.tryParse(point["project_id"]?.toString() ?? '') ?? 0,
        name: point["name"]?.toString() ?? 'Unnamed Point',
        lat: double.tryParse(point["lat"]?.toString() ?? '') ?? 0.0,
        long: double.tryParse(point["long"]?.toString() ?? '') ?? 0.0,
        date: point["date"]?.toString() ?? 'No date',
        time: point["time"]?.toString() ?? 'No time',
        description: point["description"]?.toString() ?? 'No description',
        isFavorite: toBoolean(point["is_favorite"]?.toString() ?? 'false'),
      );

      for (int i = 1; i <= 4; i++) {
        final image = point["image$i"]?.toString();
        if (image != null && image.isNotEmpty) {
          newPoint.addUrlToImageList(image);
        }
      }

      pointList.addPoint(newPoint);
    });

    return pointData;
  }

  Future postPoint(
    int projectId,
    String name,
    double latitude,
    double longitude,
    String date,
    String time,
    String description,
    List<File> photos,
  ) async {
    final Map<String, dynamic> pointData = {
      'project_id': projectId.toString(),
      'name': name,
      'lat': latitude.toString(),
      'long': longitude.toString(),
      'date': date,
      'time': time,
      'description': description,
      'is_favorite': 'false',
    };

    for (int i = 0; i < 4; i++) {
      pointData['image${i + 1}'] = (i < photos.length) ? photos[i].path : '';
    }

    await DbUtils.insert('points', pointData);
    await getPoints();
    setState(() {});
  }

  void changeFavorite(int pointId, int projectId) {
    pointList.togglePointFavorite(pointId, projectId);
  }

  Future<void> refresh(BuildContext context) async {
    setState(() => pointList = PointList());
  }

  // deletePointDef(int userId, String token, int pointId) async {
  deletePointDef(int pointId) async {
    Widget alert = AlertDialog(
      title: const Text("Delete point?",
          style: TextStyle(
            color: Color.fromARGB(255, 189, 39, 39),
          )),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            pointList.removePoint(pointId);
            //await deletePoint(userId, token, pointId);
            await DbUtils.deletePoint(pointId);

            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Point deleted'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text("Delete"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {});
          },
          child: const Text("Cancel"),
        ),
      ],
    );
    showDialog(context: context, builder: (ctx) => alert);
  }

  @override
  Widget build(BuildContext context) {
    final Project project = widget.project;

    void awaitResultFromNewPointScreen() async {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.NEW_POINT,
        arguments: project,
      );

      if (result != null && result is Point) {
        postPoint(
          project.id,
          result.name!,
          result.lat!,
          result.long!,
          result.date!,
          result.time!,
          result.description!,
          result.pickedImages!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New point added')),
        );
      }
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
          },
        ),
        title: Column(
          children: [
            const Icon(
              Icons.gps_fixed,
              color: Colors.white,
            ),
            Text(
              project.name + " points",
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
            // onPressed: () {
            //   DbUtils.downloadData();
            //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       content: Text('Data downloaded'),
            //       duration: Duration(seconds: 2),
            //     ),
            //   );

            //   // Navigator.of(context)
            //   //     .pushNamedAndRemoveUntil(AppRoutes.HOME, (route) => false);
            //   //logOut();
            // },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => refresh(context),
        child: FutureBuilder(
          future: getPoints(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.amber));
            }

            final points = pointList.getPointsForProject(project.id);
            return points.isEmpty
                ? const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gps_off, color: Colors.amber),
                        SizedBox(width: 5),
                        Text('No points added yet',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 50),
                    itemCount: points.length,
                    itemBuilder: (ctx, index) => PointItem(
                      points[index],
                      project,
                      deletePointDef,
                      changeFavorite,
                      false,
                    ),
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          awaitResultFromNewPointScreen();
          setState(() {});
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
