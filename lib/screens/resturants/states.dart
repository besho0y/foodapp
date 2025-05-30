abstract class ResturantsStates {}

class ResturantsInitialState extends ResturantsStates {}

class RestaurantsFilteredState extends ResturantsStates {}

class RestuarantsGetDataSuccessState extends ResturantsStates {}

class RestuarantsLoadingState extends ResturantsStates {}

class RestuarantsErrorState extends ResturantsStates {
  final String error;
  RestuarantsErrorState(this.error);
}

// New category-related states
class CategoriesLoadedState extends ResturantsStates {}

class CategoryAddedState extends ResturantsStates {}

class CategoryDeletedState extends ResturantsStates {}
