part of 'filter_bloc.dart';


abstract class FilterState extends Equatable {
  const FilterState();

  @override
  List<Object> get props => [];
}

class FilterInitial extends FilterState {}

class FilterInProgress extends FilterState {}

class FilterSuccess extends FilterState {
  final List<Item> filterResult;

  const FilterSuccess({@required this.filterResult}) : assert(filterResult != null);

  @override
  List<Object> get props => [filterResult];
}

class FilterFailure extends FilterState {}