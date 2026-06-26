import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/utility/device_helper.dart';

/// High-level phase of [ContinuousLocationService].
enum ContinuousLocationPhase {
  idle,
  starting,
  blocked,
  active,
}

/// Immutable snapshot for UI or blocs listening to [ContinuousLocationService].
@immutable
class ContinuousLocationSnapshot {
  const ContinuousLocationSnapshot({
    required this.phase,
    this.lastValidPosition,
    this.lastValidAt,
    this.blockedReason,
    this.lastSampleRejection,
  });

  static const idle = ContinuousLocationSnapshot(phase: ContinuousLocationPhase.idle);

  final ContinuousLocationPhase phase;
  final Position? lastValidPosition;
  final DateTime? lastValidAt;
  final String? blockedReason;
  final String? lastSampleRejection;
}

/// Foreground continuous GPS with shared permission checks and the same
/// secure validation as [Device.secureUserPosition], without calling
/// [Device.userPosition] on every update.
///
/// Start when the user session is active (e.g. main tab shell). Stop on logout.
class ContinuousLocationService extends ChangeNotifier {
  ContinuousLocationService._();
  static final ContinuousLocationService instance = ContinuousLocationService._();

  ContinuousLocationSnapshot _snapshot = ContinuousLocationSnapshot.idle;
  ContinuousLocationSnapshot get snapshot => _snapshot;

  bool _started = false;
  bool _attachBusy = false;
  int _evalGeneration = 0;

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<ServiceStatus>? _serviceSub;
  Timer? _blockedRetryTimer;
  Timer? _serviceDebounce;

  void _setSnapshot(ContinuousLocationSnapshot s) {
    _snapshot = s;
    notifyListeners();
  }

  /// Idempotent: safe to call multiple times.
  Future<void> start() async {
    if (_started) {
      await _tryAttachStream();
      return;
    }
    _started = true;
    _setSnapshot(
      const ContinuousLocationSnapshot(phase: ContinuousLocationPhase.starting),
    );
    await _tryAttachStream();
    _ensureServiceStatusListener();
  }

  /// Cancels subscriptions and clears state.
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    _evalGeneration++;
    await _positionSub?.cancel();
    _positionSub = null;
    await _serviceSub?.cancel();
    _serviceSub = null;
    _blockedRetryTimer?.cancel();
    _blockedRetryTimer = null;
    _serviceDebounce?.cancel();
    _serviceDebounce = null;
    _setSnapshot(ContinuousLocationSnapshot.idle);
  }

  void _ensureServiceStatusListener() {
    if (_serviceSub != null) return;
    _serviceSub = Geolocator.getServiceStatusStream().listen((status) {
      if (!_started) return;
      _serviceDebounce?.cancel();
      _serviceDebounce = Timer(const Duration(milliseconds: 400), () {
        if (!_started) return;
        if (status == ServiceStatus.enabled) {
          unawaited(_tryAttachStream());
        } else {
          _handleServiceDisabled();
        }
      });
    });
  }

  void _handleServiceDisabled() {
    _positionSub?.cancel();
    _positionSub = null;
    _setSnapshot(
      ContinuousLocationSnapshot(
        phase: ContinuousLocationPhase.blocked,
        blockedReason:
            'Location services are disabled.Please enable to continue',
        lastValidPosition: _snapshot.lastValidPosition,
        lastValidAt: _snapshot.lastValidAt,
      ),
    );
    _scheduleBlockedRecoveryPoll();
  }

  Future<void> _tryAttachStream() async {
    if (!_started || _attachBusy) return;
    _attachBusy = true;
    try {
      final issue = await Device().locationAvailabilityIssue();
      if (issue != null) {
        _positionSub?.cancel();
        _positionSub = null;
        _setSnapshot(
          ContinuousLocationSnapshot(
            phase: ContinuousLocationPhase.blocked,
            blockedReason: issue,
            lastValidPosition: _snapshot.lastValidPosition,
            lastValidAt: _snapshot.lastValidAt,
          ),
        );
        _scheduleBlockedRecoveryPoll();
        return;
      }

      _blockedRetryTimer?.cancel();
      _blockedRetryTimer = null;

      await _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 12,
        ),
      ).listen(
        _onPositionUpdate,
        onError: _onPositionStreamError,
      );

      unawaited(_seedFromLastKnownPosition());

      _setSnapshot(
        ContinuousLocationSnapshot(
          phase: ContinuousLocationPhase.active,
          lastValidPosition: _snapshot.lastValidPosition,
          lastValidAt: _snapshot.lastValidAt,
        ),
      );
    } finally {
      _attachBusy = false;
    }
  }

  void _scheduleBlockedRecoveryPoll() {
    _blockedRetryTimer?.cancel();
    _blockedRetryTimer =
        Timer.periodic(const Duration(seconds: 18), (_) async {
      if (!_started) return;
      final issue = await Device().locationAvailabilityIssue();
      if (issue == null) {
        _blockedRetryTimer?.cancel();
        _blockedRetryTimer = null;
        await _tryAttachStream();
      }
    });
  }

  void _onPositionStreamError(Object error) {
    if (!_started) return;
    if (kDebugMode) {
      debugPrint('ContinuousLocationService stream error: $error');
    }
    _setSnapshot(
      ContinuousLocationSnapshot(
        phase: ContinuousLocationPhase.blocked,
        blockedReason: error.toString(),
        lastValidPosition: _snapshot.lastValidPosition,
        lastValidAt: _snapshot.lastValidAt,
      ),
    );
    _scheduleBlockedRecoveryPoll();
  }

  Future<void> _seedFromLastKnownPosition() async {
    if (!_started || _snapshot.lastValidPosition != null) return;
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && _started) {
        _onPositionUpdate(lastKnown);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ContinuousLocationService seed error: $e');
      }
    }
  }

  void _onPositionUpdate(Position pos) {
    if (!_started) return;
    final gen = ++_evalGeneration;
    scheduleMicrotask(() async {
      final reason = await Device().secureRejectionReasonForPosition(pos);
      if (!_started || gen != _evalGeneration) return;
      if (reason != null) {
        _setSnapshot(
          ContinuousLocationSnapshot(
            phase: ContinuousLocationPhase.active,
            lastValidPosition: _snapshot.lastValidPosition,
            lastValidAt: _snapshot.lastValidAt,
            lastSampleRejection: reason,
          ),
        );
        return;
      }
      final now = DateTime.now();
      _setSnapshot(
        ContinuousLocationSnapshot(
          phase: ContinuousLocationPhase.active,
          lastValidPosition: pos,
          lastValidAt: now,
        ),
      );
    });
  }

  Position? _tryCachedValidPosition({
    Duration streamMaxAge = const Duration(seconds: 45),
    int maxFixAgeSeconds = 90,
  }) {
    final s = _snapshot;
    final p = s.lastValidPosition;
    final at = s.lastValidAt;
    if (p != null &&
        at != null &&
        s.phase == ContinuousLocationPhase.active &&
        DateTime.now().difference(at) <= streamMaxAge &&
        DateTime.now().difference(p.timestamp).inSeconds.abs() <=
            maxFixAgeSeconds) {
      return p;
    }
    return null;
  }

  Future<Position?> _validatePosition(
    Position pos, {
    required int maxFixAgeSeconds,
  }) async {
    final reason = await Device().secureRejectionReasonForPosition(
      pos,
      maxFixAgeSeconds: maxFixAgeSeconds,
    );
    if (reason != null) return null;
    _setSnapshot(
      ContinuousLocationSnapshot(
        phase: _snapshot.phase == ContinuousLocationPhase.idle
            ? ContinuousLocationPhase.active
            : _snapshot.phase,
        lastValidPosition: pos,
        lastValidAt: DateTime.now(),
      ),
    );
    return pos;
  }

  Future<Position?> _waitForStreamValidPosition(
    Duration timeout, {
    required int maxFixAgeSeconds,
  }) async {
    final immediate = _tryCachedValidPosition(maxFixAgeSeconds: maxFixAgeSeconds);
    if (immediate != null) return immediate;

    final completer = Completer<Position?>();
    void onUpdate() {
      final fix = _tryCachedValidPosition(maxFixAgeSeconds: maxFixAgeSeconds);
      if (fix != null && !completer.isCompleted) {
        completer.complete(fix);
      }
    }

    addListener(onUpdate);
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) completer.complete(null);
    });
    onUpdate();

    try {
      return await completer.future;
    } finally {
      removeListener(onUpdate);
      timer.cancel();
    }
  }

  Future<Position?> _tryTimedCurrentPosition(
    LocationAccuracy accuracy,
    Duration timeLimit, {
    required int maxFixAgeSeconds,
  }) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );
      return _validatePosition(pos, maxFixAgeSeconds: maxFixAgeSeconds);
    } on TimeoutException {
      return null;
    }
  }

  /// Prefer a recent validated stream fix; otherwise performs a one-shot
  /// [Device.secureUserPosition] (same trust model as before the service existed).
  Future<Position> resolveForSecureAction({
    Duration streamMaxAge = const Duration(seconds: 45),
    int maxFixAgeSeconds = 90,
    LocationAccuracy fallbackDesiredAccuracy = LocationAccuracy.best,
  }) async {
    final cached = _tryCachedValidPosition(
      streamMaxAge: streamMaxAge,
      maxFixAgeSeconds: maxFixAgeSeconds,
    );
    if (cached != null) return cached;
    return Device().secureUserPosition(
      desiredAccuracy: fallbackDesiredAccuracy,
      maxFixAgeSeconds: maxFixAgeSeconds,
    );
  }

  /// Faster resolve for camera stamp and other UI-sensitive flows.
  ///
  /// Tries cached stream fix, last-known position, timed [getCurrentPosition]
  /// (medium then low), a short stream wait, then the slow secure fallback.
  Future<Position> resolveForSecureActionFast({
    Duration streamMaxAge = const Duration(seconds: 45),
    int maxFixAgeSeconds = 90,
    Duration streamWait = const Duration(seconds: 3),
    Duration positionTimeLimit = const Duration(seconds: 5),
    LocationAccuracy fallbackDesiredAccuracy = LocationAccuracy.medium,
  }) async {
    final cached = _tryCachedValidPosition(
      streamMaxAge: streamMaxAge,
      maxFixAgeSeconds: maxFixAgeSeconds,
    );
    if (cached != null) return cached;

    if (!_started) {
      await start();
    }

    final afterStart = _tryCachedValidPosition(
      streamMaxAge: streamMaxAge,
      maxFixAgeSeconds: maxFixAgeSeconds,
    );
    if (afterStart != null) return afterStart;

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      final validated = await _validatePosition(
        lastKnown,
        maxFixAgeSeconds: maxFixAgeSeconds,
      );
      if (validated != null) return validated;
    }

    for (final accuracy in [
      LocationAccuracy.medium,
      LocationAccuracy.low,
    ]) {
      final timed = await _tryTimedCurrentPosition(
        accuracy,
        positionTimeLimit,
        maxFixAgeSeconds: maxFixAgeSeconds,
      );
      if (timed != null) return timed;
    }

    final streamFix = await _waitForStreamValidPosition(
      streamWait,
      maxFixAgeSeconds: maxFixAgeSeconds,
    );
    if (streamFix != null) return streamFix;

    final lastChance = await _tryTimedCurrentPosition(
      fallbackDesiredAccuracy,
      positionTimeLimit * 2,
      maxFixAgeSeconds: maxFixAgeSeconds,
    );
    if (lastChance != null) return lastChance;

    throw LocationSpoofingException(
      'Unable to get a fresh GPS fix. Please try again in an open area.',
    );
  }
}
