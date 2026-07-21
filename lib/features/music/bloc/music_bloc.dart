import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/utils/base_model.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_songs_by_mood.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_daily_recommendation.dart';
import 'package:yellow_flowers/features/music/domain/usecases/play_song.dart';
import 'package:yellow_flowers/features/music/domain/usecases/pause_song.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_position_stream.dart';
import 'package:yellow_flowers/features/music/domain/entities/song_entity.dart'
    as domain;
import 'package:yellow_flowers/core/error_messages.dart';
import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';

class MusicBloc extends BaseModel {
  MusicBloc({
    required MusicRemoteRepository repository,
    GetSongsByMoodUseCase? getSongsByMoodUseCase,
    GetDailyRecommendationUseCase? getDailyRecommendationUseCase,
    PlaySongUseCase? playSongUseCase,
    PauseSongUseCase? pauseSongUseCase,
    GetPositionStreamUseCase? getPositionStreamUseCase,
  })  : _repository = repository,
        _getSongsByMood = getSongsByMoodUseCase,
        _getDailyRecommendation = getDailyRecommendationUseCase,
        _playSongUC = playSongUseCase,
        _pauseSongUC = pauseSongUseCase,
        _getPositionStreamUC = getPositionStreamUseCase {
    _init();
  }

  final MusicRemoteRepository _repository;
  final GetSongsByMoodUseCase? _getSongsByMood;
  final GetDailyRecommendationUseCase? _getDailyRecommendation;
  final PlaySongUseCase? _playSongUC;
  final PauseSongUseCase? _pauseSongUC;
  final GetPositionStreamUseCase? _getPositionStreamUC;
  // final GetCurrentPositionUseCase? _getCurrentPositionUC; // reserved for future incremental refactor

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
      if (_getSongsByMood != null) {
        final res =
            await _getSongsByMood.call(GetSongsByMoodParams(_selectedMood));
        res.when(
          success: (data) {
            _songs = data
                .map((e) => Song(
                      id: e.id,
                      title: e.title,
                      artist: e.artist,
                      audioUrl: e.audioUrl,
                      coverUrl: e.coverUrl,
                      duration: e.duration,
                      genre: e.genre,
                    ))
                .toList();
          },
          error: (f) {
            _songs = [];
            _errorMessage = friendlyErrorMessage(f.message);
          },
        );
      } else {
        _songs = await _repository.getSongsByMood(_selectedMood);
      }
      if (_getDailyRecommendation != null) {
        final rec = await _getDailyRecommendation
            .call(GetDailyRecommendationParams(_selectedMood));
        rec.when(
          success: (song) {
            _dailyRecommendation = song == null
                ? null
                : Song(
                    id: song.id,
                    title: song.title,
                    artist: song.artist,
                    audioUrl: song.audioUrl,
                    coverUrl: song.coverUrl,
                    duration: song.duration,
                    genre: song.genre,
                  );
          },
          error: (f) {
            _dailyRecommendation = null;
            _errorMessage = friendlyErrorMessage(f.message);
          },
        );
      } else {
        _dailyRecommendation =
            await _repository.getDailyRecommendation(_selectedMood);
      }
      _errorMessage = null;
    } catch (e) {
      _songs = [];
      _dailyRecommendation = null;
      _errorMessage = friendlyErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    try {
      final positionStream = _getPositionStreamUC != null
          ? (await _getPositionStreamUC(const NoParams())).when(
              success: (s) => s,
              error: (_) => null,
            )
          : await _repository.getPositionStream();
      if (positionStream != null) {
        positionStream.listen((position) {
          _position = position;
          notifyListeners();
        });
      }
    } catch (_) {
      // ignore position stream errors
    }
  }

  Future<void> playSong(Song song) async {
    _currentSong = song;
    if (_playSongUC != null) {
      final res = await _playSongUC.call(PlaySongParams(domain.SongEntity(
        id: song.id,
        title: song.title,
        artist: song.artist,
        audioUrl: song.audioUrl,
        coverUrl: song.coverUrl,
        duration: song.duration,
        genre: song.genre,
      )));
      if (res is Error) {
        _errorMessage = friendlyErrorMessage(res.failure.message);
        notifyListeners();
        return;
      }
    } else {
      await _repository.playSong(song);
    }
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pauseSong() async {
    if (_pauseSongUC != null) {
      await _pauseSongUC.call(const NoParams());
    } else {
      await _repository.pauseSong();
    }
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
      _errorMessage = friendlyErrorMessage(e);
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
      if (_getSongsByMood != null) {
        final res = await _getSongsByMood.call(GetSongsByMoodParams(mood));
        res.when(
          success: (data) {
            _songs = data
                .map((e) => Song(
                      id: e.id,
                      title: e.title,
                      artist: e.artist,
                      audioUrl: e.audioUrl,
                      coverUrl: e.coverUrl,
                      duration: e.duration,
                      genre: e.genre,
                    ))
                .toList();
          },
          error: (f) {
            _songs = [];
            _errorMessage = friendlyErrorMessage(f.message);
          },
        );
      } else {
        _songs = await _repository.getSongsByMood(mood);
      }
      if (_getDailyRecommendation != null) {
        final rec = await _getDailyRecommendation
            .call(GetDailyRecommendationParams(mood));
        rec.when(
          success: (song) {
            _dailyRecommendation = song == null
                ? null
                : Song(
                    id: song.id,
                    title: song.title,
                    artist: song.artist,
                    audioUrl: song.audioUrl,
                    coverUrl: song.coverUrl,
                    duration: song.duration,
                    genre: song.genre,
                  );
          },
          error: (f) {
            _dailyRecommendation = null;
            _errorMessage = friendlyErrorMessage(f.message);
          },
        );
      } else {
        _dailyRecommendation = await _repository.getDailyRecommendation(mood);
      }
      _errorMessage ??= null;
    } catch (e) {
      _songs = [];
      _dailyRecommendation = null;
      _errorMessage = friendlyErrorMessage(e);
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

  Future<void> seekTo(Duration position) async {
    try {
      await _repository.seekTo(position);
    } catch (_) {}
  }

  Future<void> skipNext() async {
    if (_songs.isEmpty) return;
    if (_currentSong == null) {
      await playSong(_songs.first);
      return;
    }
    final idx = _songs.indexWhere((s) => s.id == _currentSong!.id);
    final next =
        idx >= 0 && idx < _songs.length - 1 ? _songs[idx + 1] : _songs.first;
    await playSong(next);
  }

  Future<void> skipPrevious() async {
    if (_songs.isEmpty) return;
    if (_currentSong == null) {
      await playSong(_songs.last);
      return;
    }
    final idx = _songs.indexWhere((s) => s.id == _currentSong!.id);
    final prev = idx > 0 ? _songs[idx - 1] : _songs.last;
    await playSong(prev);
  }
}
