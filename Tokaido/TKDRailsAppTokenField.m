//
//  TKDRailsAppTokenField.m
//  Tokaido
//
//  Created by Patrick B. Gibson on 11/15/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDRailsAppTokenField.h"

#define kSpacing 8
#define kArrowUp 5

@interface TKDRailsAppTokenField ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) TKDAppState state;

@property (nonatomic, strong) NSImageView *gemView;
@property (nonatomic, strong) NSImageView *arrowView;
@property (nonatomic, strong) NSTextField *textField;
@end

@implementation TKDRailsAppTokenField

- (void)awakeFromNib
{
    self.gemView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 19)];
    [self addSubview:self.gemView];
    _state = TKDAppBooting;
    [self setState:TKDAppOff];
    
    self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 0, 100, 20)];
    self.textField.textColor = [NSColor darkGrayColor];
    self.textField.stringValue = @"app.tokaido";
    self.textField.drawsBackground = NO;
//    self.textField.backgroundColor = [NSColor blueColor];
    [self.textField setAlignment:NSCenterTextAlignment];
    [self.textField setBordered:NO];
    [self.textField setBezeled:NO];
    [self.textField setEditable:NO];
    [self addSubview:self.textField];
    
    self.arrowView = [[NSImageView alloc] initWithFrame:NSMakeRect(130, kArrowUp, 9, 10)];
    self.arrowView.image = [NSImage imageNamed:@"down_arrow.png"];
    [self addSubview:self.arrowView];
    
//    [self.textField bind:@"value" toObject:[self.delegate app] withKeyPath:@"appHostname" options:nil];
}

- (void)configureForRepresentedObject
{
    self.title = [self.delegate titleForTokenField:self];
    
    [[self.delegate app] addObserver:self
                          forKeyPath:@"state"
                             options:(NSKeyValueObservingOptionNew |
                                      NSKeyValueObservingOptionOld)
                             context:NULL];
    [[self.delegate app] addObserver:self
                          forKeyPath:@"appHostname"
                             options:(NSKeyValueObservingOptionNew |
                                      NSKeyValueObservingOptionOld)
                             context:NULL];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
	if ([keyPath isEqualToString:@"state"]) {
        [self setState:[[change objectForKey:NSKeyValueChangeNewKey] intValue]];
    } else if ([keyPath isEqualToString:@"appHostname"]) {
        [self setTitle:[change objectForKey:NSKeyValueChangeNewKey]];
	} else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)setState:(TKDAppState)newState;
{
    if (self.state != newState) {
        _state = newState;
        
        switch (self.state) {
            case TKDAppOn:
                self.gemView.image = [NSImage imageNamed:@"Green.png"];
                break;
            case TKDAppBooting:
            case TKDAppShuttingDown:
                self.gemView.image = [NSImage imageNamed:@"Yellow.png"];
                break;
            case TKDAppOff:
                self.gemView.image = [NSImage imageNamed:@"Red.png"];
                break;
                
            default:
                break;
        }
        
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitle:(NSString *)newTitle;
{
    if (newTitle != self.title) {
        _title = newTitle;
        self.textField.stringValue = _title;
        [self layout];
    }
}

// Layout
- (void)layout
{
    CGFloat totalWidth = self.bounds.size.width;
    
    // Figure out the size of our text field.
    NSSize textsize = [self.title sizeWithAttributes:nil];
    if (textsize.width > 120) {
        textsize.width = 120;
    }
    
    // Move the gem in to the right so that it's directly beside the text
    CGFloat textStart = (totalWidth / 2.0f) - (textsize.width / 2.0f);
    CGSize gemSize = self.gemView.bounds.size;
    self.gemView.frame = NSIntegralRect( NSMakeRect(textStart - gemSize.width - kSpacing, 1, gemSize.width, gemSize.height) );
    
    // Move the down arrow in to the left so that it's also directly beside the text
    CGFloat textEnd = totalWidth / 2.0f + textsize.width / 2.0f;
    CGSize arrowSize = self.arrowView.bounds.size;
    self.arrowView.frame = NSIntegralRect( NSMakeRect(textEnd + kSpacing, kArrowUp, arrowSize.width, arrowSize.height) );
    
    [self setNeedsDisplay:YES];
}

// Event Handling

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (NSPointInRect(curPoint, self.bounds)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tokenField:clickedWithEvent:)]) {
            [self.delegate tokenField:self clickedWithEvent:theEvent];
        }
    }
}

- (void)dealloc
{
    [[self.delegate app] removeObserver:self forKeyPath:@"state"];
    [[self.delegate app] removeObserver:self forKeyPath:@"appHostname"];
}

@end
