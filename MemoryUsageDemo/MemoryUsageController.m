//
//  MemoryUsageController.m
//  MemoryUsageDemo
//
//  Created by Mithlesh Kumar Jha on 02/03/16.
//  Copyright © 2016 Mithlesh Kumar Jha. All rights reserved.
//

#import "MemoryUsageController.h"
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <sys/types.h>

#define kUserDefaultsLastAllocationUntilWarningReached @"UDLAUWR"
#define kUserDefaultsLastAllocationUntilCarningReached @"UDLAUCR"

@interface MemoryUsageController() {
    BOOL memoryWarningReceived;
    BOOL continueAllocationAfterWarning;
    
    NSUInteger allocatedDataInMB;
    Byte *allocatedData[1000];
    
    dispatch_queue_t memoryAllocatorWorkingQueue;
    uint64_t _usrMemorySize;
    uint64_t _physicalMemorySize;
    
}

@property (nonatomic, copy) MemoryAllocationCompletionHandler completionHandlerCopy;

@end

@implementation MemoryUsageController

#pragma mark - initializer

- (instancetype) init {
    self = [super init];
    
    if (self) {
        memoryAllocatorWorkingQueue = dispatch_queue_create("memoryUsageDemo.memoryusagecontroller.workerQueue", NULL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarningReceived) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [self loadUpdatedMemoryInfo];
    }
    
    return self;
}

#pragma mark - Private Methods

- (void) loadUpdatedMemoryInfo {
    int memoryInfo[2];
    size_t lnth = 0;
    memoryInfo[0] = CTL_HW;
    memoryInfo[1] = HW_MEMSIZE;
    lnth = sizeof(int64_t);
    sysctl(memoryInfo, 2, &_physicalMemorySize, &lnth, NULL, 0);
    
    memoryInfo[1] = HW_USERMEM;
    lnth = sizeof(int64_t);
    sysctl(memoryInfo, 2, &_usrMemorySize, &lnth, NULL, 0);
}

- (void) reportProgress {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.completionHandlerCopy) {
            self.completionHandlerCopy(allocatedDataInMB, memoryWarningReceived);
        }
    });
}

- (void) allocateMemory {
    
    if (memoryWarningReceived == YES && continueAllocationAfterWarning == NO) {
        [self reportProgress];
        return;
    }
    
  //  NSLog(@"Allocate Memory start\n");
    allocatedData[allocatedDataInMB] = malloc(BYTES_PER_MB);
    memset(allocatedData[allocatedDataInMB], 0, BYTES_PER_MB);
    allocatedDataInMB ++;

    [self reportProgress];

    dispatch_async(memoryAllocatorWorkingQueue, ^{[self scheduleMemoryNextMemoryAllocation];});
    
}

- (void) scheduleMemoryNextMemoryAllocation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), memoryAllocatorWorkingQueue, ^{
        [self allocateMemory];
    });
}


#pragma mark - Public Methods

- (BOOL) allocateMemoryUntilMemoryWarningWithCompletionHandler:(MemoryAllocationCompletionHandler)completionHandler
                shouldContinueAllocatingEvenAfterMemoryWarning:(BOOL)ignoreWarningForAllocation {
    
    if (memoryAllocatorWorkingQueue == nil || _usrMemorySize == 0 || _physicalMemorySize == 0) {
        return NO;
    }
    
    self.completionHandlerCopy = completionHandler;
    continueAllocationAfterWarning = ignoreWarningForAllocation;
    
    dispatch_async(memoryAllocatorWorkingQueue, ^{[self scheduleMemoryNextMemoryAllocation];});
    return YES;
}

- (BOOL) allocateMegaBytes:(NSUInteger)mbData {
    if (memoryAllocatorWorkingQueue == nil || _usrMemorySize == 0 || _physicalMemorySize == 0) {
        return NO;
    }

    // TBD
    
    return YES;
}

- (void) clearAllocatedMemory {
    for (int i = 0; i < allocatedDataInMB; ++i) {
        free(allocatedData[i]);
    }
    
    allocatedDataInMB = 0;
}

- (uint64_t) physicalMemorySize {
    return _physicalMemorySize;
}

- (uint64_t) userMemorySize {
    return _usrMemorySize;
}


#pragma mark - Notification Handler

- (void) memoryWarningReceived {
    memoryWarningReceived = YES;
    [self scheduleMemoryNextMemoryAllocation];
}


@end
