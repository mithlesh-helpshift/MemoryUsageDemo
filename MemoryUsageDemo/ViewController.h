//
//  ViewController.h
//  MemoryUsageDemo
//
//  Created by Mithlesh Kumar Jha on 02/03/16.
//  Copyright © 2016 Mithlesh Kumar Jha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    IBOutlet UILabel *_lblTotalMemory;
    IBOutlet UILabel *_lblAvailableMemory;
    
    IBOutlet UILabel *_lblMemoryUntilWarning;
    IBOutlet UILabel *_lblMemoryWhenCrashed;
    
    IBOutlet UIProgressView *_availableMemoryIndicator;
    IBOutlet UIProgressView *_allocatedMemoryIndicator;
    
}

- (IBAction)startAllocation:(id)sender;

@end

