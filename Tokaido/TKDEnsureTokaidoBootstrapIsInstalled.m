#import "TKDEnsureTokaidoBootstrapIsInstalled.h"
#import "TKDConfiguration.h"
#import "TKDFileUtilities.h"

#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

static NSString * const kTokaidoBootstrapFirewallPlistCommandString = @"TOKAIDO_FIREWALL_COMMAND";
static NSString * const kTokaidoBootstrapFirewallPlistTmpDir = @"TOKAIDO_FIREWALL_TMPDIR";
static NSString * const kTokaidoBootstrapFirewallPlistSetupString = @"TOKAIDO_FIREWALL_SETUP";
static NSString * const kTokaidoBootstrapFirewallPlistScriptString = @"TOKAIDO_FIREWALL_SCRIPT";

@implementation TKDEnsureTokaidoBootstrapIsInstalled

@synthesize view = _view;

-(TKDEnsureTokaidoBootstrapIsInstalled *) initWithView:(id <TKDAppSupportEnsure>)view {
    if (self = [super init]) {
        _view = view;
	}
    
	return self;
}

-(Class) configuration {
    return [TKDConfiguration self];
}

-(Class) fileManager {
    return [TKDFileUtilities self];
}

-(void) execute {
    [_view starting_tokaido_bootstrap_detection];
    
    if ([[self fileManager] fileExists:[self.configuration bootstrapLaunchDaemonPlistFile]]) {    
        [_view tokaido_bootstrap_detected];
    } else {
        [_view tokaido_bootstrap_not_detected];
        [_view tokaido_bootstrap_installing];
        
        [self.fileManager createDirectoryAtPathIfNonExistant:[self.configuration firewallInstalledDirectoryPath]];
        
        NSString *executablePath = [self.configuration rubyExecutableInstalledFile];
        NSString *setupScriptPath = [self.configuration bootstrapGemsInstalledFile];
        NSString *firewallPlistPath = [self.configuration bootstrapFirewallPlistInstalledFile];
        NSString *firewallScriptPath = [self.configuration bootstrapFirewallScriptInstalledFile];
        NSString *firewallPath = [self.configuration firewallInstalledDirectoryPath];
        
        NSError *error = nil;
        NSString *firewallPlistString = [NSString stringWithContentsOfFile:firewallPlistPath
                                                                  encoding:NSUTF8StringEncoding
                                                                     error:&error];
        if (error) {
            [_view error_reading_firewall_plist_file];
        } else {
            [_view saving_firewall_plist_file];
            firewallPlistString = [firewallPlistString stringByReplacingOccurrencesOfString:kTokaidoBootstrapFirewallPlistCommandString
                                                                                 withString:executablePath];
            firewallPlistString = [firewallPlistString stringByReplacingOccurrencesOfString:kTokaidoBootstrapFirewallPlistTmpDir
                                                                                 withString:firewallPath];
            firewallPlistString = [firewallPlistString stringByReplacingOccurrencesOfString:kTokaidoBootstrapFirewallPlistSetupString
                                                                                 withString:setupScriptPath];
            firewallPlistString = [firewallPlistString stringByReplacingOccurrencesOfString:kTokaidoBootstrapFirewallPlistScriptString
                                                                                 withString:firewallScriptPath];
            [firewallPlistString writeToFile:firewallPlistPath
                                  atomically:YES
                                    encoding:NSUTF8StringEncoding
                                       error:&error];
        }
        
        if (error) {
            [_view error_saving_firewall_plist_file];
        } else {
            [_view saved_firewall_plist_file];
        }
        
        NSString *tokaidoLabel = @"io.tilde.tokaido-install";
        NSString *tokadioInstallScriptPath = [self.configuration firewallInstallScriptInstalledFile];
        
        AuthorizationItem authItem = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
        AuthorizationRights authRights = { 1, &authItem };
        AuthorizationFlags flags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
        
        NSString *promptText = @"";
        AuthorizationItem dialogConfiguration[1] = {
            {kAuthorizationEnvironmentPrompt, [promptText length], (char *) [promptText UTF8String], 0}
        };
        
        AuthorizationEnvironment authorizationEnvironment = { 0 };
        authorizationEnvironment.items = dialogConfiguration;
        authorizationEnvironment.count = 1;
        
        
        [_view requesting_authorization];
        AuthorizationRef auth;
        if( AuthorizationCreate( &authRights, &authorizationEnvironment, flags, &auth ) == errAuthorizationSuccess ) {
            (void) SMJobRemove( kSMDomainSystemLaunchd, (__bridge CFStringRef)tokaidoLabel, auth, false, NULL );
            
            NSMutableDictionary *plist = [NSMutableDictionary dictionary];
            [plist setObject:tokaidoLabel forKey:@"Label"];
            [plist setObject:[NSNumber numberWithBool:YES] forKey:@"RunAtLoad"];
            [plist setObject:[NSNumber numberWithBool:YES] forKey:@"AbandonProcessGroup"];
            [plist setObject:@[executablePath, @"-r", setupScriptPath, tokadioInstallScriptPath ] forKey:@"ProgramArguments"];
            [plist setObject:@"/var/log/tokaido-install.log" forKey:@"StandardOutPath"];
            [plist setObject:@"/var/log/tokaido-install.error" forKey:@"StandardErrorPath"];
            
            CFErrorRef error = NULL;
            
            if ( SMJobSubmit( kSMDomainSystemLaunchd, (__bridge CFDictionaryRef)plist, auth, &error) )
                [_view helper_ran_succesfully];
            else
                [_view failed_helper_authenticated_submission_with_message:[NSString stringWithFormat:@"%@", error]];
            
            if (error != NULL) {
                [_view service_management_failed_with_error:[NSString stringWithFormat:@"%@", CFErrorCopyDescription(error)]];
                CFRelease(error);
            } else {
                [_view service_management_submission_succesfull];
            }
            
            AuthorizationFree(auth, 0);
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSApplication sharedApplication] terminate:nil];
            });
            [_view quit_application];
            
        }
    }
    
    [_view finished_tokaido_bootstrap_detection];
}

@end
