#import "TKDSelectableIcon.h"

@interface TKDSelectableIcon ()

@property (nonatomic, strong) NSString *appIconPath;
@property NSImageView *iconImageView;
@property NSImageView *backgroundImageView;

@end

@implementation TKDSelectableIcon

@synthesize selected = _selected;

- (void)awakeFromNib {
    self.iconImageView = [[NSImageView alloc] initWithFrame:self.bounds];
    self.iconImageView.image = [NSImage imageNamed:@"TKIconRuby"];
    self.backgroundImageView = [[NSImageView alloc] initWithFrame:self.bounds];
    [self.backgroundImageView setImage:[NSImage imageNamed:@"TKAppIconBackground"]];
    [self.backgroundImageView setHidden:YES];
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.iconImageView];
}

- (void)setSelectedBackgroundImage:(NSImage *)backgroundImage {
    self.backgroundImageView.image = backgroundImage;
}

- (void)setIconImageWithString:(NSString *)path {
    if (path != nil) {
        _appIconPath = path;
        self.iconImageView.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:path]];
        [self setNeedsDisplay:YES];
    }
}


- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        [self.backgroundImageView setHidden:!selected];
        _selected = selected;
    }
    [self setNeedsDisplay:YES];
}

- (BOOL)selected {
    return _selected;
}

- (void)configureForRepresentedObject {
    self.appIconPath = [self.delegate pathForIcon:self];
    
    [[self.delegate app] addObserver:self
                          forKeyPath:@"appIconPath"
                             options:(NSKeyValueObservingOptionNew |
                                      NSKeyValueObservingOptionOld |
                                      NSKeyValueObservingOptionInitial)
                             context:NULL];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
	if ([keyPath isEqualToString:@"appIconPath"]) {
        [self setIconImageWithString:[change objectForKey:NSKeyValueChangeNewKey]];
	} else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)dealloc {
    [[self.delegate app] removeObserver:self forKeyPath:@"appIconPath"];
}


@end
