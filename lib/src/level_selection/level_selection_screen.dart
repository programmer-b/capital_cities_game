// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:capital_cities_game/src/utils/strings/global_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'levels.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: ResponsiveScreen(
        squarishMainArea: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Select level',
                    style:
                        TextStyle(fontFamily: 'Permanent Marker', fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final level in gameLevels)
                      _levelTab(
                        context,
                        level: level.number,
                        onTap: () {
                          final audioController =
                              context.read<AudioController>();
                          audioController.playSfx(SfxType.buttonTap);
                        },
                        enabled: playerProgress.highestLevelReached >=
                            level.number - 1,
                      )
                    // ListTile(
                    //   enabled: playerProgress.highestLevelReached >=
                    //       level.number - 1,
                    //   onTap: () {
                    //     final audioController = context.read<AudioController>();
                    //     audioController.playSfx(SfxType.buttonTap);
                    //
                    //     GoRouter.of(context)
                    //         .go('/play/session/${level.number}');
                    //   },
                    //   leading: Text(level.number.toString()),
                    //   title: Text('Level #${level.number}'),
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
        rectangularMenuArea: FilledButton(
          onPressed: () {
            GoRouter.of(context).go('/');
          },
          child: const Text('Back'),
        ),
      ),
    );
  }
}

Widget _levelTab(context,
        {required int level, void Function()? onTap, required bool enabled}) =>
    Builder(builder: (ctx) {
      final width = ctx.width() * 0.15;
      return InkWell(
        onTap: onTap,
        child: Card(
          elevation: 10,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 70, maxHeight: 150),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade50,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.cyan.withOpacity(0.4)),
            width: width,
            height: width * 2,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Text(
                  '$level',
                  style: const TextStyle(
                      fontFamily: permenentMarkerFont, fontSize: 22),
                ),
                 Icon(Icons.lock, color: enabled ? Colors.transparent : Colors.black26,)
              ],
            ),
          ),
        ),
      );
    });
