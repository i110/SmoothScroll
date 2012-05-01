//
//  ViewController.h
//  SmoothScrollSample
//
//  Created by Ichito Nagata on 12/05/02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmoothScrollBar.h"

@interface ViewController : UIViewController 
    <UITableViewDataSource, 
     UITableViewDelegate, 
     SmoothScrollDataSource, 
     SmoothScrollDelegate>
{

         
    IBOutlet UITableView *_tableView;
    SmoothScrollBar *_smoothScrollBar;
}

@end
