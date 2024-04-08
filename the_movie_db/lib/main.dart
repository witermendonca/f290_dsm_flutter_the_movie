import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/pages/home_page.dart';
import 'package:the_movie_db/repositories/movie_repository_impl.dart';
import 'package:the_movie_db/services/http_manager.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(
    providers: [
      Provider(create: (context) => Dio()),
      Provider(create: (context) => HttpManager(dio: context.read())),
      Provider(
          create: (context) => MovieRepositoryImpl(httpManager: context.read()))
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lançamentos',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromRGBO(3, 37, 65, 1.0),
        ),
        colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromRGBO(3, 37, 65, 1.0))
            .copyWith(
          onPrimaryContainer: Colors.white,
          primaryContainer: const Color.fromRGBO(27, 210, 175, 1.0),
        ),
      ),
      home: const HomePage(title: 'TheMovieDB'),
    );
  }
}