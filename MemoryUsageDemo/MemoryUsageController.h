//
//  MemoryUsageController.h
//  MemoryUsageDemo
//
//  Created by Mithlesh Kumar Jha on 02/03/16.
//  Copyright © 2016 Mithlesh Kumar Jha. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BYTES_PER_MB 1048576
#define BYTES_PER_KB 1028

typedef void (^MemoryAllocationCompletionHandler) (NSUInteger megaBytesAllocated, BOOL memoryWarningReceived);

@interface MemoryUsageController : NSObject

/**
 * Pass this message to start memory allocation until application gets memory warning. Once the memory warning is 
 * notified, completionHandler is called on main thread.
 */
- (BOOL) allocateMemoryUntilMemoryWarningWithCompletionHandler:(MemoryAllocationCompletionHandler)completionHandler shouldContinueAllocatingEvenAfterMemoryWarning:(BOOL)ignoreWarningForAllocation;
- (BOOL) allocateMegaBytes:(NSUInteger)mbData;

- (void) clearAllocatedMemory;

- (uint64_t) physicalMemorySize;
- (uint64_t) userMemorySize;

// Returns allocated bytes in MB until warning received in previous session
- (NSUInteger) allocatedSizeInPreviousSessionUntilWarning;

// Returns allocated bytes in MB until warning received in previous session
- (NSUInteger) allocatedSizeInPreviousSessionUntilCrashed;


@end
