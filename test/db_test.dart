import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlcool/sqlcool.dart';

void main() async {
  final directory = await Directory.systemTemp.createTemp();

  const MethodChannel channel = MethodChannel('com.tekartik.sqflite');
  final List<MethodCall> log = <MethodCall>[];
  String response;
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    //print("METHOD CALL: $methodCall");
    log.add(methodCall);
    switch (methodCall.method) {
      case "getDatabasesPath":
        return directory.path;
        break;
      case "insert":
        return 1;
        break;
      case "update":
        return 1;
        break;
      case "query":
        // count query
        if (methodCall.arguments["sql"] ==
            "SELECT COUNT(id) FROM test WHERE id=1") {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"count": 1}
          ];
          return res;
        }
        // exists query
        else if (methodCall.arguments["sql"] ==
            "SELECT COUNT(*) FROM test WHERE id=1") {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"count": 1}
          ];
          return res;
        } else {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"k": "v"}
          ];
          return res;
        }
    }
    return response;
  });

  tearDown(() {
    log.clear();
  });

  final db = Db();

  group("init", () {
    test("Init db", () async {
      final String schema = """CREATE TABLE item
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
    )""";
      final q = <String>[
        schema,
        'INSERT INTO item(name) values("Name 1")',
        'INSERT INTO item(name) values("Name 2")',
        'INSERT INTO item(name) values("Name 3")',
      ];

      await db.init(
          path: "testdb.sqlite", absolutePath: true, queries: q, verbose: true);
      expect(db.isReady, true);
      return true;
    });

    test("Insert", () async {
      Future<int> insert() async {
        final res =
            await db.insert(table: "test", row: {"k": "v"}, verbose: true);
        return res;
      }

      return insert().then((int r) => expect(r, 1));
    });

    test("Delete", () async {
      Future<int> delete() async {
        final res =
            await db.delete(table: "test", where: "id=1", verbose: true);
        return res;
      }

      return delete().then((int r) => expect(r, 1));
    });

    test("Update", () async {
      Future<int> update() async {
        final res = await db.update(
            table: "test", where: "id=1", row: {"k": "v"}, verbose: true);
        return res;
      }

      return update().then((int r) => expect(r, 1));
    });

    test("Upsert", () async {
      Future<Null> upsert() async {
        final Null res =
            await db.upsert(table: "test", row: {"k": "v"}, verbose: true);
        return res;
      }

      return upsert().then((r) => expect(r, null));
    });

    test("Select", () async {
      Future<List<Map<String, dynamic>>> select() async {
        final res =
            await db.select(table: "test", where: "id=1", verbose: true);
        return res;
      }

      final output = <Map<String, dynamic>>[
        <String, dynamic>{"k": "v"}
      ];
      return select().then((List<Map<String, dynamic>> r) => expect(r, output));
    });

    test("Join", () async {
      Future<List<Map<String, dynamic>>> join() async {
        final res = await db.join(
            table: "test",
            joinOn: "table1.id=1",
            joinTable: "table1",
            where: "id=1",
            verbose: true);
        return res;
      }

      final output = <Map<String, dynamic>>[
        <String, dynamic>{"k": "v"}
      ];
      return join().then((List<Map<String, dynamic>> r) => expect(r, output));
    });

    test("Query", () async {
      Future<List<Map<String, dynamic>>> query() async {
        final res = await db.query("SELECT * from test_table");
        return res;
      }

      final output = <Map<String, dynamic>>[
        <String, dynamic>{"k": "v"}
      ];
      return query().then((List<Map<String, dynamic>> r) => expect(r, output));
    });

    test("Count", () async {
      Future<int> count() async {
        final res = await db.count(table: "test", where: "id=1", verbose: true);
        return res;
      }

      return count().then((int r) => expect(r, 1));
    });

    test("Exists", () async {
      Future<bool> exists() async {
        final res =
            await db.exists(table: "test", where: "id=1", verbose: true);
        return res;
      }

      return exists().then((bool r) => expect(r, true));
    });
  });
}
