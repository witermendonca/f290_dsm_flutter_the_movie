import 'package:the_movie_db/model/movie_model.dart';

abstract class MovieRepository {
  Future<List<MovieModel>> getUpcoming();
  Future<bool> addRating(String id, double rate);
}
