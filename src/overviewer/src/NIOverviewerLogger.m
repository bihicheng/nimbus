//
// Copyright 2011 Jeff Verkoeyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NIOverviewerLogger.h"

NSString* const NIOverviewerLoggerDidAddConsoleLog = @"NIOverviewerLoggerDidAddConsoleLog";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerLogger

@synthesize oldestLogAge = _oldestLogAge;
@synthesize deviceLogs = _deviceLogs;
@synthesize consoleLogs = _consoleLogs;
@synthesize eventLogs = _eventLogs;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_deviceLogs);
  NI_RELEASE_SAFELY(_consoleLogs);
  NI_RELEASE_SAFELY(_eventLogs);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    _deviceLogs = [[NILinkedList alloc] init];
    _consoleLogs = [[NILinkedList alloc] init];
    _eventLogs = [[NILinkedList alloc] init];
    
    _oldestLogAge = 60;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pruneEntriesFromLinkedList:(NILinkedList *)ll {
  NSDate* cutoffDate = [NSDate dateWithTimeIntervalSinceNow:-_oldestLogAge];
  while ([[((NIOverviewerLogEntry *)[ll firstObject])
           timestamp] compare:cutoffDate] == NSOrderedAscending) {
    [ll removeFirstObject];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addDeviceLog:(NIOverviewerDeviceLogEntry *)logEntry {
  [self pruneEntriesFromLinkedList:_deviceLogs];

  [_deviceLogs addObject:logEntry];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addConsoleLog:(NIOverviewerConsoleLogEntry *)logEntry {
  [_consoleLogs addObject:logEntry];
  
  [[NSNotificationCenter defaultCenter] postNotificationName: NIOverviewerLoggerDidAddConsoleLog
                                                      object: nil
                                                    userInfo:
   [NSDictionary dictionaryWithObject:logEntry forKey:@"entry"]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addEventLog:(NIOverviewerEventLogEntry *)logEntry {
  [self pruneEntriesFromLinkedList:_eventLogs];

  [_eventLogs addObject:logEntry];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerLogEntry

@synthesize timestamp = _timestamp;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_timestamp);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTimestamp:(NSDate *)timestamp {
  if ((self = [super init])) {
    _timestamp = [timestamp retain];
  }
  return self;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerDeviceLogEntry

@synthesize bytesOfFreeMemory = _bytesOfFreeMemory;
@synthesize bytesOfTotalMemory = _bytesOfTotalMemory;
@synthesize bytesOfTotalDiskSpace = _bytesOfTotalDiskSpace;
@synthesize bytesOfFreeDiskSpace = _bytesOfFreeDiskSpace;
@synthesize batteryLevel = _batteryLevel;
@synthesize batteryState = _batteryState;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerConsoleLogEntry

@synthesize log = _log;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_log);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithLog:(NSString *)log {
  if ((self = [super initWithTimestamp:[NSDate date]])) {
    _log = [log copy];
  }

  return self;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerEventLogEntry

@synthesize type = _type;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithType:(NSInteger)type {
  if ((self = [super initWithTimestamp:[NSDate date]])) {
    _type = type;
  }
  
  return self;
}


@end
