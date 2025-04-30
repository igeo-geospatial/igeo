import 'package:flutter/widgets.dart';
import 'dart:io';

class Point with ChangeNotifier {
  int? id;
  String? name;
  double? lat;
  double? long;
  String? date;
  String? time;
  String? description;
  int? user_id;
  int? project_id;
  bool isFavorite;
  List<String> image = [];
  List<File>? pickedImages = [];

  Point({
    this.id,
    this.name,
    this.lat,
    this.long,
    this.date,
    this.time,
    this.description,
    this.user_id,
    this.project_id,
    this.isFavorite = false,
    this.pickedImages = const [],
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  void addUrlToImageList(String url) {
    image.add(url);
  }

  void changeCoordinates(double lat, double long) {
    this.lat = lat;
    this.long = long;
    notifyListeners();
  }

  // Método toMap para conversão para formato de banco de dados
  Map<String, dynamic> toMap() {
    return {
      'project_id': project_id,
      'name': name,
      'date': date,
      'time': time,
      'lat': lat,
      'long': long,
      'description': description,
    };
  }
}
