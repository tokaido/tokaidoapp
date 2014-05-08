#import "TKDConfiguration.h"
#import "TKDUtilities.h"
#import "TKDApp.h"
#import "TKDAppDelegate.h"
#import "TKDMuxrManager.h"
#import "TKDTask.h"
#import <YAML-Framework/YAMLSerialization.h>

static NSString *kAppNameKey = @"app_name";
static NSString *kHostnameKey = @"hostname";
static NSString *kAppIconKey = @"app_icon";


@interface TKDTask (TKDApp)
+ (instancetype)taskForApp:(TKDApp *)app;
@end

@interface TKDApp () <TKDTaskDelegate>
@property (nonatomic, strong) NSString *lastLine;
@end

@implementation TKDApp

- (id)init
{
    self = [super init];
    if (self) {
        self.usesYAMLfile = NO;
    }
    return self;
}

+ (NSDictionary *)YAMLKeyPathsByPropertyKey {
    return @{
             @"appName": @"app_name",
             @"appHostname": @"app_hostname",
             @"appIconPath" : @"app_icon_path"
             };
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"appName": @"app_name",
             @"appDirectoryPath": @"directory_path",
             @"appHostname": @"app_hostname",
             @"appState" : @"app_state",
             @"appIconPath" : @"app_icon_path"
             };
}

+ (NSValueTransformer *)stateJSONTransformer {
    NSDictionary *states = @{
                             @"off":            @(TKDAppOff),
                             @"booting":        @(TKDAppBooting),
                             @"on":             @(TKDAppOn),
                             @"shutting_down":  @(TKDAppShuttingDown)
                             };
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"stateMessage"]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"state", @"substate"]];
    } else if ([key isEqualToString:@"needsStateChange"]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"state"]];
    } else if ([key isEqualToString:@"stateChangeString"]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"state"]];
    }
    
    return keyPaths;
}

- (id)initWithTokaidoDirectory:(NSURL *)tokaidoAppURL;
{
    self = [super init];
    if (self) {
        NSData *yamlData = [NSData dataWithContentsOfURL:[tokaidoAppURL URLByAppendingPathComponent:@"Tokaido.yaml"]];
        NSError *error = nil;
        NSMutableArray *tokaidoYAML = [YAMLSerialization YAMLWithData:yamlData
                                                              options:kYAMLReadOptionStringScalars
                                                                error:&error];
        
        if (error) {
            NSLog(@"ERROR: Couldn't load Tokaido.yaml file: %@", [error localizedDescription]);
            return nil;
        } else {
            NSDictionary *appDictionary = [tokaidoYAML objectAtIndex:0];
            
            self.appName = [appDictionary objectForKey:kAppNameKey];
            if (!self.appName) {
                self.appName = @"Undefined";
            }
            
            self.appHostname = [appDictionary objectForKey:kHostnameKey];
            if (!self.appHostname) {
                self.appHostname = @"Undefined.tokaido";
            }
            
            self.appDirectoryPath = [tokaidoAppURL path];
            self.appIconPath = [appDictionary objectForKey:kAppIconKey];
            self.usesYAMLfile = YES;
        }
        
    }
    return self;
}

- (NSString *)stateMessage {
    NSMapTable *substates = [NSMapTable new];
    [substates setObject:@"Running bundle install" forKey:[NSNumber numberWithInt:TKDAppBootingBundling]];
    [substates setObject:@"bundle install failed" forKey:[NSNumber numberWithInt:TKDAppBootingBundleFailed]];
    [substates setObject:@"Booting server" forKey:[NSNumber numberWithInt:TKDAppBootingStartingServer]];
    
    if (self.state == TKDAppBooting) {
        if (self.substate == TKDAppBootingBundling) {
            if (self.lastLine == nil) { return @"bundle install"; }
            return [NSString stringWithFormat:@"bundle install: %@", self.lastLine];
        } else {
            return [substates objectForKey:[NSNumber numberWithInt:self.substate]];
        }
    } else if (self.state == TKDAppOff) {
        NSString *failureReason = self.failureReason;
        
        if (failureReason == nil) {
            return @"Not started";
        } else {
            return failureReason;
        }
    } else if (self.state == TKDAppOn) {
        return @"Started";
    } else if (self.state == TKDAppShuttingDown) {
        return @"Shutting Down";
    } else {
        return nil;
    }
}

- (NSString *)stateChangeString {
    if (self.state == TKDAppOn) {
        return @"Shut Down";
    } else if (self.state == TKDAppOff) {
        return @"Boot App";
    } else if (self.state == TKDAppBooting) {
        return @"Cancel Boot";
    } else {
        return nil;
    }
}

- (bool)needsStateChange {
    return self.state == TKDAppOff || self.state == TKDAppOn;
}

- (void)enterSubstate:(TKDAppSubstate)substate;
{
    self.substate = substate;
    
    if (substate == TKDAppBootingBundleFailed) {
        self.failureReason = @"Bundling failed. Try \"Open in Terminal\".";
    }
}

-(void)enterState:(TKDAppState)state;
{
    self.state = state;
    
    if (state == TKDAppOn) {
        self.failureReason = nil;
    }
}

-(void)setStatus:(NSString *)status;
{
    self.failureReason = status;
}

- (void)showInFinder;
{
    [[NSWorkspace sharedWorkspace] openFile:self.appDirectoryPath];
}

- (void)openInBrowser;
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@", self.appHostname];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)serializeToYAML;
{
    NSMutableDictionary *yamlDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    NSDictionary *keys = [TKDApp YAMLKeyPathsByPropertyKey];
    NSError *error = nil;
    
    for (NSString *key in [keys allKeys]) {
        NSString *yamlKeyName = [keys valueForKey:key];
        [yamlDictionary setValue:[self valueForKey:key] forKey:yamlKeyName];
    }
    
    NSData *yamlData = [YAMLSerialization dataFromYAML:yamlDictionary
                                               options:kYAMLWriteOptionSingleDocument
                                                 error:&error];
    
    if (error) {
        NSLog(@"ERROR: Couldn't form YAML data from TKDApp: %@", [error localizedDescription]);
        return;
    }
    
    BOOL success = [yamlData writeToFile:[self.appDirectoryPath stringByAppendingPathComponent:@"/Tokaido.yaml"]
                              atomically:YES];
    
    if (!success) {
        NSLog(@"ERROR: Couldn't write YAML file.");
    }
}

- (void)runBundleInstall {
    [self enterSubstate:TKDAppBootingBundling];
    dispatch_queue_t bundleInstall = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(bundleInstall, ^{
        @try {
            TKDTask *check = [self task];
            check.launchPath = [[TKDConfiguration tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"/ruby"];
            NSString *setupScriptPath = [TKDConfiguration setupScriptGemsInstalledFile];
            NSString *bundlerPath = [TKDConfiguration gemsBundlerInstalledDirectoryPath];
            check.arguments = @[ @"-r", setupScriptPath, bundlerPath, @"check" ];
            
            [check launch];
            
            if ([check terminationStatus] == 0) {
                NSLog(@"bundle check successfull");
                [self task:check didTerminate:0 reason:nil];
                return;
            }
            
            TKDTask *task = [self task];
            task.delegate = self;
            task.launchPath = [[TKDConfiguration tokaidoLocalHomeDirectoryPath] stringByAppendingPathComponent:@"/ruby"];
            
            task.arguments = @[ @"-r", setupScriptPath, bundlerPath, @"install" ];
            
            [task launch];
        } @catch (NSException *exception) {
            NSLog(@"Problem running bundle install: %@", [exception description]);
        }
    });
}

- (TKDTask *)task {
    return [TKDTask taskForApp:self];
}

- (NSDictionary *)environment {
    return @{
             @"GEM_HOME": [TKDConfiguration gemsInstalledDirectoryPath],
             @"GEM_PATH": [TKDConfiguration gemsInstalledDirectoryPath],
             @"PATH"    : [NSString stringWithFormat:@"%@:%@:%@/bin:%@",
                           [TKDConfiguration binariesInstalledDirectoryPath],
                           [TKDUtilities rubyBinDirectory:[TKDConfiguration rubyVersion]],
                           [TKDConfiguration gemsInstalledDirectoryPath],
                           @"/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/sbin:/usr/sbin:/Applications/Postgres.app/Contents/Versions/9.3/bin"] };
}

#pragma mark - TKDTaskDelegate methods

- (void)task:(TKDTask *)task didPrintLine:(NSString *)line toStandardOut:(id)_ {
    [self willChangeValueForKey:@"stateMessage"];
    self.lastLine = line;
    [self didChangeValueForKey:@"stateMessage"];
}

- (void)task:(TKDTask *)task didTerminate:(int)terminationStatus reason:(NSTaskTerminationReason)reason {
    if (terminationStatus == 0) {
        [self enterSubstate:TKDAppBootingStartingServer];
        NSString *command = [NSString stringWithFormat:@"ADD \"%@\" \"%@\"\n", self.appHostname, self.appDirectoryPath];
        [[TKDMuxrManager defaultManager] issueCommand:command];
    } else {
        [self enterSubstate:TKDAppBootingBundleFailed];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [NSAlert alertWithMessageText:@"Unable to activate app."
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"`bundle install` failed. Make sure it works before proceeding. Also check if a gem added requires a compiler and install the developer tools to proceed."];
            
            [alert runModal];
        });
        
        NSDictionary *userInfo = @{
                                   @"action": @"FAILED",
                                   @"hostname": self.appHostname
                                   };
        
        NSNotification *muxrNotification = [NSNotification notificationWithName:kMuxrNotification
                                                                         object:nil
                                                                       userInfo:userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:muxrNotification];
        });
    }
    
}

@end

@implementation TKDNullApp

- (id)init
{
    if (self = [super init])
        self.appDirectoryPath = NSHomeDirectory();
    return self;
}

@end

@implementation TKDCubalogApp

- (id)init {
    if (self = [super init]) {
        self.appName = @"cubalog";
        self.appDirectoryPath = [TKDConfiguration cubalogInstalledDirectoryPath];
        self.appHostname = [[self.appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@".tokaido"];
    }
    
    return self;
}

@end