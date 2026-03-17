import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music DB Exercise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 245, 245, 245),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Music DB'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Song {
  final int id;
  final String name;
  final String artist;
  final String genre;
  final String coverURL;
  bool favorite;

  Song({
    required this.id,
    required this.name,
    required this.artist,
    required this.genre,
    required this.coverURL,
    required this.favorite,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      name: json['name'],
      artist: json['artist'],
      genre: json['genre'],
      coverURL: json['coverURL'],
      favorite: json['favorite'],
    );
  }

  String getTitleString() {
    return "$name - $artist";
  }

  void switchFavorite() {
    favorite = !favorite;
  }
}

List<Song> getSongsOfGenre(List<Song> songs, String genre) {
  if (genre == "All") return songs;

  List<Song> result = [];
  for (var song in songs) {
    if (song.genre.toLowerCase() == genre.toLowerCase() ||
        (song.favorite && genre == "Favorites")) {
      result.add(song);
    }
  }
  return result;
}

List<Song> getFilteredSearchSongs(List<Song> songs, String search) {
  if (search.isEmpty) return songs;

  List<Song> result = [];
  for (var song in songs) {
    if (song.getTitleString().toUpperCase().contains(search.toUpperCase())) {
      result.add(song);
    }
  }
  return result;
}

Future<void> toggleFavorite(Song song) async {
  final url = Uri.parse("http://0.0.0.0:3000/songs/${song.id}/favorite");
  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"favorite": song.favorite}),
  );
  if (response.statusCode == 200) {
    print("Updated: ${response.body}");
  } else {
    print("Error: ${response.statusCode}");
  }
}

class Styler {
  static Color getTextColor() => Colors.black;
  static Color getBackgroundColor() => Colors.white;
  static Color getTileSelectedColor() =>
      const Color.fromARGB(255, 215, 215, 215);
  static Color getAppbarBackgroundColor() =>
      const Color.fromARGB(255, 106, 49, 211);
}

class _MyHomePageState extends State<MyHomePage> {
  List<Song> _songs = [];
  bool _isLoading = true;
  Song? _selectedSong;
  List<String> opciones = [
    "Likes",
    "All",
    "Pop",
    "Rock",
    "Alternative",
    "Indie",
  ];
  String activeGenre = "All";
  List<Song> _genreSongs = [];
  List<Song> _visibleSongs = [];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/songs'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _songs = data.map((json) => Song.fromJson(json)).toList();
          _isLoading = false;
          _visibleSongs = _songs;
        });
      }
    } catch (e) {
      print("Error cargando canciones: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String searchString = "";
    return Scaffold(
      backgroundColor: Styler.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Styler.getAppbarBackgroundColor(),
        foregroundColor: Styler.getTextColor(),
        title: Text(widget.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              children: [
                Padding(padding: EdgeInsets.all(8.0)),
                Expanded(
                  child: ListView.builder(
                    itemCount: opciones.length,
                    itemBuilder: (context, indexGenre) {
                      return ListTile(
                        title: Text(opciones[indexGenre]),
                        onTap: () {
                          _visibleSongs = getSongsOfGenre(
                            _songs,
                            opciones[indexGenre],
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatefulBuilder(
                                builder: (context, setLocalState) {
                                  return Scaffold(
                                    appBar: AppBar(
                                      title: Text(opciones[indexGenre]),
                                    ),
                                    body: ListView.builder(
                                      itemCount: _visibleSongs.length,
                                      itemBuilder: (context, indexSong) {
                                        return ListTile(
                                          title: Text(
                                            _visibleSongs[indexSong]
                                                .getTitleString(),
                                          ),
                                          onTap: () {
                                            _selectedSong =
                                                _visibleSongs[indexSong];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => StatefulBuilder(
                                                  builder: (context, setLocalState2) {
                                                    return Scaffold(
                                                      appBar: AppBar(
                                                        title: Text(
                                                          _selectedSong!.name,
                                                        ),
                                                      ),
                                                      body: Center(
                                                        child: Column(
                                                          children: [
                                                            Image.network(
                                                              _selectedSong!
                                                                  .coverURL,
                                                              width: 300,
                                                              height: 300,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            Text(
                                                              _selectedSong!
                                                                  .name,
                                                              style: TextStyle(
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              _selectedSong!
                                                                  .artist,
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                setLocalState(
                                                                  () {},
                                                                );
                                                                setLocalState2(
                                                                  () {},
                                                                );
                                                                setState(() {
                                                                  _selectedSong!
                                                                      .switchFavorite();
                                                                  toggleFavorite(
                                                                    _selectedSong!,
                                                                  );
                                                                  _visibleSongs =
                                                                      getSongsOfGenre(
                                                                        _songs,
                                                                        opciones[indexGenre],
                                                                      );
                                                                });
                                                              },
                                                              child:
                                                                  _selectedSong!
                                                                      .favorite
                                                                  ? Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 50,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .star_border,
                                                                      size: 50,
                                                                    ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            decoration: InputDecoration(hintText: "Search..."),
                            onChanged: (value) {
                              setState(() {
                                searchString = value;
                                _genreSongs = getSongsOfGenre(
                                  _songs,
                                  activeGenre,
                                );
                                _visibleSongs = getFilteredSearchSongs(
                                  _genreSongs,
                                  searchString,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          child: DropdownButton(
                            value: activeGenre,
                            isExpanded: true,
                            items: opciones.map((opcion) {
                              return DropdownMenuItem(
                                value: opcion,
                                child: Text(opcion),
                              );
                            }).toList(),
                            onChanged: (nuevoValor) {
                              activeGenre = nuevoValor!;
                              _genreSongs = getSongsOfGenre(
                                _songs,
                                activeGenre,
                              );
                              setState(() {
                                _visibleSongs = getFilteredSearchSongs(
                                  _genreSongs,
                                  searchString,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: _visibleSongs.isEmpty
                                    ? 1
                                    : _visibleSongs.length,
                                itemBuilder: (context, index) {
                                  if (_visibleSongs.isNotEmpty) {
                                    return ListTile(
                                      title: Text(
                                        _visibleSongs[index].getTitleString(),
                                      ),
                                      selected:
                                          _selectedSong == _visibleSongs[index],
                                      onTap: () => setState(
                                        () => _selectedSong =
                                            _visibleSongs[index],
                                      ),
                                    );
                                  } else {
                                    return Center(child: Text("No results"));
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _selectedSong == null
                      ? Center(child: Text("Select a song."))
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                _selectedSong!.coverURL,
                                width: 400,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                _selectedSong!.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _selectedSong!.artist,
                                style: TextStyle(fontSize: 22),
                              ),
                              Text(
                                _selectedSong!.genre,
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedSong!.switchFavorite();
                                    toggleFavorite(_selectedSong!);
                                    _genreSongs = getSongsOfGenre(
                                      _songs,
                                      activeGenre,
                                    );
                                    _visibleSongs = getFilteredSearchSongs(
                                      _genreSongs,
                                      searchString,
                                    );
                                  });
                                },
                                child: _selectedSong!.favorite
                                    ? Icon(Icons.star, size: 50)
                                    : Icon(Icons.star_border, size: 50),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
