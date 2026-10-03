import 'package:flutter_riverpod/flutter_riverpod.dart';

class AzanPlayback {
  const AzanPlayback({this.state = 'stopped', this.name = '', this.millis = 0});

  final String state;
  final String name;
  final int millis;

  bool get active => state != 'stopped';
}

class AzanPlaybackNotifier extends Notifier<AzanPlayback> {
  @override
  AzanPlayback build() => const AzanPlayback();

  void apply(Map<Object?, Object?> data) {
    state = AzanPlayback(
      state: data['state'] as String? ?? 'stopped',
      name: data['name'] as String? ?? '',
      millis: (data['millis'] as num?)?.toInt() ?? 0,
    );
  }
}

final azanPlaybackProvider =
    NotifierProvider<AzanPlaybackNotifier, AzanPlayback>(
      AzanPlaybackNotifier.new,
    );
