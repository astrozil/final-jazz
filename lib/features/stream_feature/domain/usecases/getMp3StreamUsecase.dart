
import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/stream_feature/domain/entities/mp3Stream.dart';
import 'package:jazz/features/stream_feature/domain/repositories/streamRepository.dart';

class GetMp3StreamUseCase {
  final StreamRepository repository;

  GetMp3StreamUseCase(this.repository);

  Future<Either<Failure,Mp3Stream?>> call(String videoId,String videoUrl) async {
   try{
     final result = await repository.getMp3Stream(videoId,videoUrl);
     return Right(result);
   }catch(e){
     return Left(ServerFailure("Sever Failure"));
   }
  }
}
