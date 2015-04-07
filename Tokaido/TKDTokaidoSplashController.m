#import "TKDTokaidoSplashController.h"
#import "TKDEnsureAppSupportUpdated.h"
#import "TKDEnsureTokaidoInstallIsInstalled.h"
#import "TKDEnsureTokaidoBootstrapIsInstalled.h"
#import "TKDStopTokaido.h"
#import "TKDStartTokaido.h"
#import "TKDMuxrManager.h"
#import "TKDApp.h"
#import "TKDAppDelegate.h"
#import "TKDTerminalSessions.h"


@implementation TKDTokaidoSplashController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    
    if (self = [super initWithWindowNibName:windowNibName]) {
        _logger = [[TKDCubalogApp alloc] init];
        
        _progress.indeterminate = YES;
        _progress.displayedWhenStopped = YES;
        return self;
    }
    
    return nil;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    [self.window setDelegate:self];
    [self start];
}

-(void) start {
    
    [_progress startAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *tasks = @[[TKDEnsureAppSupportUpdated self],
                           [TKDEnsureTokaidoInstallIsInstalled self],
                           [TKDEnsureTokaidoBootstrapIsInstalled self],
                           [TKDStopTokaido self],
                           [TKDStartTokaido self]];
        
        for (Class task in tasks)
            [[[task alloc] initWithView:self] execute];
        
        [self finish];
    });
     
     
    [self finish];
}

-(void) finish {
    dispatch_async(dispatch_get_main_queue(), ^{
        _progress.displayedWhenStopped = NO;
        [_progress stopAnimation:self];
    
        [_status setStringValue:@"Ready. Find me in the bar and start managing apps."];
    });
    
    // Force connection attempt with Muxr
    //[TKDMuxrManager defaultManager];
}

-(IBAction)openTerminal:(id)sender {
    [[TKDTerminalSessions sharedTerminalSessions] open];
}

-(void) report:(NSString *)status {
    [self report:status incrementBy:0.0];
}

-(void) report:(NSString *)activity incrementBy:(double)delta {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_status setStringValue:activity];
    });
}

-(void) checking_ruby_installation {
    [self report:NSLocalizedString(@"Checking Ruby Installation.", nil)];
}

-(void) finished_checking_ruby_installation {
    [self report:NSLocalizedString(@"Finished checking Ruby Instalation.", nil)];
}

-(void) finding_rubies_bundled {
    [self report:NSLocalizedString(@"Finding Rubies.", nil)];
}

-(void) found_ruby_not_installed:(TKDRubyBinary *)rb {
    [self report:[NSString stringWithFormat:NSLocalizedString(@"Ruby %@ not installed.", nil), [rb name]]];
}

-(void) unzipping_ruby_bundled {
    [self report:NSLocalizedString(@"Unzipping Ruby.", nil)];
}

-(void) finished_unzipping_ruby_bundled {
    [self report:NSLocalizedString(@"Finished unzipping Ruby.", nil)];
}

-(void) ruby_installed {
    [self report:NSLocalizedString(@"Ruby is installed!", nil)];
}

-(void) finished_ruby_installations {
    [self report:NSLocalizedString(@"Finished checking ruby installations.", nil) incrementBy:10.0];
}

-(void) checking_gems_installation {
    [self report:NSLocalizedString(@"Checking Gems installation.", nil)];
}

-(void) unzipping_gems_bundled {
    [self report:NSLocalizedString(@"Unzipping Gems.", nil)];
}

-(void) finished_unzipping_gems_bundled {
    [self report:NSLocalizedString(@"Finished unzipping gems.", nil) incrementBy:30.0];
}

-(void) checking_binaries_installation {
    [self report:NSLocalizedString(@"Checking binaries installation.", nil)];
}

-(void) unzipping_binaries_bundled {
    [self report:NSLocalizedString(@"Unzipping binaries.", nil)];
}

-(void) finished_unzipping_binaries_bundled {
    [self report:NSLocalizedString(@"Finished unzipping binaries.", nil) incrementBy:5.0];
}

-(void) starting_clang_search {
    [self report:NSLocalizedString(@"Searching for clang.", nil) incrementBy:1.0];
}

-(void) clang_not_found {
    [self report:NSLocalizedString(@"Clang not found.", nil) incrementBy:1.0];
}

-(void) starting_clang_symlink {
    [self report:NSLocalizedString(@"Starting symlink for clang.", nil) incrementBy:2.0];
}

-(void) finished_clang_symlink {
    [self report:NSLocalizedString(@"Finished symlink for clang.", nil) incrementBy:2.0];
}

-(void) applying_rbconfig_patches {
    [self report:NSLocalizedString(@"Applying rbconfig patches.", nil) incrementBy:1.0];
}

-(void) error_patching_rbconfig_with_message:(NSString *)message {
    NSLog(@"%@: %@", NSLocalizedString(@"Failed patching rbconfig.rb", nil), message);
    [self report:[NSString stringWithFormat:NSLocalizedString(@"Failed patching rbconfig.rb", nil), message] incrementBy:2.0];
}

-(void) replacing_config_topdir_line_with:(NSString *)line {
    NSLog(@"%@ with %@", NSLocalizedString(@"Replacing CONFIG[\"TOPDIR\"] rbconfig.rb", nil), line);
    [self report:[NSString stringWithFormat:NSLocalizedString(@"Replacing CONFIG[\"TOPDIR\"] rbconfig.rb", nil), line] incrementBy:2.0];
}

-(void) replacing_config_cc_line {
    [self report:NSLocalizedString(@"Replacing CONFIG[\"CC\"] rbconfig.rb", nil) incrementBy:2.0];
}

-(void) patching_rbconfig_complete {
    [self report:NSLocalizedString(@"Patching rbconfig complete!", nil) incrementBy:2.0];
}

-(void) finished_ensuring_app_support_is_updated {
    [self report:NSLocalizedString(@"Finished ensuring Application Support is up to date.", nil)];
}

-(void) checking_tokaido_bootstrap_installation {
    [self report:NSLocalizedString(@"Checking Tokaido Install.", nil)];
}

-(void) unzipping_tokaido_bootstrap_bundled {
    [self report:NSLocalizedString(@"Unzipping Tokaido Install", nil)];
}

-(void) finished_unzipping_tokaido_bootstrap_bundled {
    [self report:NSLocalizedString(@"Finished unzipping Tokaido Install.", nil)];
}

-(void) finished_checking_tokaido_bootstrap_installation {
    [self report:NSLocalizedString(@"Finished checking Tokaido Install.", nil) incrementBy:8.0];
}

-(void) starting_tokaido_bootstrap_detection {
    [self report:NSLocalizedString(@"Starting Tokaido Bootstrap detection.", nil)];
}

-(void) tokaido_bootstrap_detected {
    [self report:NSLocalizedString(@"Tokaido Bootstrap detected.", nil)];
}

-(void) tokaido_bootstrap_not_detected {
    [self report:NSLocalizedString(@"Tokaido Bootstrap not detected.", nil)];
}

-(void) tokaido_bootstrap_installing {
    [self report:NSLocalizedString(@"Installing Tokaido Bootstrap.", nil)];
}

-(void) error_reading_firewall_plist_file {
    [self report:NSLocalizedString(@"Reading Firewall configuration.", nil)];
}

-(void) saving_firewall_plist_file {
    [self report:NSLocalizedString(@"Saving Firewall configuration.", nil)];
}

-(void) error_saving_firewall_plist_file {
    [self report:NSLocalizedString(@"Failed saving Firewall configuration.", nil)];
}

-(void) saved_firewall_plist_file {
    [self report:NSLocalizedString(@"Firewall configuration saved.", nil)];
}

-(void) requesting_authorization {
    [self report:NSLocalizedString(@"Authorizing.", nil)];
}

-(void) helper_ran_succesfully {
    [self report:NSLocalizedString(@"Helper launched succesfully.", nil)];
}

-(void) failed_helper_authenticated_submission_with_message:(NSString *)message {
    NSLog(@"%@: %@", NSLocalizedString(@"Failed submitting helper task", nil), message);
    [self report:NSLocalizedString(@"Failed submitting helper task", nil)];
}

-(void) service_management_failed_with_error:(NSString *)message {
    NSLog(@"%@: %@", NSLocalizedString(@"Failed submitting helper task", nil), message);
    [self report:NSLocalizedString(NSLocalizedString(@"Failed submitting helper task", nil), nil)];
}

-(void) service_management_submission_succesfull {
    [self report:NSLocalizedString(@"Launch task submission succesful.", nil)];
}

-(void) finished_tokaido_bootstrap_detection {
    [self report:NSLocalizedString(@"Finished Tokaido Bootstrap detection.", nil) incrementBy:30.0];
}

-(void) starting_shutting_down_tokaido_bootstrap {
    [self report:NSLocalizedString(@"Starting Tokaido Bootstrap shutdown.", nil)];
}

-(void) shutting_down_tokaido_bootstrap {
    [self report:NSLocalizedString(@"Shutting down tokaido-bootstrap.", nil)];
}

-(void) tokaido_boostrap_shutdown {
    [self report:NSLocalizedString(@"tokaido-bootstrap shutdown complete.", nil)];
}

-(void) finished_tokaido_boostrap_shutdown {
    [self report:NSLocalizedString(@"Finished shutting down tokaido-bootstrap.", nil) incrementBy:1.0];
}

-(void) starting_tokaido_bootstrap {
    [self report:NSLocalizedString(@"Staring tokaido-bootstrap.", nil)];
}

-(void) unlinking_current_socket {
    [self report:NSLocalizedString(@"Unlinking current socket", nil)];
}

-(void) tokaido_bootstrap_started {
    [self report:NSLocalizedString(@"tokaido-bootstrap started.", nil)];
}

-(void) finished_starting_tokaido_bootstrap {
    [self report:NSLocalizedString(@"Finished starting tokaido-bootstrap.", nil) incrementBy:1.0];
}

-(void) failed_starting_tokaido_bootstrap_with_error:(NSString *)message {
    NSLog(@"%@: %@", NSLocalizedString(@"Failed starting tokaido-bootstrap", nil), message);
    [self report:NSLocalizedString(@"Failed starting tokaido-bootstrap", nil)];
}

-(void) quit_application {
    [[NSApplication sharedApplication] terminate:nil];
}

@end
