import 'package:flutter/material.dart';

import '../components/new_project_form.dart';
import '../components/project_item.dart';
import '../utils/db_utils.dart';
import '../models/project.dart';

class ProjectsScreen extends StatefulWidget {
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  // Placeholder for the list of projects
  List<Project> projects = [];

  dynamic projectData;

  getProjects() async {
    projects = [];
    projectData = await DbUtils.getData("projects");
    if (projectData.length == 0) {
      print("vazio");
      return;
    }

    projectData.forEach((project) {
      projects.add(
        Project(id: project["id"], name: project["project_name"]),
      );
    });
    projects.forEach(
      (project) => print("${project.id} - ${project.name}"),
    );
  }

  Future postProject(String name) async {
    await DbUtils.insert('projects', {
      'project_name': name,
    });
  }

  void _addProject(String name) {
    postProject(name).then((value) => setState(() {
          projects.add(Project(
            id: projects.isEmpty ? 0 : projects.last.id + 1,
            name: name,
          ));
        }));

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project added'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> deleteProjectDef(int projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete project?"),
        content: const Text(
            "This will permanently delete the project and all its points"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == false) {
      setState(() {});
      return;
    }

    try {
      await DbUtils.deleteProjectPoints(projectId);

      await DbUtils.deleteProject(projectId);

      setState(() {
        projects.removeWhere((project) => project.id == projectId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project and all points deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deletion failed: ${e.toString()}')),
      );
    }
  }

  void openNewProjectFormModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: NewProjectForm(_addProject),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: IgeoAppbar.getBar(context),
      body: FutureBuilder(
        future: getProjects(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                    ),
                  )
                : projects.isNotEmpty
                    ? ListView.builder(
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          return ProjectItem(
                            projects[index],
                            deleteProjectDef,
                          );
                        },
                      )
                    : Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.terrain,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'No projects created',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF004D40),
        onPressed: () {
          openNewProjectFormModal(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
