import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdsPage extends StatefulWidget {
  const BannerAdsPage({super.key});

  @override
  State<BannerAdsPage> createState() => _BannerAdsPageState();
}

class _BannerAdsPageState extends State<BannerAdsPage> {

  BannerAd? bannerAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BannerAd(
        size: AdSize.banner,
        adUnitId: 'ca-app-pub-3940256099942544/9214589741',
        listener: BannerAdListener(
          onAdLoaded: (ads){
            setState(() {
              bannerAd = ads as BannerAd;
            });
          },
          onAdFailedToLoad: (ads, error){
            print('Failed to load the ads: ${error.message}');
            ads.dispose();
          }
        ),
        request: AdRequest()
    ).load();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         if(bannerAd != null)
           Align(
             alignment: Alignment.bottomCenter,
             child: SizedBox(
               height: bannerAd!.size.height.toDouble(),
               width: bannerAd!.size.width.toDouble(),
               child: AdWidget(
                   ad: bannerAd!
               ),
             ),
           )
        ],
      ),
    );
  }
}
