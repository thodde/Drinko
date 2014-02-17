//
//  MyScene.h
//  Drinko
//
//  Created by Trevor Hodde
//  Copyright (c) 2014 Trevor Hodde. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PlinkoScene : SKScene

extern SKSpriteNode *puck;
extern NSInteger puckCount;
extern NSInteger* MAX_PUCKS;
extern NSString* strNumberOfPlayers;
extern NSInteger* numberOfPlayers;
extern NSInteger* isFirstDrop;

extern NSTimer* timer;

@end
