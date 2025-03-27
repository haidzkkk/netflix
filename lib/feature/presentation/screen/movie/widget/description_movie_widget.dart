import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_slide_show/image_slide_show.dart';
import 'package:spotify/feature/commons/utility/style_util.dart';
import 'package:spotify/feature/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/presentation/screen/widget/image_widget.dart';
import 'package:spotify/feature/presentation/screen/widget/read_more_widget.dart';

class DescriptionMovieWidget extends StatefulWidget {
  const DescriptionMovieWidget({super.key});

  @override
  State<DescriptionMovieWidget> createState() => _DescriptionMovieWidgetState();
}

class _DescriptionMovieWidgetState extends State<DescriptionMovieWidget> {
  late MovieBloc viewModel = context.read<MovieBloc>();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: BlocBuilder<MovieBloc, MovieState>(
                    buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                    builder: (context, state) {
                      return ImageSlideWidget(
                        child: ImageWidget(
                          url: state.currentMovie?.posterUrl ?? "",
                          fit: BoxFit.cover,
                        ),
                      );
                    })),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 3,
              child: BlocBuilder<MovieBloc, MovieState>(
                  buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "Category: ", style: Style.body.copyWith(fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: state.currentMovie?.categories
                                        ?.map((category) => category.name)
                                        .toList()
                                        .join(", ") ??
                                    " _ _ ",
                                style: Style.body),
                          ]),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "Country: ", style: Style.body.copyWith(fontWeight: FontWeight.w700)),
                            TextSpan(
                                text:
                                    state.currentMovie?.countries?.map((country) => country.name).toList().join(", ") ??
                                        " _ _ ",
                                style: Style.body),
                          ]),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "Actor: ", style: Style.body.copyWith(fontWeight: FontWeight.w700)),
                            TextSpan(text: state.currentMovie?.actor?.join(", ") ?? " _ _ ", style: Style.body),
                          ]),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "Director: ", style: Style.body.copyWith(fontWeight: FontWeight.w700)),
                            TextSpan(text: state.currentMovie?.director?.join(", ") ?? " _ _ ", style: Style.body),
                          ]),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
        const SizedBox(height: 5),
        BlocBuilder<MovieBloc, MovieState>(
            buildWhen: (previous, current) => previous.currentMovie != current.currentMovie,
            builder: (context, state) {
              if (state.movie.data?.content == null) {
                return const SizedBox(height: 5);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("Mô tả", style: Style.body.copyWith(fontWeight: FontWeight.w700)),
                  ReadMoreText(
                    "${state.currentMovie?.content ?? " _ _ "}  ",
                    style: Style.body.copyWith(color: Colors.white.withOpacity(0.4)),
                    trimLength: 250,
                  )
                ],
              );
            }),
        const SizedBox(height: 20),
      ],
    );
  }
}
