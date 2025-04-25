import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/widgets/itemcard.dart';

class Favouritsscreen extends StatelessWidget {
  const Favouritsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = Favouritecubit.get(context);
    return BlocConsumer<Favouritecubit, FavouriteState>(
      
      listener: (context, state) {

      },
      builder: (context, state) {
        return cubit.favourites.isEmpty?Center(
                  child: Text(
                    "No Favourites Yet",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                
              )
        
        
:         Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return itemcard(context, true,cubit.favourites[index] );
            },
            itemCount:cubit.favourites.length,
          ),
        );
      },
    );
  }
}
