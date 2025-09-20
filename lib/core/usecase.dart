import 'result.dart';

abstract class UseCase<Out, Params> {
  Future<Result<Out>> call(Params params);
}

class NoParams {
  const NoParams();
}
