import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/employee_helper.dart';

final db = EmployeeHelper();

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method not allowed'},
    );
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    if (body['employee_id'] == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'employee_id is required'},
      );
    }

    final updatedEmployee = await db.updateEmployee(
      id: body['employee_id'] as int,
      name: body['name'].toString(),
      position: body['position'].toString(),
      department: body['department'].toString(),
      salary: (body['salary'] as num?)?.toDouble(),
    );

    if (updatedEmployee == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Employee not found'},
      );
    }

    return Response.json(
      body: {
        'message': 'Employee updated successfully',
        'employee': updatedEmployee,
      },
    );
  } catch (e, s) {
    print(e.toString());
    print(s.toString());

    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to update employee', 'details': e.toString()},
    );
  }
}
