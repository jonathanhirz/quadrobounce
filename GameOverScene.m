//
//  GameOverScene.m
//  quadropong
//
//  Created by Jonathan Hirz on 5/18/11.
//  Copyright 2011 SuaveApps. All rights reserved.
//

#import "GameOverScene.h"
#import "HelloWorldLayer.h"
#import "MenuScene.h"
#import "CCTransition.h"

extern float calibrationX;
extern float calibrationY;
extern int rightOrLeft;

BOOL paused;


@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {
    if ((self = [super init])) {
        self.layer = [GameOverLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation GameOverLayer
@synthesize label = _label;
@synthesize score = _score;

- (id)init {
    if ((self = [super initWithColor:ccc4(150,150,150,255)])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile:@"menuScreen.png"];
        background.tag = 1;
        background.anchorPoint = CGPointMake(0,0);
        [self addChild:background];
        
        self.label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
        _label.color = ccc3(0,0,0);
        _label.position = ccp(winSize.width/2, winSize.height/2 + 48);
        
        self.score = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:26];
        _score.color = ccc3(0,0,0);
        _score.position = ccp(winSize.width/2, winSize.height/2 + 16);
        
        [self addChild:_label];
        [self addChild:_score];
        
        CCMenuItemImage *playAgainButton = [CCMenuItemImage 
                                            itemFromNormalImage:@"playAgain.png"
                                            selectedImage:@"playAgainPushed.png"
                                            target:self
                                            selector:@selector(playAgain)];
        
        CCMenuItemImage *returnToMenuButton = [CCMenuItemImage
                                                itemFromNormalImage:@"quit.png"
                                                selectedImage:@"quitPushed.png"
                                                target:self 
                                                selector:@selector(returnToMenu)];
        
        CCMenu *menu = [CCMenu menuWithItems:playAgainButton, returnToMenuButton, nil];
        menu.position = ccp(winSize.width/2, winSize.height/2 - 50);
        [menu alignItemsHorizontally];
        [self addChild:menu];
        self.isAccelerometerEnabled = YES;

    }
    return self;
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    calibrationX = acceleration.y;
    calibrationY = acceleration.x;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
        rightOrLeft = -1;        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        rightOrLeft = 1;
    }
    
}

- (void)playAgain {
    paused = NO;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
}

-(void)returnToMenu {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuScene scene]]];
}



- (void)dealloc {
    [_label release];
    _label = nil;
    [super dealloc];
}

@end
