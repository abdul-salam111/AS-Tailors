import 'package:flutter_template/core/shared/domain/failures/failure.dart';
import 'package:flutter_template/core/shared/presentation/pagination/pagination_cubit.dart';
import 'package:flutter_template/core/shared/presentation/pagination/pagination_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('PaginationCubit', () {
    test('fetchFirstPage emits loading then success with items', () async {
      final cubit = PaginationCubit<int>(
        pageSize: 2,
        fetchPage: (page) async => const Right([1, 2]),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<PaginationState<int>>(
            (s) => s.status == PaginationStatus.loadingFirstPage,
          ),
          predicate<PaginationState<int>>(
            (s) =>
                s.status == PaginationStatus.success &&
                s.items.length == 2 &&
                s.page == 1 &&
                // Returned exactly pageSize items, so more may exist.
                !s.hasReachedMax,
          ),
        ]),
      );

      await cubit.fetchFirstPage();
      await expectation;

      await cubit.close();
    });

    test('fetchNextPage appends items and sets hasReachedMax when a short page returns', () async {
      var callCount = 0;
      final cubit = PaginationCubit<int>(
        pageSize: 2,
        fetchPage: (page) async {
          callCount++;
          if (page == 1) return const Right([1, 2]);
          return const Right([3]); // shorter than pageSize -> last page
        },
      );

      await cubit.fetchFirstPage();
      await cubit.fetchNextPage();

      expect(callCount, 2);
      expect(cubit.state.items, [1, 2, 3]);
      expect(cubit.state.page, 2);
      expect(cubit.state.hasReachedMax, isTrue);

      await cubit.close();
    });

    test('fetchNextPage is a no-op once hasReachedMax is true', () async {
      var callCount = 0;
      final cubit = PaginationCubit<int>(
        pageSize: 2,
        fetchPage: (page) async {
          callCount++;
          return const Right([1]); // always short -> reaches max on page 1
        },
      );

      await cubit.fetchFirstPage();
      expect(cubit.state.hasReachedMax, isTrue);

      await cubit.fetchNextPage();
      expect(callCount, 1); // second call never happened

      await cubit.close();
    });

    test('a failure surfaces on state without clearing previously loaded items', () async {
      var callCount = 0;
      final cubit = PaginationCubit<int>(
        pageSize: 2,
        fetchPage: (page) async {
          callCount++;
          if (callCount == 1) return const Right([1, 2]);
          return const Left(ServerFailure('boom'));
        },
      );

      await cubit.fetchFirstPage();
      await cubit.fetchNextPage();

      expect(cubit.state.status, PaginationStatus.failure);
      expect(cubit.state.failure, isA<ServerFailure>());
      expect(cubit.state.items, [1, 2]); // untouched

      await cubit.close();
    });
  });
}
