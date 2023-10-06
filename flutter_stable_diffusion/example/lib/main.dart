import 'package:dio/dio.dart';
import 'package:flutter_stable_diffusion_example/src/app.dart';

import 'src/services/logging.dart';
import 'src/services/model_service.dart';
import 'src/services/model_stroage_service.dart';

void main() {
  var builder = AppBuilder();
  builder.addSingleton((serviceProvider) => ModelService());
  builder.addSingleton((serviceProvider) => ModelStroageService(), initializeWhenServiceProviderBuilt: true);
  builder.addSingleton((serviceProvider) => Logging());
  builder.addSingleton((serviceProvider) => Dio());
  var app = builder.buildApp();
  app.run();
}
