#import "TKDEnsureTokaidoAppSupportUpdatedProgress.h"
#import "TKDEnsureAppSupportUpdated.h"
#import "TKDEnsureTokaidoInstallIsInstalled.h"
#import "TKDEnsureTokaidoInstallIsInstalled.h"
#import "TKDEnsureTokaidoBootstrapIsInstalled.h"
#import "TKDStartTokaido.h"
#import "TKDStopTokaido.h"
#import "TKDRubyBinary.h"

@implementation TKDEnsureTokaidoAppSupportUpdatedProgress

-(void) configure:(id)controller {
    _controller = (TKDLoadingTokaidoController *)controller;
    _controller.progress.indeterminate = NO;
}

-(void) start {
    [_controller.progress startAnimation:self];
    
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
}

-(void) finish {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp endSheet:_controller.window];
    });
}

-(void) report:(NSString *)status {
    [self report:status incrementBy:0.0];
}

-(void) report:(NSString *)activity incrementBy:(double)delta {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (delta) {
            [_controller.progress incrementBy:delta];
            [_controller.progress displayIfNeeded];
        }
        
        [_controller.status setStringValue:activity];
        NSLog(@"%@", activity);
    });
}

-(void) checking_ruby_installation {
    [self report:@"Checking Ruby Installation."];
}

-(void) finished_checking_ruby_installation {
    [self report:@"Finished check."];
}

-(void) finding_rubies_bundled {
    [self report:@"Finding Rubies bundled with Tokaido."];
}

-(void) found_ruby_not_installed:(TKDRubyBinary *)rb {
    [self report:[NSString stringWithFormat:@"Found Ruby %@ not installed.", [rb name]]];
}

-(void) unzipping_ruby_bundled {
    [self report:@"Unzipping Ruby bundled."];
}

-(void) finished_unzipping_ruby_bundled {
    [self report:@"Finished unzipping Ruby."];
}

-(void) ruby_installed {
    [self report:@"Ruby is installed!"];
}

-(void) finished_ruby_installations {
    [self report:@"Finished checking ruby installations." incrementBy:10.0];
}

-(void) checking_gems_installation {
    [self report:@"Checking Gems installation."];
}

-(void) unzipping_gems_bundled {
    [self report:@"Unzipping Gems bundled."];
}

-(void) finished_unzipping_gems_bundled {
    [self report:@"Finished unzipping gems bundled." incrementBy:30.0];
}

-(void) checking_binaries_installation {
    [self report:@"Checking binaries installation."];
}

-(void) unzipping_binaries_bundled {
    [self report:@"Unzipping binaries bundled."];
}

-(void) finished_unzipping_binaries_bundled {
    [self report:@"Finished unzipping binaries bundled." incrementBy:5.0];
}

-(void) starting_clang_search {
    [self report:@"Searching for clang." incrementBy:1.0];
}

-(void) clang_not_found {
    [self report:@"Clang not found." incrementBy:1.0];
}

-(void) starting_clang_symlink {
    [self report:@"Starting symlink for clang." incrementBy:2.0];
}

-(void) finished_clang_symlink {
    [self report:@"Finished symlink for clang." incrementBy:2.0];
}

-(void) applying_rbconfig_patches {
    [self report:@"Applying rbconfig patches." incrementBy:1.0];
}

-(void) error_patching_rbconfig_with_message:(NSString *)message {
    [self report:[NSString stringWithFormat:@"Problem patching rbconfig: %@", message] incrementBy:2.0];
}

-(void) replacing_config_topdir_line {
    [self report:@"Replacing CONFIG[\"TOPDIR\"] rbconfig.rb" incrementBy:2.0];
}

-(void) replacing_config_cc_line {
    [self report:@"Replacing CONFIG[\"CC\"] rbconfig.rb" incrementBy:2.0];
}

-(void) patching_rbconfig_complete {
    [self report:@"Patching rbconfig complete!" incrementBy:2.0];
}

-(void) finished_ensuring_app_support_is_updated {
    [self report:@"Finished ensuring Application Support is up to date."];
}

-(void) checking_tokaido_bootstrap_installation {
    [self report:@"Checking Tokaido Install."];
}

-(void) unzipping_tokaido_bootstrap_bundled {
    [self report:@"Unzipping Tokaido Install bundled."];
}

-(void) finished_unzipping_tokaido_bootstrap_bundled {
    [self report:@"Finished unzipping Tokaido Install."];
}

-(void) finished_checking_tokaido_bootstrap_installation {
    [self report:@"Finished checking Tokaido Install." incrementBy:8.0];
}

-(void) starting_tokaido_bootstrap_detection {
    [self report:@"Starting Tokaido Bootstrap detection."];
}

-(void) tokaido_bootstrap_detected {
    [self report:@"Tokaido Bootstrap detected."];
}

-(void) tokaido_bootstrap_not_detected {
    [self report:@"Tokaido Bootstrap not detected."];
}

-(void) tokaido_bootstrap_installing {
    [self report:@"Installing Tokaido Bootstrap."];
}

-(void) error_reading_firewall_plist_file {
    [self report:@"Reading Firewall plist file."];
}

-(void) saving_firewall_plist_file {
    [self report:@"Saving Firewall plist file."];
}

-(void) error_saving_firewall_plist_file {
    [self report:@"Failed saving Firewall plist file."];
}

-(void) saved_firewall_plist_file {
    [self report:@"Firewall plist file saved."];
}

-(void) requesting_authorization {
    [self report:@"Authorizing."];
}

-(void) helper_ran_succesfully {
    [self report:@"Helper launched succesfully."];
}

-(void) failed_helper_authenticated_submission_with_message:(NSString *)message {
    [self report:[NSString stringWithFormat:@"Failed submitting helper task: %@", message]];
}

-(void) service_management_failed_with_error:(NSString *)message {
    [self report:[NSString stringWithFormat:@"Failed submitting helper task: %@", message]];
}

-(void) service_management_submission_succesfull {
    [self report:@"Launch task submission succesful."];
}

-(void) finished_tokaido_bootstrap_detection {
    [self report:@"Finished Tokaido Bootstrap detection." incrementBy:30.0];
}

-(void) starting_shutting_down_tokaido_bootstrap {
    [self report:@"Starting Tokaido Bootstrap shutdown."];
}

-(void) shutting_down_tokaido_bootstrap {
    [self report:@"Shutting down tokaido-bootstrap."];
}

-(void) tokaido_boostrap_shutdown {
    [self report:@"tokaido-bootstrap shutdown complete."];
}

-(void) finished_tokaido_boostrap_shutdown {
    [self report:@"Finished shutting down tokaido-bootstrap." incrementBy:1.0];
}

-(void) starting_tokaido_bootstrap {
    [self report:@"Staring tokaido-bootstrap."];
}

-(void) unlinking_current_socket {
    [self report:@"Unlinking current socket"];
}

-(void) tokaido_bootstrap_started {
    [self report:@"tokaido-bootstrap started."];
}

-(void) finished_starting_tokaido_bootstrap {
    [self report:@"Finished starting tokaido-bootstrap." incrementBy:1.0];
}

-(void) failed_starting_tokaido_bootstrap_with_error:(NSString *)message {
    [self report:[NSString stringWithFormat:@"Failed starting tokaido-bootstrap: %@", message]];
}

-(void) quit_application {
    //[[NSApplication sharedApplication] terminate:nil];
}

@end
