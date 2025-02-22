import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/usecases/search.dart';
import 'package:meta/meta.dart';


part 'song_event.dart';
part 'song_state.dart';


class SongBloc extends Bloc<SongEvent, SongState> {
  final Search search;

  SongBloc(this.search) : super(SongInitial()){
    on<SearchForSongs>(_searchForSongs);
  }
Future<void> _searchForSongs(
    SongEvent event,Emitter<SongState> emit
    )async{
 if(event is SearchForSongs){

   emit (SongLoading());
   final failureOrSongs = await search(event.query);
    failureOrSongs.fold(
         (failure) => emit(SongError("${failure.message}")),
         (songs) => emit(SongLoaded(songs!.cast<Song>())),
   );
 }
}


}
