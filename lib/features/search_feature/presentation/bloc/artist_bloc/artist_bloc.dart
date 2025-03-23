import 'package:bloc/bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/usecases/fetch_artist.dart';
import 'package:meta/meta.dart';

part 'artist_event.dart';
part 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final FetchArtistUseCase _fetchArtistUseCase;
  ArtistBloc({required FetchArtistUseCase fetchArtistUseCase}) :
        _fetchArtistUseCase = fetchArtistUseCase,
        super(ArtistInitial()) {
    on<FetchArtistEvent>((event, emit)async {
      emit(ArtistInitial());
      try{
     final artist = await _fetchArtistUseCase(event.artistId);
     emit(ArtistFetchSuccess(artist: artist));
      }catch(e){
        emit(ArtistFetchError(errorMessage: e.toString()));
      }
    });
  }
}
