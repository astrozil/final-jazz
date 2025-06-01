import 'package:bloc/bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/usecases/fetch_artist.dart';
import 'package:jazz/features/search_feature/domain/usecases/fetch_artists_use_case.dart';
import 'package:meta/meta.dart';

part 'artist_event.dart';
part 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistFetchSuccess> {
  final FetchArtistUseCase _fetchArtistUseCase;
  final FetchArtistsUseCase _fetchArtistsUseCase;
  ArtistBloc({required FetchArtistUseCase fetchArtistUseCase,required FetchArtistsUseCase fetchArtistsUseCase}) :
        _fetchArtistUseCase = fetchArtistUseCase,
  _fetchArtistsUseCase = fetchArtistsUseCase,
        super(ArtistFetchSuccess(isLoading: false)) {
    on<FetchArtistEvent>((event, emit)async {
    emit(state.copyWith(isLoading: true));
      try{
     final artist = await _fetchArtistUseCase(event.artistId);

       emit(state.copyWith(artist: artist,isLoading: false));


      }catch(e){

      }
    });

    on<FetchArtistsEvent>((event, emit)async {
        emit(state.copyWith(isLoading: true));
      try{
        final artists = await _fetchArtistsUseCase(event.artistIdList);

          emit(state.copyWith(artists: artists,isLoading: false));

      }catch(e){

      }
    });
  }

}
