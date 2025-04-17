import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/points_screen.dart';
//import 'package:igeo_flutter/screens/project_points_screen.dart';

import '../models/project.dart';
//import '../utils/routes.dart';

class ProjectItem extends StatelessWidget {
  final Project project;

  final Function(int) onDeleteProject;

  const ProjectItem(this.project, this.onDeleteProject, {super.key});

  void _selectProjectItem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PointsScreen(
              project: project,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.horizontal,
      background: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          color: Theme.of(context).colorScheme.error,
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      key: ValueKey(project.id),
      onDismissed: (_) {
        onDeleteProject(
          project.id,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: InkWell(
          splashColor: Colors.amber,
          hoverColor: const Color.fromARGB(255, 181, 220, 238),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          onTap: () => _selectProjectItem(context),
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            child: ListTile(
              title: Text(
                project.name.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black12,
                    size: 14,
                  ),
                  Text(
                    " " +
                        DateFormat("d/M/yyyy")
                            .format(DateTime.now())
                            .toString(),
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              leading: const Icon(
                Icons.gps_fixed,
                color: Colors.amber,
              ),
              trailing: ElevatedButton(
                  onPressed: () => _selectProjectItem(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    "Details",
                    style: TextStyle(color: Colors.white),
                  )),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => PointsScreen(projectName: projects[index])),
                // );
                _selectProjectItem(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
