//
//  ViewController.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "TracklistViewController.h"
#import "UPlayer.h"

#import "PlayerMessage.h"
#import "PlayerSerachMng.h"


typedef enum
{
   displayMode_tracklist,
   displayMode_tracklist_search,
} displayMode;

@interface NSTableView (rc)
/// select item at right click.
-(NSMenu *)menuForEvent:(NSEvent *)event;
@end

@implementation NSTableView (rc)
-(NSMenu *)menuForEvent:(NSEvent *)event
{
    // what row are we at?
    NSInteger row = [self rowAtPoint: [self convertPoint: [event
                                                     locationInWindow] fromView: nil]];
    if (row != -1) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex: row] byExtendingSelection:YES];
    }
    return [super menu]; // use what we've got
}
@end

@interface TracklistViewController () <NSTableViewDelegate , NSTableViewDataSource >
@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,assign) NSArray *columnNames,*columnWidths;
@property (nonatomic) displayMode displaymode;
@property (nonatomic,strong) PlayerSearchMng* searchMng;
@property (nonatomic,strong) PlayerlList *playerlList;
@end

@implementation TracklistViewController

-(void)awakeFromNib
{
    addObserverForEvent(self, @selector(reloadTrackList:), EventID_to_reload_tracklist);
    
    addObserverForEvent(self, @selector(playSelctedTrack), EventID_to_play_selected_track);
    
    
    self.playerlList = player().document.playerlList;
}


/// @see EventID_to_reload_tracklist
-(void)reloadTrackList:(NSNotification*)n
{
    
    [self.tableView becomeFirstResponder];
    
    // quit search mode.
    if (self.displaymode == displayMode_tracklist_search)
        self.displaymode = displayMode_tracklist;
    
    [self.tableView reloadData];
    
    [self.tableView resignFirstResponder];
    
    PlayerList *list =  n.object; // the selected
    
    int targetIndex = -1;
    if ( list == nil) // then reload playing.
    {
        int index = self.playerlList.playIndex ;
        list = [self.playerlList getItem: index];
        [self.playerlList setSelectIndex:index];
        
        targetIndex = list.playIndex;
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex: targetIndex] byExtendingSelection:YES];
        [self scrollRowToCenter:targetIndex];
    }
    else if (list == [self.playerlList getSelectedList])
    {
        
    }
    else
    {
        [self.playerlList getSelectedList].topIndex = [self getRowOnTableTop];
        
        [self.playerlList setSelectItem: list];
        if (list.selectIndex >= 0)
        {
            targetIndex = list.selectIndex;
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex: targetIndex] byExtendingSelection:YES];
            [self scrollRowToCenter:targetIndex];
        }
        else
        {
            targetIndex = list.topIndex;
            [self scrollRowToTop:targetIndex];
        }
        
    }
    
    
}


-(int)getRowOnTableTop
{
    NSRange rg = [self.tableView rowsInRect:self.tableView.visibleRect];
    return  (int) rg.location;
}

-(void)scrollRowToTop:(int)targetIndex
{
    int rowsPerPage = self.tableView.visibleRect.size.height/ self.tableView.rowHeight;
    
    int topIndex = [self getRowOnTableTop];
    
    if ( targetIndex > topIndex )
        targetIndex +=  rowsPerPage ;
    
    [self.tableView scrollRowToVisible: targetIndex ];
}

-(void)scrollRowToCenter:(int)targetIndex
{
    int rowsPerPage = self.tableView.visibleRect.size.height/ self.tableView.rowHeight;
    
    int topIndex = [self getRowOnTableTop];
    
    int target;
    if ( targetIndex < topIndex )
    {
        target = targetIndex - rowsPerPage / 2;
        if (target < 0)
            target = 0;
    }
    else
    {
        int count = (int) [self numberOfRowsInTableView:self.tableView];
        target = targetIndex + rowsPerPage /2;
        if (target > count - 1)
            target = count - 1;
    }
    
    [self.tableView scrollRowToVisible: target ];
}


-(void)viewDidAppear
{
    [super viewDidAppear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat bottomBarHeight = 22.0;
    
    NSRect rc = NSMakeRect(0, 0 + bottomBarHeight, self.view.bounds.size.width, self.view.bounds.size.height  - bottomBarHeight);
    
    NSScrollView *tableContainer = [[NSScrollView alloc]initWithFrame:rc];
    tableContainer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.tableView = [[NSTableView alloc]initWithFrame:tableContainer.bounds];
    self.tableView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;;
    self.tableView.rowHeight = 40.;
    self.tableView.allowsMultipleSelection = TRUE;
    
    // disable table header's menu.
    NSMenu *menu = [[NSMenu alloc] init];
    self.tableView.headerView.menu = menu;
    
    self.columnNames = [NSArray arrayWithObjects:@"#",@"artist",@"title",@"album",@"genre",@"year", nil];
    self.columnWidths = [NSArray arrayWithObjects: @60,@120,@320,@320,@60,@60, nil];
    
    for (int i = 0; i < self.columnNames.count; i++)
    {
        NSTableColumn *cn = [[NSTableColumn alloc]initWithIdentifier: @"idn"];
        cn.title = (NSString*) self.columnNames[i];
        cn.width =((NSNumber*)self.columnWidths[i]).intValue;
        
        [self.tableView addTableColumn:cn];
    }
    
    
    self.tableView.doubleAction=@selector(doubleClicked);
    
    
    
    self.tableView.usesAlternatingRowBackgroundColors = true;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    tableContainer.documentView = self.tableView;
    tableContainer.hasVerticalScroller = true;
    [self.view addSubview:tableContainer];
    
    [self.tableView reloadData];
}



-(void)filterTable:(NSString*)key
{
    if (key.length > 0)
    {
        self.displaymode= displayMode_tracklist_search;
        if (self.searchMng == nil)
            self.searchMng = [[PlayerSearchMng alloc]init];
        
        self.searchMng.playerlistOriginal = [self.playerlList getSelectedList];
        
        [self.searchMng search:key];
    }
    else
    {
        self.displaymode = displayMode_tracklist;
        
    }
    
    [self.tableView reloadData];
}


-(void)playTrack:(NSInteger)index
{
    NSInteger row = index;
    
    if ( row >= 0)
    {
        PlayerList *list ;
        
        PlayerTrack *track;
        if (self.displaymode == displayMode_tracklist_search)
        {
            list = self.searchMng.playerlistFilter ;
            
            track = [self.searchMng getOrginalByIndex:row];
            [list setSelectIndex:row];
            
            list = self.searchMng.playerlistOriginal;
        }
        else
        {
            list = [_playerlList getSelectedList];
            track = [list getItem:row];
            [list setSelectIndex:row];
        }
        
        playTrack(track);
    }
    
 
}

-(void)playClickedTrack
{
    [self playTrack: self.tableView.clickedRow];
}

-(void)playSelectedTrack
{
    [self playTrack:self.tableView.selectedRow];
}

-(void)doubleClicked
{
    //postEvent(EventID_to_play_selected_track, nil);
    
    [player().document.playerQueue clear];
    
    [self playClickedTrack];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if ( self.displaymode == displayMode_tracklist_search)
        return   [self.searchMng.playerlistFilter count ];
    else if ( self.displaymode == displayMode_tracklist)
        return   [[self.playerlList getSelectedList] count];
    else
        return  [self.playerlList count];
}

-(PlayerTrack*)getSelectedItem:(NSInteger)row
{
    PlayerTrack *track = self.displaymode == displayMode_tracklist_search? [self.searchMng.playerlistFilter getItem: (int)row ]: [[self.playerlList getSelectedList] getItem: (int)row];
    return track;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSInteger column = [self.tableView.tableColumns indexOfObject:tableColumn];
    
    NSString *identifier = @"t_itf";
    NSTextField *textField = (NSTextField *)[self.tableView makeViewWithIdentifier:identifier owner:self];
    
    if (textField == nil)
    {
        textField = [[NSTextField alloc]initWithFrame:NSMakeRect(0, 0, tableColumn.width, 0)];
        textField.autoresizingMask = ~0 ;
        textField.bordered = false ;
        textField.drawsBackground = false ;
        textField.font = [NSFont systemFontOfSize:30] ;
        textField.editable = false ;
        textField.identifier=identifier;
    }

    
    TrackInfo *info = [self getSelectedItem:row].info;
    
    if (column == 0) {
        textField.stringValue = [NSString stringWithFormat:@"%ld",row + 1];
        textField.editable = false;
        
    }
    else if(column == 1)
    {
        textField.stringValue = info.artist;
    }
    else if(column == 2)
    {
        textField.stringValue = info.title ;
    }
    else if(column == 3)
    {
        textField.stringValue = info.album;
    }
    else if(column == 4)
    {
        textField.stringValue = info.genre;
    }
    else if(column == 5)
    {
        textField.stringValue = info.year;
    }
    
    return textField;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void)keyDown:(NSEvent *)theEvent
{
    NSLog(@"%@",self);
//    printf("key pressed: %s\n", [[theEvent description] cString]);
    
    // press 'Enter' to play item.
    if ([theEvent.characters isEqualToString:@"\r" ] ) {
        [self playSelectedTrack];
    }
}

- (IBAction)cmdShowInFinder:(id)sender
{
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    if ( rows.count > 0)
    {
        NSMutableArray *urlArr=[NSMutableArray array];
        [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            TrackInfo *info = [self getSelectedItem:idx].info;
            [urlArr addObject: [NSURL fileURLWithPath: info.path]];
            
        }];
        
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: urlArr ];
    }
}

- (IBAction)cmdAddToPlayQueue:(id)sender
{
    NSInteger i = self.tableView.selectedRow;
    if (i > 0)
    {
        PlayerTrack *track = [self getSelectedItem: i ];
        
        [player().document.playerQueue push:track];
    }
    
}

@end
