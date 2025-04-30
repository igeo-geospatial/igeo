import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/point.dart';
import '../models/project.dart';
import '../utils/db_utils.dart';
import '../components/image_item.dart';

class PointDetailScreen extends StatelessWidget {
  const PointDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final point = arguments["point"] as Point;
    final project = arguments["project"] as Project;
    List<String> images = [];

    Future<void> loadData() async {
      final dataList = await DbUtils.queryImages(point.id!, point.project_id!);

      for (int i = 1; i <= 4; i++) {
        final imageKey = 'image$i';
        if (dataList.isNotEmpty &&
            dataList[0][imageKey] != null &&
            dataList[0][imageKey].toString().isNotEmpty) {
          images.add(dataList[0][imageKey].toString());
        }
      }
    }

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
        title: Column(
          children: [
            const Icon(
              Icons.gps_fixed,
              color: Colors.white,
            ),
            Text(
              "Point in ${project.name}",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       //DbUtil.downloadData();
        //       ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(
        //           content: Text('Data downloaded'),
        //           duration: Duration(seconds: 2),
        //         ),
        //       );

        //       // Navigator.of(context)
        //       //     .pushNamedAndRemoveUntil(AppRoutes.HOME, (route) => false);
        //       //logOut();
        //     },
        //     icon: const Icon(
        //       Icons.download,
        //       color: Colors.white,
        //     ),
        //   ),
        // ],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => Navigator.pushNamed(
              context,
              '/edit-point',
              arguments: {
                'point': point,
                'project': project,
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData(),
        builder: (ctx, snapshot) => Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 200,
                    child: point.lat != 0
                        ? FlutterMap(
                            options: MapOptions(
                              center: LatLng(point.lat!, point.long!),
                              zoom: 13.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(point.lat!, point.long!),
                                    builder: (ctx) => const Icon(
                                      Icons.location_pin,
                                      color: Colors.amber,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const Center(child: Text("No location added")),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF004D40)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: FittedBox(
                              child: Text(
                                "${point.name}",
                                style: const TextStyle(
                                    color: Color(0xFF004D40),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: FittedBox(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  Text(" ${point.date!}"),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: FittedBox(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lock_clock,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  Text(" ${point.time!}"),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: FittedBox(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.gps_fixed_sharp,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  FittedBox(
                                    child: point.lat != 0
                                        ? Text(
                                            " Lat: ${point.lat!.toStringAsFixed(6)} - Long: ${point.long!.toStringAsFixed(6)}")
                                        : const Text(" No location added"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.textsms,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      " Description",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text("${point.description}"),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.photo,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      " Photos",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                images.isEmpty
                                    ? const Center(
                                        child: Text(
                                        "No photos added",
                                        style: TextStyle(color: Colors.grey),
                                      ))
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        child: GridView.builder(
                                          padding: const EdgeInsets.all(10),
                                          itemCount: images.length,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 3 / 2,
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing: 5,
                                          ),
                                          itemBuilder:
                                              (BuildContext context, index) =>
                                                  ImageItem(
                                                      imageUrl: images[index]),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
