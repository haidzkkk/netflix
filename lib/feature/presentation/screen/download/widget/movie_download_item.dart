
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/date_converter.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';
import 'package:spotify/feature/blocs/download/download_cubit.dart';
import 'package:spotify/feature/blocs/download/download_state.dart';
import 'package:spotify/feature/presentation/screen/download/widget/movie_download_manager_widget.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_banner.dart';
import 'package:spotify/feature/presentation/screen/overview_movie/widget/chip_text.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_bottom.dart';
import 'package:spotify/feature/presentation/screen/widget/image_widget.dart';

import '../../../../commons/utility/style_util.dart';
import '../../overview_movie/overview_screen.dart';

class MovieDownloadItem extends StatefulWidget {
  const MovieDownloadItem({super.key, required this.movieLocal, this.showDate, this.animation});

  final MovieLocal movieLocal;
  final bool? showDate;
  final Animation<double>? animation;

  @override
  State<MovieDownloadItem> createState() => _MovieDownloadItemState();
}

class _MovieDownloadItemState extends State<MovieDownloadItem> {

  late DownloadCubit viewModel = context.read<DownloadCubit>();

  Widget animationWidget({required Widget child}){
    if(widget.animation != null){
      return SizeTransition(
        sizeFactor: widget.animation!,
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {

    return animationWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(widget.showDate == true)
            Text(
              DateConverter.dateStringToday(DateTime.fromMillisecondsSinceEpoch(widget.movieLocal.lastTime ?? 0)),
              style: Style.title2,
            ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              context.openOverviewScreen(widget.movieLocal.toMovieInfo());
            },
            onLongPress: (){
              selectEpisode();
            },
            child: Container(
              margin: const EdgeInsetsDirectional.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150.w,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadiusDirectional.all(Radius.circular(5)),
                    ),
                    child: Stack(
                      children: [
                        ImageWidget(
                          url: widget.movieLocal.poster ?? "",
                          fit: BoxFit.cover,
                        ),
                        Builder(
                          builder: (context) {
                            EpisodeDownload? item = widget.movieLocal.episodesDownload?.values.firstWhereOrNull((e) {
                              return e.status == StatusDownload.LOADING && e.executeProcess != null;
                            });
                            if(item == null) return const SizedBox();

                            return  Positioned.fill(child: Container(
                              color: Colors.white.withOpacity(0.5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.downloading, color: Colors.black),
                                  Text('${item.executeProcess ?? 0}%', style: Style.body.copyWith(color: Colors.black),),
                                ],
                              ),
                            ));
                          }
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.movieLocal.name ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Style.title2.copyWith(color: Colors.white),
                              ),
                            ),

                            PopupMenuButton(
                                offset: const Offset(-20, 50),
                                color: Colors.grey,
                                itemBuilder: (context){
                                  return [
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.delete_outline_outlined, color: Colors.black,),
                                          SizedBox(width: 5,),
                                          Text("Quản lý tải xuống", style: TextStyle(color: Colors.black),)
                                        ],
                                      ),
                                      onTap: () {
                                        selectEpisode();
                                        },
                                    ),
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.share, color: Colors.black,),
                                          SizedBox(width: 5,),
                                          Text("Chia sẻ", style: TextStyle(color: Colors.black),)
                                        ],
                                      ),
                                      onTap: () {

                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.black,),
                                          SizedBox(width: 5,),
                                          Text("Thông tin", style: TextStyle(color: Colors.black),)
                                        ],
                                      ),
                                      onTap: () {

                                      },
                                    ),
                                  ];
                                },
                                icon: Icon(Icons.more_vert, color: Colors.white, size: 20.sp,)
                            )
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Builder(
                          builder: (context) {
                            var items = <Widget>[];
                            var listData = widget.movieLocal.episodesDownload?.values.toList() ?? [];
                            for(int i = 0; i < listData.length; i++){
                              var item = listData[i];
                              if(i > 10){
                                items.add(const Padding(
                                  padding: EdgeInsetsDirectional.all(4),
                                  child: ChipText(child: Text("\t\t...\t\t")),
                                ));
                                break;
                              }
                              items.add(Padding(
                                padding: const EdgeInsetsDirectional.all(4),
                                child: ChipText(child: Text("${item.name} ${item.getStatus()}")),
                              ));
                            }

                            return Wrap(
                              children: items,
                            );
                          }
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  selectEpisode() async{
    await context.showBottomSheet(
        child: MovieDownloadManagerWidget(movieLocal: widget.movieLocal,)
    );
    viewModel.selectDeleteEpisodeDownload({}, refresh: true);
  }
}
