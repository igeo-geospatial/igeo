import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';

import '../models/point.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageInput extends StatefulWidget {
  final Function onSelectImage;
  ImageInput(this.onSelectImage);

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  List<File> storedImage = [];

  double? lat;
  double? long;
  LocationPermission? permission;

  Future<void> _getCurrentUserLocation() async {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    final locData = await Geolocator.getCurrentPosition();
    setState(() {
      lat = locData.latitude;
      long = locData.longitude;
    });
  }

  void takePicture() async {
    await _getCurrentUserLocation();
    if (storedImage.length >= 4) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("The limit is 4 images"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    XFile? imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
    );

    if (imageFile == null) return;

    final decodeImg = img.decodeImage(File(imageFile.path).readAsBytesSync());
    img.drawString(
      decodeImg!,
      '${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())} - Lat: $lat - Long: $long',
      x: 10,
      y: 10,
      font: img.arial24,
      color: img.ColorRgb8(255, 0, 0),
    );

    final encodeImage = img.encodeJpg(decodeImg, quality: 100);
    setState(() {
      storedImage.add(File(imageFile.path)..writeAsBytesSync(encodeImage));
    });

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    String fileName = path.basename(storedImage.last.path);
    final savedImage = await storedImage.last.copy('${appDir.path}/$fileName');

    final PermissionState status = await PhotoManager.requestPermissionExtend();
    if (!status.isAuth) return;

    final AssetEntity? entity = await PhotoManager.editor.saveImageWithPath(
      savedImage.path,
      title: path.basename(savedImage.path),
    );

    if (entity == null) {
      print('Failed to save image to gallery');
      return;
    }

    // Obtenha o arquivo real do AssetEntity
    final file = await entity.file;
    if (file != null && mounted) {
      widget.onSelectImage(File(file.path)); // Usar o caminho da entidade salva
    }
  }

  void removePicture(File file) async {
    try {
      final filePath = file.absolute.path;
      final fileName = path.basename(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      final PermissionState status =
          await PhotoManager.requestPermissionExtend();
      if (status.isAuth) {
        final List<AssetPathEntity> albums =
            await PhotoManager.getAssetPathList();
        for (final album in albums) {
          final List<AssetEntity> assets = await album.getAssetListPaged(
            page: 0,
            size: await album.assetCountAsync,
          );

          AssetEntity? matchingAsset;
          try {
            matchingAsset = assets.firstWhere(
              (asset) => asset.title == fileName,
            );
          } catch (e) {
            matchingAsset = null;
          }

          if (matchingAsset != null) {
            final List<String> deletedIds =
                await PhotoManager.editor.deleteWithIds([matchingAsset.id]);
            if (!deletedIds.contains(matchingAsset.id)) {
              throw Exception('Failed to remove from gallery');
            }
            break;
          }
        }
      }

      if (mounted) {
        setState(() => storedImage.removeWhere((f) => f.path == filePath));
      }
    } catch (e) {
      print('Deletion error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 370,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            color: Colors.black12,
          ),
          alignment: Alignment.center,
          child: storedImage.isEmpty
              ? const Text("No photos added")
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: storedImage.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Image.file(
                            storedImage[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          // Positioned(
                          //   top: 8,
                          //   right: 8,
                          //   child: GestureDetector(
                          //     onTap: () => removePicture(storedImage[index]),
                          //     child: Container(
                          //       padding: const EdgeInsets.all(4),
                          //       decoration: const BoxDecoration(
                          //         color: Colors.red,
                          //         shape: BoxShape.circle,
                          //       ),
                          //       child: const Icon(
                          //         Icons.close,
                          //         color: Colors.white,
                          //         size: 20,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: TextButton.icon(
            onPressed: takePicture,
            icon: const Icon(Icons.camera, color: Colors.amber, size: 16),
            label: const Text(
              "Take picture",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
