//
//  TKDRailsAppTokenField.m
//  Tokaido
//
//  Created by Patrick B. Gibson on 11/15/12.
//  Copyright (c) 2012 Tilde. All rights reserved.
//

#import "TKDRailsAppTokenField.h"

@interface TKDRailsAppTokenField ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) TKDRailsAppTokenState state;

@property (nonatomic, strong) NSImageView *gemView;
@property (nonatomic, strong) NSImageView *arrowView;
@property (nonatomic, strong) NSTextField *textField;
@end

@implementation TKDRailsAppTokenField

- (void)awakeFromNib
{
    self.gemView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 19)];
    [self setState:TKDRailsAppTokenStateWorking];
    [self addSubview:self.gemView];
    
    self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 0, 100, 20)];
    self.textField.textColor = [NSColor lightGrayColor];
    self.textField.stringValue = @"app.tokaido";
    self.textField.drawsBackground = NO;
    [self.textField setAlignment:NSCenterTextAlignment];
    [self.textField setBordered:NO];
    [self.textField setBezeled:NO];
    [self.textField setEditable:NO];
    [self addSubview:self.textField];
    
    self.arrowView = [[NSImageView alloc] initWithFrame:NSMakeRect(130, 0, 9, 10)];
    self.arrowView.image = [NSImage imageNamed:@"down_arrow.png"];
    [self addSubview:self.arrowView];
}

- (void)setState:(TKDRailsAppTokenState)newState;
{
    if (self.state != newState) {
        _state = newState;
        
        switch (self.state) {
            case TKDRailsAppTokenStateActivated:
                self.gemView.image = [NSImage imageNamed:@"Green.png"];
                break;
            case TKDRailsAppTokenStateWorking:
                self.gemView.image = [NSImage imageNamed:@"Yellow.png"];
                break;
            case TKDRailsAppTokenStateDeactivated:
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
        [self setNeedsDisplay:YES];
    }
}


- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (NSPointInRect(curPoint, self.bounds)) {
        NSLog(@"Clicked point inside: %@", NSStringFromPoint([theEvent locationInWindow]));
    }
}

@end
