import 'package:flutter/widgets.dart';
import '../utils/db_utils.dart';

import 'point.dart';

import 'dart:convert';

class PointList with ChangeNotifier {
  List<Point> points = [];

  List<Point> get getPoints => points;

  List<Point> getPointsForProject(int projectId) {
    return points.where((point) => point.project_id == projectId).toList();
  }

  List<Point> get favoritePoints =>
      points.where((point) => point.isFavorite).toList();

  void addPoint(Point point) {
    points.add(point);
    notifyListeners();
  }

  void removePoint(int id) {
    points.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Point getPoint(int pointId, int projectId) {
    return points
        .where((point) => point.id == pointId && point.project_id == projectId)
        .first;
  }

  void togglePointFavorite(int pointId, int projectId) {
    if (getPoint(pointId, projectId).isFavorite == false) {
      getPoint(pointId, projectId).isFavorite = true;
      DbUtils.favoritePoint(pointId, projectId);
    } else {
      getPoint(pointId, projectId).isFavorite = false;
      DbUtils.favoritePoint(pointId, projectId);
    }
    print(getPoint(pointId, projectId).isFavorite);
    notifyListeners();
  }

  void clear() {
    points = [];
    notifyListeners();
  }
}
