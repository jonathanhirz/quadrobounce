//
//  PauseScene.m
//  quadropong
//
//  Created by Jonathan Hirz on 6/23/11.
//  Copyright 2011 SuaveApps. All rights reserved.
//

#import "PauseScene.h"
#import "HelloWorldLayer.h"
#import "CCTransition.h"
#import "GameCenterManager.h"

extern float calibrationX;
extern float calibrationY;
extern int rightOrLeft;
extern BOOL paused;

@implementation PauseScene

+(id) scene{
    
    CCScene *scene = [CCScene node];
    PauseScene *layer = [PauseScene node];
    [scene addChild:layer];
    return scene;
}

-(id) init{
    if ((self = [super initWithColor:ccc4(150,150,150,255)])){
        
        [[CCDirector sharedDirector] pause];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile:@"menuScreen.png"];
        background.tag = 1;
        background.anchorPoint = CGPointMake(0,0);
        [self addChild:background];
        
        CCMenuItemImage *pauseBar = [CCMenuItemImage
                                       itemFromNormalImage:@"pauseBar.png" 
                                       selectedImage:@"pauseBar.png"
                                       target:self
                                       selector:@selector(resumeGame:)];
        CCMenu *menu = [CCMenu menuWithItems:pauseBar, nil];
        menu.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:menu];
        
        self.isAccelerometerEnabled = YES;
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        
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


-(void) resumeGame: (id) sender{
    paused = NO;
    //[[GameCenterManager sharedGameCenterManager] authenticateLocalPlayer];
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] popScene];
}

-(void) dealloc{
    [super dealloc];
}

@end
