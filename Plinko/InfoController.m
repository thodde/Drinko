//
//  InfoController.m
//  Plinko
//
//  Created by Trevor Hodde on 2/17/14.
//  Copyright (c) 2014 Josh Rooke-Ley. All rights reserved.
//

#import "InfoController.h"

@implementation InfoController

-(void)loadView {
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = btn;
    [btn release];
}

-(void)backPressed: (id)sender
{
    [self.navigationController popViewControllerAnimated: YES]; // or popToRoot... if required.
}

@end
