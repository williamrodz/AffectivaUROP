//
//  FaceEventManager.m
//  AffdexMe
//
//  Created by Steve Phillips on 2/23/17.
//  Copyright © 2017 Affectiva. All rights reserved.
//

#import "FaceEventManager.h"

// ClassifierConfiguration

@interface ClassifierConfiguration : NSObject

@property (assign) CGFloat onThreshold;
@property (assign) CGFloat offThreshold;

@end

@implementation ClassifierConfiguration

- (id)initWithOnThreshold:(CGFloat)onThreshold offThreshold:(CGFloat)offThreshold;
{
    if (self = [super init])
    {
        _onThreshold = onThreshold;
        _offThreshold = offThreshold;
    }
    return self;
}

@end

// ClassifierInfo
@interface ClassifierInfo ()

@property (nonatomic, assign) CGFloat activeLevelSum;

@end

@implementation ClassifierInfo

- (id)initWithClassifierID:(kClassifierID)classifierID;
{
    if (self = [super init])
    {
        _classifierID = classifierID;
        _activeLevelSum = 0;
    }
    return self;
}

@end

// ClassifierState

@interface ClassifierState : NSObject

@property (nonatomic, assign) kClassifierID classifierID;
@property (assign) BOOL active;
@property (nonatomic, strong) ClassifierInfo *classifierInfo;

@end

@implementation ClassifierState

- (id)initWithClassifierID:(kClassifierID)classifierID;
{
    if (self = [super init])
    {
        self.classifierID = classifierID;
        self.classifierInfo = [[ClassifierInfo alloc] initWithClassifierID:classifierID];
        self.active = FALSE;
    }
    return self;
}

@end

// FaceInfo

@interface FaceInfo ()

@property (nonatomic, assign) CGFloat brightnessSum;

- (id)initWithFaceID:(NSInteger)faceID startTime:(NSTimeInterval)startTime;

@end

@implementation FaceInfo

- (id)initWithFaceID:(NSInteger)faceID startTime:(NSTimeInterval)startTime;
{
    if (self = [super init])
    {
        _faceID = faceID;
        _startTime = startTime;
        _frameCount = 0;
        _classifierActivationCount = 0;
        _brightnessSum = 0.0;
    }
    return self;
}

@end

// FaceState

@interface FaceState : NSObject

@property(nonatomic, strong) FaceInfo *faceInfo;
@property (nonatomic, strong) NSMutableArray<ClassifierState *> *classifierStates;

@end

@implementation FaceState

- (NSMutableArray<ClassifierState *> *)classifierStates;
{
    if (_classifierStates == nil) {
        _classifierStates = [[NSMutableArray alloc] init];
        for (int i=0; i<kClassifierIDCount; i++)
        {
            ClassifierState *classifierState = [[ClassifierState alloc] initWithClassifierID:(kClassifierID)i];
            [_classifierStates addObject:classifierState];
        }
    }
    return _classifierStates;
}

- (id)initWithFaceID:(NSInteger)faceID startTime:(NSTimeInterval)startTime;
{
    if (self = [super init])
    {
        self.faceInfo = [[FaceInfo alloc] initWithFaceID:faceID startTime:startTime];
    }
    return self;
}

@end

// FaceEventManager

@interface FaceEventManager ()

// Retain a weak reference to the delegate to avoid circular references which prevent proper deallocation.
@property(nonatomic, weak) id<FaceEventManagerDelegate> delegate;

@property(nonatomic, strong) NSMutableDictionary *faceStates;
@property(nonatomic, strong) NSMutableArray *classifierConfigurations;
@property(nonatomic, strong) NSArray<NSString *> *classifierNames;

@property (assign) long processedFrameCount;
@property (assign) long unprocessedFrameCount;

- (void)processClassifier:(kClassifierID)classifierID withLevel:(CGFloat)level faceState:(FaceState *)faceState atTime:(NSTimeInterval)time;

@end

@implementation FaceEventManager

- (NSMutableDictionary *)faceStates;
{
    if (_faceStates == nil) {
        _faceStates = [[NSMutableDictionary alloc] init];
    }
    return _faceStates;
}

- (NSArray<NSString *> *)classifierNames;
{
    if (_classifierNames == nil) {
        _classifierNames = [NSArray arrayWithObjects:
                            @"Anger", @"Contempt", @"Disgust", @"Engagement", @"Fear", @"Joy",
                            @"Sadness", @"Surprise", @"Positive Valence", @"Negative Valence",
                            @"Attention", @"Brow Furrow", @"Brow Raise", @"Chin Raise",
                            @"Eye Closure", @"Inner Brow Raise", @"Jaw Drop", @"Lid Tighten",
                            @"Lip Corner Depressor", @"Lip Press", @"Lip Pucker", @"Lip Stretch",
                            @"Lip Suck", @"Mouth Open", @"Nose Wrinkle", @"Smile", @"Smirk",
                            @"Upper Lip Raise",
                            nil];
    }
    return _classifierNames;
}

- (NSString *)nameForClassifier:(kClassifierID)classifierID;
{
    return [self.classifierNames objectAtIndex:classifierID];
}

- (NSMutableArray *)classifierConfigurations;
{
    if (_classifierConfigurations == nil) {
        _classifierConfigurations = [NSMutableArray arrayWithCapacity:kClassifierIDCount];
        for (int i=0; i<kClassifierIDCount; i++)
        {
            ClassifierConfiguration *classifierConfiguration = [[ClassifierConfiguration alloc] initWithOnThreshold:70.0 offThreshold:40.0];
            [_classifierConfigurations addObject:classifierConfiguration];
        }
    }
    return _classifierConfigurations;
}

- (id)initWithDelegate:(id<FaceEventManagerDelegate>)delegate;
{
    if (self = [super init])
    {
        self.delegate = delegate;
    }
    return self;
}

// Specify the activation and deactivation thresholds for the specified classifier.
- (void)setOnThreshold:(CGFloat)onThreshold offThreshold:(CGFloat)offThreshold forClassifier:(kClassifierID)classifierID;
{
    ClassifierConfiguration *classifierConfiguration = [self.classifierConfigurations objectAtIndex:classifierID];
    classifierConfiguration.onThreshold = onThreshold;
    classifierConfiguration.offThreshold = offThreshold;
}

- (void)processClassifier:(kClassifierID)classifierID withLevel:(CGFloat)level faceState:(FaceState *)faceState atTime:(NSTimeInterval)time;
{
    ClassifierConfiguration *classifierConfiguration = [self.classifierConfigurations objectAtIndex:classifierID];
    ClassifierState *classifierState = [faceState.classifierStates objectAtIndex:classifierID];
    ClassifierInfo *classifierInfo = classifierState.classifierInfo;

    if (classifierState.active == FALSE)
    {
        if (level >= classifierConfiguration.onThreshold)
        {
            // The event is starting.
            faceState.faceInfo.classifierActivationCount = faceState.faceInfo.classifierActivationCount + 1;

            classifierState.active = TRUE;
            classifierInfo.startFrameIndex = self.processedFrameCount;
            classifierInfo.startTime = time;
            classifierInfo.duration = 0.0;
            classifierInfo.activeLevelSum = level;
            classifierInfo.currentLevel = level;
            classifierInfo.peakLevel = level;
            classifierInfo.frameCount = 1;
            classifierInfo.averageLevel = classifierInfo.activeLevelSum / classifierInfo.frameCount;

            // Dispatch to delegate callback
            if ([self.delegate respondsToSelector:@selector(classifierActivated:forFace:)])
            {
                [self.delegate classifierActivated:classifierInfo forFace:faceState.faceInfo];
            }
        }
    }
    else  // (classifierState.active == TRUE)
    {
        if (level > classifierConfiguration.offThreshold)
        {
            // This is a continuation of a previously active event.
            classifierInfo.duration = time - classifierInfo.startTime;
            classifierInfo.activeLevelSum = classifierInfo.activeLevelSum + level;
            classifierInfo.currentLevel = level;
            if (classifierInfo.peakLevel < level)
            {
                classifierInfo.peakLevel = level;
            }
            classifierInfo.frameCount = classifierInfo.frameCount + 1;
            classifierInfo.averageLevel = classifierInfo.activeLevelSum / classifierInfo.frameCount;

            // Dispatch to delegate callback
            if ([self.delegate respondsToSelector:@selector(classifierActive:forFace:)])
            {
                [self.delegate classifierActive:classifierInfo forFace:faceState.faceInfo];
            }
        }
        else
        {
            // The event is deactivated.
            classifierState.active = FALSE;

            // Dispatch to delegate callback
            if ([self.delegate respondsToSelector:@selector(classifierDeactivated:forFace:)])
            {
                [self.delegate classifierDeactivated:classifierInfo forFace:faceState.faceInfo];
                classifierInfo.userInfo = nil;
            }
        }
    }
}

- (void)detector:(AFDXDetector *)detector hasResults:(NSMutableDictionary *)faces forImage:(NSImage *)image atTime:(NSTimeInterval)time;
{
    // For each frame, we will get a call with faces == nil before the image is processed, and
    // with faces set to an NSDictionary pointer after the frame is processed.  For a processed
    // frame call, this dictionary will be non-bull but zero-length if no faces were detected.
    // If the frame is internally dropped within the SDK, only an unprocessed call (faces == nil)
    // will be received for that frame.
    //
    if (faces != nil)
    {
        self.processedFrameCount++;
        NSMutableDictionary *newFaceStates = [[NSMutableDictionary alloc] init];

        for (AFDXFace *face in [faces allValues])
        {
            NSNumber *faceID = [NSNumber numberWithInteger:face.faceId];
            FaceState *faceState = [self.faceStates objectForKey:faceID];
            BOOL newFace = NO;

            if (faceState == nil)
            {
                // Create an entry for the face which just appeared.
                faceState = [[FaceState alloc] initWithFaceID:face.faceId startTime:time];
                faceState.faceInfo.startFrameIndex = self.processedFrameCount;
                newFace = YES;
            }
            else
            {
                // Remove the faceState entry from the input dictionary to confirm that we've processed it.
                [self.faceStates removeObjectForKey:faceID];
            }

            faceState.faceInfo.frameCount = faceState.faceInfo.frameCount + 1;
            faceState.faceInfo.duration = time - faceState.faceInfo.startTime;
            faceState.faceInfo.brightnessSum = faceState.faceInfo.brightnessSum + face.faceQuality.brightness;
            faceState.faceInfo.averageBrightness = faceState.faceInfo.brightnessSum / faceState.faceInfo.frameCount;

            // Store face positioning information.
            faceState.faceInfo.faceBounds = face.faceBounds;
            faceState.faceInfo.orientation = face.orientation;
            faceState.faceInfo.faceQuality = face.faceQuality;
            faceState.faceInfo.facePoints = face.facePoints;
            faceState.faceInfo.appearance = face.appearance;
            faceState.faceInfo.dominantEmoji = face.emojis.dominantEmoji;
            faceState.faceInfo.image = image;

            // Dispatch to delegate callback
            if (newFace)
            {
                if ([self.delegate respondsToSelector:@selector(faceFound:)])
                {
                    [self.delegate faceFound:faceState.faceInfo];
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(faceVisible:)])
                {
                    [self.delegate faceVisible:faceState.faceInfo];
                }
            }

            // Update the dictionary of active faces so we can check for any which have disappeared.
            [newFaceStates setObject:faceState forKey:faceID];

            // Update classifier states for this face.
            [self processClassifier:kClassifierIDEmotionAnger withLevel:face.emotions.anger faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionContempt withLevel:face.emotions.contempt faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionDisgust withLevel:face.emotions.disgust faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionEngagement withLevel:face.emotions.engagement faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionFear withLevel:face.emotions.fear faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionJoy withLevel:face.emotions.joy faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionSadness withLevel:face.emotions.sadness faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionSurprise withLevel:face.emotions.surprise faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionPositiveValence withLevel:face.emotions.valence faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDEmotionNegativeValence withLevel:-face.emotions.valence faceState:faceState atTime:time];

            [self processClassifier:kClassifierIDExpressionAttention withLevel:face.expressions.attention faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionBrowFurrow withLevel:face.expressions.browFurrow faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionBrowRaise withLevel:face.expressions.browRaise faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionChinRaise withLevel:face.expressions.chinRaise faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionEyeClosure withLevel:face.expressions.eyeClosure faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionInnerBrowRaise withLevel:face.expressions.innerBrowRaise faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionJawDrop withLevel:face.expressions.jawDrop faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionLidTighten withLevel:face.expressions.lidTighten faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionLipCornerDepressor withLevel:face.expressions.lipCornerDepressor faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionLipPress withLevel:face.expressions.lipPress faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionLipPucker withLevel:face.expressions.lipPucker faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionLipStretch withLevel:face.expressions.lipStretch faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionLipSuck withLevel:face.expressions.lipSuck faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionMouthOpen withLevel:face.expressions.mouthOpen faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionNoseWrinkle withLevel:face.expressions.noseWrinkle faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionSmile withLevel:face.expressions.smile faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionSmirk withLevel:face.expressions.smirk faceState:faceState atTime:time];
            [self processClassifier:kClassifierIDExpressionUpperLipRaise withLevel:face.expressions.upperLipRaise faceState:faceState atTime:time];
        }

        // Check for any faces which have disappeared.
        for (NSNumber *faceLostKey in [self.faceStates allKeys]) {
            FaceState *faceLostState = [self.faceStates objectForKey:faceLostKey];

            // Deactivate any active classifier events for this face.
            for (ClassifierState *classifierState in faceLostState.classifierStates)
            {
                if (classifierState.active)
                {
                    // The event is deactivated.
                    classifierState.active = FALSE;

                    // Dispatch to delegate callback
                    if ([self.delegate respondsToSelector:@selector(classifierDeactivated:forFace:)])
                    {
                        [self.delegate classifierDeactivated:classifierState.classifierInfo forFace:faceLostState.faceInfo];
                        classifierState.classifierInfo.userInfo = nil;
                    }
                }
            }

            // Dispatch to delegate callback
            if ([self.delegate respondsToSelector:@selector(faceLost:)])
            {
                [self.delegate faceLost:faceLostState.faceInfo];
                faceLostState.faceInfo.userInfo = nil;
            }
        }

        // Update the face state information for this frame.
        self.faceStates = newFaceStates;
    }
    else
    {
        self.unprocessedFrameCount++;
    }
}

// This method should be called from the detectorDidFinishProcessing delegate
// method to send deactivation events for any active faces or classifiers.
- (void)detectorDidFinishProcessing:(AFDXDetector *)detector;
{
    // Terminate all active faces.
    for (NSNumber *faceKey in [self.faceStates allKeys]) {
        FaceState *faceState = [self.faceStates objectForKey:faceKey];

        // Deactivate any active classifier events for this face.
        for (ClassifierState *classifierState in faceState.classifierStates)
        {
            if (classifierState.active)
            {
                // The event is deactivated.
                classifierState.active = FALSE;

                // Dispatch to delegate callback
                if ([self.delegate respondsToSelector:@selector(classifierDeactivated:forFace:)])
                {
                    [self.delegate classifierDeactivated:classifierState.classifierInfo forFace:faceState.faceInfo];
                    classifierState.classifierInfo.userInfo = nil;
                }
            }
        }

        // Dispatch to delegate callback
        if ([self.delegate respondsToSelector:@selector(faceLost:)])
        {
            [self.delegate faceLost:faceState.faceInfo];
            faceState.faceInfo.userInfo = nil;
        }
    }
    self.faceStates = nil;
}

@end
