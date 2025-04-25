import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/favourits/states.dart';

class Favouritecubit extends Cubit<FavouriteState> {
  Favouritecubit() : super(FavouriteInitialState());

  static Favouritecubit get(context) => BlocProvider.of(context);

  List<Item> favourites = [];

  void toggleFavourite(Item item) {
    item.isfavourite = !item.isfavourite;

    if (item.isfavourite) {
      favourites.add(item);
      emit(FavouriteAddState());
    } else {
      favourites.removeWhere((i) => i.id == item.id);
      emit(FavouriteRemoveState());
    }
  }
}
