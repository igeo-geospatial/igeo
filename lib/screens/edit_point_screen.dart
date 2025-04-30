import 'package:flutter/material.dart';
import 'package:igeo/utils/routes.dart';
import '../models/point.dart';
import '../models/project.dart';
import '../utils/db_utils.dart';

class EditPointScreen extends StatefulWidget {
  const EditPointScreen({super.key});

  @override
  _EditPointScreenState createState() => _EditPointScreenState();
}

class _EditPointScreenState extends State<EditPointScreen> {
  late Point _originalPoint;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _latController = TextEditingController();
    _longController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  void _loadArguments() {
    if (_nameController.text.isEmpty) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _originalPoint = arguments["point"] as Point;
      _nameController.text = _originalPoint.name ?? '';
      _descriptionController.text = _originalPoint.description ?? '';
      _latController.text = _originalPoint.lat?.toStringAsFixed(6) ?? '';
      _longController.text = _originalPoint.long?.toStringAsFixed(6) ?? '';
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedPoint = Point(
        id: _originalPoint.id,
        project_id: _originalPoint.project_id,
        name: _nameController.text,
        date: _originalPoint.date,
        time: _originalPoint.time,
        lat: double.tryParse(_latController.text),
        long: double.tryParse(_longController.text),
        description: _descriptionController.text,
      );

      await DbUtils.updatePoint(updatedPoint);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.HOME2,
        (Route<dynamic> route) => false, // Remove todas as rotas anteriores
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit point', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF004D40),
        iconTheme: const IconThemeData(color: Colors.white),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.save, color: Colors.white),
        //     onPressed: _saveChanges,
        //   ),
        //   TextButton(
        //     onPressed: _saveChanges,
        //     child: const Text('OK',
        //         style: TextStyle(color: Colors.white, fontSize: 16)),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Point Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _latController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required field';
                  final lat = double.tryParse(value);
                  if (lat == null) return 'Invalid number';
                  if (lat < -90 || lat > 90) return 'Between -90 and 90';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _longController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required field';
                  final long = double.tryParse(value);
                  if (long == null) return 'Invalid number';
                  if (long < -180 || long > 180) return 'Between -180 and 180';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                maxLines: 5,
              ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
