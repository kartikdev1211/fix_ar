import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final Map<String, dynamic>? data;

  const ProfileState({this.isLoading = false, this.data});

  ProfileState copyWith({bool? isLoading, Map<String, dynamic>? data}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [isLoading, data];
}
