import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app/mindcare_app.dart';
import 'core/config/api_config.dart';
import 'features/chat/data/chat_api_data_source.dart';
import 'features/chat/data/chat_repository_impl.dart';

void main() {
  final httpClient = http.Client();
  final dataSource = ChatApiDataSource(
    client: httpClient,
    baseUri: ApiConfig.baseUri,
  );

  runApp(MindCareApp(chatRepository: ChatRepositoryImpl(dataSource)));
}
