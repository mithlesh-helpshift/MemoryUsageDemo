//
//  ViewController.m
//  MemoryUsageDemo
//
//  Created by Mithlesh Kumar Jha on 02/03/16.
//  Copyright © 2016 Mithlesh Kumar Jha. All rights reserved.
//

#import "ViewController.h"
#import "MemoryUsageController.h"

@interface ViewController () {
    MemoryUsageController *_controller;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _allocatedMemoryIndicator.progress = 0;
    
    _controller = [[MemoryUsageController alloc] init];
    
    uint64_t physicalMemoryInMB = [_controller physicalMemorySize] / BYTES_PER_MB;
    uint64_t userMemoryInMB = [_controller userMemorySize] / BYTES_PER_MB;
    
    float availableMemoryProgress = (float)userMemoryInMB / physicalMemoryInMB;
    _availableMemoryIndicator.progress = availableMemoryProgress;
    
    _lblTotalMemory.text = [NSString stringWithFormat:@"%llu MB", physicalMemoryInMB];
    _lblAvailableMemory.text = [NSString stringWithFormat:@"%llu MB", userMemoryInMB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAllocation:(id)sender {
    [_controller allocateMemoryUntilMemoryWarningWithCompletionHandler:
     ^(NSUInteger megaBytesAllocated, BOOL memoryWarningReceived){
         _lblMemoryUntilWarning.text = [NSString stringWithFormat:@"%lu MB", (unsigned long)megaBytesAllocated];
         uint64_t physicalMemoryInMB = [_controller physicalMemorySize] / BYTES_PER_MB;
         float progress = (float)megaBytesAllocated / physicalMemoryInMB;
         _allocatedMemoryIndicator.progress = progress;
         
         if (memoryWarningReceived == YES) {
             _lblMemoryUntilWarning.textColor = [UIColor redColor];
         }

        }
                    shouldContinueAllocatingEvenAfterMemoryWarning:YES];
}


@end
