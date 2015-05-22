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

#import "PlayerLastFm.h"
#import "PlayerLayout+MemoryFileBuffer.h"

#import "id3Info.h"
#import "ThreadJob.h"


@interface columnData : NSObject
@property (nonatomic,strong) NSString *title;
@property (nonatomic) int identifies,order,state,ascending;
@property (nonatomic) float width;

+(instancetype)columnDataWith:(NSString*)title identifies:(int)identifies order:(int)order state:(int)state ascending:(int)ascending width:(float)width;

+(int)objectSize;
@end


@implementation columnData
+(int)objectSize
{
    return sizeof(NSString*)+sizeof(int)*4+sizeof(float);
}

+(instancetype)columnDataWith:(NSString*)title identifies:(int)identifies order:(int)order state:(int)state ascending:(int)ascending width:(float)width
{
    columnData *c = [[columnData alloc]init];
    c.title = title;
    c.identifies = identifies;
    c.order = order;
    c.state = state;
    c.ascending = ascending;
    c.width = width;
    return c;
}
@end



enum defaultColumnIden
{
    columnIden_number,
    columnIden_cover,
    columnIden_artist,
    columnIden_title,
    columnIden_album,
    columnIden_genre,
    columnIden_year,
};

const int defaultColumnNumbers = 7;

bool columnAscending[defaultColumnNumbers];

#define defaultColumnNames  @[\
NSLocalizedString(@"Index", nil),\
NSLocalizedString(@"Cover", nil),\
NSLocalizedString(@"Artist", nil),\
NSLocalizedString(@"Title", nil),\
NSLocalizedString(@"Album", nil),\
NSLocalizedString(@"Genre", nil),\
NSLocalizedString(@"Year", nil)\
]



NSImage* resizeImage(NSImage* sourceImage ,NSSize size)
{
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage* targetImage = nil;
    NSImageRep *sourceImageRep =
    [sourceImage bestRepresentationForRect:targetFrame
                                   context:nil
                                     hints:nil];
    
    targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];
    
    return targetImage;
}



@interface TracklistViewController () <NSTableViewDelegate , NSTableViewDataSource >
@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,strong) NSArray *columnDatas;
@property (nonatomic,assign) bool isSearchMode;
@property (nonatomic,strong) PlayerSearchMng* searchMng;
@property (nonatomic,strong) PlayerlList *playerlList;

@property (nonatomic,strong) NSProgressIndicator *progress;
-(void)fileDraggedIn:(NSArray*)arrStringFileNames;
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
    // dealloc is not expect when application is running.
}

-(void)initLoad
{
    addObserverForEvent(self, @selector(reloadTrackList:), EventID_to_reload_tracklist);
    
    /// @param: PlayerList *list.
    addObserverForEvent(self, @selector(reloadPlaylist:), EventID_to_reload_playlist);
    
    /// @param: array of PlayerTrack.
    addObserverForEvent(self, @selector(reloadTracks:), EventID_to_reload_tracks);
    
    /// Reload the playing item.
    addObserverForEvent(self, @selector(reloadPlayingTrack), EventID_to_reload_playing_track);
    
    addObserverForEvent(self, @selector(playSelectedTrack), EventID_to_play_selected_track);
    
    addObserverForEvent(self, @selector(playTrackItem:), EventID_to_play_item);

    addObserverForEvent(self, @selector(startPIAnimation), EventID_importing_tracks_begin);
    
    addObserverForEvent(self, @selector(stopPIAnimation), EventID_importing_tracks_end);
    
    addObserverForEvent(self, @selector(saveLayout), EventID_applicationWillTerminate);
    
    self.playerlList = player().document.playerlList;
    
}

-(void)headerMenuClicked:(NSMenuItem*)item
{
    int index =  (int)item.tag;
    columnData *data = self.columnDatas[index];
    
    if (item.state == NSOffState)
    {
        item.state = NSOnState;
        data.state = NSOnState;
        
        NSTableColumn *tableColumn = [[NSTableColumn alloc]initWithIdentifier:@(item.tag).stringValue];
        
        
        tableColumn.title = data.title;
        
        [self.tableView beginUpdates];
        [self.tableView addTableColumn: tableColumn];
        int cc = (int)self.tableView.tableColumns.count;
        
        [self.tableView moveColumn:cc-1 toColumn:data.order];
        
        [self.tableView endUpdates];
        [self updateColumnThisPage:data.order];
        
        NSAssert( 0 <= data.order && data.order < defaultColumnNumbers, nil);
    }
    else
    {
        item.state = NSOffState;
        data.state = NSOffState;
        
        NSTableColumn *column = [self.tableView tableColumnWithIdentifier:@(item.tag).stringValue];
        NSAssert(column, nil);
        
        int order = (int)[self.tableView.tableColumns indexOfObject:column];
        
        NSAssert( 0 <= order && order < defaultColumnNumbers, nil);
        
        data.width = column.width;
        data.order = order;
        
        [self.tableView removeTableColumn: column ];
    }

}


-(void)saveLayout
{
    MemoryFileBuffer buffer( [columnData objectSize]  * defaultColumnNumbers);
    
    for (int j = 0 ; j < defaultColumnNumbers; j++) {
        columnData *data = self.columnDatas[j];
        int i = data.identifies,s=data.state,a=data.ascending;
        float w=data.width;
        
        int o = (int)[self.tableView columnWithIdentifier:@(j).stringValue];
        if (o == -1) {
            o = data.order;
        }
        
        NSAssert( 0 <= o && o < defaultColumnNumbers, nil);
        
        buffer.write(i);
        buffer.write(o);
        buffer.write(s);
        buffer.write(a);
        buffer.write(w);

    }

    
    NSData *data = dataFromMemoryFileBuffer(&buffer);
    [player().layout saveData:data withKey:self.className];
}

-(bool)loadLayout
{
    NSData *data = [player().layout getDataByKey:self.className];
    if(data )
    {
        MemoryFileBuffer *buffer = newMemoryFileBufferFromData(data);

        NSMutableArray *arrColumnDatas = [ NSMutableArray array];
        
        for (int j = 0 ; j < defaultColumnNumbers; j++) {
            int i,o,s,a;
            float w;
            
            buffer->read(i);
            buffer->read(o);
            buffer->read(s);
            buffer->read(a);
            buffer->read(w);
            
            
            columnData *c = [columnData columnDataWith:defaultColumnNames[j] identifies:i order:o state:s ascending:a width:w];
            [arrColumnDatas addObject:c];
        }
        
        self.columnDatas = arrColumnDatas;
        
        return true;
    }
    
    return false;
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

-(void)reloadPlaylist:(NSNotification*)n
{
    MAAssert(n.object);
    MAAssert([n.object isKindOfClass:[PlayerList class]]);
    
    
    [self.view.window makeFirstResponder:self.tableView];
    
    // quit search mode.
    if(self.isSearchMode)
        self.isSearchMode = false;
    
    PlayerList *listOld = self.playerlList.selectItem;
    PlayerList *list = n.object;
    
    int target = 0;
    // scroll target index to center or top?
    bool toCenter = YES;
    
    // current is not showing. reload it.
    if (list != self.playerlList.selectItem)
    {
        [self.playerlList setSelectItem:list];
        
        target = list.topIndex;
        toCenter = false;
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



-(void)reloadTracks:(NSNotification*)n
{
    NSArray *arrTracks = n.object;
    MAAssert([arrTracks isKindOfClass:[NSArray class]]);
    
    PlayerTrack *track = arrTracks.firstObject;
    MAAssert([track isKindOfClass:[PlayerTrack class]]);
    
    
    [self.view.window makeFirstResponder:self.tableView];
    
    // quit search mode.
    if(self.isSearchMode)
        self.isSearchMode = false;
    
    
    
    PlayerList *listOld = self.playerlList.selectItem;

    PlayerList *list = track.list;
    
    int target = (int)track.index;
    
    /// Scroll target index to center or top?
    bool toCenter = YES;
    
    if (list != self.playerlList.selectItem)
    {
        [self.playerlList setSelectItem:list];
        [self.tableView reloadData];
    }
    
    
    // Current is not showing. reload it.
    if (list != self.playerlList.selectItem)
    {
        [self.playerlList setSelectItem:list];
        
        target = list.topIndex;
        toCenter = false;
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
    
    
    NSMutableIndexSet *sets = [NSMutableIndexSet indexSet];
    for (PlayerTrack *track2 in arrTracks) {
        [sets addIndex:[track2 getIndex]];
    }
    
    [self.tableView selectRowIndexes:sets byExtendingSelection:YES];
}

-(void)reloadPlayingTrack
{
    [self.view.window makeFirstResponder:self.tableView];
    
    // quit search mode.
    if(self.isSearchMode)
        self.isSearchMode = false;
    
    PlayerList *listOld = self.playerlList.selectItem;
    PlayerList *list = player().playing.list;
    
    int target = (int)player().playing.index;
    // scroll target index to center or top?
    bool toCenter = YES;
    
    // current is not showing. reload it.
    if (list != self.playerlList.selectItem)
    {
        [self.playerlList setSelectItem:list];
        
        target = list.topIndex;
        toCenter = false;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert(self.playerlList, @"method: `InitLoad` not actived.");
 

    [self.view registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    
    
    // Create table view.
    CGFloat bottomBarHeight = 22.0;
    
    NSRect rc = NSMakeRect(0, 0 + bottomBarHeight, self.view.bounds.size.width, self.view.bounds.size.height  - bottomBarHeight);
    
    NSScrollView *tableContainer = [[NSScrollView alloc]initWithFrame:rc];
    tableContainer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.tableView = [[NSTableView alloc]initWithFrame:tableContainer.bounds];
    self.tableView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;;
    self.tableView.rowHeight = 40.;
    self.tableView.allowsMultipleSelection = TRUE;
    

    // Reserialize table columns
    if( [self loadLayout] == FALSE)
    {
        // Then set default value.
        self.columnDatas =
        [NSArray arrayWithObjects:
         [columnData columnDataWith: NSLocalizedString(@"Index", nil) identifies:columnIden_number  order:0 state:NSOnState ascending:0 width:60.] ,
         [columnData columnDataWith: NSLocalizedString(@"Cover", nil) identifies:columnIden_cover order:1 state:NSOnState ascending:0 width:60.] ,
         [columnData columnDataWith:NSLocalizedString(@"Artist", nil) identifies:columnIden_artist order:2 state:NSOnState ascending:0 width:120.] ,
         [columnData columnDataWith:NSLocalizedString(@"Title", nil) identifies:columnIden_title order:3 state:NSOnState ascending:0 width:320.] ,
         [columnData columnDataWith:NSLocalizedString(@"Album", nil) identifies:columnIden_album order:4 state:NSOnState ascending:0 width:320.] ,
         [columnData columnDataWith:NSLocalizedString(@"Genre", nil) identifies:columnIden_genre order:5 state:NSOnState ascending:0 width:60.] ,
         [columnData columnDataWith:NSLocalizedString(@"Year", nil) identifies:columnIden_year order:6 state:NSOnState ascending:0 width:60.] ,
         nil];
    }
    
    
    // Load table header menu state.
    NSMenu *menu = [[NSMenu alloc] init];
    int j = 0;
    for (NSString *columnName in defaultColumnNames)
    {
        columnData *c = self.columnDatas[j];
        
        NSMenuItem *item;
        item = [[NSMenuItem alloc]initWithTitle:columnName action:@selector(headerMenuClicked:) keyEquivalent:@""];
        item.tag = j;
        item.state = c.state;
        [menu addItem:item];
        
        j++;
    }
    self.tableView.headerView.menu = menu;
    
    
    // Table columns by order not index.
    int arrOrder2Index[defaultColumnNumbers];
    for (int i = 0; i < defaultColumnNumbers; i++) {
        columnData *data = self.columnDatas[i];
        int order = data.order;
        
        arrOrder2Index[order] = i;
    }
    
    
    for (int order = 0; order < defaultColumnNumbers; order++)
    {
        int index = arrOrder2Index[order];
        
        NSAssert( 0 <= index && index < defaultColumnNumbers, nil);
        
        columnData *data = self.columnDatas[index];
        if (data.state == NSOnState) {
            // Use the identify as the origin index.
            NSTableColumn *cn = [[NSTableColumn alloc]initWithIdentifier: @(data.identifies).stringValue ];
            cn.title = data.title;
            cn.width = data.width;
            [self.tableView addTableColumn:cn];
        }
    }
    
    
    // others.
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
    NSInteger column = tableColumn.identifier.intValue;
    
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
    
    if (column == columnIden_cover)
    {
        NSImageView *imageV = [[NSImageView alloc]initWithFrame: NSMakeRect(0, 0, tableColumn.width, 0)];
        
        if(!info.imageSmall)
        {
            NSImage * image =  [[NSImage alloc]initWithData: getId3ImageFromAudio([NSURL fileURLWithPath: info.path])];
            info.imageSmall = resizeImage( image, NSMakeSize(tableColumn.width, tableColumn.width));
        }
        
        imageV.image = info.imageSmall;
        
        return imageV;
    }
    else if (column == columnIden_number)
    {
        textField.stringValue = [NSString stringWithFormat:@"%ld",row + 1];
        
        textField.editable = false;
    }
    else if(column == columnIden_artist) {
        textField.stringValue = info.artist;
    }
    else if(column == columnIden_title) {
        textField.stringValue = info.title ;
    }
    else if(column == columnIden_album) {
        textField.stringValue = info.album;
    }
    else if(column == columnIden_genre) {
        textField.stringValue = info.genre;
    }
    else if(column == columnIden_year) {
        textField.stringValue = info.year;
    }
    
    return textField;
}

#pragma mark - Sort

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    NSInteger column = tableColumn.identifier.intValue;
    
    if ( column != columnIden_number && columnIden_cover != column)
    {
        NSImage *indicatorImage;
        
        NSString *key;
        
        if (column == columnIden_artist)
            key = @"info.artist";
        else if( column == columnIden_album)
            key = @"info.album";
        else if( column == columnIden_title)
            key = @"info.title";
        else if( column == columnIden_genre)
            key = @"info.genre";
        else if( column == columnIden_year)
            key = @"info.year";
        
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending: columnAscending[column]];
        
        NSArray *sortDescriptors = @[descriptor];
        
        PlayerList *list = [self.playerlList getItem:self.playerlList.selectIndex];
        
        NSArray *sortedArray = [list.playerTrackList sortedArrayUsingDescriptors:sortDescriptors];
        
        list.playerTrackList = [NSMutableArray arrayWithArray: sortedArray];
        
        //sort your data ascending
        indicatorImage = [NSImage imageNamed: columnAscending[column] ? @"NSAscendingSortIndicator":@"NSDescendingSortIndicator" ];
        
        columnAscending[column] = !columnAscending[column];
        
        [tableView setIndicatorImage: indicatorImage
                       inTableColumn: tableColumn];
        
        [tableView reloadData];
    }
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
            PlayerTrack *track = nil;
            
            if (self.tableView.selectedRow != -1)
                track = [self getSelectedItem:self.tableView.selectedRow];
            
            self.isSearchMode = false;
            postEvent(EventID_to_reload_tracklist, track);
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
    
    [self.tableView removeRowsAtIndexes:rows withAnimation:YES];
    
    [self updateColumnThisPage: [self index2order: columnIden_number ]];
}

-(int)index2order:(int)index
{
    return  (int)[self.tableView columnWithIdentifier: @(index).stringValue];
}

-(void)removeItemsToTrash:(NSIndexSet*)set
{
    PlayerList *list = self.playerlList.selectItem;
    
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        PlayerTrack *track = [list getItem: idx ];
        [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath: track.info.path] resultingItemURL:nil error:nil];
    }];
    
    [list removeTracks: set ];
    
    [self.tableView removeRowsAtIndexes:set withAnimation:YES];
   
    [self updateColumnThisPage: [self index2order: columnIden_number ]];
}

-(void)updateColumnThisPage:(int)columnOrder
{
    NSRange r =  [self.tableView rowsInRect:self.tableView.visibleRect];
    
    NSIndexSet *rows = [NSIndexSet indexSetWithIndexesInRange: r];
    
    [self.tableView reloadDataForRowIndexes:rows columnIndexes:[NSIndexSet indexSetWithIndex: columnOrder ]];
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

-(bool)rowSelectedLastFmEnabled
{
    return [self hasRowSelected] && [self lastFmEnabled];
}

-(bool)lastFmEnabled
{
    return player().document.lastFmEnabled;
}

- (IBAction)cmdLastFm_Love:(id)sender
{
    PlayerTrack *track = [self getSelectedItem: self.tableView.selectedRow];
    
    lastFm_loveTrack(track);
}

- (void) copy:(id)sender {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    
    [pasteBoard clearContents];
    
    NSMutableArray *copiedObjects = [NSMutableArray array];
    
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        TrackInfo *info = [self getSelectedItem:idx].info;
        [copiedObjects addObject:info];
    }];
    
    [pasteBoard writeObjects:copiedObjects];
}

- (void)paste:sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

    NSArray *classArray = [NSArray arrayWithObjects:[TrackInfo class],[NSURL class],nil];
    
    NSDictionary *options = [NSDictionary dictionary];
    

    BOOL ok = [pasteboard canReadObjectForClasses:classArray options:options];
    
    if (ok) {
        
        NSArray *objectsToPaste = [pasteboard readObjectsForClasses:classArray options:options];
        
        NSLog(@"objectsToPaste: %@",objectsToPaste);
        
        NSArray *added = [self.playerlList.selectItem addTrackInfoItems: objectsToPaste];
        
        postEvent(EventID_to_reload_tracks, added);
    }
    
}



@end





@implementation NSTracklistView

#pragma mark - NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
        
        if (sourceDragMask & NSDragOperationLink) {
            NSLog(@"link files: %@",files);
            [self fileDraggedIn:files];
        }
    }
    
    return YES;
}


-(void)fileDraggedIn:(NSArray*)arrStringFileNames
{
    PlayerList *list = player().document.playerlList.selectItem;
    
    NSMutableArray *array = [NSMutableArray array];
    __block NSArray *added;
    
    dojobInBkgnd(
                 ^{
                     postEvent(EventID_importing_tracks_begin, nil);
                     
                     for (NSString *file in arrStringFileNames) {
                         BOOL isDirectory;
                         [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory];
                         
                         if(isDirectory)
                         {
                             [array addObjectsFromArray: enumAudioFiles(file)];
                         }
                         else
                         {
                             TrackInfo *arti = getId3Info(file);
                             if (arti) {
                                 arti.path = file;
                                 [array addObject:arti];
                             }
                         }
                     }
                     
                     added = [list addTrackInfoItems: array ];
                 } ,
                 ^{
                     postEvent(EventID_importing_tracks_end, nil);
                     postEvent(EventID_to_reload_tracks, added);
                 });
    
}

@end