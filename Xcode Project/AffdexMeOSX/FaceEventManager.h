//
//  FaceEventManager.h
//  AffdexMe
//
//  Created by Steve Phillips on 2/23/17.
//  Copyright © 2017 Affectiva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Affdex/Affdex.h>

typedef enum kClassifierID {
    kClassifierIDFirstEmotion = 0,
    kClassifierIDEmotionAnger = kClassifierIDFirstEmotion,
    kClassifierIDEmotionContempt,
    kClassifierIDEmotionDisgust,
    kClassifierIDEmotionEngagement,
    kClassifierIDEmotionFear,
    kClassifierIDEmotionJoy,
    kClassifierIDEmotionSadness,
    kClassifierIDEmotionSurprise,
    kClassifierIDEmotionPositiveValence,
    kClassifierIDEmotionNegativeValence,
    kClassifierIDLastEmotion = kClassifierIDEmotionNegativeValence,

    // Expressions
    kClassifierIDFirstExpression,
    kClassifierIDExpressionAttention = kClassifierIDFirstExpression,
    kClassifierIDExpressionBrowFurrow,
    kClassifierIDExpressionBrowRaise,
    kClassifierIDExpressionChinRaise,
    kClassifierIDExpressionEyeClosure,
    kClassifierIDExpressionInnerBrowRaise,
    kClassifierIDExpressionJawDrop,
    kClassifierIDExpressionLidTighten,
    kClassifierIDExpressionLipCornerDepressor,
    kClassifierIDExpressionLipPress,
    kClassifierIDExpressionLipPucker,
    kClassifierIDExpressionLipStretch,
    kClassifierIDExpressionLipSuck,
    kClassifierIDExpressionMouthOpen,
    kClassifierIDExpressionNoseWrinkle,
    kClassifierIDExpressionSmile,
    kClassifierIDExpressionSmirk,
    kClassifierIDExpressionUpperLipRaise,
    kClassifierIDLastExpression = kClassifierIDExpressionUpperLipRaise,

    // must be last
    kClassifierIDCount
} kClassifierID;

#define CLASSIFIER_IS_EMOTION(classifierID) ((((int)(classifierID)) >= ((int)(kClassifierIDFirstEmotion))) && \
                                             (((int)(classifierID)) <= ((int)(kClassifierIDLastEmotion))))

#define CLASSIFIER_IS_EXPRESSION(classifierID) ((((int)(classifierID)) >= ((int)(kClassifierIDFirstExpression))) && \
                                                (((int)(classifierID)) <= ((int)(kClassifierIDLastExpression))))

// This structure contains information about a currently active face.
@interface FaceInfo : NSObject

@property (nonatomic, strong) id userInfo;                           // Delegate can store arbitrary objects through a faceFound/faceVisible/FaceLost event cycle.
@property (nonatomic, assign) NSInteger faceID;                      // ID of this face
@property (nonatomic, assign) NSTimeInterval startTime;              // Face detection start time.
@property (nonatomic, assign) NSTimeInterval duration;               // Face detection duration time.
@property (nonatomic, assign) NSInteger startFrameIndex;             // Index of the frame when the face first came into view.
@property (nonatomic, assign) NSInteger frameCount;                  // Count of processed frames for this face.
@property (nonatomic, assign) NSInteger classifierActivationCount;   // Number of classifier activations for this face.
@property (nonatomic, assign) CGFloat averageBrightness;             // Average face brightness during the time it is visible.

@property (nonatomic, assign) CGRect faceBounds;                     // Face bounding rectangle
@property (nonatomic, strong) AFDXOrientation *orientation;          // Face orientation angles
@property (nonatomic, strong) AFDXFaceQuality *faceQuality;          // Face brightness level
@property (nonatomic, strong) NSArray<NSValue *> *facePoints;        // Face points
@property (nonatomic, strong) AFDXAppearance *appearance;            // Age/ethnicity/gender/glasses
@property (nonatomic, assign) Emoji dominantEmoji;                   // Dominant emoji
@property (nonatomic, strong) NSImage *image;                        // Original processed image

@end

// This structure contains information about a currently active classifier.
@interface ClassifierInfo : NSObject

@property (nonatomic, strong) id userInfo;                           // Delegate can store arbitrary objects through a classifierActivated/classifierActive/classifierDeactivated event cycle.
@property (nonatomic, assign) kClassifierID classifierID;            // ID of the emotion/expression for this classifier.
@property (nonatomic, assign) NSTimeInterval startTime;              // Expression detection start time (seconds).
@property (nonatomic, assign) NSTimeInterval duration;               // Expression detection duration (seconds).
@property (nonatomic, assign) NSInteger startFrameIndex;             // Processed frame index when the classifier was first activated.
@property (nonatomic, assign) NSInteger frameCount;                  // Count of processed frames for this classifier activation.
@property (nonatomic, assign) CGFloat currentLevel;                  // Current classifier level.
@property (nonatomic, assign) CGFloat averageLevel;                  // Average classifier level over this activation.
@property (nonatomic, assign) CGFloat peakLevel;                     // Peak classifier level over this activation.

@end

// This protocol defines the events which will be sent back to the delegate.

@protocol FaceEventManagerDelegate <NSObject>

@required

@optional

// Called once when the face is found.
- (void)faceFound:(FaceInfo *)faceInfo;

// Called for every subsequent frame while the face is active.
- (void)faceVisible:(FaceInfo *)faceInfo;

// Called when the face is lost.
- (void)faceLost:(FaceInfo *)faceInfo;

// Called once when the classifier is activated.
- (void)classifierActivated:(ClassifierInfo *)classifierInfo forFace:(FaceInfo *)faceInfo;

// Called for every subsequent frame while the classifier is active.
- (void)classifierActive:(ClassifierInfo *)classifierInfo forFace:(FaceInfo *)faceInfo;

// Called once when the classifier is deactivated.
- (void)classifierDeactivated:(ClassifierInfo *)classifierInfo forFace:(FaceInfo *)faceInfo;

@end

@interface FaceEventManager : NSObject

// Initialize the face event manager with the specified delegate class to receive event notifications.
- (id)initWithDelegate:(id<FaceEventManagerDelegate>)delegate;

// Return a descriptive name for a classifier.
- (NSString *)nameForClassifier:(kClassifierID)classifierID;

// Specify the activation and deactivation thresholds for the specified classifier.  This setting applies to all faces.
- (void)setOnThreshold:(CGFloat)onThreshold offThreshold:(CGFloat)offThreshold forClassifier:(kClassifierID)classifierID;

// The following two methods are required only because the event framework code is currently written at the application level.

// This method takes the same arguments as the detector hasResults method and can be dispatched directly.
// Will not be needed once this code is moved inside the SDK.
- (void)detector:(AFDXDetector *)detector hasResults:(NSMutableDictionary *)faces forImage:(NSImage *)image atTime:(NSTimeInterval)time;

// This method takes the same arguments as the detectorDidFinishProcessing method and can be dispatched directly.
// Will not be needed once this code is moved inside the SDK.
- (void)detectorDidFinishProcessing:(AFDXDetector *)detector;

@end
