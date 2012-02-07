//
//  coinView.m
//  Silver90
//
//  Created by Simon Williams on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "coinView.h"
#import "ViewController.h"
#import "CoinInfoView.h"
#import "Coin.h"

@implementation coinView
#define kCameraY 0.05

@synthesize coinIndex, numMeshes;
@synthesize coinName;
@synthesize currentValue;
@synthesize viewCtrlr;
@synthesize spotPrice;
@synthesize cameraGoalX;
@synthesize cameraX;
// @synthesize percentSilver;
@synthesize value;
@synthesize name;
@synthesize coinInfoView;
@synthesize currentCoins, currentMeshes;
@synthesize buttonBack, buttonNext, buttonPrev, infoButton;
@synthesize loadingView;
@synthesize pinged;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (void) initInit {
    self.paused = YES;
    infoViewVisible = NO;
    [self createSystemSounds];
}
#pragma mark - NGL stuff
- (void) goNGL3D
{
    [coinInfoView setUpGesturesWithParent:self];
    self.paused = NO;
    pinged = NO;
    currentCoinIndex = 0;
    
    
    NSString *coinObj;
    if (coinIndex == 100) {
		coinObj = @"dollar.obj";
        coinScale = 0.5;
	}
	if (coinIndex == 50) {
        coinObj = @"hlafDollar.obj";
        coinScale = 0.4;
	}
	if (coinIndex == 25) {
		coinObj = @"quarter.obj";
        coinScale = 0.35;
	}
	if (coinIndex == 10) {
		coinObj = @"dime.obj";
        coinScale = 0.25;
	}
    if (coinIndex == 5) {
		coinObj = @"nickel.obj";
        coinScale = 0.3;
	}
    currentMeshes = [[NSMutableArray alloc] init];
    numMeshes = [currentCoins count];
    for(int i = 0; i < numMeshes; i++) {
        
        Coin *aCoin = [currentCoins objectAtIndex:i];
        NSString *coinTex = [NSString stringWithFormat: @"%@", aCoin.coinTexture];
        
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES], kNGLMeshAutoCentralize,
                                  [NSNumber numberWithBool:YES], kNGLMeshAutoNormalize,
                                  [NSNumber numberWithFloat:coinScale], kNGLMeshAutoNormalizeTo,
                                  nil];
        
        NGLMesh *curMesh = [[NGLMesh alloc] initWithOBJFile:coinObj setProperties:settings];
        curMesh.rotateX = 90;
        curMesh.x = i * 0.7;
        NGLMaterial *material = [NGLMaterial materialPewter];
        material.diffuseMap = [NGLTexture texture2DWithFile:coinTex]; //@"dollar_Peace.jpg"]; // 
        // material.bumpMap = [NGLTexture texture2DWithFile:@"dollar_Peace_NRM.png"];
        material.specularColor = nglColorMake(0.3, 0.3, 0.3, 1.0);
        curMesh.material = material;
        [curMesh compileCoreMesh];
        [currentMeshes addObject:curMesh];
        
    }
    [self updateLabels];
    
    
    
    // Background Mesh
    NSDictionary *bgSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], kNGLMeshAutoCentralize,
                                [NSNumber numberWithBool:YES], kNGLMeshAutoNormalize,
                                [NSNumber numberWithFloat:2], kNGLMeshAutoNormalizeTo,
                                nil];
    bgMesh = [[NGLMesh alloc] initWithOBJFile:@"plane.obj" setProperties:bgSettings];
    bgMesh.rotateX = 90;
    bgMesh.y = -0.2;
    bgMesh.z = -0.9;
    NGLMaterial *bgMaterial = [NGLMaterial material];
    // bgMaterial.ambientMap = [NGLTexture texture2DWithFile:@"planeBG.png"];
    bgMaterial.diffuseMap = [NGLTexture texture2DWithFile:@"planeBG.png"];
    bgMaterial.specularColor = nglColorMake(0.0, 0.0, 0.0, 0.0);
    bgMesh.material = bgMaterial;
    [bgMesh compileCoreMesh];
    
    
    
    camera = [[NGLCamera alloc] initWithMeshes:bgMesh, nil];
    roeLog(@"%i",[currentMeshes count]);
    [camera addMeshesFromArray:currentMeshes];
    
    camera.y = kCameraY;
    cameraX = 0;
    cameraGoalX = 0;
    
    [self fadeOutLoadingView];

}

- (void)fadeOutLoadingView
{    
    [UIView animateWithDuration:0.3 delay:0.1 options: UIViewAnimationCurveLinear
                     animations:^{
                         loadingView.alpha = 0.0;
                     } completion:^(BOOL finished){
                         loadingView.hidden = YES;
                     }];
}
- (void)drawView {
    
    // limit the amount the camera can zoom out / in
    [camera moveRelativeTo:NGLMoveForward distance:distance];
    if (camera.z > 1.25) camera.z = 1.25;
    if (camera.z < 0.25) camera.z = 0.25;
    camera.y = (camera.z * kCameraY) + 0.0;
    // roeLog(@"y:%f, z:%f",camera.y,camera.z);
    camera.x -= (camera.x - cameraGoalX) * 0.1;
    
    // move the background with the camera, gnome sain?
    bgMesh.x = camera.x;
    bgMesh.y = camera.y;
    bgMesh.z = camera.z - 1.9;
    
    goalPos.x -= (goalPos.x - position.x) * 0.1;
    goalPos.y -= (goalPos.y - position.y) * 0.1;
    
    for (int i = 0; i < numMeshes; i++) {
        NGLMesh *aMesh = [currentMeshes objectAtIndex:i];
        aMesh.rotateX -= -goalPos.y;
        aMesh.rotateZ -= goalPos.x;
    }
    
	// mesh.rotateX -= -goalPos.y;
	// mesh.rotateZ -= goalPos.x;
    // mesh2.rotateX = mesh3.rotateX = mesh.rotateX;
    // mesh2.rotateZ = mesh3.rotateZ = mesh.rotateZ;
    
	[camera drawCamera];
	
	distance = 0.0;
    if (position.x < 0.01 || position.y < 0.01) {
        position.x = 0;
        position.y = 0;
    } else {
        position.x *= 0.96;
        position.y *= 0.96;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)nextCoin
{
    float maxCameraX = 0.7 * (numMeshes-1);
    cameraGoalX += 0.7;
    if (cameraGoalX > maxCameraX) cameraGoalX = 0;
    
    currentCoinIndex ++;
    if (currentCoinIndex > numMeshes-1) currentCoinIndex = 0;
    
    [self updateLabels];
}

- (void)prevCoin
{
    float maxCameraX = 0.7 * (numMeshes-1);
    cameraGoalX -= 0.7;
    if (cameraGoalX < -0.0001) cameraGoalX = maxCameraX;
    
    currentCoinIndex --;
    if (currentCoinIndex < 0) currentCoinIndex = numMeshes-1;

    [self updateLabels];
}

- (void)updateLabels
{
    roeLog(@"coin index: %i",currentCoinIndex);
    NSString *coinNamed = [NSString stringWithFormat: @"%@", [[currentCoins objectAtIndex:currentCoinIndex] name]];
    name.text = [coinNamed uppercaseString];
    
    NSString *weightInOz = [NSString stringWithFormat: @"%@oz", [[currentCoins objectAtIndex:currentCoinIndex] netWeightSilverInOz]];
    CGFloat ozsSilver = [weightInOz floatValue];
    NSString *estimatedMarkUp = [NSString stringWithFormat: @"%@oz", [[currentCoins objectAtIndex:currentCoinIndex] estimatedMarkupOverSpot]];
    CGFloat markUpFloat = [estimatedMarkUp floatValue];
    CGFloat curVal = spotPrice * ozsSilver + markUpFloat;
    value.text = [NSString stringWithFormat: @"$%.2f", curVal];
    
    // info panel:
    coinInfoView.weightInGrams.text = [NSString stringWithFormat: @"%@g", [[currentCoins objectAtIndex:currentCoinIndex] weightInGrams]];
    coinInfoView.silverPercentage.text = [NSString stringWithFormat: @"%@%%", [[currentCoins objectAtIndex:currentCoinIndex] silverPercentage]];
    coinInfoView.netWeightSilverInOz.text = [NSString stringWithFormat: @"%@oz", [[currentCoins objectAtIndex:currentCoinIndex] netWeightSilverInOz]];
    coinInfoView.dates.text = [NSString stringWithFormat: @"%@", [[currentCoins objectAtIndex:currentCoinIndex] dates]];
        
}
#pragma mark - touch events

- (void)animateCoinInfoViewOntoScreen:(BOOL) frealz
{
    CGRect coinInfoViewFrame = coinInfoView.frame;
    int goalY = -320;
    if (frealz) goalY = 0;
    coinInfoViewFrame.origin.y = goalY;
    
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         coinInfoView.frame = coinInfoViewFrame;
                     } completion:^(BOOL finished){
                         NSLog(@"Info!");
                     }];

}

- (float) distanceFromPoint:(CGPoint)pointA toPoint:(CGPoint)pointB
{
	float xD = fabs(pointA.x - pointB.x);
	float yD = fabs(pointA.y - pointB.y);
	
	return sqrt(xD*xD + yD*yD);
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[touches allObjects] objectAtIndex:0]; // [touches anyObject];
    CGPoint pointA;
    pinged = YES;
	pointA = [touch locationInView:self];
    if (touch.tapCount == 2) { 
        infoViewVisible = !infoViewVisible;
        [self animateCoinInfoViewOntoScreen:infoViewVisible];
    }
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touchA, *touchB;
	CGPoint pointA, pointB;
	
	// Pan gesture.
	if ([touches count] == 1) {
		touchA = [[touches allObjects] objectAtIndex:0];
		pointA = [touchA locationInView:self];
		pointB = [touchA previousLocationInView:self];
        
        position.x = (pointA.x - pointB.x);
        position.y = (pointA.y - pointB.y);
        if((position.x > 80 || position.y > 80) && pinged) {
            pinged = NO;
            [self playSound];
        }
	}
	// Pinch gesture.
	else if ([touches count] == 2) {
		touchA = [[touches allObjects] objectAtIndex:0];
		touchB = [[touches allObjects] objectAtIndex:1];
		
		// Current distance.
		pointA = [touchA locationInView:self];
		pointB = [touchB locationInView:self];
		float currDistance = [self distanceFromPoint:pointA toPoint:pointB];
		
		// Previous distance.
		pointA = [touchA previousLocationInView:self];
		pointB = [touchB previousLocationInView:self];
		float prevDistance = [self distanceFromPoint:pointA toPoint:pointB];
		
		distance = (currDistance - prevDistance) * 0.005;
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// something
    // roeLog(@"\n");
}

- (IBAction) handleTouchFrom:(UIButton *)buttonSender
{
    // buttonSender.tag
    // 0 == Back
    // 1 == Next
    // 2 == Prev
    // 3 == Info
    if (buttonSender.tag == 0) {
        // go back
        self.paused = YES;
        [viewCtrlr coinViewSlideTo:320 withButtonIndex:0];
        [self animateCoinInfoViewOntoScreen:NO];
        loadingView.alpha = 1.0;
        loadingView.hidden = NO;
    } else if (buttonSender.tag == 1) {
        [self nextCoin];
    } else if (buttonSender.tag == 2) {
        [self prevCoin];
    } else {
        [self animateCoinInfoViewOntoScreen:YES];
    }
    // roeLog(@"tag:%i",buttonSender.tag);
}
#pragma mark - sounds
- (void) createSystemSounds {
    // roeLog(@"create system sounds!");
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Eisen0" ofType:@"caf"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound1); 
    if (err != kAudioServicesNoError) roeLog(@"error!");
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"Morgan" ofType:@"caf"];
    soundURL = [NSURL fileURLWithPath:soundPath];
    err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound2); 
    if (err != kAudioServicesNoError) roeLog(@"error!");
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"Flip3" ofType:@"caf"];
    soundURL = [NSURL fileURLWithPath:soundPath];
    err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound3); 
    if (err != kAudioServicesNoError) roeLog(@"error!");
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"Peace0" ofType:@"caf"];
    soundURL = [NSURL fileURLWithPath:soundPath];
    err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound4); 
    if (err != kAudioServicesNoError) roeLog(@"error!");
}

- (void) playSound {
    int randomNumber = (random() % 4);
    if (randomNumber == 0)AudioServicesPlaySystemSound(sound1);
    if (randomNumber == 1)AudioServicesPlaySystemSound(sound2);
    if (randomNumber == 2)AudioServicesPlaySystemSound(sound3);
    if (randomNumber == 3)AudioServicesPlaySystemSound(sound4);
}

@end
