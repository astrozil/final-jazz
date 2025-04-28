import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class SearchUsersUseCase {
  final AuthRepository repository;
  SearchUsersUseCase(this.repository);

  Stream<List<AppUser>> call(String query)  {
    return repository.searchUsers(query);

  }
}