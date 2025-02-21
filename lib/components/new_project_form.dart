import 'package:flutter/material.dart';

class NewProjectForm extends StatefulWidget {
  final void Function(String) onSubmit;

  const NewProjectForm(this.onSubmit); //this.onSubmit);

  @override
  State<NewProjectForm> createState() => _NewProjectFormState();
}

class _NewProjectFormState extends State<NewProjectForm> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  //final _teacherController = TextEditingController();

  void _submitForm() {
    //final id = int.parse(_idController.text);
    final name = _nameController.text;
    //final teacher = _teacherController.text;

    if (name.isEmpty) {
      return;
    }

    widget.onSubmit(name); //acesso ao componente stateful
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // TextField(
              //   keyboardType: TextInputType.text,
              //   onSubmitted: (_) => _submitForm(),
              //   controller: _idController,
              //   decoration: InputDecoration(labelText: "ID"),
              // ),
              TextField(
                keyboardType: TextInputType.text,
                onSubmitted: (_) => _submitForm(),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name', filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  fillColor: Colors.black12, // Fill color set to transparent
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
              // TextField(
              //   keyboardType: TextInputType.text,
              //   onSubmitted: (_) => _submitForm(),
              //   controller: _teacherController,
              //   decoration: InputDecoration(labelText: "Professor"),
              // ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    "Create",
                    style: TextStyle(fontFamily: 'Roboto', color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
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
