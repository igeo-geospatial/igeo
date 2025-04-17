import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as syspaths;

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class DbUtils {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'points.db'),
      onCreate: (db, version) => _createDb(db),
      version: 1,
    );
  }

  static void _createDb(Database db) {
    db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY, 
        first_name TEXT, 
        last_name TEXT, 
        email TEXT, 
        accept_use TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_name TEXT,
        project_imageUrl TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT, 
        lat REAL, 
        long REAL, 
        date TEXT, 
        time TEXT, 
        description TEXT, 
        is_favorite INTEGER DEFAULT 0,
        image1 TEXT,
        image2 TEXT,
        image3 TEXT,
        image4 TEXT,
        project_id INTEGER,
        FOREIGN KEY (project_id) REFERENCES projects(id)
      )
    ''');

    db.execute('''
      CREATE TABLE accepts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accept TEXT
      )
    ''');

    db.insert('accepts', {'accept': 'false'});
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database();
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await database();
    return await db.query(table);
  }

  static Future<List<Map<String, dynamic>>> queryImages(
      int pointId, int projectId) async {
    final db = await DbUtils.database();
    return db.rawQuery('SELECT * FROM points WHERE id=? AND project_id=?',
        [pointId, projectId]);
  }

  static Future<void> favoritePoint(int pointId, int projectId) async {
    final db = await database();

    final results = await db.query(
      'points',
      where: 'id = ? AND project_id = ?',
      whereArgs: [pointId, projectId],
    );

    if (results.isNotEmpty) {
      final currentStatus =
          int.tryParse(results.first['is_favorite'].toString()) ?? 0;
      await db.update(
        'points',
        {'is_favorite': currentStatus == 0 ? 1 : 0},
        where: 'id = ? AND project_id = ?',
        whereArgs: [pointId, projectId],
      );
    }
  }

  static Future<String> generateCsv(List<List<dynamic>> inputData) async {
    final csvData = const ListToCsvConverter().convert(inputData);

    late final Directory dir;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final isLegacy = androidInfo.version.sdkInt != null &&
          androidInfo.version.sdkInt! <= 28;

      // Verificação de permissão apenas para Android antigo
      if (isLegacy && !await Permission.storage.request().isGranted) {
        throw Exception('Permissão de armazenamento necessária');
      }

      // Melhoria 1: Validação reforçada do caminho
      final List<Directory>? extDirs =
          await syspaths.getExternalStorageDirectories();
      if (extDirs == null || extDirs.isEmpty) {
        throw Exception('Armazenamento externo não disponível');
      }

      // Melhoria 2: Fallback para diferentes padrões de caminho
      String basePath = extDirs.first.path;
      if (!basePath.contains('Android')) {
        basePath = extDirs.first.parent?.path ?? basePath;
      }

      // Melhoria 3: Verificação de diretório válido
      final String downloadsPath = '${basePath.split('Android').first}Download';
      dir = Directory(downloadsPath);

      // Melhoria 4: Tratamento de erro na criação
      try {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } catch (e) {
        throw Exception('Falha ao criar diretório: $e');
      }

      // Melhoria 5: Verificação final
      if (!await dir.exists()) {
        throw Exception('Diretório de Downloads não encontrado');
      }
    } else {
      dir = await syspaths.getApplicationDocumentsDirectory();
    }

    final fileName =
        "igeo_export_${DateTime.now().toIso8601String().replaceAll(RegExp(r'[^\d]'), '_')}.csv";
    final File file = File('${dir.path}/$fileName');

    await file.writeAsString(csvData);

    // iOS mantém o compartilhamento
    if (Platform.isIOS) {
      await Share.shareXFiles([XFile(file.path)], text: 'iGeo Export');
    }

    return file.path;
  }

  static Future<String?> downloadData() async {
    final db = await database();
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery(
          'SELECT p.long, p.lat, p.id, p.name, p.description, p.date, p.time, s.project_name '
          'FROM points AS p '
          'JOIN projects AS s ON p.project_id = s.id');

      if (result.isEmpty) return null;

      final csvData = [
        [
          "long",
          "lat",
          "id",
          "name",
          "description",
          "date",
          "time",
          "project_name"
        ],
        ...result.map((e) => [
              e["long"],
              e["lat"],
              e["id"],
              e["name"],
              e["description"],
              e["date"],
              e["time"],
              e["project_name"]
            ])
      ];

      return await generateCsv(csvData);
    } finally {
      await db.close();
    }
  }

  // static Future<dynamic> downloadData() async {
  //   final db = await DbUtils.database();

  //   final int dataLength = await db
  //       .rawQuery(
  //           'SELECT p.long, p.lat, p.id, p.name, p.description, p.date, p.time, s.project_name FROM points AS p JOIN projects AS s on p.project_id = s.id')
  //       .then((value) => value.length);

  //   if (dataLength == 0) {
  //     return;
  //   }

  //   List<List<dynamic>> listData = [
  //     [
  //       "long",
  //       "lat",
  //       "id",
  //       "name",
  //       "description",
  //       "date",
  //       "time",
  //       "project_name"
  //     ],
  //   ];
  //   await db
  //       .rawQuery(
  //           'SELECT p.long, p.lat, p.id, p.name, p.description, p.date, p.time, s.project_name FROM points AS p JOIN projects AS s on p.project_id = s.id')
  //       .then((value) {
  //     print("listdata");
  //     print(value);
  //     value.forEach((element) => listData.add([
  //           element["long"],
  //           element["lat"],
  //           element["id"],
  //           element["name"],
  //           element["description"],
  //           element["date"],
  //           element["time"],
  //           element["project_name"],
  //         ]));
  //     generateCsv(listData);
  //   });

  //   return db.rawQuery(
  //       'SELECT p.long, p.lat, p.id, p.name, p.description, p.date, p.time, s.project_name FROM points AS p JOIN projects AS s on p.project_id = s.id');
  // }

  static Future<void> deleteProject(int projectId) async {
    final db = await database();
    await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  static Future<void> deleteProjectPoints(int projectId) async {
    final db = await database();
    await db.delete(
      'points',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  static Future<void> deletePoint(int pointId) async {
    final db = await database();
    await db.delete(
      'points',
      where: 'id = ?',
      whereArgs: [pointId],
    );
  }

  static Future<int> updateAccept() async {
    final db = await DbUtils.database();

    Map<String, String> row = {
      'accept': 'true',
    };

    var result = await db.update(
      'accepts',
      row,
      where: 'id = ?',
      whereArgs: [1],
    );

    return result;
  }
}
