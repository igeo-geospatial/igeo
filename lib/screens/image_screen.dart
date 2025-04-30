import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart' as path; // Adicione esta importação

class ImageScreen extends StatelessWidget {
  final String imageUrl;
  const ImageScreen({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen
          },
        ),
        title: const Column(
          children: [
            Icon(
              Icons.photo_album,
              color: Colors.white,
            ),
            Text(
              "Photo",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final PermissionState status =
                  await PhotoManager.requestPermissionExtend();
              if (!status.isAuth) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You should have permission')),
                );
                return;
              }

              final AssetEntity? entity =
                  await PhotoManager.editor.saveImageWithPath(
                imageUrl,
                title: path.basename(
                    imageUrl), // Usando a função basename do pacote path
              );

              if (entity != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved in gallery'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4,
          child: Image.file(
            File(imageUrl),
            width: double.infinity,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final PermissionState status =
              await PhotoManager.requestPermissionExtend();
          if (!status.isAuth) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You should have permission')),
            );
            return;
          }

          final AssetEntity? entity =
              await PhotoManager.editor.saveImageWithPath(
            imageUrl,
            title: path
                .basename(imageUrl), // Usando a função basename do pacote path
          );

          if (entity != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved in gallery'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.download),
      ),
    );
  }
}
