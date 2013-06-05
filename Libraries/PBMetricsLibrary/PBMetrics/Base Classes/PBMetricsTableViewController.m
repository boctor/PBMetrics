//
//  PBMetricsTableViewController.m
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

#import "PBMetricsTableViewController.h"
#import "PBMetricsViewControllerHelper.h"

#define MAX_METRICS_STRING_LENGTH 128

@interface PBMetricsTableViewController ()
@property (strong, nonatomic) PBMetricsViewControllerHelper* metricsHelper;
@end

@implementation PBMetricsTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.metricsHelper = [[PBMetricsViewControllerHelper alloc] init];
}

- (void) viewDidAppear:(BOOL)animated
{
  [self.metricsHelper processViewDidAppear:self animated:animated];
  
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [self.metricsHelper processViewDidDisappear:self animated:animated];
  
  [super viewDidDisappear:animated];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self recordCellSelectionMetric:theTableView indexPath:indexPath];
}

- (void) recordCellSelectionMetric:(UITableView *)theTableView indexPath:(NSIndexPath *)indexPath
{
  [[PBMetricsManager instance] addTouchEvent:@{@"row:":[NSNumber numberWithInteger:indexPath.row], @"section:":[NSNumber numberWithInteger:indexPath.section], @"cell_text":[self metricsTextForRowAtIndexPath:indexPath tableView:theTableView], @"view_controller":[[PBMetricsManager instance] entryForObject:self]}];
}

-(NSArray*) metricsTextForRowAtIndexPath:(NSIndexPath*) indexPath tableView:(UITableView *)theTableView
{
  NSMutableArray* results = [NSMutableArray array];
  UITableViewCell * cell = [theTableView cellForRowAtIndexPath:indexPath];
  [self findText:cell results:results];
  return results;
}

- (void) findText:(UIView*)tableViewCell results:(NSMutableArray*)results
{
  for (UIView* subview in tableViewCell.subviews)
  {
    // UILable, UITextField and UITextView all have a text property
    if ([subview respondsToSelector:@selector(text)])
    {
      NSString* text = [subview performSelector:@selector(text)];
      [self addString:text toResults:results];
    }

    // UILable, UITextField and UITextView all also have an attributedText property
    if ([subview respondsToSelector:@selector(attributedText)])
    {
      NSAttributedString* attributedText = [subview performSelector:@selector(attributedText)];
      [self addString:attributedText.string toResults:results];
    }

    [self findText:subview results:results];
  }
}

- (void) addString:(NSString*)string toResults:(NSMutableArray*)results
{
  if (string && string.length > 0)
  {
    NSString* stringToAdd = nil;
    if (string.length <= MAX_METRICS_STRING_LENGTH)
      stringToAdd = string;
    else
      stringToAdd = [string substringToIndex:MAX_METRICS_STRING_LENGTH-1];
    
    if ([results indexOfObject:string] == NSNotFound)
      [results addObject:string];
  }
}

@end
