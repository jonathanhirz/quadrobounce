//
//  GameCenterManager.m
//
//  copied from http://ganbarugames.com/2011/07/cocos2d-game-center/
//
//  quadropong
//
//  Created by Jonathan Hirz on 8/7/11.
//  Copyright 2011 SuaveApps. All rights reserved.
//


#import "GameCenterManager.h"
#import "cocos2d.h"
#import "MenuScene.h"


@implementation GameCenterManager

@synthesize hasGameCenter, unsentScores;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameCenterManager);

- (id)init{
    if ((self = [super init]))
    {
        if ([self isGameCenterAPIAvailable])
            hasGameCenter = YES;
        else
            hasGameCenter = NO;
    }
    return self;
}

- (BOOL)isGameCenterAPIAvailable{
    
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
}

- (void)authenticateLocalPlayer{
    if (hasGameCenter)
    {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
            if (localPlayer.isAuthenticated)
            {
                /* Perform additional tasks for authenticated player here */
                
                //if unsentScores  array has length > 0, try to send saved scores
                if ([unsentScores count] > 0)
                {
                    //create new array 
                    NSMutableArray *removedScores = [NSMutableArray array];
                    
                    for (GKScore *score in unsentScores)
                    {
                        [score reportScoreWithCompletionHandler:^(NSError *error) {
                            if (error != nil)
                            {
                                //if there's an error in reporting the score again, leave it in the array
                            }
                            else
                            {
                                [removedScores addObject:score];
                            }
                        }];
                    }
                    [unsentScores removeObjectsInArray:removedScores];
                }
            }
            else
            {
                hasGameCenter = NO;
            }
        }];
    }
}

- (void)reportScore:(int64_t)score forCategory:(NSString *)category{
    if (hasGameCenter){
        GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
        
        scoreReporter.value = score;
        
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil){
                [unsentScores addObject:scoreReporter];
            }
        }];
    }
}

- (void)showLeaderboardForCategory:(NSString *)category{
    if (hasGameCenter){
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
        
        if (leaderboardController != nil){
            leaderboardController.leaderboardDelegate = self;
            leaderboardController.category = category;
            leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
            
            myViewController  = [[UIViewController alloc] init];
            
            [[[[CCDirector sharedDirector] openGLView] window] addSubview:myViewController.view];
            
            [myViewController presentModalViewController:leaderboardController animated:YES];
        }
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
    [myViewController dismissModalViewControllerAnimated:NO];
    [myViewController.view removeFromSuperview];
    [myViewController release];
}

+ (void)loadState{
    @synchronized([GameCenterManager class])
    {
        if (!sharedGameCenterManager)
            [GameCenterManager sharedGameCenterManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *file = [documentsDirectory stringByAppendingPathComponent:@"GameCenterManager.bin"];
        Boolean saveFileExists = [[NSFileManager defaultManager] fileExistsAtPath:file];
        
        if (saveFileExists){
            [NSKeyedUnarchiver unarchiveObjectWithFile:file];
        }
    }
}

+ (void)saveState{
    @synchronized([GameCenterManager class])
    {
        GameCenterManager *state = [GameCenterManager sharedGameCenterManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *saveFile = [documentsDirectory stringByAppendingPathComponent:@"GameCenterManager.bin"];
        [NSKeyedArchiver archiveRootObject:state toFile:saveFile];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeBool:self.hasGameCenter forKey:@"hasGameCenter"];
    [coder encodeObject:self.unsentScores forKey:@"unsentScores"];
}

- (id)initWithCoder:(NSCoder *)coder{
    if ((self = [super init]))
    {
        self.hasGameCenter = [coder decodeBoolForKey:@"hasGameCenter"];
        self.unsentScores = [coder decodeObjectForKey:@"unsentScores"];
    }
    return self;
}

@end







