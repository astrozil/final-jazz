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
     if(result != null && result.isNotEmpty){
       emit(GotLyricsState(syncedLyrics: result));
     }else{
       emit(NoLyricsState(failure: "No Lyrics"));
     }
    });
  }
}
