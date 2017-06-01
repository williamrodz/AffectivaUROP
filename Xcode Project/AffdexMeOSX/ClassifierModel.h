//
//  ClassifierModel.h
//  AffdexMe
//
//  Created by Boisy Pitre on 3/15/16.
//  Copyright (c) 2017 Affectiva Inc.
//

#import <AppKit/AppKit.h>

@interface ClassifierModel : NSObject

@property (strong) NSString *name;
@property (strong) NSString *title;
@property (strong) NSString *scoreProperty;
@property (strong) NSImage *image;
@property (strong) NSURL *movieURL;
@property (strong) NSNumber *emojiCode;
@property (assign) BOOL enabled;

+ (NSMutableArray *)emotions;
+ (NSMutableArray *)expressions;
+ (NSMutableArray *)emojis;

+ (ClassifierModel *)modelWithName:(NSString *)name;

@end
