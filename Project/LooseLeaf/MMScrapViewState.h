//
//  MMScrapViewState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JotUI/JotUI.h>
#import "MMScrapBackgroundView.h"
#import "MMScrapViewStateDelegate.h"
#import "MMScrapsOnPaperState.h"

@interface MMScrapViewState : NSObject<JotViewStateProxyDelegate>{
    __weak NSObject<MMScrapViewStateDelegate>* delegate;
    __weak MMScrapsOnPaperState* scrapsOnPaperState;
}

@property (weak) NSObject<MMScrapViewStateDelegate>* delegate;
@property (readonly) UIBezierPath* bezierPath;
@property (readonly) CGSize originalSize;
@property (readonly) UIView* contentView;
@property (readonly) CGRect drawableBounds;
@property (readonly) NSString* uuid;
@property (readonly) JotView* drawableView;
@property (readonly) NSString* pathForScrapAssets;
@property (nonatomic, readonly) int fullByteSize;

-(id) initWithUUID:(NSString*)uuid andPaperState:(MMScrapsOnPaperState*)scrapsOnPaperState;

-(id) initWithUUID:(NSString*)uuid andBezierPath:(UIBezierPath*)bezierPath andPaperState:(MMScrapsOnPaperState*)scrapsOnPaperState;

-(void) saveScrapStateToDisk:(void(^)(BOOL hadEditsToSave))doneSavingBlock;

-(void) loadScrapStateAsynchronously:(BOOL)async;

-(void) unloadState;

-(BOOL) isStateLoaded;

-(UIImage*) activeThumbnailImage;

-(void) addElements:(NSArray*)elements;
-(void) addUndoLevelAndFinishStroke;

-(JotGLTexture*) generateTexture;
-(void) importTexture:(JotGLTexture*)texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4;


-(MMScrapBackgroundView*) backgroundView;
-(void) setBackgroundView:(MMScrapBackgroundView*)backgroundView;
-(CGPoint) currentCenterOfScrapBackground;

-(UIView*) contentView;

+(NSString*) bundledScrapDirectoryPathForUUID:(NSString*)uuid;

@end
