import 'package:bloc/bloc.dart';
import 'package:fix_ar/screens/auth/bloc/auth_event.dart';
import 'package:fix_ar/screens/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent,AuthState> {
  AuthBloc():super(AuthState.initial()){
    on<ToggleAuthMode>((event,emit){
      emit(state.copyWith(
        isLogin: !state.isLogin,
        isSuccess: false,
        error: null,
      ));
    });
    on<LoginRequested>((event,emit)async{
      if(event.email.isEmpty||event.password.isEmpty){
        emit(state.copyWith(error: "Fill all the fields"));
        return;
      }
      emit(state.copyWith(isLoading: true,isSuccess: false, error: null));
      await Future.delayed(Duration(seconds: 2));
      emit(state.copyWith(isLoading: false,isSuccess: true));
    });
    on<SignUpRequested>((event,emit)async{
      if(event.name.isEmpty){
        emit(state.copyWith(error:"Enter name"));
        return;
      }
      if (event.password != event.confirmPassword) {
        emit(state.copyWith(error: "Passwords do not match"));
        return;
      }

      emit(state.copyWith(isLoading: true, isSuccess: false, error: null));

      await Future.delayed(Duration(seconds: 2));

      emit(state.copyWith(isLoading: false,isSuccess: true));
    });
  }
}