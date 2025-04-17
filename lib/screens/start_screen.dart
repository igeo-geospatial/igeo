import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/igeo_appbar.dart';
import '../components/text.dart';
import '../utils/db_utils.dart';
import '../utils/routes.dart';
import 'package:photo_manager/photo_manager.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isLoading = true;
  bool accept = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final PermissionState status = await PhotoManager.requestPermissionExtend();
    if (!mounted) return;

    if (!status.isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem permissão'),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  submitForm() async {
    //print(formData);
    final dataFromAccept = await DbUtils.getData("accepts");
    print(dataFromAccept);

    if (dataFromAccept[0]['accept'] == 'false') {
      Widget alert = AlertDialog(
        title: const Row(
          children: [
            const Icon(
              Icons.warning_amber_outlined,
              color: Colors.amber,
              size: 12,
            ),
            const Expanded(
              child: Text(
                " Termos de Uso/Terms of Use",
                style: TextStyle(
                  fontSize: 10,
                  color: Color.fromARGB(255, 189, 39, 39),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            signupText,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // setState(() {
              //   accept = true;
              // });
              Navigator.of(context).pop();
              await DbUtils.updateAccept();

              Navigator.of(context).pushNamed(
                AppRoutes.HOME2,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have accepted the terms of use'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Agree/aceito"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop();
              setState(() {
                //accept = false;
              });

              return;
            },
            child: const Text("Not agree/não aceito"),
          ),
        ],
      );
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => alert,
      );

      // if (accept) {
      //   await DbUtil.updateAccept();

      //   Navigator.of(context).pushNamed(
      //     AppRoutes.HOME2,
      //   );
      //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Você aceitou o termo de responsabilidade'),
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      // } else {
      //   return;
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IgeoAppbar.getBarWithoutBack(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/logo.png",
                    height: 300,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await submitForm();
                      Navigator.pushReplacementNamed(context, AppRoutes.HOME2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Enter',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
