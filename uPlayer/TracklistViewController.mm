//
//  TracklistViewController.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "TracklistViewController.h"
#import "UPlayer.h"
#import "PlayerMessage.h"
#import "PlayerSerachMng.h"
#import "keycode.h"
#import "MAAssert.h"

#import "Last_fm_user.h"
#import "Last_fm_api.h"

#import "ThreadJob.h"

/*
@interface NSTableView (rc)
/// select item at right click.
-(NSMenu *)menuForEvent:(NSEvent *)event;
@end

@implementation NSTableView (rc)
-(NSMenu *)menuForEvent:(NSEvent *)event
{
    NSEvent *e = [NSEvent mouseEventWithType: NSLeftMouseDown location:event.locationInWindow modifierFlags:event.modifierFlags timestamp:event.timestamp windowNumber:event.windowNumber context:event.context eventNumber:event.eventNumber clickCount:event.clickCount pressure:event.pressure];
    
    [super menuForEvent: e];
    
    // what row are we at?
    NSInteger row = [self rowAtPoint: [self convertPoint: [event locationInWindow] fromView: nil]];
    
    //if( row == -1)
    //    [self deselectAll:nil];
    //else
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex: row] byExtendingSelection:YES];
    
    return [super menu]; // use what we've got
}
@end
*/

@interface TracklistViewController () <NSTableViewDelegate , NSTableViewDataSource >
@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,assign) NSArray *columnNames,*columnWidths;
@property (nonatomic,assign) bool isSearchMode;
@property (nonatomic,strong) PlayerSearchMng* searchMng;
@property (nonatomic,strong) PlayerlList *playerlList;

@property (nonatomic,strong) NSProgressIndicator *progress;
@end

@implementation TracklistViewController
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initLoad];
    }
    
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initLoad];
    }
    
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initLoad];
    }
    
    return self;
}

-(void)dealloc
{
    
}

-(void)initLoad
{
    addObserverForEvent(self, @selector(reloadTrackList:), EventID_to_reload_tracklist);
    
    addObserverForEvent(self, @selector(playSelectedTrack), EventID_to_play_selected_track);
    
    addObserverForEvent(self, @selector(playTrackItem:), EventID_to_play_item);

    addObserverForEvent(self, @selector(startPIAnimation), EventID_importing_tracks_begin);
    addObserverForEvent(self, @selector(stopPIAnimation), EventID_importing_tracks_end);
    
    self.playerlList = player().document.playerlList;
}

/**
 @see EventID_to_reload_tracklist
 
 if n.object is `nil` , then will located to the playing track.
 if n.object is `PlayerList* list` , then will located to the list's top item.
 if n.object is `PlayerTrack *track`, then the track.
 */

-(void)reloadTrackList:(NSNotification*)n
{
    [self.view.window makeFirstResponder:self.tableView];
    
    // quit search mode.
    if(self.isSearchMode)
        self.isSearchMode = false;
    
    PlayerList *listOld = self.playerlList.selectItem;
    PlayerList *list;
    int target = 0;
    // scroll target index to center or top?
    bool toCenter = YES;
    
    if (n.object)
    {
        MAAssert( [n.object isKindOfClass:[PlayerTrack class]] || [n.object isKindOfClass:[PlayerList class]]  );

        if ([n.object isKindOfClass:[PlayerTrack class] ])
        {
            PlayerTrack *track;
            track = n.object;
            
            list = track.list;
            
            if (list != self.playerlList.selectItem)
            {
                [self.playerlList setSelectItem:list];
                [self.tableView reloadData];
            }

            target = (int)track.index;
        }
        else
        {
            list = n.object;
            
            // current is not showing. reload it.
            if (list != self.playerlList.selectItem)
            {
                [self.playerlList setSelectItem:list];
                
                target = list.topIndex;
                toCenter = false;
            }
        }
    }
    else
    {
        // then reload playing.
        list = player().playing.list;
        
        target = (int)player().playing.index;
    }

    

    if ( list != listOld)
    {
        if (listOld)
            listOld.topIndex = [self getRowOnTableTop];
        
        if (list)
            [self.playerlList setSelectItem:list];
    }
    
    [self.tableView reloadData];
    
    if (toCenter)
        [self scrollRowToCenter: target];
    else
        [self scrollRowToTop: target];
    
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex: target] byExtendingSelection:YES];

}


-(int)getRowOnTableTop
{
    NSRange rg = [self.tableView rowsInRect:self.tableView.visibleRect];
    return  (int) rg.location;
}

-(void)scrollRowToTop:(NSInteger)targetIndex
{
    int rowsPerPage = self.tableView.visibleRect.size.height/ self.tableView.rowHeight;
    
    int topIndex = [self getRowOnTableTop];
    
    if ( targetIndex > topIndex )
        targetIndex +=  rowsPerPage ;
    
    [self.tableView scrollRowToVisible: targetIndex ];
}

-(void)scrollRowToCenter:(NSInteger)targetIndex
{
    int rowsPerPage = self.tableView.visibleRect.size.height/ self.tableView.rowHeight;
    
    int topIndex = [self getRowOnTableTop];
    
    NSInteger target;
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
    
    self.columnNames = [NSArray arrayWithObjects:
                        NSLocalizedString(@"#", nil),
                        NSLocalizedString(@"artist", nil),
                        NSLocalizedString(@"title", nil),
                        NSLocalizedString(@"album", nil),
                        NSLocalizedString(@"genre", nil),
                        NSLocalizedString(@"year", nil),nil];
    
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
        self.isSearchMode = true;
        
        if (self.searchMng == nil)
            self.searchMng = [[PlayerSearchMng alloc]init];
        
        self.searchMng.playerlistOriginal = self.playerlList.selectItem;
        
        [self.searchMng search:key];
    }
    else
    {
        self.isSearchMode = false;
    }
    
    [self.tableView reloadData];
    
    //select the first item by default.
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex: 0] byExtendingSelection:YES];
}

// play item in this playlist.
-(void)playTrack:(NSInteger)index
{
    NSInteger row = index;
    
    if ( row >= 0)
    {
        PlayerList *list ;
        
        PlayerTrack *track;
        if (self.isSearchMode )
        {
            list = self.searchMng.playerlistFilter ;
            
            track = [self.searchMng getOrginalByIndex:row];
            
            player().playing = track;
            
            [list markSelected];
            
            //[list setSelectIndex:(int)row];
            
            list = self.searchMng.playerlistOriginal;
        }
        else
        {
            list = _playerlList.selectItem;
            track = [list getItem:row];
            [list setSelectIndex:(int)row];
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

- (IBAction)cmdPlayClickedTrack:(id)sender
{
    [self playSelectedTrack];
}

-(void)doubleClicked
{
    //postEvent(EventID_to_play_selected_track, nil);
    
    [player().document.playerQueue clear];
    
    [self playClickedTrack];
}

// play track in or not in selecting playlist.
-(void)playTrackItem:(NSNotification*)n
{
    PlayerTrack * track = n.object;
    
    NSAssert([track isKindOfClass:[PlayerTrack class]], @"");
    
    playTrack(track);
    
    postEvent(EventID_to_reload_tracklist, track);
}

-(PlayerTrack*)getSelectedItem:(NSInteger)row
{
    PlayerTrack *track = self.isSearchMode ? [self.searchMng.playerlistFilter getItem: (int)row ]: [self.playerlList.selectItem  getItem: (int)row];
    return track;
}

#pragma mark - NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if ( self.isSearchMode )
        return   [self.searchMng.playerlistFilter count ];
    else
        return   [self.playerlList.selectItem count];
}


#pragma mark - NSTableViewDelegate

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

    PlayerTrack *track = [self getSelectedItem:row];
    TrackInfo *info = track.info;
    
    if (column == 0) {
        textField.stringValue = [NSString stringWithFormat:@"%ld",row + 1];
        
        textField.editable = false;
    }
    else if(column == 1) {
        textField.stringValue = info.artist;
    }
    else if(column == 2) {
        textField.stringValue = info.title ;
    }
    else if(column == 3) {
        textField.stringValue = info.album;
    }
    else if(column == 4) {
        textField.stringValue = info.genre;
    }
    else if(column == 5) {
        textField.stringValue = info.year;
    }
    
    return textField;
}


#pragma mark - key event

- (void)keyDown:(NSEvent *)theEvent
{
    //printf("key pressed: %s\n", [[theEvent description] UTF8String]);
    
    NSString *keyString = keyStringFormKeyCode(theEvent.keyCode);
    
    // press 'Enter' to start play item.
    if ([keyString isEqualToString:@"RETURN" ]||
        [keyString isEqualToString:@"ENTER" ])
    {
        if ( self.tableView.selectedRow != -1)
        {
            [self playSelectedTrack];
            
            PlayerTrack *track = [self getSelectedItem:self.tableView.selectedRow];
            postEvent(EventID_to_reload_tracklist, track);
        }
    }
    // 'Space' to play/pause item.
    else if ( [keyString isEqualToString:@"SPACE"] )
    {
        [player().engine playPause];
    }
    
    
    
    if (self.isSearchMode )
    {
        if([keyString isEqualToString:@"ESCAPE"])
        {
            self.isSearchMode = false;
            [self.tableView reloadData];
            if (self.tableView.selectedRow != -1)
            {
                PlayerTrack *track = [self getSelectedItem:self.tableView.selectedRow];
                postEvent(EventID_to_reload_tracklist, track);
            }
        }
    }
   
}

#pragma mark - context menu command

-(bool)hasRowSelected
{
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    return rows.count > 0;
}

- (IBAction)cmdShowInFinder:(id)sender
{
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    NSMutableArray *urlArr=[NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        TrackInfo *info = [self getSelectedItem:idx].info;
        [urlArr addObject: [NSURL fileURLWithPath: info.path]];
        
    }];
    
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: urlArr ];
}

- (IBAction)cmdAddToPlayQueue:(id)sender
{
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
     {
         PlayerTrack *track = [self getSelectedItem:idx];
         
         [player().document.playerQueue push:track];
     }];
    
}

-(bool)isPlayQueueNotEmpty
{
    return [player().document.playerQueue count] > 0;
}

- (IBAction)cmdClearPlayQueue:(id)sender {
    [player().document.playerQueue clear];
}

- (IBAction)cmdRemoveRefrence:(id)sender {
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self.playerlList.selectItem removeTrack: idx ];
    }];
    
    [self.tableView reloadData];
}

-(void)removeItemsToTrash:(NSIndexSet*)set
{
    PlayerList *list = self.playerlList.selectItem;
    
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        PlayerTrack *track = [list getItem: idx ];
        [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath: track.info.path] resultingItemURL:nil error:nil];
    }];
    
    [list removeTracks: set ];
    [self.tableView reloadData];
}

- (IBAction)cmdRemoveToTrash:(id)sender {
    
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    NSString *alertSuppressionKey = @"RemoveItemToTrashConfirm";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    if (self.isSearchMode)
    {
        NSMutableIndexSet *rowsOrginal = [NSMutableIndexSet indexSet];
        
        [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSUInteger d = [self.searchMng getOrginalByIndex:idx].index;
            [rowsOrginal addIndex:d];
        }];
        
        rows = rowsOrginal;
    }
    
    if ([defaults boolForKey: alertSuppressionKey])
    {
        [self removeItemsToTrash: rows];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat: NSLocalizedString(@"Remove %d items to Trash", nil ) , rows.count ];
        alert.alertStyle=NSWarningAlertStyle;
        [alert addButtonWithTitle:NSLocalizedString(@"Continue",nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel",nil)];
        alert.showsSuppressionButton = YES; // Uses default checkbox title
        
        if( [alert runModal] == NSAlertFirstButtonReturn)
            [self removeItemsToTrash: rows];
        
        // Suppress this alert from now on
        if (alert.suppressionButton.state == NSOnState)
            [defaults setBool: YES forKey: alertSuppressionKey];
        
    }
    
    if (self.isSearchMode)
    {
        //refresh the search result.
        [self.searchMng research];
        [self.tableView reloadData];
    }
    
}

-(void)startPIAnimation
{
    CGFloat bottomBarHeight = 22.0;
    
    NSRect rc = NSMakeRect(0, 0 + bottomBarHeight, self.view.bounds.size.width, self.view.bounds.size.height  - bottomBarHeight);
 
    _progress = [[NSProgressIndicator alloc]initWithFrame: rc ];
    _progress.style = NSProgressIndicatorSpinningStyle;
    [_progress startAnimation:nil];
    _progress.autoresizingMask =  NSViewWidthSizable | NSViewHeightSizable;
    
    [self.view addSubview:_progress];
}

-(void)stopPIAnimation
{
    [_progress stopAnimation:nil];
    [_progress removeFromSuperview];
}

-(bool)lastFmEnabled
{
    return player().document.lastFmEnabled;
}

- (IBAction)cmdLastFm_Love:(id)sender
{
    PlayerTrack *track = [self getSelectedItem: self.tableView.selectedRow];
 
    
    dojobInBkgnd(^{
        string artist(track.info.artist.UTF8String);
        string title(track.info.title.UTF8String);
        
        LFUser *user = lastFmUser() ;
        track_love(user->sessionKey , artist , title);
    }, ^{
        
    });
    
}


@end
