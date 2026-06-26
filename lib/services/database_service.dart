import 'package:get/get.dart';
import 'package:cineflow_app/models/movie_model.dart';
import 'package:cineflow_app/models/tv_show_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cineflow_app/models/person_model.dart';

class DatabaseService extends GetxService {
  static Database? _database;

  @override
  void onInit() {
    super.onInit();
    // Veritabanını hemen başlat - lazy loading yerine
    // ignore: unawaited_futures
    database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'movies.db');
      // ignore: avoid_print
      print('Database path: $path');

      return await openDatabase(
        path,
        version: 5,
        onCreate: (db, version) async {
          // ignore: avoid_print
          print('Creating database tables...');
          // Movies table
          await db.execute('''
            CREATE TABLE favorites (
              id INTEGER PRIMARY KEY,
              title TEXT,
              overview TEXT,
              posterPath TEXT,
              releaseDate TEXT,
              type TEXT DEFAULT 'movie'
            )
          ''');
          
          // TV Shows table
          await db.execute('''
            CREATE TABLE favorite_tv_shows (
              id INTEGER PRIMARY KEY,
              name TEXT,
              overview TEXT,
              posterPath TEXT,
              firstAirDate TEXT,
              type TEXT DEFAULT 'tv'
            )
          ''');
          // Actors table
          await db.execute('''
            CREATE TABLE favorite_actors (
              id INTEGER PRIMARY KEY,
              name TEXT,
              profilePath TEXT
            )
          ''');
          // Watch History table
          await db.execute('''
            CREATE TABLE watch_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              itemId INTEGER NOT NULL,
              itemType TEXT NOT NULL,
              title TEXT NOT NULL,
              posterPath TEXT,
              progress REAL DEFAULT 0.0,
              lastWatchedAt INTEGER NOT NULL,
              status TEXT DEFAULT 'watching',
              UNIQUE(itemId, itemType)
            )
          ''');
          // ignore: avoid_print
          print('Database tables created successfully');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // ignore: avoid_print
          print('Upgrading database from version $oldVersion to $newVersion');
          if (oldVersion < 2) {
            // Add type column to existing favorites table
            try {
              await db.execute('ALTER TABLE favorites ADD COLUMN type TEXT DEFAULT "movie"');
            } catch (e) {
              // ignore: avoid_print
              print('Column type may already exist: $e');
            }
            
            // Create TV shows table
            await db.execute('''
              CREATE TABLE IF NOT EXISTS favorite_tv_shows (
                id INTEGER PRIMARY KEY,
                name TEXT,
                overview TEXT,
                posterPath TEXT,
                type TEXT DEFAULT 'tv'
              )
            ''');
          }
          if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS favorite_actors (
                id INTEGER PRIMARY KEY,
                name TEXT,
                profilePath TEXT
              )
            ''');
          }
          if (oldVersion < 4) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS watch_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                itemId INTEGER NOT NULL,
                itemType TEXT NOT NULL,
                title TEXT NOT NULL,
                posterPath TEXT,
                progress REAL DEFAULT 0.0,
                lastWatchedAt INTEGER NOT NULL,
                status TEXT DEFAULT 'watching',
                UNIQUE(itemId, itemType)
              )
            ''');
          }
          if (oldVersion < 5) {
            try {
              await db.execute(
                  'ALTER TABLE favorites ADD COLUMN releaseDate TEXT');
            } catch (e) {
              // ignore: avoid_print
              print('releaseDate column may already exist: $e');
            }
            try {
              await db.execute(
                  'ALTER TABLE favorite_tv_shows ADD COLUMN firstAirDate TEXT');
            } catch (e) {
              // ignore: avoid_print
              print('firstAirDate column may already exist: $e');
            }
          }
          // ignore: avoid_print
          print('Database upgrade completed');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing database: $e');
      rethrow;
    }
  }

  // Movie methods
  Future<void> addFavorite(Movie movie) async {
    try {
      final db = await database;
      await db.insert(
        'favorites',
        movie.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // ignore: avoid_print
      print('Movie ${movie.id} added to favorites');
    } catch (e) {
      // ignore: avoid_print
      print('Error adding movie to favorites: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Movie>> getFavorites() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('favorites', where: 'type = ?', whereArgs: ['movie']);
      // ignore: avoid_print
      print('Found ${maps.length} favorite movies in database');

      return List.generate(maps.length, (i) {
        return Movie.fromMap(maps[i]);
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error getting favorite movies: $e');
      return [];
    }
  }

  Future<List<Movie>> getFavoriteMovies() async {
    return await getFavorites();
  }

  Future<bool> isFavorite(int id) async {
    final db = await database;
    final maps = await db.query('favorites', where: 'id = ? AND type = ?', whereArgs: [id, 'movie']);
    return maps.isNotEmpty;
  }

  Future<void> toggleFavoriteMovie(Movie movie) async {
    if (await isFavorite(movie.id)) {
      await removeFavorite(movie.id);
    } else {
      await addFavorite(movie);
    }
  }

  // TV Show methods
  Future<void> addFavoriteTvShow(TvShow tvShow) async {
    try {
      final db = await database;
      await db.insert(
        'favorite_tv_shows',
        tvShow.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // ignore: avoid_print
      print('TV Show ${tvShow.id} added to favorites');
    } catch (e) {
      // ignore: avoid_print
      print('Error adding TV show to favorites: $e');
      rethrow;
    }
  }

  Future<void> removeFavoriteTvShow(int id) async {
    final db = await database;
    await db.delete('favorite_tv_shows', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TvShow>> getFavoriteTvShows() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('favorite_tv_shows');
      // ignore: avoid_print
      print('Found ${maps.length} favorite TV shows in database');

      return List.generate(maps.length, (i) {
        return TvShow.fromMap(maps[i]);
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error getting favorite TV shows: $e');
      return [];
    }
  }

  Future<bool> isFavoriteTvShow(int id) async {
    final db = await database;
    final maps = await db.query('favorite_tv_shows', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }

  Future<void> toggleFavoriteTvShow(TvShow tvShow) async {
    if (await isFavoriteTvShow(tvShow.id)) {
      await removeFavoriteTvShow(tvShow.id);
    } else {
      await addFavoriteTvShow(tvShow);
    }
  }

  Future<void> clearFavoriteTvShows() async {
    final db = await database;
    await db.delete('favorite_tv_shows');
  }

  Future<void> clearAllFavorites() async {
    final db = await database;
    await db.delete('favorites');
    await db.delete('favorite_tv_shows');
    await db.delete('favorite_actors');
  }

  // Actor methods
  Future<void> addFavoriteActor(Person person) async {
    final db = await database;
    await db.insert(
      'favorite_actors',
      {
        'id': person.id,
        'name': person.name,
        'profilePath': person.profilePath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavoriteActor(int id) async {
    final db = await database;
    await db.delete('favorite_actors', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Person>> getFavoriteActors() async {
    final db = await database;
    final maps = await db.query('favorite_actors');
    return maps.map((m) => Person(
      id: m['id'] as int,
      name: (m['name'] as String?) ?? 'Unknown',
      profilePath: m['profilePath'] as String?,
      biography: null,
      knownForDepartment: null,
      birthday: null,
      placeOfBirth: null,
      popularity: null,
      gender: null,
    )).toList();
  }

  Future<bool> isFavoriteActor(int id) async {
    final db = await database;
    final maps = await db.query('favorite_actors', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }

  Future<void> toggleFavoriteActor(Person person) async {
    if (await isFavoriteActor(person.id)) {
      await removeFavoriteActor(person.id);
    } else {
      await addFavoriteActor(person);
    }
  }

  // Watch History methods
  Future<void> addToWatchHistory({
    required int itemId,
    required String itemType,
    required String title,
    String? posterPath,
    double progress = 0.0,
    String status = 'watching',
  }) async {
    try {
      final db = await database;
      await db.insert(
        'watch_history',
        {
          'itemId': itemId,
          'itemType': itemType,
          'title': title,
          'posterPath': posterPath,
          'progress': progress,
          'lastWatchedAt': DateTime.now().millisecondsSinceEpoch,
          'status': status,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // ignore: avoid_print
      print('Added $itemType $itemId to watch history');
    } catch (e) {
      // ignore: avoid_print
      print('Error adding to watch history: $e');
      rethrow;
    }
  }

  Future<void> updateWatchProgress({
    required int itemId,
    required String itemType,
    required double progress,
    String? status,
  }) async {
    try {
      final db = await database;
      final updates = <String, dynamic>{
        'progress': progress,
        'lastWatchedAt': DateTime.now().millisecondsSinceEpoch,
      };
      if (status != null) {
        updates['status'] = status;
      }
      
      await db.update(
        'watch_history',
        updates,
        where: 'itemId = ? AND itemType = ?',
        whereArgs: [itemId, itemType],
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error updating watch progress: $e');
    }
  }

  Future<void> removeFromWatchHistory(int itemId, String itemType) async {
    final db = await database;
    await db.delete(
      'watch_history',
      where: 'itemId = ? AND itemType = ?',
      whereArgs: [itemId, itemType],
    );
  }

  Future<List<Map<String, dynamic>>> getWatchHistory({
    String? itemType,
    int limit = 100,
  }) async {
    try {
      final db = await database;
      final where = itemType != null ? 'itemType = ?' : null;
      final whereArgs = itemType != null ? [itemType] : null;
      
      final maps = await db.query(
        'watch_history',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'lastWatchedAt DESC',
        limit: limit,
      );
      
      return maps;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting watch history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getWatchProgress(int itemId, String itemType) async {
    try {
      final db = await database;
      final maps = await db.query(
        'watch_history',
        where: 'itemId = ? AND itemType = ?',
        whereArgs: [itemId, itemType],
        limit: 1,
      );
      
      return maps.isNotEmpty ? maps.first : null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting watch progress: $e');
      return null;
    }
  }

  Future<int> getWatchHistoryCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM watch_history');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting watch history count: $e');
      return 0;
    }
  }
}
