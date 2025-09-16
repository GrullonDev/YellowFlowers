import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/utils/base_model.dart';
import 'package:yellow_flowers/data/music_service/jamendo_service.dart';

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
  String _selectedGenre = 'All';
  Mood _selectedMood = Mood.relaxed;
  final List<String> _genres = [
    'All',
    'pop',
    'rock',
    'jazz',
    'classical',
    'electronic',
    'hip-hop',
    'r&b',
    'reggae',
    'latin',
    'blues',
    'country',
    'folk',
    'metal',
    'indie',
    'soul',
    'funk',
    'disco',
    'ambient',
    'reggaeton',
    'salsa',
    'merengue',
    'bachata',
    'romantic',
    'instrumental',
    'lofi',
    'dance',
    'house',
    'techno',
    'trap',
    'alternative',
  ];
  bool _isLoading = true;
  Song? _dailyRecommendation;
  String? _errorMessage;

  List<Song> get songs {
    final g = _selectedGenre.toLowerCase();
    if (g == 'all') return List.unmodifiable(_songs);
    return _songs
        .where((song) => (song.genre).toLowerCase().contains(g))
        .toList();
  }
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  String get selectedGenre => _selectedGenre;
  List<String> get genres => _genres;
  bool get isLoading => _isLoading;
  Mood get selectedMood => _selectedMood;
  Song? get dailyRecommendation => _dailyRecommendation;
  String? get errorMessage => _errorMessage;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Initial load by mood instead of genre
      _songs = await _repository.getSongsByMood(_selectedMood);
      _dailyRecommendation = await _repository.getDailyRecommendation(_selectedMood);
      _errorMessage = null;
    } catch (e) {
      _songs = [];
      _dailyRecommendation = null;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    try {
      final positionStream = await _repository.getPositionStream();
      positionStream.listen((position) {
        _position = position;
        notifyListeners();
      });
    } catch (_) {
      // ignore position stream errors
    }
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
    _selectedGenre = genre;
    if (genre.toLowerCase() == 'all') {
      // Keep current mood-based list and just update the filter
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _songs = await _repository.getSongs(_selectedGenre);
      _errorMessage = null;
    } catch (e) {
      // keep existing list on failure
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectMood(Mood mood) async {
    _isLoading = true;
    notifyListeners();
    _selectedMood = mood;
    // Reset genre filter to All when changing mood to avoid over-filtering
    _selectedGenre = 'All';
    try {
      _songs = await _repository.getSongsByMood(mood);
      _dailyRecommendation = await _repository.getDailyRecommendation(mood);
      _errorMessage = null;
    } catch (e) {
      _songs = [];
      _dailyRecommendation = null;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await selectMood(_selectedMood);
  }

  void selectSong(Song song) {
    _currentSong = song;
    notifyListeners();
  }
}
