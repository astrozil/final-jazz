import 'package:bloc/bloc.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_album.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/track_thumbnail_bloc/track_thumbnail_bloc.dart';
import 'package:meta/meta.dart';

part 'album_event.dart';
part 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final SearchAlbumUseCase searchAlbumUseCase;
  final TrackThumbnailBloc trackThumbnailBloc;
  AlbumBloc({required this.searchAlbumUseCase,required this.trackThumbnailBloc}) : super(AlbumInitial()) {
    on<SearchAlbum>((event, emit)async{
    emit(AlbumInitial());
    final result =  await searchAlbumUseCase(event.albumId);
    result.fold(
        (failure)=> emit(AlbumError(failure: failure)),
        (album){
          emit(AlbumFound(album: album));

          trackThumbnailBloc.add(TrackThumbnailUpdateEvent(tracks: album.tracks));
        }
    );
    });
  }
}
