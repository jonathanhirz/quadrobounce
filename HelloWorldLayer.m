//
//  HelloWorldLayer.m
//  quadropong
//
//  Created by Jonathan Hirz on 5/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces

#import "HelloWorldLayer.h"
#import "CCTouchDispatcher.h"
#import "GameOverScene.h"
#import "PauseScene.h"
#import "MenuScene.h"
#import "CCTransition.h"
#import "SimpleAudioEngine.h"
#import "GameCenterManager.h"
//#import "cocos2d.h"

#define kSensitivity 50

CCSprite *paddleBottom;
CCSprite *paddleTop;
CCSprite *paddleLeft;
CCSprite *paddleRight;
CCSprite *ball;
CCMenu *pauseBarMenu;

NSString *theScore;

NSMutableArray *_paddlesX;
NSMutableArray *_paddlesY;


int velocityX;
int velocityY;
int buffer = 0;        //size of 'gutter' around the board. set dynamically in init so speed doesn't matter.
int score;
int bounceCount;
int maxSpeed = 5;
int adBarHeight;

float calibrationX;
float calibrationY;
float accelX;
float accelY;
int rightOrLeft;

BOOL paused = NO;

// HelloWorldLayer implementation
@implementation HelloWorldLayer


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	    
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(150,150,150,255)])) {
                
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile:@"menuScreen.png"];
        background.tag = 1;
        background.anchorPoint = CGPointMake(0,0);
        [self addChild:background];
        
        CCMenuItemImage *pauseButton = [CCMenuItemImage
                                        itemFromNormalImage:@"pauseButton.png"
                                        selectedImage:@"pauseButton.png"
                                        target:self
                                        selector:@selector(pauseGame:)];
        CCMenu *pauseButtonMenu = [CCMenu menuWithItems:pauseButton, nil];
        pauseButtonMenu.position = ccp(winSize.width - pauseButton.contentSize.width/2, 
                                       winSize.height - pauseButton.contentSize.height/2);
        [self addChild:pauseButtonMenu];
        
        _paddlesX = [[NSMutableArray alloc] init];
        _paddlesY = [[NSMutableArray alloc] init];
        
        //checking if IAP has been purchased or not. Make space for ads if they haven't paid.
        if (1) {
            adBarHeight = 0;
        }else {
            adBarHeight = 0;
        }
                
        //add bottom paddle sprite
        paddleBottom = [CCSprite spriteWithFile:@"paddle.png"];
        paddleBottom.position = ccp(winSize.width/2, paddleBottom.contentSize.height/2 + adBarHeight);
        [_paddlesX addObject:paddleBottom];
        [self addChild:paddleBottom];
        
        //add top paddle sprite
        paddleTop = [CCSprite spriteWithFile:@"paddle.png"];
        paddleTop.position = ccp(winSize.width/2, (winSize.height - paddleTop.contentSize.height/2));
        [_paddlesX addObject:paddleTop];
        [self addChild:paddleTop];
        
        //add left paddle sprite
        paddleLeft = [CCSprite spriteWithFile:@"paddle.png"];
        paddleLeft.rotation = 90;
        paddleLeft.position = ccp(paddleLeft.contentSize.height/2,winSize.height/2);
        //position relative stuff is annoying because contentSize.height/width is calculated BEFORE rotation. 
        //so height and width are switched to figure out where to place sprite at edge of screen.
        [_paddlesY addObject:paddleLeft];
        [self addChild:paddleLeft];
        
        //add right paddle sprite
        paddleRight = [CCSprite spriteWithFile:@"paddle.png"];
        paddleRight.rotation = 90;
        paddleRight.position = ccp((winSize.width - paddleRight.contentSize.height/2),winSize.height/2);
        [_paddlesY addObject:paddleRight];
        [self addChild:paddleRight];
        
        ball = [CCSprite spriteWithFile:@"ball.png"];
        [self addChild:ball];
        
        //reset variables at the start of the game
        int randomPosX = (arc4random() % 100) - 50;
        int randomPosY = (arc4random() % 80) - 70;
        ball.position = ccp(winSize.width/2 + randomPosX, winSize.height/2 + randomPosY);
        int randomXDirection = arc4random() % 2;        //random number from 0 - x-1 (in this case either a 0 or 1
        if (randomXDirection == 1){
            velocityX = 1;
        }else{
            velocityX = -1;
        }
        
        velocityY = 1;
        //if (velocityX > velocityY) { buffer = 18 - velocityX; } //trying to set the buffer to (20 - larger number)
        //if (velocityY > velocityX) { buffer = 18 - velocityY; } //if velX and velY are the same, buffer = 0
        score = 0;
        bounceCount = 0;
        
        //if greater than 1 (faster ball) it will skip over the paddle and 'game over' without bouncing
        //need to bounce before edge check, or increase buffer, or use actions to move ball...
        //which I probably should do in order to move at different angles.
                
        //schedule a repeating callback on every frame
        [self schedule:@selector(nextFrame:)];
        //self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
                
        }
	return self;
}

-(void) nextFrame:(ccTime)dt {
    //code that updates every frame
    //ball bouncing code could go here
        
    if (paused){
        [[CCDirector sharedDirector] pushScene:[PauseScene scene]];
        paused = NO;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    //update ball position
    ball.position = ccp(ball.position.x + velocityX, ball.position.y + velocityY);
    
    //update paddle positions
    paddleTop.position = ccp(paddleTop.position.x + accelX, paddleTop.position.y);
    paddleBottom.position = ccp(paddleBottom.position.x + accelX, paddleBottom.position.y);
    paddleLeft.position = ccp(paddleLeft.position.x, paddleLeft.position.y + accelY);
    paddleRight.position = ccp(paddleRight.position.x, paddleRight.position.y + accelY);
    
    //checking if paddles are at the screen's edges
    //if top (and consequently bottom) paddle reaches left side of screen, stop
    if (paddleTop.position.x < paddleTop.contentSize.width/2 + paddleTop.contentSize.height) {
        paddleTop.position = ccp(paddleTop.contentSize.width/2 + paddleTop.contentSize.height,paddleTop.position.y);
        paddleBottom.position = ccp(paddleBottom.contentSize.width/2 + paddleTop.contentSize.height,paddleBottom.position.y);
    }
    //if top (and...) paddle reaches right side of screen, stop
    if (paddleTop.position.x > (winSize.width - paddleTop.contentSize.width/2 - paddleTop.contentSize.height)) {
        paddleTop.position = ccp(winSize.width - paddleTop.contentSize.width/2 -paddleTop.contentSize.height,paddleTop.position.y);
        paddleBottom.position = ccp(winSize.width - paddleBottom.contentSize.width/2 - paddleTop.contentSize.height,paddleBottom.position.y);
    }
    //if left (and consequently right) paddle reaches bottom of screen, stop
    if (paddleLeft.position.y < paddleLeft.contentSize.width/2 + paddleTop.contentSize.height + adBarHeight) {
        paddleLeft.position = ccp(paddleLeft.position.x, paddleLeft.contentSize.width/2 + paddleTop.contentSize.height + adBarHeight);
        paddleRight.position = ccp(paddleRight.position.x, paddleRight.contentSize.width/2 + paddleTop.contentSize.height + adBarHeight);
    }
    //if left (and...) paddle reaches top of screen, stop
    if (paddleLeft.position.y > (winSize.height - paddleLeft.contentSize.width/2 - paddleTop.contentSize.height)){
        paddleLeft.position = ccp(paddleLeft.position.x, winSize.height - paddleLeft.contentSize.width/2 - paddleTop.contentSize.height);
        paddleRight.position = ccp(paddleRight.position.x, winSize.height - paddleRight.contentSize.width/2 - paddleTop.contentSize.height);
    }

    //make rect for ball
    CGRect ballRect = CGRectMake(ball.position.x - (ball.contentSize.width/2),
                                 ball.position.y - (ball.contentSize.height/2),
                                 ball.contentSize.width,
                                 ball.contentSize.height);
    
    //for top/bottom paddle, make a rect
    for (CCSprite *paddle in _paddlesX) {
        CGRect paddleRectX = CGRectMake(paddle.position.x - (paddle.contentSize.width/2),
                                        paddle.position.y - (paddle.contentSize.height/2),
                                        paddle.contentSize.width,
                                        paddle.contentSize.height);

        //check if they intersect
        if (CGRectIntersectsRect(paddleRectX, ballRect)){
            if (ball.position.y < winSize.height/2){
                ball.position = ccp(ball.position.x, 0 + paddle.contentSize.height + ball.contentSize.height/2 + adBarHeight);
            }else{
                ball.position = ccp(ball.position.x,  winSize.height - paddle.contentSize.height - ball.contentSize.height/2);
            }
            [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
            velocityY = -velocityY;
            score++;
            bounceCount++;
            if (bounceCount == 10){
                [[SimpleAudioEngine sharedEngine] playEffect:@"hitHigh.caf"];
                if ((abs(velocityX) < maxSpeed) || (abs(velocityY) < maxSpeed))
                {
                    if (velocityX > 0){
                        velocityX++;
                    }else{
                        velocityX--;
                    }
                    if (velocityY > 0){
                        velocityY++;
                    }else{
                        velocityY--;
                    }
                }
                bounceCount = 0;
            }
        }
    }
    //now the same for right/left paddles
    for (CCSprite *paddle in _paddlesY) {
        CGRect paddleRectY = CGRectMake(paddle.position.x - (paddle.contentSize.height/2),
                                        paddle.position.y - (paddle.contentSize.width/2),
                                        paddle.contentSize.height,
                                        paddle.contentSize.width);
        //height and width are backwards on this rect too, for the rotated paddles.

        //check if they intersect
        if (CGRectIntersectsRect(paddleRectY, ballRect)){
            if (ball.position.x < winSize.width/2){
                ball.position = ccp(0 + paddle.contentSize.height + ball.contentSize.width/2, ball.position.y);
            }else{
                ball.position = ccp(winSize.width - paddle.contentSize.height - ball.contentSize.width/2, ball.position.y);
            }
            [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
            velocityX = -velocityX;
            score++;
            bounceCount++;
            if (bounceCount == 10){
                [[SimpleAudioEngine sharedEngine] playEffect:@"hitHigh.caf"];
                if ((abs(velocityX) < maxSpeed) || (abs(velocityY) < maxSpeed))
                {
                    if (velocityX > 0){
                        velocityX++;
                    }else{
                        velocityX--;
                    }
                    if (velocityY > 0){
                        velocityY++;
                    }else{
                        velocityY--;
                    }
                }
                bounceCount = 0;
            }

        }
    }
    
    //if ball hits edge of the screen. there's got to be a better way to check this....
    if (ball.position.x < (0 + ball.contentSize.width/2 + buffer) ||                   //left edge
        ball.position.x > (winSize.width - ball.contentSize.width/2 - buffer) ||       //right edge
        ball.position.y < (0 + ball.contentSize.height/2 + buffer + adBarHeight) ||                  //bottom edge
        ball.position.y > (winSize.height - ball.contentSize.height/2 - buffer)) {     //top edge
        
        //game over man!
        //pause();  // find some way to pause for 1-2 seconds here, or fade the board away
        [[SimpleAudioEngine sharedEngine] playEffect:@"edge.caf"];
        [[GameCenterManager sharedGameCenterManager] reportScore:score forCategory:@"com.suaveapps.quadropong.score_"];
        GameOverScene *gameOverScene = [GameOverScene node];
        [gameOverScene.layer.label setString:@"Game Over!"];
        NSString *theScore = [NSString stringWithFormat:@"Score: %i", score];
        [gameOverScene.layer.score setString:theScore];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }
    
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    
        accelX = rightOrLeft * ((acceleration.y * -kSensitivity) - (calibrationX * -kSensitivity));
        accelY = rightOrLeft * ((acceleration.x * kSensitivity) - (calibrationY * kSensitivity));

}

/*
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
}
*/

-(void) pauseGame: (id) sender{
    [[CCDirector sharedDirector] pushScene:[PauseScene scene]];
    
}
/*
-(void) resumeGame: (id) sender{
    [self removeChild:pauseBarMenu cleanup:YES];
    [[CCDirector sharedDirector] resume];
}
*/



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{	
    [paddleBottom release];
    paddleBottom = nil;
    
    [paddleTop  release];
    paddleTop = nil;
    
    [paddleRight release];
    paddleRight = nil;
    
    [paddleLeft release];
    paddleLeft = nil;
        
    /*                  //for some reason, if either of these three below (ball, _paddlesX, paddlesY) are uncommented, CRASH
    [ball release];
    ball = nil;
    
    [_paddlesX release];
    _paddlesX = nil;
    
    [_paddlesY release];
    _paddlesY = nil;
    */
    // don't forget to call "super dealloc"
    [super dealloc];

}
@end
