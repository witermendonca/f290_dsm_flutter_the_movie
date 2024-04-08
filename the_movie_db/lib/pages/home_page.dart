import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/repositories/movie_repository_impl.dart';

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
      body: FutureBuilder(
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
                  placeholder: const AssetImage('images/logo.png'),
                );
              });
        },
      ),
    );
  }
}
