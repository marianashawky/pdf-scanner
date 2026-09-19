import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants.dart';

class AdsService {
  InterstitialAd? _interstitial;
  bool _ready = false;

  String get bannerId {
    if (Platform.isIOS) return AppConstants.iosBannerId;
    return AppConstants.androidBannerId;
  }

  String get interstitialId {
    if (Platform.isIOS) return AppConstants.iosInterstitialId;
    return AppConstants.androidInterstitialId;
  }

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _ready = true;
      await preloadInterstitial();
    } catch (error) {
      debugPrint('Ads unavailable: $error');
      _ready = false;
    }
  }

  Future<BannerAd?> createBanner({required void Function(BannerAd ad) onReady}) async {
    if (!_ready) return null;
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: bannerId,
      listener: BannerAdListener(
        onAdLoaded: (ad) => onReady(ad as BannerAd),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );
    await ad.load();
    return ad;
  }

  Future<void> preloadInterstitial() async {
    if (!_ready) return;
    await InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: $error');
          _interstitial = null;
        },
      ),
    );
  }

  Future<void> maybeShowInterstitial(int saveCount) async {
    if (saveCount == 0 || saveCount % AppConstants.interstitialEvery != 0) return;
    final ad = _interstitial;
    if (ad == null) {
      await preloadInterstitial();
      return;
    }
    await ad.show();
  }

  void dispose() {
    _interstitial?.dispose();
  }
}
