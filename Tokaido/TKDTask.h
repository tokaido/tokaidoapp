#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TKDTaskState) {
    TKDTaskStateCreated,
    TKDTaskStateReady,
    TKDTaskStateRunning,
    TKDTaskStateTerminated
};

@class TKDApp, TKDTask;

@protocol TKDTaskDelegate <NSObject>
@optional
- (void)task:(TKDTask *)task didPrintLine:(NSString *)line toStandardOut:(id)_;
- (void)task:(TKDTask *)task didPrintLine:(NSString *)line toStandardErr:(id)_;
- (void)task:(TKDTask *)task willLaunch:(id)_;
- (void)task:(TKDTask *)task didLaunch:(id)_;
- (void)task:(TKDTask *)task didTerminate:(int)terminationStatus reason:(NSTaskTerminationReason)reason;
@end

@interface TKDTask : NSObject

+ (instancetype)task;

@property (nonatomic, weak) id<TKDTaskDelegate> delegate;

@property (nonatomic, readonly) TKDApp *app;
@property (nonatomic, readonly) TKDTaskState state;

@property (nonatomic, copy) NSArray *arguments;
@property (nonatomic, strong) NSString *currentDirectoryPath;
@property (nonatomic, copy) NSDictionary *environment;
@property (nonatomic, strong) NSString *launchPath;

@property (nonatomic, readonly) NSArray *standardOutputLines;
@property (nonatomic, readonly) NSArray *standardErrorLines;

- (void)launch;
- (void)waitUntilExit;
- (int)terminationStatus;
@end
