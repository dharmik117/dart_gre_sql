import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  // Allow only POST requests
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method Not Allowed', 'method': context.request.method},
    );
  }

  try {
    final db = TodosHelper();

    // Try to read the request body safely
    final body = await context.request.body();

    if (body.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Request body cannot be empty'},
      );
    }

    // Decode JSON safely
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid JSON structure'},
      );
    }

    final data = decoded;

    // Validate required fields
    if (!data.containsKey('id')) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required field: id'},
      );
    }

    final idValue = data['id'];
    if (idValue is! int) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid type for id (expected int)'},
      );
    }

    // Attempt to delete the todo
    final result = await db.deleteTodo(id: idValue);

    if (result.isNotEmpty) {
      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Todo deleted successfully',
          'id': idValue,
          'method': context.request.method.toString()
        },
      );
    } else {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Todo not found'},
      );
    }
  } catch (e, stack) {
    // Log for debugging in dev environments
    print('Error in delete_todo: $e\n$stack');

    // Return a safe error for production
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error'},
    );
  }
}
