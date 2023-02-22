// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const gameLevels = [
  GameLevel(
    number: 1,
    difficulty: 5,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 2,
    difficulty: 42,
  ),
  GameLevel(
    number: 3,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
  GameLevel(
    number: 4,
    difficulty: 42,
  ),
  GameLevel(
    number: 5,
    difficulty: 42,
  ),
  GameLevel(
    number: 6,
    difficulty: 42,
  ),
  GameLevel(
    number: 7,
    difficulty: 42,
  ),
  GameLevel(
    number: 8,
    difficulty: 42,
  ),
  GameLevel(
    number: 9,
    difficulty: 42,
  ),
  GameLevel(
    number: 10,
    difficulty: 42,
  ),
  GameLevel(
    number: 11,
    difficulty: 42,
  ),
  GameLevel(
    number: 12,
    difficulty: 42,
  ),
  GameLevel(
    number: 13,
    difficulty: 42,
  ),
  GameLevel(
    number: 14,
    difficulty: 42,
  ),
  GameLevel(
    number: 15,
    difficulty: 42,
  ),
  GameLevel(
    number: 16,
    difficulty: 42,
  ),
  GameLevel(
    number: 17,
    difficulty: 42,
  ),
  GameLevel(
    number: 18,
    difficulty: 42,
  ),
  GameLevel(
    number: 19,
    difficulty: 42,
  ),
  GameLevel(
    number: 20,
    difficulty: 42,
  ),
];

class GameLevel {
  final int number;

  final int difficulty;

  /// The achievement to unlock when the level is finished, if any.
  final String? achievementIdIOS;

  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
    required this.number,
    required this.difficulty,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
            (achievementIdAndroid != null && achievementIdIOS != null) ||
                (achievementIdAndroid == null && achievementIdIOS == null),
            'Either both iOS and Android achievement ID must be provided, '
            'or none');
}
