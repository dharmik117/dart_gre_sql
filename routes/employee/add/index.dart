import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/employee_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = EmployeeHelper();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final body = await context.request.body();
  final data = jsonDecode(body) as Map<String, dynamic>;

  final name = data['name'] as String;
  final position = data['position'] as String;
  final salary = double.parse(data['salary'].toString());
  final department = data['department'].toString();

  final employee = await db.insertEmployee(
    name: name,
    position: position,
    salary: salary,
    department: department,
  );

  if (employee.containsKey('error')) {
    return Response.json(
      statusCode: 500,
      body: employee,
    );
  }

  return Response.json(
    body: {
      'message': 'Employee added successfully',
      'employee': employee,
    },
  );
}
