// Shared barrel — core third-party packages and base classes used across all layers.
export 'package:equatable/equatable.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:fpdart/fpdart.dart' hide State;

export 'datasource/base_datasource.dart';
export 'domain/failures/failure.dart';
export 'domain/repository/base_repository.dart';
export 'domain/usecases/pagination_params.dart';
export 'domain/usecases/usecase.dart';
export 'presentation/mixins/usecase_executer_mixin.dart';
export 'presentation/pagination/pagination_cubit.dart';
export 'presentation/pagination/pagination_state.dart';
