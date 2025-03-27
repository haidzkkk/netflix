import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/utility/pageutil.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_better_player.dart';
import 'package:spotify/feature/presentation/screen/widget/process_indicator/custom_process.dart';

class PlayerMovieWidget extends StatefulWidget {
  const PlayerMovieWidget({
    super.key,
    required this.heightBottomNav,
    required this.heightMovieCollapse,
    required this.actionDispose,
    required this.heightProcess,
  });

  final double heightBottomNav;
  final double heightMovieCollapse;
  final double heightProcess;
  final Function() actionDispose;

  @override
  State<PlayerMovieWidget> createState() => _PlayerMovieWidgetState();
}

class _PlayerMovieWidgetState extends State<PlayerMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<MovieBloc, MovieState>(
            buildWhen: (previous, current) =>
                previous.isExpandWatchMovie != current.isExpandWatchMovie || previous.isPlay != current.isPlay,
            builder: (context, state) {
              viewModel.betterPlayerController?.setControlsEnabled(state.isExpandWatchMovie);
              return GestureDetector(
                onTap: state.isExpandWatchMovie
                    ? null
                    : () {
                        viewModel.add(ChangeExpandedMovieEvent(isExpand: true));
                      },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    AnimatedContainer(
                      height: state.isExpandWatchMovie ? PageUtil.screenWidth / 16 * 9 : widget.heightMovieCollapse,
                      width: state.isExpandWatchMovie ? PageUtil.screenWidth : widget.heightMovieCollapse / 9 * 21,
                      duration: const Duration(milliseconds: 200),
                      child: AspectRatio(
                        aspectRatio: state.isExpandWatchMovie ? 16 / 9 : 21 / 9,
                        child: viewModel.betterPlayerController != null
                            ? CustomBetterPlayer(
                                controller: viewModel.betterPlayerController!,
                              )
                            : const SizedBox(),
                      ),
                    ),
                    if (!state.isExpandWatchMovie)
                      Expanded(
                        child: Row(
                          children: [
                            const Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              flex: 13,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.currentMovie?.name ?? "",
                                    style: Style.title2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Tập ${state.currentEpisode?.getNumberName() ?? ""}",
                                    style: Style.body,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: IconButton(
                                  onPressed: () {
                                    if (viewModel.betterPlayerController?.isPlaying() == true) {
                                      viewModel.betterPlayerController?.pause();
                                    } else {
                                      viewModel.betterPlayerController?.play();
                                    }
                                  },
                                  icon: Icon(
                                    state.isPlay == true ? Icons.pause : Icons.play_arrow_rounded,
                                    size: 25.sp,
                                  )),
                            ),
                            Expanded(
                              flex: 4,
                              child: IconButton(
                                  onPressed: () => widget.actionDispose(),
                                  icon: Icon(
                                    Icons.clear,
                                    size: 25.sp,
                                  )),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              );
            }),
        BlocBuilder<MovieBloc, MovieState>(
            buildWhen: (previous, current) =>
                previous.visibleControlsPlayer != current.visibleControlsPlayer ||
                previous.totalTimeEpisode != current.totalTimeEpisode ||
                previous.currentTimeEpisode != current.currentTimeEpisode,
            builder: (context, state) {
              var process = (state.currentTimeEpisode ?? 0.0) / (state.totalTimeEpisode ?? 0.0);
              if (process.isNaN || process.isInfinite || process < 0 || process > 1) {
                process = 0;
              }

              return CustomProcessIndicator(
                width: MediaQuery.of(context).size.width,
                height: widget.heightProcess,
                indicatorSize: widget.heightProcess * 3,
                color: viewModel.state.currentMovie?.color,
                process: process,
                enable: state.visibleControlsPlayer,
                margin: const EdgeInsets.only(bottom: 15),
                onMoved: (value) {
                  viewModel.betterPlayerController
                      ?.seekTo(Duration(seconds: ((state.totalTimeEpisode ?? 0).toDouble() * value).toInt()));
                },
              );
            }),
      ],
    );
  }
}
