import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../models/point.dart';
import '../models/project.dart';

import '../utils/routes.dart';

class PointItemFavorite extends StatelessWidget {
  final Point point;
  final List<Project> projects;
  //final Map<String, dynamic> userData;

  const PointItemFavorite(this.point, this.projects, {super.key});

  void _goToPointDetailsScreen(
      BuildContext context, List<Project> projects, Point point) {
    Project project =
        projects.where((project) => project.id == point.project_id).first;
    Navigator.of(context).pushNamed(AppRoutes.POINT_DETAILS,
        arguments: {"project": project, "point": point});
  }

  // Future favoritePoint(int userId, String token, int pointId) async {
  //   final data = {
  //     "user_id": userId,
  //     "authentication_token": token,
  //     "id": pointId
  //   };

  //   final http.Response response = await http.post(
  //     Uri.parse("https://app.uff.br/umm/api/favorite_point_in_igeo"),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(data),
  //   );
  //   return response;
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _goToPointDetailsScreen(context, projects, point),
      splashColor: Colors.amber,
      hoverColor: const Color.fromARGB(255, 181, 220, 238),
      child: ListTile(
        leading: const FittedBox(
          fit: BoxFit.fitWidth,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ),
        ),
        title: Text(point.name!),
        subtitle: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 2),
              child: const Icon(
                Icons.gps_fixed_sharp,
                size: 12,
                color: Color.fromARGB(255, 7, 163, 221),
              ),
            ),
            Text(
                "Lat: ${point.lat!.toStringAsFixed(1)} - Lon: ${point.long!.toStringAsFixed(1)} - "),
            Container(
              margin: const EdgeInsets.only(right: 2),
              child: const Icon(
                Icons.calendar_month,
                size: 12,
                color: Color.fromARGB(255, 7, 163, 221),
              ),
            ),
            Text(point.date!)
          ],
        ),
      ),
    );
  }
}
