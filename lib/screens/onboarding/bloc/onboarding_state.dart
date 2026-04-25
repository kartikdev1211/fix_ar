class OnboardingState {
  final int currentPage;
  final bool isLastPage;
  final bool navigateToAuth;

  OnboardingState({
    required this.currentPage,
    required this.isLastPage,
    this.navigateToAuth = false,
  });

  factory OnboardingState.initial() =>
      OnboardingState(currentPage: 0, isLastPage: false);

  OnboardingState copyWith({
    int? currentPage,
    bool? isLastPage,
    bool? navigateToAuth,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
      navigateToAuth: navigateToAuth ?? this.navigateToAuth,
    );
  }
}
