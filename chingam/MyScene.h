//
//  MyScene.h
//  chingam
//

//  Copyright (c) 2014 Rijul Gupta. All rights reserved.
//
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#include "GADInterstitial.h"
#import <RevMobAds/RevMobAds.h>
#include "Reachability.h"


@interface MyScene : SKScene <GKGameCenterControllerDelegate, GADInterstitialDelegate>{
    GADInterstitial *adMobinterstitial_;
    GADRequest *request;
}

@property(nonatomic)BOOL isCharging;
@property(nonatomic)BOOL buttIsHit;

@property(nonatomic)BOOL gameOver;
@property(nonatomic)BOOL gameBegan;



@end
