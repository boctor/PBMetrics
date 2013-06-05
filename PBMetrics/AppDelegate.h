//
//  AppDelegate.h
//  PBMetrics
//
//  Created by Peter Boctor on 6/4/13.
//
//

#import "PBMetricsTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PBMetricsTabBarController *tabBarController;

@end
