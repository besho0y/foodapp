abstract class AdminPanelStates {}

class AdminPanelInitialState extends AdminPanelStates {}

// Restaurant states
class LoadingRestaurantsState extends AdminPanelStates {}

class SuccessLoadingRestaurantsState extends AdminPanelStates {}

class ErrorLoadingRestaurantsState extends AdminPanelStates {
  final String error;
  ErrorLoadingRestaurantsState(this.error);
}

class AddingRestaurantState extends AdminPanelStates {}

class SuccessAddingRestaurantState extends AdminPanelStates {}

class ErrorAddingRestaurantState extends AdminPanelStates {
  final String error;
  ErrorAddingRestaurantState(this.error);
}

class DeletingRestaurantState extends AdminPanelStates {}

class SuccessDeletingRestaurantState extends AdminPanelStates {}

class ErrorDeletingRestaurantState extends AdminPanelStates {
  final String error;
  ErrorDeletingRestaurantState(this.error);
}

// Item states
class AddingItemState extends AdminPanelStates {}

class SuccessAddingItemState extends AdminPanelStates {}

class ErrorAddingItemState extends AdminPanelStates {
  final String error;
  ErrorAddingItemState(this.error);
}

class DeletingItemState extends AdminPanelStates {}

class SuccessDeletingItemState extends AdminPanelStates {}

class ErrorDeletingItemState extends AdminPanelStates {
  final String error;
  ErrorDeletingItemState(this.error);
}

// Category states
class AddingCategoryState extends AdminPanelStates {}

class SuccessAddingCategoryState extends AdminPanelStates {}

class ErrorAddingCategoryState extends AdminPanelStates {
  final String error;
  ErrorAddingCategoryState(this.error);
}

class DeletingCategoryState extends AdminPanelStates {}

class SuccessDeletingCategoryState extends AdminPanelStates {}

class ErrorDeletingCategoryState extends AdminPanelStates {
  final String error;
  ErrorDeletingCategoryState(this.error);
}

class ImageUploadingState extends AdminPanelStates {}

class SuccessImageUploadingState extends AdminPanelStates {
  final String imageUrl;
  SuccessImageUploadingState(this.imageUrl);
}

class ErrorImageUploadingState extends AdminPanelStates {
  final String error;
  ErrorImageUploadingState(this.error);
}

// Menu Category states
class AddingMenuCategoryState extends AdminPanelStates {}

class SuccessAddingMenuCategoryState extends AdminPanelStates {}

class ErrorAddingMenuCategoryState extends AdminPanelStates {
  final String error;
  ErrorAddingMenuCategoryState(this.error);
}

class DeletingMenuCategoryState extends AdminPanelStates {}

class SuccessDeletingMenuCategoryState extends AdminPanelStates {}

class ErrorDeletingMenuCategoryState extends AdminPanelStates {
  final String error;
  ErrorDeletingMenuCategoryState(this.error);
}
