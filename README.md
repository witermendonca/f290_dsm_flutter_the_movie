# f290_dsm_aula_05_abril_24

# The MovieDB

Nesta atividade iremo iniciar o consumo da API `TheMovieDB`. 

## Parte I - UI

Nesta parte iremos criar a Interface Gráfica do App utilizando o `FutureBuilder` para a construção das telas, é uma alternativa nativa para construção assincrona de componentes de UI.

> Antes de iniciar, inclua as dependencias abaixo.

```dart
flutter pub add dio provider json_annotation flutter_dotenv
```

```dart
dart pub add --dev json_serializable build_runner 
```

1. Crie a classe `/lib/App.dart` e inclua o trecho abaixo.

```dart
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
```

2. No diretório `/lib/pages` crie o arquivo `home_page.dart` com o código abaixo.

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      /** 
      * O FutureBuilder é um widget que constroi elemento de UI com base em uma requisição assincrona.
      * A propriedade future faz com que o widget consiga monitorar o andamento da requisição
      */
      body: FutureBuilder(
        future: null, //TODO: Criar providers na Parte II. è neste ponto que executaremos uma requisição à API TheMovieDB.
        builder: (context, snapshot) {
          /** O método builder rebebe como argumento o snapshot(uma imagem instantanea) do estado atual da requisição.
          * Atraves dele, podemos analidar o status da conexão e o status dos dados recebidos.
          * Com base nestes status podemos decidir o que vamos exibir na UI; o FutureBuilder controla todo o fluxo.
          */
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CircularProgressIndicator(),
              ),
            );
          }

          //Aqui coletamos os dados após a conclusão da requisição
          var data = snapshot.data;

          // Caso não haja dados, exibimos um Widget customizado.
          if (data?.isEmpty ?? true) {
            return const Center(
              child: Card(
                  child: Padding(
                padding: EdgeInsets.all(17.0),
                child: Text(
                  'Preencha o arquivo .env na raiz do projeto com a API_KEY e TOKEN para que as requisições possam e ser autenticadas corretamente, assim voce poderá consultar sua avaliações de favoritos posteriormente.',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              )),
            );
          }

        //Neste trecho já temos os dados com a conclusão da requisição
        //Neste trecho iremos estruturar uma visualização em forma de Grid para exibir os cartazes dos filmes.
          return GridView.builder(
              itemCount: data?.length ?? 0,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 4,
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                //Este Widget faz com que uma imagem de fundo seja exibidao durante o carregamento, ela estará np diretório assets neste repositório
                return FadeInImage(
                  fadeInCurve: Curves.bounceInOut,
                  fadeInDuration: const Duration(milliseconds: 500),
                  //O NetworkImage irá fazer uma requisição e baixar a imagem dos poster.
                  image: NetworkImage(data![index].getPostPathUrl()),
                  placeholder: const AssetImage('assets/images/logo.png'),
                );
              });
        },
      ),
    );
  }
}

```

## Parte II - Dados

Nests parte iremos criar as domain classes e os repositórios e serviços para gerenciar o consumo da API TheMovieDB.

### Classes de domínio

1. Crie o arquivo `/lib/model/movie_model.dart` e inclua o trecho abaixo. Desta vez não utilizaremos o `@frezzed`.

```dart
import 'package:json_annotation/json_annotation.dart';

// Inclua o part para gerar as classes de serialização e deserialização pelo build_runner
part 'movie_model.g.dart';

@JsonSerializable()
class MovieModel {
  int id = 0;
  bool? adult = false;
  @JsonKey(name: 'backdrop_path')
  String backdropPath = '';
  @JsonKey(name: 'original_language')
  String originalLanguage = '';
  @JsonKey(name: 'original_title')
  String originalTitle = '';
  String overview = '';
  double popularity = 0;
  @JsonKey(name: 'poster_path')
  String posterPath = '';
  @JsonKey(name: 'release_date')
  String releaseDate = '';
  String title = '';
  @JsonKey(name: 'vote_average')
  double voteAverage = 0;
  @JsonKey(name: 'vote_count')
  int voteCount = 0;
  MovieModel({
    required this.id,
    this.adult,
    required this.backdropPath,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.voteAverage,
    required this.voteCount,
  });

  String getPostPathUrl() {
    return 'http://image.tmdb.org/t/p/w500/$posterPath';
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

  @override
  String toString() {
    return 'MovieModel(id: $id, adult: $adult, backdropPath: $backdropPath, originalLanguage: $originalLanguage, originalTitle: $originalTitle, overview: $overview, popularity: $popularity, posterPath: $posterPath, releaseDate: $releaseDate, title: $title, voteAverage: $voteAverage, voteCount: $voteCount)';
  }
}

```

2. Execute o `build_runner`. 

```dart
flutter pub run build_runner build
```

### Gerenciador de Requisições

Vamos criar um gerenciador de requisições para simplificar o uso dos repositórios que serão criados na `Parte III`.

1. Crie o arquivo `/lib/services/http_manager` e inclua o trecho abaixo.

```dart
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class HttpManager {
  final Dio dio;

  HttpManager({required this.dio});

  /** No metodo abaixo, nós iremos ter uma unica forma de disparar as requisições, informando o método a ser executado, os cabeçalhos e o corpo das requisições; além de tratar as exceções.
  */
  Future<Map<String, dynamic>> sendRequest({
    required String url,
    required String method,
    Map? headers,
    Map? body,
  }) async {
    final defaulHeaders = headers?.cast<String, String>() ?? {};
    try {
      Response response = await dio.request(
        url,
        options: Options(method: method, headers: defaulHeaders),
        data: body,
      );

      return response.data;
    } on DioException catch (dioError) {
      log('''Falha ao processar requisição. 
        Tipo: $method. Endpoint: $url.''', error: dioError.message);
      return dioError.response?.data ?? {};
    } catch (error) {
      log('''Falha ao executar requisição. 
        Tipo: $method. Endpoint: $url.''', error: error.toString());
      return {};
    }
  }

  Map<String, dynamic> getSimpleAuthHeader(String user, String password) {
    return {
      'Authorization': 'Basic ${base64Encode(utf8.encode("$user:$password"))}'
    };
  }
}

abstract class HttpMethod {
  static const String get = 'GET';
  static const String post = 'POST';
  static const String delete = 'DELETE';
  static const String patch = 'PATCH';
  static const String put = 'PUT';
}
```

### Repositórios

Agora que já temos uma calsse responsável por executar as requisições, vamos criar os repositórios que irão reduperar os dados dos filmes urilizando o HttpManager.

1. Crie o arquivo `/lib/repositories/movie_repository.dart` e inclu o código abaixo. Não esqueçãde ajustar o import do MovieModel com base na sua estrutura de pastas.

```dart
abstract class MovieRepository {
  Future<List<MovieModel>> getUpcoming();
  Future<bool> addRating(String id, double rate);
}

```

2. Cria a implementação do repositório em `/lib/repositories/movie_repository_impl.dart` incluindo o trecho abaixo. Os imports são por sua conta.

```dart
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

```

## Parte III - Integração

Agora iremo integrar as camadas de dados com a UI.

### Ajustando o MAIN

Neste prjeto iremo utilizar o pacote `provider` para fazer a injeção de dependencia. Vamos disponibilizar o Dio, o HttpManagee e o MovieRepositoryImpl no escopo de gerencia de estado com o Provider.

1. Crie o arquivo `.env` na raiz do projeto.
2. Inclua as constantes abaixo para a autenticação com a API TheMovieDB.

```properties
API_KEY='PREENCHER API_KEY DE CADASTRO DO THE MOVIE DB'
API_TOKEN='PREENCHER API_TOKEN DE CADASTRO DO THE MOVIE DB'
```

3. Faça com que o App carrega esta informações na inicialização da aplicação alterando o metodo `main`.

```dart
void main() async {
  await dotenv.load(fileName: ".env");
  // Restante do código aqui...
}
```

4. Envolva o App() com o widget `MultiProvider()`, ele fará com que as dependencias estejam disponiveis em todos os nodes da aplicação.

```dart
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

```

5. Inclua a chamada do repositório de filmes no `FutureBuilder` da `HomePage`.

```dart
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        /**
        * Ao incluir o Provider, ou seja transforma o App() como filho de MultiProvider, toda nossa arvore de widgets tem acesso ao Dio, HttpManager e MovieRepositoryImpl.
        * 
        * Desta maneira, nós podemos acessar diretamente o contexto(escopo) e ler todos os providers.
        * 
        * Especificamente estamos acessando o MovieRepositoryImpl e executando a requisição getUpcoming.
        *
        * Esta requisição é assincrona e o FutureBuilder a trata. Quando ela concluir, nos recuperamos os dados, os convertemos e montamos nossa UI.
        */    
        future: context.read<MovieRepositoryImpl>().getUpcoming(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CircularProgressIndicator(),
              ),
            );
          }

          var data = snapshot.data;
          //Restante do código aqui...
        }
  }
```

### Teste o App

## Desafio Extra

Já temos o método que realiza o rate de um filme; o desafio será criar a tela para enviar o rating do filme.

#### Até a próxima aula.
