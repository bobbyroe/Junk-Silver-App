//
//  coinView.h
//  Silver90
//
//  Created by Simon Williams on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NinevehGL/NinevehGL.h>
#import <AudioToolbox/AudioServices.h>
@class ViewController;
@class CoinInfoView;

@interface coinView : NGLView
{
    // NGLMesh *curMesh;
    // NGLMesh *mesh2;
    // NGLMesh *mesh3;
    NGLMesh *bgMesh;
    NGLCamera *camera;
    
    float distance;
	CGPoint position;
    CGPoint goalPos;
    float coinScale;
    BOOL readySwipe;
    int currentCoinIndex;
    CGPoint touchedVel;
    BOOL infoViewVisible;
    
    SystemSoundID sound1;
    SystemSoundID sound2;
    SystemSoundID sound3;
    SystemSoundID sound4;
}

@property (assign) int coinIndex;
@property (assign) NSString *coinName;
@property (assign) NSString *currentValue;
@property (strong,nonatomic) ViewController *viewCtrlr;
@property (assign) CGFloat spotPrice;
@property (assign) float cameraGoalX;
@property (assign) float cameraX;

@property (strong, nonatomic) IBOutlet UILabel *value;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet CoinInfoView *coinInfoView;
@property (strong, nonatomic) NSMutableArray *currentCoins;
@property (strong, nonatomic) NSMutableArray *currentMeshes;
@property (assign) int numMeshes;
@property (strong, nonatomic) IBOutlet UIButton *buttonBack;
@property (strong, nonatomic) IBOutlet UIButton *buttonNext;
@property (strong, nonatomic) IBOutlet UIButton *buttonPrev;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

@property (strong, nonatomic) IBOutlet UIImageView *loadingView;
@property BOOL pinged;
// @property (assign) CGFloat percentSilver;
// - (void)rightSwipeDetected:(UIGestureRecognizer *)sender;
- (void)animateCoinInfoViewOntoScreen:(BOOL) frealz;

- (void) initInit;

- (void)goNGL3D;
- (void)nextCoin;
- (void)prevCoin;
- (void)updateLabels;
- (IBAction) handleTouchFrom:(UIButton *)buttonSender;
- (void)fadeOutLoadingView;
- (void) createSystemSounds;
- (void) playSound;
@end
