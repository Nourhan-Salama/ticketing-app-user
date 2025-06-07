import 'package:final_app/cubits/statistics/statistics-state.dart';
import 'package:final_app/services/statistics-service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsService statisticsService;

  StatisticsCubit(this.statisticsService) : super(StatisticsInitial());

  Future<void> getStatistics() async {
    try {
      emit(StatisticsLoading());
      final stats = await statisticsService.getTechnicianStatistics();
      emit(StatisticsLoaded(stats));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }
}