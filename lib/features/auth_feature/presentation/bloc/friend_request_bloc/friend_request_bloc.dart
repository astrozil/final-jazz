import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/auth_feature/data/models/friend_request_model.dart';
import 'package:jazz/features/auth_feature/domain/entities/friend_request.dart';
import 'package:jazz/features/auth_feature/domain/use_case/friend_request_use_cases/accept_friend_request_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/friend_request_use_cases/cancel_sent_friend_request_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/friend_request_use_cases/get_received_request_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/friend_request_use_cases/get_sent_requests_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/friend_request_use_cases/reject_friend_request_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/friend_request_use_cases/send_friend_request_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/friend_request_use_cases/unfriend_use_case.dart';
import 'package:meta/meta.dart';

part 'friend_request_event.dart';
part 'friend_request_state.dart';

class FriendRequestBloc extends Bloc<FriendRequestEvent, FriendRequestState> {
  final SendFriendRequestUseCase _sendFriendRequest;
  final AcceptFriendRequestUseCase _acceptFriendRequest;
  final RejectFriendRequestUseCase _rejectFriendRequest;
  final CancelSentFriendRequestUseCase _cancelSentFriendRequestUseCase;
  final GetReceivedRequestUseCase _getReceivedFriendRequests;
  final GetSentRequestsUseCase _getSentFriendRequests;
  final UnfriendUseCase _unfriendUseCase;

  StreamSubscription? _receivedRequestsSubscription;
  StreamSubscription? _sentRequestsSubscription;
  StreamSubscription<List<FriendRequestModel>>? _allRequestsSubscription;



  FriendRequestBloc(
      this._sendFriendRequest,
      this._acceptFriendRequest,
      this._rejectFriendRequest,
      this._getReceivedFriendRequests,
      this._getSentFriendRequests,
      this._cancelSentFriendRequestUseCase,
      this._unfriendUseCase
      ) : super(FriendRequestInitial()) {
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<CancelSentFriendRequestEvent>(_onCanceledSentFriendRequest);
    on<RejectFriendRequestEvent>(_onRejectFriendRequest);
    on<GetReceivedFriendRequestsEvent>(_onGetReceivedFriendRequests);
    on<GetSentFriendRequestsEvent>(_onGetSentFriendRequests);
   on<UnfriendEvent>(_onUnfriend);
    on<GetAllRequestsEvent>(_onGetAllRequests);
    on<SetCurrentUserIdEvent>(_onSetCurrentUserId);
    on<_ReceivedFriendRequestsUpdated>(_onReceivedFriendRequestsUpdated);
    on<_SentFriendRequestsUpdated>(_onSentFriendRequestsUpdated);
    on<_FriendRequestError>(_onFriendRequestError);
    on<_AllRequestsUpdated>(_onAllFriendRequestsUpdated);
  }

  void _onSetCurrentUserId(
      SetCurrentUserIdEvent event,
      Emitter<FriendRequestState> emit,
      ) {

  }
  Future<void> _onGetAllRequests(GetAllRequestsEvent event,Emitter<FriendRequestState> emit)async{
    emit(FriendRequestLoading());

      _allRequestsSubscription?.cancel();
      _allRequestsSubscription = _getAllFriendRequests().listen(
          (requests)=> add(_AllRequestsUpdated(requests)),
        onError: (error)=> add(_FriendRequestError(error))
      );
    

  }
  
  Stream<List<FriendRequestModel>> _getAllFriendRequests(){
  return  FirebaseFirestore.instance.collection("friendRequests").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FriendRequestModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }
  Future<void> _onSendFriendRequest(
      SendFriendRequestEvent event,
      Emitter<FriendRequestState> emit,
      ) async {

    try {
      await _sendFriendRequest.execute(FirebaseAuth.instance.currentUser!.uid, event.receiverId);

    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }
  Future<void> _onCanceledSentFriendRequest(
      CancelSentFriendRequestEvent event,
      Emitter<FriendRequestState> emit,
      ) async {

    try {
      await _cancelSentFriendRequestUseCase.execute(event.requestId);

    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }
  Future<void> _onUnfriend(
      UnfriendEvent event,
      Emitter<FriendRequestState> emit
      )async{
    try{
      await _unfriendUseCase.execute(event.friendUserId, FirebaseAuth.instance.currentUser!.uid);
    }catch(e){
      emit(FriendRequestError(e.toString()));
    }
  }
  Future<void> _onAcceptFriendRequest(
      AcceptFriendRequestEvent event,
      Emitter<FriendRequestState> emit,
      ) async {

    try {
      await _acceptFriendRequest.execute(event.requestId, FirebaseAuth.instance.currentUser!.uid);

    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }



  Future<void> _onRejectFriendRequest(
      RejectFriendRequestEvent event,
      Emitter<FriendRequestState> emit,
      ) async {

    try {
      await _rejectFriendRequest.execute(event.requestId, FirebaseAuth.instance.currentUser!.uid);

    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }

  void _onGetReceivedFriendRequests(
      GetReceivedFriendRequestsEvent event,
      Emitter<FriendRequestState> emit,
      ) {

    _receivedRequestsSubscription?.cancel();
    _receivedRequestsSubscription = _getReceivedFriendRequests
        .execute(FirebaseAuth.instance.currentUser!.uid)
        .listen(
          (requests) => add(_ReceivedFriendRequestsUpdated(requests)),
      onError: (error) => add(_FriendRequestError(error.toString())),
    );
  }

  void _onGetSentFriendRequests(
      GetSentFriendRequestsEvent event,
      Emitter<FriendRequestState> emit,
      ) {

    _sentRequestsSubscription?.cancel();
    _sentRequestsSubscription = _getSentFriendRequests
        .execute(FirebaseAuth.instance.currentUser!.uid)
        .listen(
          (requests) => add(_SentFriendRequestsUpdated(requests)),
      onError: (error) => add(_FriendRequestError(error.toString())),
    );
  }

  void _onReceivedFriendRequestsUpdated(
      _ReceivedFriendRequestsUpdated event,
      Emitter<FriendRequestState> emit,
      ) {
    emit(ReceivedFriendRequestsLoaded(event.requests));
  }
  void _onAllFriendRequestsUpdated(
      _AllRequestsUpdated event,
      Emitter<FriendRequestState> emit,
      ) {
    emit(AllFriendRequestsLoaded(requests:event.requests));
  }


  void _onSentFriendRequestsUpdated(
      _SentFriendRequestsUpdated event,
      Emitter<FriendRequestState> emit,
      ) {
    emit(SentFriendRequestsLoaded(event.requests));
  }

  void _onFriendRequestError(
      _FriendRequestError event,
      Emitter<FriendRequestState> emit,
      ) {
    emit(FriendRequestError(event.message));
  }

  @override
  Future<void> close() {
    _receivedRequestsSubscription?.cancel();
    _sentRequestsSubscription?.cancel();
    return super.close();
  }
}