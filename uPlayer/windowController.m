//
//  windowController.m
//  uPlayer
//
//  Created by liaogang on 15/1/28.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "windowController.h"
#import "ViewController.h"
#import "UPlayer.h"

@interface WindowController ()
<NSToolbarDelegate>
@property (weak) IBOutlet NSComboBox *orderCombo;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSSlider *volumnSlider;
@property (weak) IBOutlet NSSearchField *searchField;
@end

@implementation WindowController
- (IBAction)actionSearch:(id)sender
{
    ViewController *vc = (ViewController *) self.contentViewController;
    
    NSSearchField *sf = (NSSearchField *)sender;
    
    [vc filterTable:sf.stringValue];
}
- (IBAction)actionChangePlayOrder:(id)sender {
}
- (IBAction)actionProgressSlider:(id)sender {
}
- (IBAction)actionVolumnSlider:(id)sender {
}

-(instancetype)init
{
    self =[ super init];
    if (self) {
        
        
        
    }
    
    return self;
}

- (void) windowWillClose:(NSNotification *)notification
{
    [player().core stop];
}

-(void)awakeFromNib
{
    [self.window setContentBorderThickness:22 forEdge:NSMinYEdge];
}

@end

