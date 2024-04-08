import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:the_movie_db/model/movie_model.dart';
import 'package:the_movie_db/repositories/movie_repository.dart';
import 'package:the_movie_db/services/http_manager.dart';

final apiKey = dotenv.env['API_KEY'];
final apiToken = dotenv.env['API_TOKEN'];

class MovieRepositoryImpl extends MovieRepository {
  final HttpManager httpManager;

  MovieRepositoryImpl({required this.httpManager});

  @override
  Future<bool> addRating(String id, double rate) async {
    final url = 'https://api.themoviedb.org/3/movie/$id/rating';
    final headers = {
      'Authorization': 'Bearer $apiToken',
    };

    // Estamos realizando um POST informando o VERBO, os HEADERS e o BODY
    var response = await httpManager.sendRequest(
      url: url,
      method: HttpMethod.post,
      headers: headers,
      body: {'value': rate},
    );

    return response.containsKey('success') ? response['success'] : false;
  }

  @override
  Future<List<MovieModel>> getUpcoming() async {
    final url =
        'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey&language=pt-BR&page=1';

    List<MovieModel> movies = [];

    // Neste trecho disparamos uma requisição GET à url definida acima.
    var response = await httpManager.sendRequest(
      url: url,
      method: HttpMethod.get,
    );

    if (response.containsKey('results')) {
      /** Neste trecho os Iterables do Dart possuem o metodo map.
      * O map nos possibilita iterar uma lista mapear cada elemento para um novo tipo ou manipulação.
      * EM nosso caso, a cada mapeamento, convertemos um JSON de entrada em um objeto do tipo MovieModel a partir do construtor nomeado MovieModel.fromJson() 
      */
      movies = response['results']
          .map<MovieModel>((m) => MovieModel.fromJson(m))
          .toList();
    }

    return movies;
  }
}
