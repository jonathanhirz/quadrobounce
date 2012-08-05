//
//  AppDelegate.h
//  quadropong
//
//  Created by Jonathan Hirz on 5/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
}

@property (nonatomic, retain) RootViewController *viewController;
@property (nonatomic, retain) UIWindow *window;

@end
