import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'current_song_widget_event.dart';
part 'current_song_widget_state.dart';

class CurrentSongWidgetBloc extends Bloc<CurrentSongWidgetEvent, CurrentSongWidgetState> {
  CurrentSongWidgetBloc() : super(CurrentSongWidgetCollapseState()) {
    on<CurrentSongWidgetCollapseEvent>((event, emit) {
      emit(CurrentSongWidgetCollapseState());
    });

    on<CurrentSongWidgetExpandEvent>((event,emit){
      emit(CurrentSongWidgetExpandState());
    });
  }
}
