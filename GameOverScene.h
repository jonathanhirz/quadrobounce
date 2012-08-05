//
//  GameOverScene.h
//  quadropong
//
//  Created by Jonathan Hirz on 5/18/11.
//  Copyright 2011 SuaveApps. All rights reserved.
//

#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor {
    CCLabelTTF *_label;
    CCLabelTTF *_score;
}

@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, retain) CCLabelTTF *score;
@end

@interface GameOverScene : CCScene {
    GameOverLayer *_layer;
    
}
@property (nonatomic, retain) GameOverLayer *layer;
@end

