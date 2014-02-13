//
//  MyScene.m
//  Drinko
//
//  Created by Trevor Hodde
//  Copyright (c) 2014 Trevor Hodde. All rights reserved.
//

#import "PlinkoScene.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

// make the puck object global so we can track its position
SKSpriteNode *puck;

// this is responsible for tracking the number of pucks
NSInteger puckCount;

// Change this var if we want there to be more pucks per round
NSInteger const MAX_PUCKS = 1;

NSTimer *timer;

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
    for (int row=1;row<=rows;row++)
    {
        for (int col=1;col<=cols;col++)
        {
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
    
    if (node && ![node.name isEqualToString:@"puck"])
    {
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
    
    //SKAction *rotate = [SKAction repeatActionForever:[SKAction rotateByAngle:3.1416*2 duration:6.]];
    //[peg runAction:[SKAction sequence:@[[SKAction waitForDuration:.2 withRange:.8],rotate]]];
    
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
            alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Beer!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 1:
            alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Shot!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 2:
            alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"x2!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 3:
            alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Shot!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 4:
            alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Give one!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 5:
            alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Pass!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        case 6:
            alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Beer!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            break;
        default:
            break;
    }
    
    [alert show];
}

- (void)createPuck:(CGPoint)loc
{
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

- (NSInteger)isPuckResting
{
    if(puckCount > 0) {
        if(puck.position.y < 15) {
            if(timer) {
                [timer invalidate];
            }
            [self stopMotionUpdates];
        }
        return 1;
    }
    return 0;
}

//TODO: make this handle all of the buckets...
- (NSInteger)getPuckBucket
{
    if(puck.position.x > 0 && puck.position.x < self.frame.size.width / 6) {
        NSLog(@"X pos: %f", puck.position.x);
        return 0;
    }
    return 1;
}

- (void)startMotionUpdates
{
    if (!_motionManager)
        _motionManager =[[CMMotionManager alloc] init];
    
    _motionManager.deviceMotionUpdateInterval = 0.01;
    [_motionManager startDeviceMotionUpdates];
        
    timer = [NSTimer scheduledTimerWithTimeInterval:1/10 target:self selector:@selector(isPuckResting) userInfo:nil repeats:YES];
}

// TODO: make this repeat until there is no more motion and then print the bucket
- (void)stopMotionUpdates
{
    [_motionManager stopDeviceMotionUpdates];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1/10 target:self selector:@selector(getPuckBucket) userInfo:nil repeats:YES];

    //dummy bucket for now
    [self displayAlert:0];
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

@end
