import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/feature/presentation/screen/home_screen/widget/action_button.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_bottom.dart';
import 'package:spotify/feature/presentation/screen/widget/trailer_widget.dart';
import 'package:spotify/gen/assets.gen.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key, required this.movie});

  final MovieInfo? movie;

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.002, 0.3, 0.4],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: TrailerWidget(
                // url: "https://www.youtube.com/watch?v=_OKAwz2MsJs",
                trailerUrl: "",
                thumbnail: widget.movie?.posterUrl ?? "",
              ),
            ),
          ),
          Positioned.fill(

            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Container(
                color: Colors.black
              ),
            ),
          ),
          Positioned(
            top: 20.h,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Assets.img.iconNetflix.image(width: 30, height: 30)
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Tv shows", style: Style.title2,),
                      Text("Movie", style: Style.title2,),
                      Text("My list", style: Style.title2,),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15.h,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("#1 in Anime Today", style: TextStyle(fontSize: 18.sp),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                        icon: Icon(FontAwesomeIcons.plus, size: 25.sp,),
                        title: Text("My list", style: Style.body,),
                        onTap: (){

                        }
                    ),
                    CustomButton(
                      backgroundColor: Colors.white,
                      margin: EdgeInsets.zero,
                      height: 30,
                      wrapWidth: true,
                      borderRadius: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.play, color: Colors.black, size: 23.sp,),
                          const SizedBox(width: 5,),
                          Text("Play", style: Style.title2.copyWith(color: Colors.black),)
                        ],
                      ),
                      onPressed: (){
                        if(widget.movie != null){
                          context.openOverviewScreen(widget.movie!);
                        }else{
                          context.showSnackBar("Không tìm thấy phim");
                        }
                      },
                    ),
                    ActionButton(
                        icon: Icon(Icons.error_outline, size: 25.sp,),
                        title: Text("Info", style: Style.body),
                        onTap: (){

                        }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
