import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:spotify/context_service.dart';
import 'package:spotify/feature/commons/contants/theme.dart';
import 'package:spotify/feature/blocs/download/download_cubit.dart';
import 'package:spotify/feature/blocs/home/home_bloc.dart';
import 'package:spotify/feature/blocs/main/main_bloc_cubit.dart';
import 'package:spotify/feature/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/blocs/search/search_bloc.dart';
import 'package:spotify/feature/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/blocs/watched/watched_cubit.dart';
import 'package:spotify/feature/presentation/screen/main/main_screen.dart';
import 'package:spotify/feature/presentation/screen/splash/splash_screen.dart';
import 'feature/commons/utility/pageutil.dart';
import 'feature/data/local/hive_manager.dart';
import 'feature/di/injection_container.dart';
import 'feature/di/injection_container.dart' as di;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await sl<HiveManager>().init();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  PageUtil.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    sl<HiveManager>().closeBox();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainBloc>(create: (context) => sl<MainBloc>()),
        BlocProvider<HomeBloc>(create: (context) => sl<HomeBloc>()),
        BlocProvider<MovieBloc>(create: (context) => sl<MovieBloc>()),
        BlocProvider<SearchBloc>(create: (context) => sl<SearchBloc>()),
        BlocProvider<WatchedCubit>(create: (context) => sl<WatchedCubit>()),
        BlocProvider<DownloadCubit>(create: (context) => sl<DownloadCubit>()),
        BlocProvider<SettingCubit>(create: (context) => sl<SettingCubit>()),
      ],
      child: Builder(
        builder: (context) {
          context.read<MainBloc>().initMain();

          return BlocConsumer<MainBloc, MainState>(
            listener: (context, state) {
            },
          builder: (context, state) {
              return MaterialApp(
                navigatorKey: sl<ContextService>().globalKey,
                debugShowCheckedModeBanner: false,
                theme: darkTheme,
                locale: state.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate, // Add this line
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                // list languages AppLocalizations auto generate
                home: const SplashScreen(),
              );
            },
          );
        }
      ),
    );
  }
}

