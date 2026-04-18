abstract class OnboardingEvent {}
class PageChanged extends OnboardingEvent{
  final int index;
  PageChanged(this.index);
}
class NextPressed extends OnboardingEvent{}
class SkipPressed extends OnboardingEvent{}
