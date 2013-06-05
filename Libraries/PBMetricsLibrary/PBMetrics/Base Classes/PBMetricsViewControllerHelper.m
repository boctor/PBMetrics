//
//  PBMetricsViewControllerHelper.m
//
// Copyright (c) 2013 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "PBMetricsViewControllerHelper.h"
#import "PBMetricsViewController.h"

@interface PBMetricsViewControllerHelper ()
@property (strong, nonatomic) NSDate* viewDidAppearTime;
@property (strong, nonatomic) NSMutableDictionary* eventData;
@end

@implementation PBMetricsViewControllerHelper

- (void) processViewDidAppear:(UIViewController*)viewController animated:(BOOL)animated
{
  self.eventData = [NSMutableDictionary dictionary];

  self.eventData[@"class_name"] = [[PBMetricsManager instance] entryForObject:viewController];
  
  self.viewDidAppearTime = [NSDate date];
  self.eventData[@"appear_time"] = self.viewDidAppearTime;

  self.eventData[@"is_moving_to_parent_view_controller"] = [NSNumber numberWithBool:[viewController isMovingToParentViewController]];
  self.eventData[@"was_pushed"] = [NSNumber numberWithBool:[viewController isMovingToParentViewController]];
  self.eventData[@"is_being_presented"] = [NSNumber numberWithBool:[viewController isBeingPresented]];
  self.eventData[@"appeared_animated"] = [NSNumber numberWithBool:animated];
}

- (void) processViewDidDisappear:(UIViewController*)viewController animated:(BOOL)animated
{
  NSDate* viewDidDisappearTime = [NSDate date];
  self.eventData[@"disappear_time"] = viewDidDisappearTime;

  NSNumber* viewAppearanceDuration = [NSNumber numberWithDouble:[viewDidDisappearTime timeIntervalSinceDate:self.viewDidAppearTime]];
  self.eventData[@"appearance_duration"] = viewAppearanceDuration;
  
  self.eventData[@"is_moving_from_parent_view_controller"] = [NSNumber numberWithBool:[viewController isMovingFromParentViewController]];
  self.eventData[@"was_popped"] = [NSNumber numberWithBool:[viewController isMovingFromParentViewController]];
  self.eventData[@"is_being_dismissed"] = [NSNumber numberWithBool:[viewController isBeingDismissed]];
  self.eventData[@"disappeared_animated"] = [NSNumber numberWithBool:animated];

  [[PBMetricsManager instance] addViewEvent:self.eventData];
}

@end
