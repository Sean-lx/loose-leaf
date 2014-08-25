//
//  MMCloudKitBaseState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMCloudKitBaseState : NSObject

#pragma mark - State

-(void) runState;

-(void) updateStateBasedOnError:(NSError*)err;

#pragma mark - Notifications

-(void) cloudKitInfoDidChange;

-(void) applicationDidBecomeActive;

-(void) reachabilityDidChange;

@end
