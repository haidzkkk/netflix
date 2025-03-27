import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/feature/blocs/home/home_bloc.dart';
import 'package:spotify/feature/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/overview_screen.dart';

void showToast(String content){
  Fluttertoast.showToast(
      msg: content,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white.withOpacity(0.1),
      textColor: Colors.white,
  );
}

void printData(String? content){
  // if (kDebugMode) {
    debugPrint("==========> $content");
  // }
}

double calculateHeightItemGirdView(BuildContext context, double height, int columnCount){
  double widgetItem = MediaQuery.of(context).size.width / columnCount;
  return widgetItem / height;
}

hasDomainUrl(String url){
  return url.contains("http://") || url.contains("https://");
}

Future<Color?> generateColorImageUrl(String url) async{
  String imageUrl = url;
  PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(imageUrl));

  if(paletteGenerator.vibrantColor != null){
    return paletteGenerator.vibrantColor!.color;
  }else if(paletteGenerator.dominantColor != null){
    return paletteGenerator.dominantColor!.color;
  }else if(paletteGenerator.mutedColor != null){
    return paletteGenerator.mutedColor!.color;
  }
  return Colors.transparent;
}

Future<String> getLocalPathVideo({required String movieName, required String episodeName}) async{
  Directory? directory;
  if (Platform.isAndroid){
    directory = Directory("${(await getExternalStorageDirectory())?.path}/download/$movieName");
  } else if (Platform.isIOS) {
    directory = await getDownloadsDirectory();
  }

  if (directory != null && !await directory.exists()) {
    await directory.create(recursive: true);
  }

return "${directory?.path ?? ""}/$episodeName.mp4";
}


extension NumExt on num {
  String format(){
    final NumberFormat formatter = NumberFormat('#,###');
    return formatter.format(this);
  }

  String get secondsToMinute {
    var minuteSeconds = this / 60;
    var minute = minuteSeconds.truncate();
    var second = ((double.parse(minuteSeconds.toStringAsFixed(2)) - minute) * 60).toInt();
    return "${minute.toString().padLeft(2, "0")}:${second.toString().padLeft(2, "0")}";
  }
}

extension BuildContextExt on BuildContext{
  void to(Widget screen){
    Navigator.push(this, MaterialPageRoute(builder: (context) => screen));
  }
  void toWithCupertino(Widget screen){
    Navigator.push(this, CupertinoPageRoute(builder: (context) => screen));
  }
  void back(){
    Navigator.pop(this);
  }
  void replace(Widget screen){
    Navigator.pushReplacement(this, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> showBottomSheet({
    required Widget child,
  }) async{
    showModalBottomSheet(
        context: this,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
            )
        ),
        builder: (context){
          return child;
        }
    );
  }

  Future<void> openOverviewScreen(MovieInfo movie) async{
    var movieBloc = read<MovieBloc>();
    if(movieBloc.state.currentMovie?.slug == movie.slug){
      movieBloc.add(ChangeExpandedMovieEvent(isExpand: true));
      return;
    }

    showDraggableBottomSheet(
        builder: (context, controller){
          return OverViewScreen(
            movie: movie,
            draggableScrollController: controller,
          );
        }
    );
  }

  static bool bottomSheetOpen = false;
  Future<void> showDraggableBottomSheet({
    required Widget Function(BuildContext context, ScrollController scrollController) builder
  }) async{
    if(bottomSheetOpen) back();

    bottomSheetOpen = true;
    await showModalBottomSheet(
        context: this,
        isScrollControlled: true,
        enableDrag: false,
        builder: (context){
          return NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.1 && bottomSheetOpen == true) {
                  context.back();
                  return true;
                }
                return false;
              },
              child: DraggableScrollableSheet(
                initialChildSize: 1,
                maxChildSize: 1,
                minChildSize: 0.0,
                snap: true,
                expand: false,
                builder: builder,
              )
          );
        }
    );
    bottomSheetOpen = false;
  }

  void showSnackBar(String content){
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    var snackBar = SnackBar(
      content: Text(content, style: Style.body.copyWith(color: Colors.white),),
      backgroundColor: ColorResources.secondaryColor,
    );

    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  void showSnackBarWidget({required Widget child, int? seconds, Color? backgroundColor}){
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    SnackBar snackBar = SnackBar(
      content: child,
      backgroundColor: backgroundColor ?? ColorResources.secondaryColor,
      duration: Duration(seconds: seconds ?? 2),
    );

    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}

extension IterableExt on Iterable{
  E? firstWhereOrNull<E>(bool Function(E element) check) {
    for (E element in this) {
      if (check(element)) return element;
    }
    return null;
  }
}
extension DateTimeExt on DateTime{
  bool isSameDay(DateTime? dateTime) {
    return year == dateTime?.year &&
        month == dateTime?.month &&
        day == dateTime?.day;
  }
}
