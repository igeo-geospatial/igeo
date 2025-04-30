import 'package:flutter/material.dart';
import '../components/image_input.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/point.dart';
import '../models/project.dart';
import '../components/location_input.dart';

class NewPointFormScreen extends StatefulWidget {
  @override
  State<NewPointFormScreen> createState() => _NewPointFormScreenState();
}

class _NewPointFormScreenState extends State<NewPointFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<File> pickedImages = [];

  void addImage(File pickedImage) {
    if (pickedImages.length >= 4) return;
    pickedImages.add(pickedImage);
  }

  void sendBackData(BuildContext context, Project project) {
    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    // if (pointProvider.lat == null || pointProvider.long == null) {
    //   showDialog(
    //     context: context,
    //     builder: (ctx) => AlertDialog(
    //       title: const Text('Missing Location'),
    //       content: const Text('Please select a location before submitting'),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(ctx),
    //           child: const Text('OK'),
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }

    final newPoint = Point(
      name: _nameController.text,
      description: _descriptionController.text,
      lat: pointProvider.lat,
      long: pointProvider.long,
      date: DateFormat("d/M/yyyy").format(DateTime.now()),
      time: DateTime.now().toString().substring(10, 19),
      user_id: 1,
      project_id: project.id,
      pickedImages: pickedImages,
    );

    Navigator.pop(context, newPoint);
  }

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)!.settings.arguments as Project;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            children: [
              const Icon(Icons.gps_fixed, color: Colors.white),
              Text(
                "New point in ${project.name}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Consumer<PointProvider>(
              builder: (context, pointProvider, child) {
                return Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Point name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a point name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Point description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    LocationInput(),
                    ImageInput(addImage),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => sendBackData(context, project),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        "Create",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
