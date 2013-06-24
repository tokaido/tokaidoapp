//
//  TKDRailsAppTokenField.m
//  Tokaido
//
//  Created by Patrick B. Gibson on 11/15/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDRailsAppTokenField.h"

#define kSpacing 3
#define kArrowUpWidth 9

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
    self.gemView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 9, 9, 9)];
    [self addSubview:self.gemView];

    _state = TKDAppBooting;
    [self setState:TKDAppOff];

    // the total width of the view is 150px
    // - gem view: 18px
    // - padding: 0px
    // - text field: liquid (max 117px)
    // - padding: 5px
    // - arrow: 10px

    self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(18, 0, 117, 20)];
    self.textField.textColor = [NSColor darkGrayColor];
    self.textField.stringValue = @"app.tokaido";
    self.textField.drawsBackground = NO;

    // truncate using ellipses
    [[self.textField cell] setLineBreakMode:NSLineBreakByTruncatingTail];

    // center text
    //[self.textField setAlignment:NSCenterTextAlignment];
    [self.textField setBordered:NO];
    [self.textField setBezeled:NO];
    [self.textField setEditable:NO];
    [self addSubview:self.textField];
    
    self.arrowView = [[NSImageView alloc] initWithFrame:NSMakeRect(140, 5, kArrowUpWidth, kArrowUpWidth + 1)];
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
                self.gemView.image = [NSImage imageNamed:@"Green"];
                break;
            case TKDAppBooting:
            case TKDAppShuttingDown:
                self.gemView.image = [NSImage imageNamed:@"Yellow"];
                break;
            case TKDAppOff:
                self.gemView.image = [NSImage imageNamed:@"Red"];
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
        [self setNeedsLayout:YES];
    }
}

// Layout
- (void)layout
{
    // This method has a lot of hardcoded values. Ideally that would be addressed.

    CGFloat viewWidth = self.bounds.size.width;
    CGSize gemSize = self.gemView.bounds.size;
    CGSize arrowSize = self.arrowView.bounds.size;
    
    CGFloat maxTextWidth = viewWidth - gemSize.width - kSpacing - kSpacing - kArrowUpWidth;
    NSSize textSize = [self.title sizeWithAttributes:nil];

    if (textSize.width + 10 > maxTextWidth) {
        textSize.width = maxTextWidth;
    } else {
        textSize.width = textSize.width + 10;
    }
    
    CGFloat extraSpace = maxTextWidth - textSize.width;
    CGFloat padding = extraSpace / 2.0f;
    
    CGFloat start = padding;
    CGFloat textStart = padding + gemSize.width + kSpacing;
    CGFloat textEnd = viewWidth - kArrowUpWidth - kSpacing - padding;
    CGFloat arrowStart = textEnd + kSpacing;

    self.gemView.frame = NSIntegralRect( NSMakeRect(start, 5, gemSize.width, gemSize.height));
    self.arrowView.frame = NSIntegralRect( NSMakeRect(arrowStart, 5, arrowSize.width, arrowSize.height));
    self.textField.frame = NSIntegralRect( NSMakeRect(textStart, 4, textSize.width, textSize.height));
    
    [super layout];
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
