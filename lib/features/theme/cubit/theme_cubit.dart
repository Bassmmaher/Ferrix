import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_state.dart';



class ThemeCubit extends Cubit<ThemeState>{



  ThemeCubit()

      : super(

    ThemeState(

      isDark: false,

    ),

  );




  void changeTheme(){


    emit(

      ThemeState(

        isDark: !state.isDark,

      ),

    );


  }



}