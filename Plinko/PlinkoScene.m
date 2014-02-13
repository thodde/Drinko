//
//  MyScene.m
//  Drinko
//
//  Created by Trevor Hodde
//  Copyright (c) 2014 Trevor Hodde. All rights reserved.
//

#import "PlinkoScene.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

// make the puck object global so we can track its position
SKSpriteNode *puck;

// this is responsible for tracking the number of pucks
NSInteger puckCount;

// Change this var if we want there to be more pucks per round
NSInteger const MAX_PUCKS = 1;

// use this timer a bunch for checking state information periodically
NSTimer *timer;

NSString *strNumberOfPlayers;
NSInteger *numberOfPlayers;

@implementation PlinkoScene
{
    CMMotionManager *_motionManager;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        [self createSceneContents];
    }
    return self;
}

// set up the environment -- probably use this to reset state information between rounds
- (void)createSceneContents
{
    self.backgroundColor = [SKColor blueColor];
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
    
    myLabel.fontColor = [SKColor yellowColor];
    myLabel.text = @"Drink-O";
    myLabel.fontSize = 40;
    
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)-80);
    
    CGSize inset = CGSizeMake(25, 25);
    CGRect pegRect = CGRectInset(self.frame, inset.width, inset.height);
    
    //Add the pegs...
    NSInteger cols = 6;
    NSInteger rows = 11;
    
    CGFloat rowSpacing = CGRectGetHeight(pegRect)/rows;
    CGFloat colSpacing = CGRectGetWidth(pegRect)/cols + 2;
    
    CGFloat  colOffset = inset.width-(colSpacing/2.);
    CGFloat  rowOffset = inset.height-(rowSpacing/2.);
    
    // These loops create all the pegs in alternating rows
    for (int row=1;row<=rows;row++) {
        for (int col=1;col<=cols;col++) {
            CGPoint loc = CGPointMake(colOffset+colSpacing*col,rowOffset+rowSpacing*row);
            BOOL isAltRow = (row % 2)==0;
            
            if (isAltRow && col == cols)
                continue;
            
            if (isAltRow)
                loc.x += colSpacing/2;
            
            SKSpriteNode *peg = [self createPeg:loc];
            if (isAltRow) {
                peg.color = [SKColor whiteColor];
            }
        }
    }
    
    // This loop creates the walls at the bottom of the game that separates each final position
    for(int wall=1; wall <= cols; wall++) {
        CGPoint wallLoc = CGPointMake(colOffset+colSpacing*wall, 10);
        [self createBucket:wallLoc];
    }
    
    [self addChild:myLabel];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [self startMotionUpdates];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint clickPoint = [touch locationInNode:self];

    SKNode *node = [self nodeAtPoint:clickPoint];
    
    if (node && ![node.name isEqualToString:@"puck"]) {
        // make sure the user cannot continuously drop pucks
        if(puckCount != MAX_PUCKS) {
            [self createPuck:clickPoint];
        }
    }
}

- (SKSpriteNode *)createPeg:(CGPoint)loc
{
    // Create the pegs -- try changing the sizes here
    SKSpriteNode *peg = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(8, 10)];
    peg.position = loc;
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:.6];
    [peg runAction:fadeIn];
    
    // prevents the ball from getting stuck... is it too weird?
    SKAction *rotate = [SKAction repeatActionForever:[SKAction rotateByAngle:3.1416*2 duration:6.]];
    [peg runAction:[SKAction sequence:@[[SKAction waitForDuration:.2 withRange:.8],rotate]]];
    
    peg.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, 1, 10)];
    peg.physicsBody.affectedByGravity = NO;
    
    [self addChild:peg];

    return peg;
}

// Tell the user what to drink based on where their puck landed
-(void)displayAlert:(NSInteger)bucket
{
    UIAlertView* alert;
    switch (bucket) {
        case 0:
            alert = [[UIAlertView alloc] initWithTitle:@"Drink-O" message:@"Drink a Beer!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 1:
            alert = [[UIAlertView alloc] initWithTitle:@"Drink-O" message:@"Take a Shot!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 2:
            alert = [[UIAlertView alloc] initWithTitle:@"Drink-O" message:@"Drink x2!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 3:
            alert = [[UIAlertView alloc] initWithTitle:@"Drink-O" message:@"Pass!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 4:
            alert = [[UIAlertView alloc] initWithTitle:@"Drink-O" message:@"Give a Drink!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 5:
            alert = [[UIAlertView alloc] initWithTitle:@"Drink-O" message:@"Take a Shot!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        default:
            alert = [[UIAlertView alloc] initWithTitle:@"Drink-O" message:@"Drink a Beer!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
    }
    
    [alert show];
}

// set up the puck and all its state info
- (void)createPuck:(CGPoint)loc
{
    // by the time we reach this point, we know how many players there are
    strNumberOfPlayers = textField.text;
    numberOfPlayers = (NSInteger*)[strNumberOfPlayers intValue];
    
    puck = [SKSpriteNode spriteNodeWithImageNamed:@"puck"];
    puck.name = @"puck";
    puck.position = loc;
    puck.alpha = 0.;
    puck.size = CGSizeMake(1, 1);
    
    puck.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
    puck.physicsBody.restitution = .7;
    puck.physicsBody.dynamic = YES;
    puckCount = puckCount + 1;

    SKAction *fadeIn = [SKAction fadeInWithDuration:.6];
    SKAction *scale = [SKAction scaleBy:20 duration:.3];
    [puck runAction:[SKAction group:@[fadeIn,scale]]];
    
    [self addChild:puck];
}

// Determine if the puck has stopped moving
- (NSInteger)isPuckResting
{
    // make sure the puck exists -- CHANGE THIS if we ever decide to add more pucks
    if(puckCount > 0) {
        // check if the puck has reached the bottom of the screen
        if(puck.position.y < 15) {
            // kill the timer once the puck stops
            if(timer) {
                [timer invalidate];
            }
            //stop checking the state of motion
            [self stopMotionUpdates];
        }
        return 1;
    }
    return 0;
}

// Use the position of the puck to determine which bucket
// it fell into
- (NSInteger)getPuckBucket
{
    // kill the timer if its still running
    if(timer)
        [timer invalidate];
    
    if(puck.position.x >= 0 && (puck.position.x <= self.frame.size.width / 6)) {
        //NSLog(@"Beer: X pos: %f", puck.position.x);
        return 0;
    }
    else if(puck.position.x > (self.frame.size.width / 6) && (puck.position.x <= (self.frame.size.width / 6)*2)) {
        //NSLog(@"Shot: X pos: %f", puck.position.x);
        return 1;
    }
    else if(puck.position.x > (self.frame.size.width / 6)*2 && (puck.position.x <= (self.frame.size.width / 6)*3)) {
        //NSLog(@"x2: X pos: %f", puck.position.x);
        return 2;
    }
    else if(puck.position.x > (self.frame.size.width / 6)*3 && (puck.position.x <= (self.frame.size.width / 6)*4)) {
        //NSLog(@"Pass: X pos: %f", puck.position.x);
        return 3;
    }
    else if(puck.position.x > (self.frame.size.width / 6)*4 && (puck.position.x <= (self.frame.size.width / 6)*5)) {
        //NSLog(@"Give: X pos: %f", puck.position.x);
        return 4;
    }
    else if(puck.position.x > (self.frame.size.width / 6)*5) {
        //NSLog(@"Shot: X pos: %f", puck.position.x);
        return 5;
    }
    else
        return 0;
}

// check for motion updates periodically
- (void)startMotionUpdates
{
    //set up the motion manager
    if (!_motionManager)
        _motionManager =[[CMMotionManager alloc] init];
    
    // check every 1 ms for changes
    _motionManager.deviceMotionUpdateInterval = 0.01;
    [_motionManager startDeviceMotionUpdates];
    
    // go see if the puck is at rest every 1 ms until it is actually at rest
    timer = [NSTimer scheduledTimerWithTimeInterval:1/10 target:self selector:@selector(isPuckResting) userInfo:nil repeats:YES];
}

// end all motion management
- (void)stopMotionUpdates
{
    [_motionManager stopDeviceMotionUpdates];
    
    // determine the bucket the puck is sitting in
    timer = [NSTimer scheduledTimerWithTimeInterval:1/10 target:self selector:@selector(getPuckBucket) userInfo:nil repeats:YES];
    
    NSInteger bucket = [self getPuckBucket];

    // display what to do based on the puck location
    [self displayAlert:bucket];
}

// Create the bottom buckets
- (SKSpriteNode *)createBucket:(CGPoint)loc
{
    // Create the buckets at the bottom of the screen
    SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(2, 40)];
    line.position = loc;
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:.6];
    [line runAction:fadeIn];
    
    line.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, 1, 10)];
    line.physicsBody.affectedByGravity = NO;
    
    [self addChild:line];
    
    return line;
}

// used for resetting the game once the user has played a round
- (void)resetAllStates
{
    puckCount = 0;
    puck = nil;
    timer = nil;
    _motionManager = nil;
    strNumberOfPlayers = @"";
    numberOfPlayers = 0;
}

@end
