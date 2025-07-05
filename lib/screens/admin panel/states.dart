import 'package:foodapp/models/promocode.dart';

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

class EditingMenuCategoryState extends AdminPanelStates {}

class SuccessEditingMenuCategoryState extends AdminPanelStates {}

class ErrorEditingMenuCategoryState extends AdminPanelStates {
  final String error;
  ErrorEditingMenuCategoryState(this.error);
}

// Promocode states
class LoadingPromocodesState extends AdminPanelStates {}

class SuccessLoadingPromocodesState extends AdminPanelStates {
  final List<Promocode> promocodes;
  SuccessLoadingPromocodesState(this.promocodes);
}

class ErrorLoadingPromocodesState extends AdminPanelStates {
  final String error;
  ErrorLoadingPromocodesState(this.error);
}

class AddingPromocodeState extends AdminPanelStates {}

class SuccessAddingPromocodeState extends AdminPanelStates {}

class ErrorAddingPromocodeState extends AdminPanelStates {
  final String error;
  ErrorAddingPromocodeState(this.error);
}

class DeletingPromocodeState extends AdminPanelStates {}

class SuccessDeletingPromocodeState extends AdminPanelStates {}

class ErrorDeletingPromocodeState extends AdminPanelStates {
  final String error;
  ErrorDeletingPromocodeState(this.error);
}

// Banner states
class LoadingBannersState extends AdminPanelStates {}

class SuccessLoadingBannersState extends AdminPanelStates {}

class ErrorLoadingBannersState extends AdminPanelStates {
  final String error;
  ErrorLoadingBannersState(this.error);
}

class AddingBannerState extends AdminPanelStates {}

class SuccessAddingBannerState extends AdminPanelStates {}

class ErrorAddingBannerState extends AdminPanelStates {
  final String error;
  ErrorAddingBannerState(this.error);
}

class DeletingBannerState extends AdminPanelStates {}

class SuccessDeletingBannerState extends AdminPanelStates {}

class ErrorDeletingBannerState extends AdminPanelStates {
  final String error;
  ErrorDeletingBannerState(this.error);
}

// City states
class LoadingCitiesState extends AdminPanelStates {}

class SuccessLoadingCitiesState extends AdminPanelStates {}

class ErrorLoadingCitiesState extends AdminPanelStates {
  final String error;
  ErrorLoadingCitiesState(this.error);
}

class AddingCityState extends AdminPanelStates {}

class SuccessAddingCityState extends AdminPanelStates {}

class ErrorAddingCityState extends AdminPanelStates {
  final String error;
  ErrorAddingCityState(this.error);
}

class DeletingCityState extends AdminPanelStates {}

class SuccessDeletingCityState extends AdminPanelStates {}

class ErrorDeletingCityState extends AdminPanelStates {
  final String error;
  ErrorDeletingCityState(this.error);
}

// Area states
class LoadingAreasState extends AdminPanelStates {}

class SuccessLoadingAreasState extends AdminPanelStates {}

class ErrorLoadingAreasState extends AdminPanelStates {
  final String error;
  ErrorLoadingAreasState(this.error);
}

class AddingAreaState extends AdminPanelStates {}

class SuccessAddingAreaState extends AdminPanelStates {}

class ErrorAddingAreaState extends AdminPanelStates {
  final String error;
  ErrorAddingAreaState(this.error);
}

class DeletingAreaState extends AdminPanelStates {}

class SuccessDeletingAreaState extends AdminPanelStates {}

class ErrorDeletingAreaState extends AdminPanelStates {
  final String error;
  ErrorDeletingAreaState(this.error);
}
