import 'package:bloc/bloc.dart';
import 'package:jazz/features/lyrics_feature/domain/usecases/get_lyrics_usecase.dart';
import 'package:meta/meta.dart';

part 'lyrics_event.dart';
part 'lyrics_state.dart';

class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  final GetLyrics getLyrics;
  LyricsBloc({required this.getLyrics}) : super(LyricsInitial()) {
    on<GetLyricsEvent>((event, emit)async {
     var result = await getLyrics(event.artist,event.songName);
     result.fold(
         (failure)=> emit(NoLyricsState(failure: failure.message)),
         (lyrics)=> emit(GotLyricsState(lyrics: lyrics))
     );
    });
  }
}
