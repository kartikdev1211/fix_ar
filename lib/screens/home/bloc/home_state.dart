class HomeState {
  final int selectedCategory;
  final int selectedNav;
  final bool isLoading;
  const HomeState({
    this.selectedCategory = 0,
    this.selectedNav = 0,
    this.isLoading = true,
  });
  HomeState copyWith({
    int? selectedCategory,
    int? selectedNav,
    bool? isLoading,
  }) => HomeState(
    selectedCategory: selectedCategory ?? this.selectedCategory,
    selectedNav: selectedNav ?? this.selectedNav,
    isLoading: isLoading ?? this.isLoading,
  );
}
