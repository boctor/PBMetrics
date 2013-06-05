//
//  PBMetricsManager.m
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

#import "PBMetricsManager.h"
#import "KeenClient.h"
#import "UIDeviceHardware.h"

#define LAUNCH_METRICS_COLLECTION @"app_launch"
#define VIEWS_COLLECTION @"views"
#define TOUCHES_COLLECTION @"touches"
#define PUSHES_COLLECTION @"pushes"

#ifndef PB_LOG
#define PB_LOG NSLog
#endif

@interface PBMetricsManager ()
@property (strong, nonatomic) NSDate* sessionStartTime;
@property (strong, nonatomic) NSDictionary* sessionLaunchOptions;
@end

@implementation PBMetricsManager
static PBMetricsManager * _instance = nil;
+ (PBMetricsManager *) instance
{
  if (_instance == nil)
    _instance = [[PBMetricsManager alloc] init];

  return _instance;
}

- (id)init
{
  self = [super init];
  if (self)
  {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishLaunchingWithOptions:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
  }
  return self;
}

- (void)didFinishLaunchingWithOptions:(NSNotification *)notification
{
  NSDictionary* userInfo = [notification userInfo];
  [self startMetrics:userInfo];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
  [self startSession];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
  [self endSession];
  [self uploadMetricsInBackground];
}

-(void) startMetrics:(NSDictionary*)launchOptions
{
#ifdef DEBUG
 [KeenClient enableLogging];
#endif

  self.sessionLaunchOptions = launchOptions;
  NSAssert(self.keenProjectId && self.keenWriteyKey && self.keenReadKey, @"You must set your Keen project id, read key and write key!");
  KeenClient *client = [KeenClient sharedClientWithProjectId:self.keenProjectId andWriteKey:self.keenWriteyKey andReadKey:self.keenReadKey];

 if (client)
   client.globalPropertiesDictionary = [self globalProperties];
}

-(NSDictionary*)globalProperties
{
  NSMutableDictionary* standard_properties = [NSMutableDictionary dictionaryWithDictionary: @{
    @"model":[[UIDevice currentDevice] model], // iPhone
    @"system": [[UIDevice currentDevice] systemName], // iPhone OS
    @"system_version": [[UIDevice currentDevice] systemVersion], // 6.1.3
    @"device": [UIDeviceHardware platform], // iPhone5,1
    @"device_name": [UIDeviceHardware platformString], // iPhone 5 (GSM)
    @"app_build_number": [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"], // 20130425
    @"app_version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], // 1.0
    @"location_services_enabled": [CLLocationManager locationServicesEnabled] ? @"1" : @"0", // 1
    @"enabled_remote_notification_types": [self enabledRemoteNotificationTypes], // [UIRemoteNotificationTypeAlert]
    @"screen_scale": [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [NSNumber numberWithFloat:[UIScreen mainScreen].scale] : @1.0, // 2.0
    @"language": [NSLocale preferredLanguages][0], // en
    @"jb": [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt"] ? @"1" : @"0" // 0
    }];
  
  if (self.loggedIn)
    standard_properties[@"logged_in"] = [self.loggedIn boolValue] ? @"1" : @"0";
  
  if (self.loggedInUser)
    standard_properties[@"logged_in_user"] = self.loggedInUser;
  
  if (self.firstTimeAppLaunch)
    standard_properties[@"first_time_app_launch"] =  [self.firstTimeAppLaunch boolValue] ? @"1" : @"0";
    
    return @{@"standard_properties":standard_properties};
}

-(NSArray*)enabledRemoteNotificationTypes
{
  NSMutableArray* enabledTypesArray = [NSMutableArray array];
  UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
  if (enabledTypes & UIRemoteNotificationTypeNone)
    [enabledTypesArray addObject:@"UIRemoteNotificationTypeNone"];
  if (enabledTypes & UIRemoteNotificationTypeBadge)
    [enabledTypesArray addObject:@"UIRemoteNotificationTypeBadge"];
  if (enabledTypes & UIRemoteNotificationTypeSound)
    [enabledTypesArray addObject:@"UIRemoteNotificationTypeSound"];
  if (enabledTypes & UIRemoteNotificationTypeAlert)
    [enabledTypesArray addObject:@"UIRemoteNotificationTypeAlert"];
  if (enabledTypes & UIRemoteNotificationTypeNewsstandContentAvailability)
    [enabledTypesArray addObject:@"UIRemoteNotificationTypeNewsstandContentAvailability"];
  return enabledTypesArray;
}

-(void)uploadMetricsInBackground
{
  UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
    PB_LOG(@"Background task is being expired.");
  }];

  [[KeenClient sharedClient] uploadWithFinishedBlock:^(void) {
    [[UIApplication sharedApplication] endBackgroundTask:taskId];
  }];
}

-(void) startSession
{
  self.sessionStartTime = [NSDate date];
}

-(void) endSession
{
  NSDate* sessionEndTime = [NSDate date];
  NSNumber* sessionDuration = [NSNumber numberWithDouble:[sessionEndTime timeIntervalSinceDate:self.sessionStartTime]];
  NSMutableDictionary* sessionEvent = [NSMutableDictionary dictionaryWithDictionary:@{@"session_start":self.sessionStartTime, @"session_end":sessionEndTime, @"session_duration":sessionDuration}];
  if (self.sessionLaunchOptions)
  {
    sessionEvent[@"launch_options"] = self.sessionLaunchOptions;
    self.sessionLaunchOptions = nil;
  }
  [self addAppLaunchEvent:sessionEvent];
}

- (void) addViewEvent:(NSDictionary*)event
{
  [self recordEvent:event toEventCollection:VIEWS_COLLECTION withTimestamp:event[@"appear_time"]];
}

- (void) addTouchEvent:(NSDictionary*)event
{
  [self recordEvent:event toEventCollection:TOUCHES_COLLECTION];
}

- (void) addPushEvent:(NSDictionary*)event
{
  [self recordEvent:event toEventCollection:PUSHES_COLLECTION];
}

- (void) addAppLaunchEvent:(NSDictionary*)event
{
  [self recordEvent:event toEventCollection:LAUNCH_METRICS_COLLECTION];
}

- (void) recordEvent:(NSDictionary*)event toEventCollection:(NSString*)collection withTimestamp:(NSDate*)timestamp
{
  if (self.pauseMetrics) return;
  
  PB_LOG(@"Recording %@ metric: %@", collection, event);
  KeenProperties* keenProperties = [[KeenProperties alloc] init];
  keenProperties.timestamp = timestamp;
  [[KeenClient sharedClient] addEvent:event withKeenProperties:keenProperties toEventCollection:collection error:nil];
}

- (void) recordEvent:(NSDictionary*)event toEventCollection:(NSString*)collection
{
  if (self.pauseMetrics) return;
  
  PB_LOG(@"Recording %@ metric: %@", collection, event);
  [[KeenClient sharedClient] addEvent:event toEventCollection:collection error:nil];
}

- (id) entryForObject:(id)object
{
  if ([object respondsToSelector:@selector(metricsProperties)])
    return [object performSelector:@selector(metricsProperties)];
  return NSStringFromClass([object class]);
}

@end
