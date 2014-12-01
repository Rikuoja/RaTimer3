//
//  DismissSegue.m
//  RaTimer3
//
//  Created by Riku Oja on 2.12.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
