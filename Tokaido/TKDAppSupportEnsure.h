#import <Foundation/Foundation.h>
#import "TKDRubyBinary.h"

@protocol TKDAppSupportEnsure <NSObject>

@required
-(void) checking_ruby_installation;
-(void) finished_checking_ruby_installation;
-(void) finding_rubies_bundled;
-(void) found_ruby_not_installed:(TKDRubyBinary *)rb;
-(void) unzipping_ruby_bundled;
-(void) finished_unzipping_ruby_bundled;
-(void) ruby_installed;
-(void) finished_ruby_installations;
-(void) checking_gems_installation;
-(void) unzipping_gems_bundled;
-(void) finished_unzipping_gems_bundled;
-(void) checking_binaries_installation;
-(void) unzipping_binaries_bundled;
-(void) finished_unzipping_binaries_bundled;
-(void) starting_clang_search;
-(void) clang_not_found;
-(void) starting_clang_symlink;
-(void) finished_clang_symlink;
-(void) applying_rbconfig_patches;
-(void) error_patching_rbconfig_with_message:(NSString *)message;
-(void) replacing_config_topdir_line;
-(void) replacing_config_cc_line;
-(void) patching_rbconfig_complete;
-(void) finished_ensuring_app_support_is_updated;

-(void) checking_tokaido_bootstrap_installation;
-(void) unzipping_tokaido_bootstrap_bundled;
-(void) finished_unzipping_tokaido_bootstrap_bundled;
-(void) finished_checking_tokaido_bootstrap_installation;

-(void) starting_tokaido_bootstrap_detection;
-(void) tokaido_bootstrap_detected;
-(void) tokaido_bootstrap_not_detected;
-(void) tokaido_bootstrap_installing;
-(void) error_reading_firewall_plist_file;
-(void) saving_firewall_plist_file;
-(void) error_saving_firewall_plist_file;
-(void) saved_firewall_plist_file;
-(void) requesting_authorization;
-(void) helper_ran_succesfully;
-(void) failed_helper_authenticated_submission_with_message:(NSString *)message;
-(void) service_management_failed_with_error:(NSString *)message;
-(void) service_management_submission_succesfull;
-(void) finished_tokaido_bootstrap_detection;

-(void) starting_shutting_down_tokaido_bootstrap;
-(void) finished_tokaido_boostrap_shutdown;

-(void) unlinking_current_socket;
-(void) starting_tokaido_bootstrap;
-(void) tokaido_bootstrap_started;
-(void) failed_starting_tokaido_bootstrap_with_error:(NSString *)message;
-(void) finished_starting_tokaido_bootstrap;

-(void) quit_application;
@end
