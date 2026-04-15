import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionPlan { free, pro }

class SubscriptionService extends ChangeNotifier {
  static const _kPlan = 'subscription.plan';

  SharedPreferences? _prefs;
  bool _isLoaded = false;

  SubscriptionPlan _plan = SubscriptionPlan.free;

  bool get isLoaded => _isLoaded;
  SubscriptionPlan get plan => _plan;
  bool get isPro => _plan == SubscriptionPlan.pro;

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final p = _prefs!;

    final raw = p.getString(_kPlan);
    _plan = SubscriptionPlan.values.firstWhere(
      (v) => v.name == raw,
      orElse: () => SubscriptionPlan.free,
    );

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setPlan(SubscriptionPlan next) async {
    if (next == _plan) return;
    _plan = next;
    notifyListeners();
    await _prefs?.setString(_kPlan, next.name);
  }
}

