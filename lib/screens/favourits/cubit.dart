import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/favourits/states.dart';

class Favouritecubit extends Cubit<FavouriteState> {
  Favouritecubit() : super(FavouriteInitialState());

  static Favouritecubit get(context) => BlocProvider.of(context);

  List<Item> favourites = [];
void toggleFavourite(Item item) async {
  final userDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  item.isfavourite = !item.isfavourite;

  if (item.isfavourite) {
    favourites.add(item);

    final favIds = favourites.map((i) => i.id).toList();
    await userDoc.set({'favourites': favIds}, SetOptions(merge: true));

    emit(FavouriteAddState());
  } else {
    favourites.removeWhere((i) => i.id == item.id);

    final favIds = favourites.map((i) => i.id).toList();
    await userDoc.set({'favourites': favIds}, SetOptions(merge: true));

    emit(FavouriteRemoveState());
  }
}



void loadFavourites() async {
  emit(FavouriteLoadingState());

  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final favIds = List<String>.from(userDoc.data()?['favourites'] ?? []);

    favourites.clear();

    for (String id in favIds) {
      // Search in all restaurants' items or a global 'items' collection
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('items')
          .where(FieldPath.documentId, isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final item = Item.fromJson(data);
        item.id = id; // manually set the ID
        item.isfavourite = true;
        favourites.add(item);
      }
    }

    emit(FavouriteLoadedState());
  } catch (e) {
    emit(FavouriteErrorState(e.toString()));
  }
}








}
