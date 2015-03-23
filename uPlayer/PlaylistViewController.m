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
//    NSStoryboardShowSegueTemplate *s;
    self.playerlList = player().document.playerlList;
}


-(void)reloadTrackList
{
    /// @todo save top index.
    
    [self.tableView reloadData];
    
    [self.tableView resignFirstResponder];
    
    PlayerTrack *track = player().playing;
    
    PlayerList *list = track.list;
    
    NSInteger row = track.index;
    
    if (row == -1)
        return;
    
    NSInteger rowsPerPage = self.tableView.visibleRect.size.height/ self.tableView.rowHeight;
    
    NSRange rg = [self.tableView rowsInRect:self.tableView.visibleRect];
    int topIndex = (int) rg.location;
    
    NSInteger target;
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
    
    addObserverForEvent( self.tableView , @selector(reloadData), EventID_tracks_changed);
    addObserverForEvent( self.tableView , @selector(reloadData), EventID_list_changed);
    
}



-(void)doubleClicked
{
    int selectedRow = (int) self.tableView.selectedRow;
    if ( selectedRow != -1)
    {
        PlayerList *l = [self.playerlList getItem:selectedRow];
        
        postEvent(EventID_to_reload_tracklist, l );
    }
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
    
    PlayerList * list = [self.playerlList getItem:(int)row];
    
    if (column == 0)
    {
        textField.stringValue = [NSNumber numberWithInt:(int)row+1].stringValue;
    }
    else if (column == 1)
    {
        textField.stringValue = [NSString stringWithFormat:@"%zu", list.count];
    }
    else
    {
        textField.stringValue = list.name;
    }
    
    return textField;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void)keyDown:(NSEvent *)theEvent
{
//    NSLog(@"%@",self);
//    printf("key pressed: %s\n", [[theEvent description] cString]);
    
    if (theEvent.characters ) {
        
    }
}

-(bool)hasRowSelected
{
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    return rows.count > 0;
}

- (IBAction)cmdDeleteItem:(id)sender
{
    NSInteger item = self.tableView.selectedRow;
    
    PlayerList* nearItem = [player().document.playerlList deleteItem:item];
    
    [self.tableView reloadData];
    
    postEvent(EventID_to_reload_tracklist, nearItem);
    
    
}

- (IBAction)cmdActiveItem:(id)sender
{
    int selectedRow = (int) self.tableView.selectedRow;
    PlayerList *l = [self.playerlList getItem:selectedRow];
    
    postEvent(EventID_to_reload_tracklist, l );
    
}

@end
