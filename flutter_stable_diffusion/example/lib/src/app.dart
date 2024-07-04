import 'package:flutter/material.dart';
import 'package:flutter_mvc/flutter_mvc.dart';

import 'pages/index/controller.dart';

class AppBuilder extends ServiceCollection {
  App buildApp() {
    addSingleton((serviceProvider) => App._());
    WidgetsFlutterBinding.ensureInitialized();
    var serviceProvider = build();
    return serviceProvider.get<App>();
  }
}

class App with DependencyInjectionService {
  App._();

  void run() {
    runApp(
      MvcApp(
        serviceProvider: serviceProvider,
        child: MaterialApp(
          home: Mvc(create: () => IndexPageController()),
        ),
      ),
    );
  }
}
