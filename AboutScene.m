//
//  AboutScene.m
//  quadropong
//
//  Created by Jonathan Hirz on 7/28/11.
//  Copyright 2011 SuaveApps. All rights reserved.
//

#import "AboutScene.h"
#import "MenuScene.h"


@implementation AboutScene

+(id) scene{
    
    CCScene *scene = [CCScene node];
    AboutScene *layer = [AboutScene node];
    [scene addChild:layer];
    return scene;
}

-(id) init{
    
    if ((self = [super init])){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCMenuItemImage *aboutScreen = [CCMenuItemImage 
                                        itemFromNormalImage:@"aboutScreen.png"
                                        selectedImage:@"aboutScreen.png"
                                        target:self
                                        selector:@selector(returnToMenu:)];
        CCMenu *menu = [CCMenu menuWithItems:aboutScreen, nil];
        menu.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:menu];
    }
    return self;
}

-(void) returnToMenu: (id) sender{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuScene scene]]];
}

@end
