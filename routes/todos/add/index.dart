import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method not allowed. Use POST.'},
    );
  }

  try {
    final body = await context.request.body();

    if (body.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Request body cannot be empty.', 'is_success': false},
      );
    }

    late Map<String, dynamic> data;
    try {
      data = jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid JSON format.', 'is_success': false},
      );
    }

    final text = data['text'];
    final userId = data['user_id'];
    final color = data['color'] ?? '#ffffff';

    if (text == null || text is! String || text.trim().isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Missing or invalid "text" field.',
          'is_success': false
        },
      );
    }

    if (userId == null || userId is! int) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Missing or invalid "user_id" field.',
          'is_success': false
        },
      );
    }

    final db = TodosHelper();

    try {
      final insert = await db.addTodo(
          text: text.trim(), id: userId, color: color.toString());
      return Response.json(
        statusCode: 201,
        body: {
          'message': 'Todo created successfully.',
          'data': insert,
          'is_success': true
        },
      );
    } catch (dbError) {
      // Don’t expose internal DB errors
      return Response.json(
        statusCode: 500,
        body: {
          'error': 'Failed to create todo.',
          'details': dbError.toString(),
          'is_success': false
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'Internal server error.',
        'details': e.toString(),
        'is_success': false
      },
    );
  }
}
