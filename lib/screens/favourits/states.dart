abstract class FavouriteState {}

class FavouriteInitialState extends FavouriteState {}

class FavouriteAddState extends FavouriteState {}

class FavouriteRemoveState extends FavouriteState {}

class FavouriteLoadingState extends FavouriteState {}

class FavouriteLoadedState extends FavouriteState {}

class FavouriteErrorState extends FavouriteState {
  final String error;
  FavouriteErrorState(this.error);
}
