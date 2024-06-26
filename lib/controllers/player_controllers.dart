import 'package:async/async.dart';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wizardly_fucked_wizards/other/constants.dart';

class PlayerController extends GetxController {
  final RxInt _health = startingHealth.obs;
  final RxInt _temperature = 0.obs;
  final RxBool _isFrozen = false.obs;
  final RxBool _isCharged = false.obs;
  final RxBool _isOvercharged = false.obs;
  final RxBool _isWet = false.obs;
  final RxBool _hasRainCloud = false.obs;

  int get health => _health.value;
  int get temperature => _temperature.value;
  bool get isFrozen => _isFrozen.value;
  bool get isCharged => _isCharged.value;
  bool get isOvercharged => _isOvercharged.value;
  bool get isWet => _isWet.value;
  bool get hasRainCloud => _hasRainCloud.value;

  set health(int value) {
    _health.value = value;
  }

  set temperature(int value) {
    _temperature.value = value;
  }

  set isFrozen(bool value) {
    _isFrozen.value = value;
  }

  set isCharged(bool value) {
    _isCharged.value = value;
  }

  set isOvercharged(bool value) {
    _isOvercharged.value = value;
  }

  set isWet(bool value) {
    _isWet.value = value;
  }

  set hasRainCloud(bool value) {
    _hasRainCloud.value = value;
  }

  void reset() {
    _health.value = startingHealth;
    _temperature.value = 0;
    _isFrozen.value = false;
    _isCharged.value = false;
    _isOvercharged.value = false;
    _isWet.value = false;
    _hasRainCloud.value = false;
  }
}

class YouController extends PlayerController {
  late RealtimeChannel _broadcastChannel;
  late Function _onDeath;
  late RestartableTimer wetTimer;
  final RxDouble _damageMultiplier = 1.0.obs;
  final RxDouble _healMultiplier = 1.0.obs;

  double get damageMultiplier => _damageMultiplier.value;
  double get healMultiplier => _healMultiplier.value;

  set damageMultiplier(double value) {
    _damageMultiplier.value = value;
  }

  @override
  set health(int value) {
    if (value <= 0) {
      value = 0;
      _onDeath();
    }
    if (value >= startingHealth) value = startingHealth;
    _health.value = value;
  }

  @override
  set temperature(int value) {
    if (value <= temperatureLimitMin) value = temperatureLimitMin;
    if (value >= temperatureLimitMax) value = temperatureLimitMax;
    _temperature.value = value;
  }

  @override
  set isCharged(bool value) {
    if (isCharged && value) {
      isOvercharged = true;
    } else {
      _isCharged.value = value;
    }
  }

  @override
  set isWet(bool value) {
    if (value) {
      wetTimer.reset();
    }
    _isWet.value = value;
  }

  void setup() {
    wetTimer = RestartableTimer(const Duration(seconds: wetDuration), () {
      _isWet.value = false;
    });
  }

  void heal(int amount) {
    health += (amount * healMultiplier).floor();
  }

  void takeDamage(int amount) {
    health -= (amount * damageMultiplier).floor();
  }

  void cool(int amount) {
    if (isWet) {
      temperature -= amount * 2;
    } else {
      temperature -= amount;
    }
  }

  void heat(int amount) {
    temperature += amount;
  }

  void setOnDeath(Function onDeath) {
    _onDeath = onDeath;
  }

  void setBroadcastChannel(RealtimeChannel broadcastChannel) {
    _broadcastChannel = broadcastChannel;
  }

  void sendUpdates() {
    _broadcastChannel.sendBroadcastMessage(event: 'opponent_update', payload: {
      'health': _health.value,
      'temperature': _temperature.value,
      'isFrozen': _isFrozen.value,
      'isCharged': _isCharged.value,
      'isOvercharged': _isOvercharged.value,
      'isWet': _isWet.value,
      'hasRainCloud': _hasRainCloud.value,
    });
  }
}

class OpponentController extends PlayerController {}
