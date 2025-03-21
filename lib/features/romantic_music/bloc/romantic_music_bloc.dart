import 'package:yellow_flowers/features/romantic_music/data/model/song.dart';
import 'package:yellow_flowers/features/romantic_music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class MusicBloc extends BaseModel {
  MusicBloc({required MusicRemoteRepository repository})
      : _repository = repository {
    _init();
  }

  final MusicRemoteRepository _repository;

  List<Song> _songs = [];
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  String _selectedGenre = 'pop';
  List<String> _genres = ['pop', 'rock', 'jazz'];
  bool _isLoading = true;

  List<Song> get songs => _songs
      .where((song) => _selectedGenre == 'All' || song.genre == _selectedGenre)
      .toList();
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  String get selectedGenre => _selectedGenre;
  List<String> get genres => _genres;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _songs = await _repository.getSongs(_selectedGenre);
    _isLoading = false;
    Stream<Duration> positionStream = await _repository.getPositionStream();
    positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    _currentSong = song;
    await _repository.playSong(song);
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pauseSong() async {
    await _repository.pauseSong();
    _isPlaying = false;
    notifyListeners();
  }

  void selectGenre(String genre) async {
    _isLoading = true;
    notifyListeners();
    _selectedGenre = genre;
    _songs = await _repository.getSongs(_selectedGenre);
    _isLoading = false;
    notifyListeners();
  }

  void selectSong(Song song) {
    _currentSong = song;
    notifyListeners();
  }
}
