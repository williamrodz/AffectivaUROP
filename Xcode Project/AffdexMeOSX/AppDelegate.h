//
//  AppDelegate.h
//  AffdexMeOSX
//
//  Created by Boisy Pitre on 11/15/14.
//  Copyright (c) 2014 Affectiva. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AffdexMeViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *hudWindow;
@property (weak) IBOutlet AffdexMeViewController *vc;

@end

