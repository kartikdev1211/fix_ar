import 'package:fix_ar/screens/home/bloc/home_event.dart';
import 'package:fix_ar/screens/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeCategoryChanged>(
      (e, emit) => emit(state.copyWith(selectedCategory: e.index)),
    );
    on<HomeNavChanged>((e, emit) => emit(state.copyWith(selectedNav: e.index)));
    on<HomeLoaded>(
      (e, emit) => emit(state.copyWith(isLoading: false)),
    ); // ← new
    _init();
  }
  void _init() async {
    await Future.delayed(const Duration(milliseconds: 1800)); // simulate fetch
    add(HomeLoaded());
  }
}
