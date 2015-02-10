//
//  ViewController.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlaylistViewController.h"
#import "UPlayer.h"

#import "PlayerMessage.h"
#import "PlayerSerachMng.h"



@interface PlaylistViewController () <NSTableViewDelegate , NSTableViewDataSource >
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic,strong) PlayerlList *playerlList;
@end

@implementation PlaylistViewController

-(void)awakeFromNib
{
//    addObserverForEvent(self, @selector(reloadTrackList), EventID_to_reload_tracklist);
    
    
//    addObserverForEvent(self, @selector(showPlayList), EventID_to_show_playlist);
    
    self.playerlList = player().document.playerlList;
}




-(void)reloadTrackList
{
    /// @todo save top index.
    
    [self.tableView reloadData];
    
    [self.tableView resignFirstResponder];
    
    PlayerList *list = [self.playerlList getPlayList];
    int row = list.playIndex;
    
    if (row == -1)
        return;
    
    int rowsPerPage = self.tableView.visibleRect.size.height/ self.tableView.rowHeight;
    
    NSRange rg = [self.tableView rowsInRect:self.tableView.visibleRect];
    int topIndex = (int) rg.location;
    
    int target;
    if ( row < topIndex )
    {
        target = row - rowsPerPage / 2;
        if (target < 0)
            target = 0;
    }
    else
    {
        int count = (int) [list count];
        target = row + rowsPerPage /2;
        if (target > count - 1)
            target = count - 1;
    }
    
    [self.tableView scrollRowToVisible: target ];
    
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex: row] byExtendingSelection:YES];
}

-(void)viewDidAppear
{
    [super viewDidAppear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.tableView.rowHeight = 40.;
    
    self.tableView.doubleAction=@selector(doubleClicked);
    
    self.tableView.usesAlternatingRowBackgroundColors = true;
    
    [self.tableView reloadData];
}


-(void)doubleClicked
{
    int selectedRow = (int) self.tableView.selectedRow;
    PlayerList *l = [self.playerlList getItem:selectedRow];
    
    postEvent(EventID_to_reload_tracklist, l );
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return  [self.playerlList count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSInteger column = [tableView.tableColumns indexOfObject:tableColumn];
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier   owner:self];

    NSTextField *textField = [cellView subviews].firstObject;
    
    if (column == 0)
    {
        textField.stringValue = [NSNumber numberWithInt:(int)row].stringValue;
    }
    else
    {
        textField.stringValue = [self.playerlList getItem:(int)row].name;
    }
    
    return textField;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void)keyDown:(NSEvent *)theEvent
{
    //printf("key pressed: %s\n", [[theEvent description] cString]);
    
    if (theEvent.characters ) {
        
    }
}


@end
