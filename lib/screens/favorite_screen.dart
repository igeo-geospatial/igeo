import 'package:flutter/material.dart';
import '../models/point_list.dart';
import '../models/project.dart';
import '../models/point.dart';
import '../components/point_item_favorite.dart';
import '../utils/db_utils.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final PointList pointList = PointList();
  List<Project> projects = [];

  bool _toBoolean(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  Future<void> _getProjects() async {
    final projectData = await DbUtils.getData("projects");
    setState(() {
      projects = projectData
          .map<Project>((project) => Project(
                id: int.tryParse(project["id"]?.toString() ?? '') ?? 0,
                name: project["project_name"]?.toString() ?? 'Unnamed Project',
              ))
          .toList();
    });
  }

  Future<void> _getPoints() async {
    final pointData = await DbUtils.getData("points");
    setState(() {
      pointList.clear();

      for (final point in pointData) {
        final newPoint = Point(
          id: int.tryParse(point["id"]?.toString() ?? '') ?? 0,
          user_id: int.tryParse(point["user_id"]?.toString() ?? '') ?? 0,
          project_id: int.tryParse(point["project_id"]?.toString() ?? '') ?? 0,
          name: point["name"]?.toString() ?? 'Unnamed Point',
          lat: double.tryParse(point["lat"]?.toString() ?? '') ?? 0.0,
          long: double.tryParse(point["long"]?.toString() ?? '') ?? 0.0,
          date: point["date"]?.toString() ?? 'No date',
          time: point["time"]?.toString() ?? 'No time',
          description: point["description"]?.toString() ?? 'No description',
          isFavorite: _toBoolean(point["is_favorite"]),
        );

        if (point["image"] is List) {
          for (var url in point["image"]) {
            if (url != null) newPoint.addUrlToImageList(url.toString());
          }
        }
        pointList.addPoint(newPoint);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getProjects();
    _getPoints();
  }

  @override
  Widget build(BuildContext context) {
    final favoritePoints = pointList.favoritePoints;

    return Scaffold(
      body: ListView.builder(
        itemCount: favoritePoints.length,
        itemBuilder: (ctx, index) => PointItemFavorite(
          favoritePoints[index],
          projects,
        ),
      ),
    );
  }
}
