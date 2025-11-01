import 'package:dartgre_sql/db_helper.dart';
import 'package:postgres/postgres.dart';

class EmployeeHelper {
  factory EmployeeHelper() => _instance;

  EmployeeHelper._internal();

  static final EmployeeHelper _instance = EmployeeHelper._internal();

  Future<Connection> get _db async => await DatabaseHelper().connection;

  Future<List<Map<String, dynamic>>> getEmployeeList() async {
    final connection = await _db;

    final result = await connection.execute('SELECT * FROM employee');

    if (result.isEmpty) return [];

    return result.map((row) {
      return {
        'id': row[0],
        'name': row[1],
        'position': row[2],
        'department': row[3],
        'join_date': row[4]?.toString(),
        'salary': row[5],
      };
    }).toList();
  }

  Future<Map<String, dynamic>> insertEmployee({
    required String name,
    required String position,
    required String department,
    required double salary,
  }) async {
    try {
      final connection = await _db;

      final result = await connection.execute(
        Sql.named(
          'INSERT INTO employee (name, position, department, salary, join_date) '
          'VALUES (@name, @position, @department, @salary, NOW()) '
          'RETURNING name, position, department, salary, join_date',
        ),
        parameters: {
          'name': name,
          'position': position,
          'department': department,
          'salary': salary,
        },
      );

      final row = result.first.toColumnMap();

      return {
        'name': row['name'],
        'position': row['position'],
        'department': row['department'],
        'salary': row['salary'],
        'join_date': row['join_date'].toString(),
      };
    } catch (e) {
      print('❌ Database error: $e');
      return {'error': 'Failed to add employee', 'details': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteEmployeeById(int id) async {
    try {
      final connection = await _db;

      final result = await connection.execute(
        Sql.named('DELETE FROM employee WHERE employee_id = @employee_id'),
        parameters: {'employee_id': id},
      );

      if (result.affectedRows > 0) {
        return {
          'success': true,
          'message': 'Employee deleted successfully',
          'deleted_id': id,
        };
      } else {
        return {
          'success': false,
          'message': 'Employee not found',
        };
      }
    } catch (e) {
      print('❌ Database error while deleting: $e');
      return {
        'success': false,
        'error': 'Failed to delete employee',
        'details': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>?> updateEmployee({
    required int id,
    String? name,
    String? position,
    String? department,
    double? salary,
  }) async {
    final connection = await _db;

    final result = await connection.execute(
      Sql.named('''
        UPDATE employee 
        SET 
          name = COALESCE(@name, name),
          position = COALESCE(@position, position),
          department = COALESCE(@department, department),
          salary = COALESCE(@salary, salary)
          WHERE employee_id = @employee_id
          RETURNING employee_id, name, position, department, salary;
      '''),
      parameters: {
        'employee_id': id,
        'name': name,
        'position': position,
        'department': department,
        'salary': salary,
      },
    );

    return result.isEmpty ? null : result.first.toColumnMap();
  }
}
