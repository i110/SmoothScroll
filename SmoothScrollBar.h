

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


#define DEFAULT_CURSOR_VERTICAL_PADDING  10
#define DEFAULT_CURSOR_HORIZONTAL_PADDING  3
#define MIN_CURSOR_HEIGHT 20

@protocol SmoothScrollDataSource;
@protocol SmoothScrollDelegate;


@interface SmoothScrollBar : UIView {

	id<SmoothScrollDataSource> dataSource;
	id<SmoothScrollDelegate> delegate;
    BOOL isScrolling;
	
	UIView *cursor;

    int cursorHeight;
	int cursorVerticalPadding;
	int cursorHorizontalPadding;
    
    BOOL _setCursorValueDisabled;
}

@property(nonatomic, retain) id<SmoothScrollDataSource> dataSource;
@property(nonatomic, retain) id<SmoothScrollDelegate> delegate;
@property(nonatomic) BOOL isScrolling;
@property(nonatomic) int cursorVerticalPadding;
@property(nonatomic) int cursorHorizontalPadding;

-(void)setupCursor;

-(void)setCursorValue:(double)value;

@end



@protocol SmoothScrollDataSource <NSObject>

-(int)scrollMinValue;
-(int)scrollMaxValue;
-(int)countPerOnePage;

@end

@protocol SmoothScrollDelegate <NSObject>


-(void)didValueChanged:(int)value;

@optional
-(void)didTouchesBegan;
-(void)didTouchesEnd;

@end

