

#import "SmoothScrollBar.h"


@implementation SmoothScrollBar

@synthesize dataSource;
@synthesize delegate;
@synthesize isScrolling;
@synthesize cursorVerticalPadding;
@synthesize cursorHorizontalPadding;

#pragma mark -
#pragma mark Private

-(void)checkRange:(int)min max:(int)max{
	if(min < 0 || min > max)
		@throw [NSException exceptionWithName:@"InvalidRangeException" reason:@"" userInfo:nil];
}

-(int)calcCursorHeight{
	int min = [self.dataSource scrollMinValue];
	int max = [self.dataSource scrollMaxValue];
	[self checkRange:min max:max];
	int height = self.frame.size.height - self.cursorVerticalPadding * 2;
	
	int cpop = [self.dataSource countPerOnePage];
	int ret = height * ((double)cpop / (max - min + 1));
	if(ret < MIN_CURSOR_HEIGHT) {
        ret = MIN_CURSOR_HEIGHT;
    }
    
    return ret;
}

-(BOOL)checkDataSourceIsValid{
	return dataSource != nil && [dataSource respondsToSelector:@selector(scrollMinValue)] && [dataSource respondsToSelector:@selector(scrollMaxValue)];
}
-(BOOL)checkDelegateIsValid{
	return delegate != nil && [delegate respondsToSelector:@selector(didValueChanged:)];
}

-(int)calcValue:(CGPoint)point{
	int min = [self.dataSource scrollMinValue];
	int max = [self.dataSource scrollMaxValue];
	[self checkRange:min max:max];
	int height = self.frame.size.height - self.cursorVerticalPadding * 2;
	int y = point.y - (cursorHeight / 2);
	
	int ret = (double)y / ((double)height / (max - min + 1)) + min;
	
	if(ret < min) ret = min;
	if(ret > max) ret = max;

	return ret;
	
}
-(int)calcCursorY:(CGPoint)point{
	int ret = point.y - (cursorHeight / 2);
	if(ret < self.cursorVerticalPadding) {
        ret = self.cursorVerticalPadding;
    }
	if(ret + cursorHeight > self.frame.size.height - self.cursorVerticalPadding) {
        ret = self.frame.size.height - self.cursorVerticalPadding - cursorHeight;
    }
	
	return ret;
}

#pragma mark -
#pragma mark NSObject

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];

    }
    self.cursorVerticalPadding = DEFAULT_CURSOR_VERTICAL_PADDING;
    self.cursorHorizontalPadding = DEFAULT_CURSOR_HORIZONTAL_PADDING;
    [self setupCursor];
    return self;
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark SmoothScrollBar

// this must be called when reset paddings or cell-count has been changed
-(void)setupCursor{
	
    if (cursor != nil) {
        [cursor removeFromSuperview];
        cursor = nil;
    }
    
	cursorHeight = [self calcCursorHeight];
    
    CGRect cursorRect = CGRectMake(
                                   self.cursorHorizontalPadding, 
                                   self.cursorVerticalPadding, 
                                   self.frame.size.width - self.cursorHorizontalPadding * 2, 
                                   cursorHeight);
	
    cursor = [[UIView alloc] initWithFrame:cursorRect];

	cursor.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
	cursor.layer.cornerRadius = 8.0f;
	cursor.layer.masksToBounds = YES;
	[self addSubview:cursor];	
}

-(void)setCursorValue:(double)value{
    if (_setCursorValueDisabled) return;

	int max = [self.dataSource scrollMaxValue];
	int min = [self.dataSource scrollMinValue];
	[self checkRange:min max:max];
	int height = self.frame.size.height - self.cursorVerticalPadding * 2;
	
	if(value > max) value = max;
	if(value < min) value = min;
	
	int y = (value - min) / (max - min + 1) * height + self.cursorVerticalPadding;
	if(y < self.cursorVerticalPadding) {
        y = self.cursorVerticalPadding;
    }
	if(y > self.frame.size.height - self.cursorVerticalPadding - cursorHeight) {
        y = self.frame.size.height - self.cursorVerticalPadding - cursorHeight;
    }


	CGRect fr = cursor.frame;
	fr.origin.y = y;
	cursor.frame = fr;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

-(void)onTouches:(NSSet *)touches withEvent:(UIEvent *)event{
	if(! [self checkDataSourceIsValid]) return;
	CGPoint point = [[touches anyObject] locationInView:self];
	int value = [self calcValue:point];
	
	CGRect fr = cursor.frame;
	fr.origin.y = [self calcCursorY:point];
	fr.size.height = cursorHeight;

	cursor.frame = fr;

	if([self checkDelegateIsValid]){
        // disable setCursorValue to avoid self feedback
        _setCursorValueDisabled = YES;
		[self.delegate didValueChanged:value];
        _setCursorValueDisabled = NO;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[self onTouches:touches withEvent:event];
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    
    self.isScrolling = YES;
	
	if([self checkDelegateIsValid] && [self.delegate respondsToSelector:@selector(didTouchesBegan)]){
		[self.delegate didTouchesBegan];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self onTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self onTouches:touches withEvent:event];
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    self.isScrolling = NO;
	
	if([self checkDelegateIsValid] && [self.delegate respondsToSelector:@selector(didTouchesEnd)]){
		[self.delegate didTouchesEnd];
	}
}

@end
