//
//  ViewController.m
//  SmoothScrollSample
//
//  Created by Ichito Nagata on 12/05/02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#define CELL_COUNT   100
#define CELL_HEIGHT   44

@implementation ViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsVerticalScrollIndicator = NO;
    
    _smoothScrollBar = [[[SmoothScrollBar alloc] initWithFrame:CGRectMake(304, 0, 16, 460)] retain];
    _smoothScrollBar.dataSource = self;
    _smoothScrollBar.delegate = self;
    _smoothScrollBar.alpha = 0;
    _smoothScrollBar.cursorHorizontalPadding = 2;
    [_smoothScrollBar setupCursor];
    [self.view addSubview:_smoothScrollBar];

}

#pragma mark - private
-(void)showOrHideSmoothScrollBar:(UIScrollView*)scrollView{

    BOOL show = ( _smoothScrollBar.isScrolling || [scrollView isDragging] || [scrollView isDecelerating]);
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.4];
    _smoothScrollBar.alpha = show ? 1 : 0;
    [UIView commitAnimations];
}

-(void)onTimer:(NSTimer*)timer{
    [self showOrHideSmoothScrollBar:[timer userInfo]];
}



#pragma mark - SmoothScrollDataSource

-(int)scrollMinValue {
    return 0;
}
-(int)scrollMaxValue {
    return CELL_COUNT - 1;
}
-(int)countPerOnePage {
    return ceil((double)_tableView.frame.size.height / CELL_HEIGHT);
}



#pragma mark - SmoothScrollDelegate
-(void)didValueChanged:(int)value {
    int index = value - [self scrollMinValue];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)didTouchesEnd {
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.6 target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark - UITableViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self showOrHideSmoothScrollBar:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidScroll");
    int contentOffsetY = scrollView.contentOffset.y;
    
    double value = (double)contentOffsetY / CELL_HEIGHT + [self scrollMinValue];
    [_smoothScrollBar setCursorValue:value];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.6 target:self selector:@selector(onTimer:) userInfo:scrollView repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(onTimer:) userInfo:scrollView repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CELL_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
    }

    cell.textLabel.text = [[[NSString alloc] initWithFormat:@"cell %d",  indexPath.row] autorelease];
    //NSLog(@"%f", cell.frame.size.height);
    return cell;
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    [_smoothScrollBar release];
}


@end
