//
//  TKDTask.m
//  Tokaido
//
//  Created by Martin Schürrer on 02.07.13.
//  Copyright (c) 2013 Martin Schürrer. All rights reserved.
//

#import "TKDTask.h"
#import "TKDApp.h"
#import "TKDAppDelegate.h"

@interface TKDTask () {
    NSDictionary *_environment;
    NSString *_currentDirectoryPath;
    NSTask *_task;
    NSPipe *_standardOutputPipe;
    NSPipe *_standardErrorPipe;
    NSFileHandle *_standardOutputFileHandle;
    NSFileHandle *_standardErrorFileHandle;
    NSMutableString *_standardOutputBuffer;
    NSMutableString *_standardErrorBuffer;
    NSMutableArray *_standardOutputLines;
    NSMutableArray *_standardErrorLines;
}
@end

@implementation TKDTask

+ (instancetype)task {
    TKDTask *task = [[TKDTask alloc] init];
    task.currentDirectoryPath = [TKDAppDelegate tokaidoAppSupportDirectory];
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
        _standardOutputLines = [NSMutableArray array];
        _standardErrorLines = [NSMutableArray array];
        _standardOutputBuffer = [NSMutableString string];
        _standardErrorBuffer = [NSMutableString string];
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
    _standardOutputFileHandle = _standardOutputPipe.fileHandleForReading;
    _standardErrorFileHandle = _standardErrorPipe.fileHandleForReading;
    _task.standardOutput = _standardOutputPipe;
    _task.standardError = _standardErrorPipe;
    _standardOutputFileHandle.readabilityHandler = [self readabilityHandlerFor:_standardOutputFileHandle buffer:_standardOutputBuffer lines:_standardOutputLines];
    _standardOutputFileHandle.readabilityHandler = [self readabilityHandlerFor:_standardErrorFileHandle buffer:_standardErrorBuffer lines:_standardErrorLines];
}

- (void (^)(NSFileHandle *))readabilityHandlerFor:(NSFileHandle *)handle buffer:(NSMutableString *)buffer lines:(NSMutableArray *)lines {
    return ^(NSFileHandle *handle) {
        [buffer appendString:[[NSString alloc] initWithData:handle.availableData encoding:NSASCIIStringEncoding]];
        NSArray *bufferLines = [buffer componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if ([[bufferLines lastObject] length] == 0) {
            // data ended in a newline -> clear buffer
            [buffer setString:@""];
        } else {
            // data did not end in newline -> make lastObject new buffer
            [buffer setString:[bufferLines lastObject]];
        }
        for (int i = 0; i < bufferLines.count - 1; i++) {
            NSString *line = bufferLines[i];
            if ([self.delegate respondsToSelector:@selector(task:didPrintLine:toStandardOut:)]) [self.delegate task:self didPrintLine:line toStandardOut:nil];
            [lines addObject:line];
        }
    };
}

@end
