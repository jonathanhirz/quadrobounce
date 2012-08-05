//
//  MenuScene.m
//  quadropong
//
//  Created by Jonathan Hirz on 6/8/11.
//  Copyright 2011 SuaveApps. All rights reserved.
//

#import "MenuScene.h"
#import "AboutScene.h"
#import "HelloWorldLayer.h"
#import "CCTransition.h"
#import "SimpleAudioEngine.h"
#import "GameCenterManager.h"

@implementation MenuScene

extern float calibrationX;
extern float calibrationY;
extern int rightOrLeft;
BOOL paused;

+(id) scene{
    
    CCScene *scene = [CCScene node];
    MenuScene *layer = [MenuScene node];
    [scene addChild:layer];
    return scene;
}

-(id) init{
    if ((self = [super initWithColor:ccc4(150,150,150,255)])){
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile:@"menuScreen.png"];
        background.tag = 1;
        background.anchorPoint = CGPointMake(0,0);
        [self addChild:background];
        
        CCSprite *titleText = [CCSprite spriteWithFile:@"quadropong!.png"];
        titleText.position = ccp(winSize.width/2, winSize.height-titleText.contentSize.height-20);
        [self addChild:titleText];
        
        CCMenuItemImage *playButton = [CCMenuItemImage
                                        itemFromNormalImage:@"Button.png" 
                                        selectedImage:@"ButtonPushed.png"
                                        target:self
                                        selector:@selector(gameStart:)];
        CCMenuItemImage *helpButton = [CCMenuItemImage
                                        itemFromNormalImage:@"help.png"
                                        selectedImage:@"helpPushed.png"
                                        target:self
                                        selector:@selector(aboutStart:)];
        CCMenuItemImage *highScoresButton = [CCMenuItemImage
                                             itemFromNormalImage:@"scores.png"
                                             selectedImage:@"scoresPushed.png"
                                             target:self
                                             selector:@selector(highScoreStart:)];
        CCMenu *menu = [CCMenu menuWithItems: helpButton, playButton, highScoresButton, nil];
        menu.position = ccp(winSize.width/2, winSize.height/2 - 60);
        [menu alignItemsHorizontallyWithPadding:1.0];
        [self addChild:menu];
        //CCMenu *menu2 = [CCMenu menuWithItems:highScoresButton, nil];
        //menu2.position = ccp(winSize.width/2, winSize.height/2-90);
        //[self addChild:menu2];
        
        self.isAccelerometerEnabled = YES;
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        [[GameCenterManager sharedGameCenterManager] authenticateLocalPlayer];

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

-(void) gameStart: (id) sender{
    paused = NO;
    [[SimpleAudioEngine sharedEngine] playEffect:@"start.caf"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
}

-(void) aboutStart: (id) sender{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[AboutScene scene]]];

}

- (void)highScoreStart: (id) sender{
    [[GameCenterManager sharedGameCenterManager] showLeaderboardForCategory:@"com.suaveapps.quadropong.score_"];
}

-(void) dealloc{
    [super dealloc];
}

@end
