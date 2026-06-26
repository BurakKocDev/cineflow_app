import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:cineflow_app/controllers/tv_show_detail_controller.dart';

class TvShowTrailerScreen extends GetView<TvShowDetailController> {
  const TvShowTrailerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<TvShowDetailController>();
      final yt = controller.ytController;
      final tvShow = controller.tvShow.value;

      if (tvShow == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (yt == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text(tvShow.name),
          ),
          body: const Center(
            child: Text(
              'Bu dizi için fragman bulunamadı.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }

      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: yt,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.redAccent,
          progressColors: const ProgressBarColors(
            playedColor: Colors.redAccent,
            handleColor: Colors.white,
          ),
        ),
        builder: (context, player) {
          return Scaffold(
            appBar: AppBar(
              title: Text(tvShow.name),
            ),
            body: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
            ),
          );
        },
      );
    });
  }
}


