import 'package:bloc/bloc.dart';
import 'package:fix_ar/screens/onboarding/bloc/onboarding_event.dart';
import 'package:fix_ar/screens/onboarding/bloc/onboarding_state.dart';
import 'package:fix_ar/screens/onboarding/onboarding_screen.dart';


class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingState.initial()) {
    on<PageChanged>((event, emit) {
      emit(
        state.copyWith(
          currentPage: event.index,
          isLastPage: event.index == onboardingSlides.length - 1,
          navigateToAuth: false,
        ),
      );
    });
    on<NextPressed>((event,emit){
      if(state.isLastPage){
        emit(state.copyWith(navigateToAuth: true));
      }else{
        emit(state.copyWith(navigateToAuth: false));
      }
    });
    on<SkipPressed>((event,emit){
      emit(state.copyWith(navigateToAuth: true));
    });
  }
}
