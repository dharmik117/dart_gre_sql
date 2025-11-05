import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  // Allow only POST requests
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method Not Allowed'},
    );
  }

  try {
    final db = TodosHelper();

    // Read request body
    final body = await context.request.body();
    if (body.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Request body cannot be empty'},
      );
    }

    // Safely decode JSON
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid JSON format'},
      );
    }

    final data = decoded;

    // Validate required fields
    if (!data.containsKey('id') ||
        !data.containsKey('text') ||
        !data.containsKey('is_liked')) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields: id, text, is_liked'},
      );
    }

    // Type validation
    final idValue = data['id'];
    final textValue = data['text'];
    final isLikedValue = data['is_liked'];

    if (idValue is! int ||
        textValue is! String ||
        isLikedValue is! bool) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid data types: expected {id: int, text: String, is_liked: bool}'},
      );
    }

    // Perform update
    final result = await db.updateTodo(
      id: idValue,
      text: textValue,
      isLiked: isLikedValue,
    );

    if (result.isNotEmpty) {
      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Todo updated successfully',
          'updated': result,
        },
      );
    } else {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Todo not found'},
      );
    }
  } catch (e, stack) {
    print('Error in update_todo: $e\n$stack');
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error'},
    );
  }
}
