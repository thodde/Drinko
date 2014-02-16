//
//  ViewController.m
//  Drinko
//
//  Created by Trevor Hodde
//  Copyright (c) 2014 Trevor Hodde. All rights reserved.
//

#import "ViewController.h"
#import "PlinkoScene.h"
#import <QuartzCore/QuartzCore.h>

UITextField *textField;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [PlinkoScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
        exit(0);
}

- (void)viewWillAppear:(BOOL)animated
{
    /*
     Probably dont need this now, but keep it in case we ever want to update and add more players
     
    // when the screen loads, ask the user for the number of players
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Drink-O" message:@"Enter the number of players:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    textField = [alertView textFieldAtIndex:0];
    [alertView show];
     */
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
