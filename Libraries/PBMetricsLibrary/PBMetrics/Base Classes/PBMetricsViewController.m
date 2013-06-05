//
//  PBMetricsViewController..m
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

#import "PBMetricsViewController.h"
#import "PBMetricsViewControllerHelper.h"

@interface PBMetricsViewController ()
@property (strong, nonatomic) PBMetricsViewControllerHelper* metricsHelper;
@end

@implementation PBMetricsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupMetrics];
}

- (void) viewDidAppear:(BOOL)animated
{
  [self processViewDidAppear:animated];
  
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [self processViewDidDisappear:animated];
  
  [super viewDidDisappear:animated];
}


- (void) setupMetrics
{
  self.metricsHelper = [[PBMetricsViewControllerHelper alloc] init];
}

- (void) processViewDidAppear:(BOOL)animated
{
  [self.metricsHelper processViewDidAppear:self animated:animated];
}

- (void) processViewDidDisappear:(BOOL)animated
{
  [self.metricsHelper processViewDidDisappear:self animated:animated];
}

@end
