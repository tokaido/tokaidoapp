#import <Quartz/Quartz.h>

#import "TKDFileUtilities.h"
#import "TKDConfiguration.h"
#import "TKDEditAppController.h"
#import "TKDAppDelegate.h"

@interface TKDEditAppController ()
@property (nonatomic, copy) NSString *prevAppName;
@property (nonatomic, copy) NSString *prevHostname;
@property (nonatomic, copy) NSString *prevAppIconPath;
@property (nonatomic, assign) BOOL prevUsesYAML;
@end

@interface toNSImage : NSValueTransformer
+(Class)transformedValueClass;
-(id)transformedValue:(id)value;
@end

@implementation toNSImage

+(Class)transformedValueClass {
    return [NSImage class];
}

-(id)transformedValue:(id)value {
    if (value == nil) {
        return nil;
    } else {
        return [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:value]];
    }
}

@end

@implementation TKDEditAppController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.prevAppIconPath = self.app.appIconPath;
    self.prevAppName = self.app.appName;
    self.prevHostname = self.app.appHostname;
    self.prevUsesYAML = self.app.usesYAMLfile;
    
}

- (IBAction)chooseImagePressed:(id)sender;
{
    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    
    [pictureTaker beginPictureTakerSheetForWindow:self.window
                                     withDelegate:self
                                   didEndSelector:@selector(pictureTakerDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
}

- (void)pictureTakerDidEnd:(IKPictureTaker *)pictureTaker returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    
    if (returnCode == NSOKButton)
        self.appImageView.image = [pictureTaker outputImage];
}

- (IBAction)savePressed:(id)sender {
    [TKDFileUtilities createDirectoryAtPathIfNonExistant:[TKDConfiguration assetsDirectoryInstalledPath]];
    
    NSImage *i = self.appImageView.image;
    [i lockFocus];
    NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, [i size].width, [i size].height)];
    [i unlockFocus];
    NSURL *path = [[NSURL fileURLWithPath:[TKDConfiguration assetsDirectoryInstalledPath] isDirectory:YES]URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[self generateName]]];
    NSData *bits = [imgRep representationUsingType: NSPNGFileType properties: nil];
    
    if ([bits writeToURL:path atomically:NO])
        self.app.appIconPath = [path absoluteString];
    
    if (self.app.usesYAMLfile)
        [self.app serializeToYAML];
    
    TKDAppDelegate *delegate = (TKDAppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate saveAppSettings];
    
    [NSApp endSheet:self.window];
}

- (IBAction)cancelPressed:(id)sender {
    self.app.appIconPath = self.prevAppIconPath;
    self.app.appName = self.prevAppName;
    self.app.appHostname = self.prevHostname;
    self.app.usesYAMLfile = self.prevUsesYAML;
    
    [NSApp endSheet:self.window];
}

-(NSString *) generateName {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end
