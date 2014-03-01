//
//  TKDTask.m
//  Tokaido
//
//  Created by Martin Schürrer on 02.07.13.
//  Copyright (c) 2013 Martin Schürrer. All rights reserved.
//

#import "TKDTask.h"
#import "TKDApp.h"
#import "TKDConfiguration.h"

@interface TKDTask () {
    NSDictionary *_environment;
    NSString *_currentDirectoryPath;
    NSTask *_task;
    NSPipe *_standardOutputPipe;
    NSPipe *_standardErrorPipe;
}
@end

@implementation TKDTask

+ (instancetype)task {
    TKDTask *task = [[TKDTask alloc] init];
    task.currentDirectoryPath = [TKDConfiguration tokaidoAppSupportDirectory];
    return task;
}

+ (instancetype)taskForApp:(TKDApp *)app {
    TKDTask *task = [[TKDTask alloc] init];
    task->_app = app;
    return task;
}

- (id)init {
    if (self = [super init]) {
        _arguments = [NSArray array];
        _environment = [NSDictionary dictionary];
    }
    return self;
}

#pragma mark - Setters

- (void)setArguments:(NSArray *)arguments {
    NSParameterAssert(arguments);
    NSParameterAssert(self.state == TKDTaskStateReady || self.state == TKDTaskStateCreated);
    _arguments = [arguments copy];
}

- (void)setCurrentDirectoryPath:(NSString *)currentDirectoryPath {
    NSParameterAssert(currentDirectoryPath);
    NSParameterAssert(!self.app);
    NSParameterAssert(self.state == TKDTaskStateReady || self.state == TKDTaskStateCreated);
    _currentDirectoryPath = currentDirectoryPath;
}

- (NSString *)currentDirectoryPath {
    if (self.app) {
        return self.app.appDirectoryPath;
    } else {
        return _currentDirectoryPath;
    }
}

- (void)setEnvironment:(NSDictionary *)environment {
    NSParameterAssert(environment);
    NSParameterAssert(!self.app);
    NSParameterAssert(self.state == TKDTaskStateReady || self.state == TKDTaskStateCreated);
    _environment = [environment copy];
}

- (NSDictionary *)environment {
    if (self.app) {
        return self.app.environment;
    } else {
        return _environment;
    }
}

- (void)setLaunchPath:(NSString *)launchPath {
    NSParameterAssert(launchPath);
    NSParameterAssert(self.state == TKDTaskStateReady || self.state == TKDTaskStateCreated);
    _launchPath = launchPath;
}

#pragma mark -

- (void)launch {
    NSAssert(self.state == TKDTaskStateReady, @"TKDTask not in ready state.");
    if ([self.delegate respondsToSelector:@selector(task:willLaunch:)]) [self.delegate task:self willLaunch:nil];
    [self setupTask];
    [_task launch];
    if ([self.delegate respondsToSelector:@selector(task:didLaunch:)]) [self.delegate task:self didLaunch:nil];
    [_task waitUntilExit];
}

-(void)waitUntilExit {
  [_task waitUntilExit];
}

- (TKDTaskState)state {
    if (_arguments && _launchPath && (_app || (_currentDirectoryPath && _environment))) {
        if (_task) {
            if (_task.isRunning) {
                return TKDTaskStateRunning;
            } else {
                return TKDTaskStateTerminated;
            }
        } else {
            return TKDTaskStateReady;
        }
    } else {
        return TKDTaskStateCreated;
    }
}

#pragma mark -

- (void)setupTask {
    NSAssert(self.state == TKDTaskStateReady, @"TKDTask not in ready state.");
    _task = [[NSTask alloc] init];
    _task.launchPath = self.launchPath;
    _task.arguments = self.arguments;
    NSMutableDictionary *env = [NSMutableDictionary dictionary];
    [env addEntriesFromDictionary:[[NSProcessInfo processInfo] environment]];

    if (_app) {
        [env addEntriesFromDictionary:self.app.environment];
        _task.currentDirectoryPath = self.app.appDirectoryPath;
    } else {
        [env addEntriesFromDictionary:self.environment];
        _task.currentDirectoryPath = self.currentDirectoryPath;
    }
    _task.environment = env;

    @weakify(self);
    _task.terminationHandler = ^(NSTask *task){
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(task:didTerminate:reason:)]) [self.delegate task:self didTerminate:task.terminationStatus reason:task.terminationReason];
    };

    _standardOutputPipe = [NSPipe pipe];
    _standardErrorPipe = [NSPipe pipe];

    _task.standardOutput = _standardOutputPipe;
    _task.standardError = _standardErrorPipe;

    [[_standardOutputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
    [[_standardErrorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];

    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
                                               object:[_standardOutputPipe fileHandleForReading]
                                               queue:nil usingBlock:[self readabilityHandlerForPipe:_standardOutputPipe]];

    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
                                               object:[_standardErrorPipe fileHandleForReading]
                                               queue:nil usingBlock:[self readabilityHandlerForPipe:_standardErrorPipe]];
}

- (void(^)(NSNotification *)) readabilityHandlerForPipe:(NSPipe *) p {
  return ^(NSNotification *notification) {
    NSData *output = [[p fileHandleForReading] availableData];
    NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];

    dispatch_sync(dispatch_get_main_queue(), ^{
      [self.delegate task:self didPrintLine:outputString toStandardOut:p];
    });

    [[p fileHandleForReading] waitForDataInBackgroundAndNotify];
  };
}

@end
