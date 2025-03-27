import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import '../../../commons/utility/style_util.dart';
import '../overview_movie/widget/chip_banner.dart';

class SlideWidget extends StatefulWidget {
  const SlideWidget({super.key, required this.movies, this.onTap});
  final List<MovieInfo> movies;
  final Function(MovieInfo movie)? onTap;

  @override
  State<SlideWidget> createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<SlideWidget> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: CarouselSlider.builder(
        itemCount: widget.movies.length,
        options: CarouselOptions(
            initialPage: 0,
            height: double.infinity,
            viewportFraction: 0.85,
            autoPlay: true,
            enableInfiniteScroll: false,
            autoPlayInterval: const Duration(seconds: 20),
            padEnds : false
        ),
        itemBuilder: (context, index, realIndex) {
          var item = widget.movies[index];
          return GestureDetector(
            onTap: (){
              if(widget.onTap != null) widget.onTap!(widget.movies[index]);
            },
            child: Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5), top: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(8, 20),
                        blurRadius: 24
                    )
                  ]
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      item.posterUrl ?? "",
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (context, object, stackTrace){
                        return const Center(child: CircularProgressIndicator(),);
                      },
                    ),
                  ),
                  if(item.episodeCurrent != null)
                    Positioned(
                        left: 5,
                        top: 5,
                        child: ChipBanner(
                          colors: const [
                            Colors.brown,
                            Colors.redAccent,
                          ],
                          child: Text(item.episodeCurrent!,
                            style: Style.body,
                          ),
                        )
                    ),
                  if(item.quality != null || item.lang != null)
                    Positioned(
                        right: 5,
                        top: 5,
                        child: ChipBanner(
                          colors: const [
                            Colors.purple,
                            Colors.pink,
                          ],
                          child: Text("${item.quality} ${item.lang}",
                              style: Style.body
                          ),
                        )
                    ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 20.h,
                        color: Colors.black.withOpacity(0.8),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(item.name ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14,),)
                            ),
                            const SizedBox(width: 5,),
                            const Text("Xem ngay", style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      )
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
