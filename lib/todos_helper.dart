import 'package:dartgre_sql/db_helper.dart';
import 'package:postgres/postgres.dart';

class TodosHelper {
  factory TodosHelper() => _instance;

  TodosHelper._internal();

  static final TodosHelper _instance = TodosHelper._internal();

  Future<Connection> get _db async => DatabaseHelper().connection;

  Future<List<dynamic>> getAllTodos() async {
    final connection = await _db;

    final result = await connection.execute('''Select * from todos''');

    if (result.isEmpty) {
      return [];
    } else {
      return result.map((element) => element.toColumnMap()).toList();
    }
  }

  Future<List<dynamic>> getTodoById({required int userId}) async {
    final connection = await _db;

    final result = await connection.execute(
        Sql.named('''Select * from todos where user_id = @user_id'''),
        parameters: {'user_id': userId});

    if (result.isEmpty) {
      return [];
    } else {
      return result.map((element) => element.toColumnMap()).toList();
    }
  }

  Future<Map<String, dynamic>> addTodo(
      {required String text, required int id}) async {
    final connection = await _db;

    try {
      final result = await connection.execute(
        Sql.named(
          'INSERT INTO todos (text,user_id) VALUES (@text,@user_id) RETURNING *',
        ),
        parameters: {'text': text, 'user_id': id},
      );

      if (result.isEmpty) {
        return {'error': 'Failed to insert todo'};
      }

      return result.first.toColumnMap();
    } catch (e, s) {
      print('❌ Error inserting todo: $e');
      print(s);
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateTodo(
      {required String text, required int id, bool? isLiked}) async {
    final connection = await _db;

    try {
      final result = await connection.execute(
        Sql.named(
          'Update todos Set text = @text, is_liked = @is_liked where id = @id  RETURNING *',
        ),
        parameters: {'text': text, 'id': id, 'is_liked': isLiked},
      );

      if (result.isEmpty) {
        return {'error': 'Failed to update todo'};
      }

      return result.first.toColumnMap();
    } catch (e, s) {
      print('❌ Error updateing todo: $e');
      print(s);
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteTodo({required int id}) async {
    final connection = await _db;

    final result = await connection.execute(
      Sql.named('''Delete from todos where id =@id returning * '''),
      parameters: {'id': id},
    );

    try {
      if (result.isEmpty) {
        return {'error': 'Todo not found'};
      } else {
        return result.first.toColumnMap();
      }
    } catch (e, s) {
      print(e.toString());
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> likeUnlikeTodo(
      {required int id, bool? isLiked}) async {
    final connection = await _db;

    try {
      final result = await connection.execute(
        Sql.named(
          'Update todos Set is_liked = @is_liked where id = @id  RETURNING *',
        ),
        parameters: {'id': id, 'is_liked': isLiked},
      );

      if (result.isEmpty) {
        return {'error': 'Failed to update todo'};
      }

      return result.first.toColumnMap();
    } catch (e, s) {
      print('❌ Error updating todo: $e');
      print(s);
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteTable({required String tableName}) async {
    final connection = await _db;

    try {
      final result = await connection.execute(
        Sql.named(
          'DROP TABLE IF EXISTS $tableName',
        ),
      );

      if (result.isEmpty) {
        return {'error': 'Failed delete table'};
      }

      return result.first.toColumnMap();
    } catch (e, s) {
      print('❌ Error delete table: $e');
      print(s);
      return {'error': e.toString()};
    }
  }
}
