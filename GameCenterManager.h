//
//  GameCenterManager.h
//  quadropong
//
//  copied from http://ganbarugames.com/2011/07/cocos2d-game-center/
//
//
//  Created by Jonathan Hirz on 8/7/11.
//  Copyright 2011 SuaveApps. All rights reserved.
//

//#import "GameKit.h"
#import <GameKit/Gamekit.h>
#import "SynthesizeSingleton.h"

@interface GameCenterManager : NSObject <NSCoding, GKLeaderboardViewControllerDelegate> {
    
    BOOL hasGameCenter;
    NSMutableArray *unsentScores;
    UIViewController *myViewController;
}

@property (readwrite) BOOL hasGameCenter;
@property (readwrite, retain) NSMutableArray *unsentScores;

//SYNTHESIZE_SINGLETON_FOR_CLASS(GameCenterManager);

- (BOOL)isGameCenterAPIAvailable;
- (void)authenticateLocalPlayer;
- (void)reportScore:(int64_t)score forCategory:(NSString *)category;
- (void)showLeaderboardForCategory:(NSString *)category;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

+ (void)loadState;
+ (void)saveState;

+ (GameCenterManager *)sharedGameCenterManager;

@end
