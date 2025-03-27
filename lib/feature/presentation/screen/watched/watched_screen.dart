import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:spotify/feature/commons/utility/size_extensions.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/blocs/watched/watched_cubit.dart';
import 'package:spotify/feature/blocs/watched/watched_state.dart';
import 'package:spotify/feature/presentation/screen/watched/widget/watched_item.dart';
import 'package:spotify/feature/presentation/screen/widget/custom_refresh.dart';
import '../search/widget/search_text_field.dart';

class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key});

  @override
  State<WatchedScreen> createState() => _WatchedScreenState();
}

class _WatchedScreenState extends State<WatchedScreen> with AutomaticKeepAliveClientMixin {
  late WatchedCubit watchedViewModel = context.read<WatchedCubit>();
  ScrollController scrollController = ScrollController();
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    watchedViewModel.getMovieHistory();
  }

  @override
  void dispose() {
    watchedViewModel.clearScreen();
    scrollController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchTextField(
              height: 20.h,
              // focusNode: searchNode,
              // controller: searchTextCtrl,
              onChange: (value) {},
              prefixIcon: GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  )),
              suffixIcon: GestureDetector(onTap: () {}, child: Icon(Icons.clear, color: Colors.white.withOpacity(0.8))),
            ),
            Expanded(
              child: CustomRefresh(
                controller: refreshController,
                scrollController: scrollController,
                onLoad: () async {
                  if (watchedViewModel.state.lastPage) {
                    refreshController.loadNoData();
                  } else {
                    await watchedViewModel.getMovieHistory();
                    refreshController.loadComplete();
                  }
                },
                onRefresh: () async {
                  await watchedViewModel.getMovieHistory(isRefresh: true);
                },
                child: BlocBuilder<WatchedCubit, WatchedState>(
                    buildWhen: (previous, current) => previous.histories != current.histories,
                    builder: (context, state) {
                      var items = state.histories;

                      if (items.isEmpty) {
                        return const Center(child: Text("Không có phim nào"));
                      }

                      return AnimatedList(
                        key: watchedViewModel.keyListAnimation,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        initialItemCount: items.length,
                        itemBuilder: (context, index, animation) {
                          MovieLocal? previousItem = index == 0 ? null : items[index - 1];
                          var item = items[index];

                          var previousItemTime = DateTime.fromMillisecondsSinceEpoch(previousItem?.lastTime ?? 0);
                          var itemTime = DateTime.fromMillisecondsSinceEpoch(item.lastTime ?? 0);
                          var showDate = itemTime.day != previousItemTime.day;

                          return WatchedItem(
                            movieLocal: item,
                            showDate: showDate,
                          );
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
