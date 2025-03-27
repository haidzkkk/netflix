part of 'main_bloc_cubit.dart';

class MainState extends Equatable {
  bool? darkMode;
  Locale? locale;

  MainState({
    this.locale,
    this.darkMode,
  });

  MainState copyWith({
    bool? darkMode,
    Locale? locale
  }){
    return MainState(
        darkMode: darkMode ?? this.darkMode,
    );
  }

  MainState copyWithLocale(Locale? mLocale,){
    return MainState(locale: mLocale, darkMode: darkMode);
  }

  MainState copyWithDarkMode(bool mDarkMode,){
    return MainState(locale: locale, darkMode: mDarkMode);
  }


  @override
  List<Object?> get props => [locale, darkMode];
}
