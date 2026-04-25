abstract class HomeEvent {}

class HomeLoaded extends HomeEvent {}

class HomeCategoryChanged extends HomeEvent {
  final int index;
  HomeCategoryChanged(this.index);
}

class HomeNavChanged extends HomeEvent {
  final int index;
  HomeNavChanged(this.index);
}
