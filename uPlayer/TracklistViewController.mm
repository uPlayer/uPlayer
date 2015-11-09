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

//http://stackoverflow.com/questions/1235219/is-there-a-right-way-to-have-nstextfieldcell-draw-vertically-centered-text
@interface NSTextFieldCell (MyCategories)
@end



@interface NSTableColumnMy : NSTableColumn
@property (nonatomic) int state;
+(int)objectSize;
+(instancetype)tableColumnWithIdentifies:(NSString*)iden title:(NSString*)title state:(bool)state width:(CGFloat)width;
@end



enum default_column_identifier
{
    column_identifier_number,
    column_identifier_cover,
    column_identifier_artist,
    column_identifier_title,
    column_identifier_album,
    column_identifier_genre,
    column_identifier_year,
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


NSImage* resizeImage(NSImage* sourceImage ,NSSize size);





@interface TracklistViewController () <NSTableViewDelegate , NSTableViewDataSource >
@property (nonatomic,strong) NSScrollView *tableContainer;
@property (nonatomic) bool scrolling;
@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,strong) NSMutableArray *tableColumns;
@property (nonatomic,assign) bool isSearchMode;
@property (nonatomic,strong) PlayerSearchMng* searchMng;
@property (nonatomic,strong) PlayerlList *playerlList;

@property (nonatomic,strong) NSProgressIndicator *progress;

@property (nonatomic,strong) NSTextField *bottomTextLeft,*bottomTextRight,*bottomTextCenter;
@property (weak) IBOutlet NSMenu *subMenuSendtoPL;
//@property (nonatomic,strong) nsarr
@property (weak) IBOutlet NSMenuItem *menuItemSendHowMuchItems;
@property (weak) IBOutlet NSMenuItem *menuItemSendToPL;

//need to serialize
@property (nonatomic) int fontsize,rowHeight;

@property (nonatomic) int fontsizeOld,rowHeightDefault;

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
    
    addObserverForEvent( self, @selector(updateBottomBar), EventID_tracks_changed);
    
    addObserverForEvent( self, @selector(updateBottomBar), EventID_list_name_changed);
    
    addObserverForEvent( self, @selector(playlistChanged), EventID_list_changed);
    
    addObserverForEvent( self, @selector(reloadMenu), EventID_player_document_loaded);
    
    addObserverForEvent(self, @selector(onSetFontSize:), EventID_to_set_font_size);
    
    self.playerlList = player().document.playerlList;
    
}

-(void)onSetFontSize:(NSNotification*)n
{
    NSNumber *num = n.object;
    
    self.fontsizeOld = self.fontsize;
    
    if ( num.intValue == -1) {
        //larger
        self.fontsize += 1;
        self.tableView.rowHeight = ++_rowHeight;
        
        [self.tableView reloadData];
        [self.tableView needsLayout];
    }
    else if( num.intValue == -2)
    {
        //smaller
        self.tableView.rowHeight = --_rowHeight;
        self.fontsize -= 1;
        [self.tableView needsLayout];
        [self.tableView reloadData];
    }
    if( num.intValue == 0)
    {
        //normal
        self.tableView.rowHeight = _rowHeight = _rowHeightDefault;
        self.fontsize = [NSFont systemFontSize];
        [self.tableView needsLayout];
        [self.tableView reloadData];
    }
    else
    {
        
    }
    
}


-(void)playlistChanged
{
    [self reloadMenu];
}

-(void)reloadMenu
{
    // reload `send to playlist` popup context menu items
    NSInteger index = [self.subMenuSendtoPL indexOfItemWithTag:12323];
    NSAssert(index != -1, nil);
    
    int i = (int)self.subMenuSendtoPL.numberOfItems -1;
    for (; i > index; i--) {
        [self.subMenuSendtoPL removeItemAtIndex: i];
    }
    
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    bool hasRowSelected = rows.count > 0;
 
    if (hasRowSelected)
    {
        PlayerlList *ll =player().document.playerlList;
        int count = (int)ll.count;
        
        
        for (int i = 0; i < count; i++) {
            PlayerList * list = [ll getItem:i];
            
            NSMenuItem *item = [self.subMenuSendtoPL addItemWithTitle:list.name action:@selector(sendItemsToPlaylist:) keyEquivalent:@""];
            item.tag = i;
            
        }
    }
    
}


/// binded to menu's `enabled`. but we just want to refresh the menu title.
-(BOOL)refreshMenuItemSendHowMuch
{
    self.menuItemSendHowMuchItems.title = [NSString stringWithFormat: NSLocalizedString(@"Send %d items to:", nil) , self.tableView.selectedRowIndexes.count];
    return FALSE;
}

-(void)sendItemsToPlaylist:(NSMenuItem*)item
{
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    
    if (rows.count)
    {
        NSMutableArray *selected = [NSMutableArray array];
        
        [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [selected addObject: [self getSelectedItem:idx].info];
        }];
        
        
        
        int index = (int)item.tag;
        PlayerList * list = [player().document.playerlList getItem: index];
        
        NSArray *added = [list addTrackInfoItems:selected];
        
        postEvent(EventID_to_reload_tracks, added);
 
    }
}



-(NSTableColumnMy*)tableColumnByIdentifier:(NSString*)identifier
{
    for (NSTableColumnMy *column in self.tableColumns) {
        if ([column.identifier isEqualToString:identifier]) {
            return column;
        }
    }
    
    NSAssert(false, nil);
    return nil;
}

-(void)headerMenuClicked:(NSMenuItem*)item
{
    int index =  (int)item.tag;
    
    if (item.state == NSOffState)
    {
        item.state = NSOnState;
        
        NSTableColumnMy *column = [self tableColumnByIdentifier: @(index).stringValue];
        
        int order = 0;
        for (NSTableColumnMy *c in self.tableColumns)
        {
            if (c == column)
                break;
            if (c.state == NSOnState)
            {
                order++;
            }
        }
        
        
        column.state = NSOnState;
        
        [self.tableView beginUpdates];
        [self.tableView addTableColumn: column];
        int count = (int)self.tableView.tableColumns.count;
        [self.tableView moveColumn:count -1 toColumn: order];
        [self.tableView endUpdates];
        
        [self updateColumnThisPage:(int)order];
    }
    else
    {
        item.state = NSOffState;
        
        NSTableColumn *column = [self.tableView tableColumnWithIdentifier:@(item.tag).stringValue];
        NSAssert(column, nil);
        
        int order = (int)[self.tableView.tableColumns indexOfObject:column];
        
        
        int o = 0 ;
        for (NSTableColumnMy *c in self.tableColumns ){
            if (c.state == NSOnState) {
                if (o == order) {
                    c.state = NSOffState;
                    c.width = column.width;
                }
                
                o++;
            }
        }
        
        [self.tableView removeTableColumn: column ];
    }
 
    [self debugPrint];
}



-(void)saveLayout
{
    
    {
        MemoryFileBuffer buffer( [NSTableColumnMy objectSize]  * defaultColumnNumbers);
        
        
        printf("\n");
        for (int j = 0 ; j < defaultColumnNumbers; j++) {
            NSTableColumnMy *c = self.tableColumns[j];
            
            int i = c.identifier.intValue;
            int s = c.state;
            float w = c.width;
            
            buffer.write(i);
            buffer.write(s);
            buffer.write(w);
            
            printf("%s,%d   ",c.title.UTF8String,c.state);
        }
        printf("\n");
        
        NSData *data = dataFromMemoryFileBuffer(&buffer);
        [player().layout saveData:data withKey:self.className];
    }
    
    
    
    
    {
        MemoryFileBuffer buffer( sizeof(int)*2);
        
        buffer.write(_fontsize);
        buffer.write(_rowHeight);
        
        NSData *data = dataFromMemoryFileBuffer(&buffer);
        [player().layout saveData:data withKey: @"tracklistview_font_size" ];
    }
    
}

-(bool)loadLayout
{
    bool column_loaded = false;
    NSData *data = [player().layout getDataByKey:self.className];
    if( data )
    {
        MemoryFileBuffer *buffer = newMemoryFileBufferFromData(data);

        NSMutableArray *arrColumnDatas = [ NSMutableArray array];
        
        for (int j = 0 ; j < defaultColumnNumbers; j++) {
            int identifier;
            int state;
            float width;
            
            buffer->read(identifier);
            buffer->read(state);
            buffer->read(width);
            
            
            NSTableColumnMy *c = [NSTableColumnMy tableColumnWithIdentifies:@(identifier).stringValue title:defaultColumnNames[identifier] state:state width:width];
            [arrColumnDatas addObject:c];
        }
        
        self.tableColumns = arrColumnDatas;
        [self debugPrint];
     
        delete buffer;
        
        column_loaded = true;
    }
    
    
    bool font_size_loaded = false;
    {
        NSData *data = [player().layout getDataByKey: @"tracklistview_font_size"];
        if( data )
        {
            MemoryFileBuffer *buffer = newMemoryFileBufferFromData(data);
            
            int fontsize;
            int rowHeight;
            buffer->read(fontsize);
            buffer->read(rowHeight);
            
            
            _fontsize = fontsize;
            _rowHeight = rowHeight;
            
            delete buffer;
            
            font_size_loaded = true;
        }
    }
    
    return column_loaded && font_size_loaded;
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

    [self updateBottomBar];
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
    
    postEvent(EventID_list_changed, nil);
    

    [self updateBottomBar];
}


-(void)updateBottomBar
{
    PlayerList *list = self.playerlList.selectItem;
    
    _bottomTextRight.stringValue = list.name;
    
    _bottomTextCenter.stringValue = [NSString stringWithFormat: NSLocalizedString(@"%d songs",nil) , list.count ];
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
    [self updateBottomBar];
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
    
    CGFloat bottomBarHeight = 22.0;
    CGFloat bottomBarWidth = self.view.bounds.size.width;
    
    // Create controls in bottom bar.
    
    CGFloat ff = bottomBarHeight;
    const CGFloat margin = 5;
    const CGFloat labelText = 100;
    
    _bottomTextLeft = [[NSTextField alloc] initWithFrame: NSMakeRect(margin, (bottomBarHeight-ff)/2, labelText + margin , ff )];
    _bottomTextLeft.autoresizingMask = NSViewMinXMargin| NSViewWidthSizable| NSViewMaxXMargin;
    _bottomTextLeft.stringValue = @"";
    _bottomTextLeft.editable = false;
    _bottomTextLeft.bordered = false;
    _bottomTextLeft.drawsBackground = false;
    _bottomTextLeft.alignment =  NSLeftTextAlignment;
    
    [self.view addSubview:_bottomTextLeft];
    
    
    _bottomTextCenter = [[NSTextField alloc] initWithFrame: NSMakeRect(labelText+margin, (bottomBarHeight-ff)/2, bottomBarWidth - labelText - labelText - margin - margin , ff )];
    _bottomTextCenter.autoresizingMask = NSViewMinXMargin| NSViewWidthSizable| NSViewMaxXMargin;
    _bottomTextCenter.editable = false;
    _bottomTextCenter.bordered = false;
    _bottomTextCenter.drawsBackground = false;
    _bottomTextCenter.alignment =  NSCenterTextAlignment;
    
    [self.view addSubview: _bottomTextCenter];
    
    
    
    _bottomTextRight = [[NSTextField alloc] initWithFrame: NSMakeRect( bottomBarWidth - margin - labelText, (bottomBarHeight-ff)/2, labelText , ff )];
    _bottomTextRight.autoresizingMask = NSViewMinXMargin| NSViewWidthSizable| NSViewMaxXMargin;
    _bottomTextRight.editable = false;
    _bottomTextRight.bordered = false;
    _bottomTextRight.drawsBackground = false;
    _bottomTextRight.alignment =  NSRightTextAlignment;
    
    [self.view addSubview:_bottomTextRight];
    
    
    
    
    // Create table view.
    NSRect rc = NSMakeRect(0, 0 + bottomBarHeight, self.view.bounds.size.width, self.view.bounds.size.height  - bottomBarHeight);
    
    NSScrollView *tableContainer = [[NSScrollView alloc]initWithFrame:rc];
    tableContainer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidEndScroll:) name:NSScrollViewDidEndLiveScrollNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidLiveScroll:) name:NSScrollViewDidLiveScrollNotification object:nil];
    
    
    self.tableView = [[NSTableView alloc]initWithFrame:tableContainer.bounds];
    self.tableView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.tableView.allowsMultipleSelection = TRUE;
    self.rowHeightDefault = self.tableView.rowHeight;
    
    // Reserialize table columns
    if( [self loadLayout] == FALSE)
    {
        // Then set default value.
        self.fontsize = self.fontsizeOld = [NSFont systemFontSize];
        
        self.rowHeight = self.rowHeightDefault;
        
        self.tableColumns =
        [NSMutableArray arrayWithObjects:
         [NSTableColumnMy tableColumnWithIdentifies:@(column_identifier_number).stringValue title:NSLocalizedString(@"Index", nil) state:NSOnState width: 60.0 ],
         [NSTableColumnMy tableColumnWithIdentifies:@(column_identifier_cover).stringValue title:NSLocalizedString(@"Cover", nil) state:NSOnState width: 60.0 ],
         [NSTableColumnMy tableColumnWithIdentifies:@(column_identifier_artist).stringValue title:NSLocalizedString(@"Artist", nil) state:NSOnState width: 120.0 ],
         [NSTableColumnMy tableColumnWithIdentifies:@(column_identifier_title).stringValue title:NSLocalizedString(@"Title", nil) state:NSOnState width: 320.0 ],
         [NSTableColumnMy tableColumnWithIdentifies:@(column_identifier_album).stringValue title:NSLocalizedString(@"Album", nil) state:NSOnState width: 320.0 ],
         [NSTableColumnMy tableColumnWithIdentifies:@(column_identifier_genre).stringValue title:NSLocalizedString(@"Genre", nil) state:NSOnState width: 60.0 ],
         [NSTableColumnMy tableColumnWithIdentifies:@(column_identifier_year).stringValue title:NSLocalizedString(@"Year", nil) state:NSOnState width: 60.0 ], nil];
    }
    
    
    

    self.tableView.rowHeight = self.rowHeight;
    
    
    
    // Load table header menu state.
    int arr_index_to_order[defaultColumnNumbers];
    for( int order = 0; order < defaultColumnNumbers; order++)
    {
        NSTableColumnMy *c = self.tableColumns[order];
        
        arr_index_to_order[c.identifier.intValue] = order;
    }
    
    
    
    NSMenu *menu = [[NSMenu alloc] init];
    int index = 0;
    for (NSString *columnName in defaultColumnNames)
    {
        NSTableColumnMy *c = self.tableColumns[ arr_index_to_order[ index] ];
        
        NSMenuItem *item;
        item = [[NSMenuItem alloc]initWithTitle:columnName action:@selector(headerMenuClicked:) keyEquivalent:@""];
        item.tag = index;
        item.state = c.state;
        [menu addItem:item];
        
        index++;
    }
    self.tableView.headerView.menu = menu;
    
    
    for (int i = 0; i < defaultColumnNumbers; i++)
    {
        NSTableColumnMy *column = self.tableColumns[i];
        
        if (column.state == NSOnState)
            [self.tableView addTableColumn: column];
    }
    
    
    // others.
    self.tableView.doubleAction=@selector(doubleClicked);
    self.tableView.usesAlternatingRowBackgroundColors = true;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    tableContainer.documentView = self.tableView;
    tableContainer.hasVerticalScroller = true;
    [self.view addSubview:tableContainer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewColumnDidMove:) name:NSTableViewColumnDidMoveNotification object:nil];
    
    
    [self.tableView reloadData];
}



-(void)tableViewColumnDidMove:(NSNotification*)n
{
    NSNumber *_old = n.userInfo[@"NSOldColumn"];
    NSNumber *_new = n.userInfo[@"NSNewColumn"];
    
    static bool bFirst = true;
    
    if (bFirst) {
        bFirst = false;
        
        int i = 0;
        int j = 0;
        for(NSTableColumnMy *c in self.tableColumns){
            if (c.state == NSOnState) {
                if (i == _old.intValue) {
                    break;
                }
                i++;
            }
            j++;
        }
        
        int old = j;
        
        i = 0;
        j = 0;
        for(NSTableColumnMy *c in self.tableColumns){
            if (c.state == NSOnState) {
                if (i == _new.intValue) {
                    break;
                }
                i++;
            }
            j++;
        }
        
        int neww = j;
        
        NSTableColumnMy * c = self.tableColumns[old];
        NSTableColumnMy * d = self.tableColumns[neww];
        NSLog(@"%@ -> %@", c.title , d.title );
        
        NSTableColumnMy *t = self.tableColumns[old];
        [self.tableColumns removeObject:t];
        [self.tableColumns insertObject:t atIndex:neww];
    }
    else
        bFirst = true;
    
    NSLog(@"tableViewColumnDidMove %@ -> %@",_old,_new);
    [self debugPrint];
}

-(void)debugPrint
{
#ifdef DEBUG
    printf("\n");
    
    for (NSTableColumnMy *c in self.tableColumns) {
        printf("%s,%s.  ",c.title.UTF8String,c.state?"1":"0" );
        
    }
    
    printf("\n");
#endif
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
    
    static NSString *identifier = @"t_itf";
    if (self.fontsize != self.fontsizeOld) {
        // font has changed
        self.fontsizeOld = self.fontsize;
        
        identifier = @(self.fontsize).stringValue;
    }
    
    NSTextField *textField = (NSTextField *)[self.tableView makeViewWithIdentifier:identifier owner:self];
    
    if (textField == nil)
    {
        textField = [[NSTextField alloc]initWithFrame:NSMakeRect(0, 0, tableColumn.width, 0)];
        textField.autoresizingMask = ~0 ;
        textField.bordered = false ;
        textField.drawsBackground = false ;
        textField.font = [NSFont systemFontOfSize:self.fontsize];
        textField.editable = false ;
        textField.identifier=identifier;
    }

    PlayerTrack *track = [self getSelectedItem:row];
    TrackInfo *info = track.info;
    
    if (column == column_identifier_cover)
    {
        NSImageView *imageV = [[NSImageView alloc]initWithFrame: NSMakeRect(0, 0, tableColumn.width, 0)];
        
        if(!info.imageSmall)
        {
            if (!self.scrolling) {
                
                int top = [self getRowOnTableTop];
                int rowsPerPage = self.tableView.visibleRect.size.height/ self.tableView.rowHeight;
                
                if (top <= row && row <= top + rowsPerPage) {
                    
                    
                    __weak typeof (imageV) weakImageV = imageV;
                    dojobInBkgnd(^{
                        
                        NSImage * image =  [[NSImage alloc]initWithData: getId3ImageFromAudio([NSURL fileURLWithPath: info.path])];
                        info.imageSmall = resizeImage( image, NSMakeSize(tableColumn.width, tableColumn.width));
                        
                    }, ^{
                        
                        if (weakImageV) {
                            weakImageV.image = info.imageSmall;
                            [weakImageV setNeedsDisplay];
                        }
                        
                    });
                }
            }

        }
        else
            imageV.image = info.imageSmall;
        
        return imageV;
    }
    else if (column == column_identifier_number)
    {
        textField.stringValue = [NSString stringWithFormat:@"%ld",row + 1];
        
        textField.editable = false;
    }
    else if(column == column_identifier_artist) {
        textField.stringValue = info.artist;
    }
    else if(column == column_identifier_title) {
        textField.stringValue = info.title ;
    }
    else if(column == column_identifier_album) {
        textField.stringValue = info.album;
    }
    else if(column == column_identifier_genre) {
        textField.stringValue = info.genre;
    }
    else if(column == column_identifier_year) {
        textField.stringValue = info.year;
    }
    
    return textField;
}

#pragma mark -  scrolling

-(void)scrollViewDidLiveScroll:(NSNotification*)n
{
    NSScrollView *v = n.object;
    if (v == self.tableContainer) {
        self.scrolling = true;
    }
}

-(void)scrollViewDidEndScroll:(NSNotification*)n
{
    NSScrollView *v = n.object;
    if (v == self.tableContainer) {
        self.scrolling = false;
    }
    
}

#pragma mark - Sort

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    NSInteger column = tableColumn.identifier.intValue;
    
    if ( column != column_identifier_number && column_identifier_cover != column)
    {
        NSImage *indicatorImage;
        
        NSString *key;
        
        if (column == column_identifier_artist)
            key = @"info.artist";
        else if( column == column_identifier_album)
            key = @"info.album";
        else if( column == column_identifier_title)
            key = @"info.title";
        else if( column == column_identifier_genre)
            key = @"info.genre";
        else if( column == column_identifier_year)
            key = @"info.year";
        
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending: columnAscending[column]];
        
        NSArray *sortDescriptors = @[descriptor];
        
        PlayerList *list = self.playerlList.selectItem;
                            
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
    
    
    
    
    if([keyString isEqualToString:@"ESCAPE"])
    {
        if (self.isSearchMode )
        {
            PlayerTrack *track = nil;
            
            if (self.tableView.selectedRow != -1)
                track = [self getSelectedItem:self.tableView.selectedRow];
            
            self.isSearchMode = false;
            postEvent(EventID_to_reload_tracklist, track);
        }
        // 'Esc' to view the album detail
        else
        {
            [self.w switchViewMode];
            
        }
    }
   
}

#pragma mark - mouse down

-(void)mouseDown:(NSEvent *)theEvent
{
    if( theEvent.type == NSLeftMouseDown)
    {
        // Active the current song if double clicked on the bottom bar.
        if (theEvent.clickCount == 2)
        {
            NSWindow *w = self.view.window;
            
            NSRect rc = NSMakeRect(0, 0, w.frame.size.width, [w contentBorderThicknessForEdge: NSMinYEdge] );
            
            if ( NSPointInRect( theEvent.locationInWindow, rc )) {
                postEvent(EventID_to_reload_tracklist, player().playing );
            }
            
        }
        // click right bottom bar to switch playlist
        else if ( theEvent.clickCount == 1)
        {
            if (NSPointInRect( [theEvent locationInWindow] , _bottomTextRight.frame ) )
            {
                PlayerlList *ll =player().document.playerlList;
                int count = (int)ll.count;
                
                NSMenu *menu = [[NSMenu alloc]init];
                
                for (int i = 0; i < count; i++) {
                    PlayerList * list = [ll getItem:i];
                   
                    NSMenuItem *item = [menu addItemWithTitle:list.name action:@selector(switchPlaylist:) keyEquivalent:@""];
                    
                    item.tag = i;
                    if (list == ll.selectItem) {
                        item.state  =  NSOnState;
                    } 
                }
                
                
                [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self.view];
            }
        }
    }
    
}

-(void)switchPlaylist:(NSMenuItem*)item
{
    PlayerList * list = [player().document.playerlList getItem:(int)item.tag];
    postEvent(EventID_to_reload_playlist, list);
}

#pragma mark - context menu command

-(bool)hasRowSelected
{
    [self reloadMenu];
    
    NSIndexSet *rows = self.tableView.selectedRowIndexes;
    bool hasRowSelected = rows.count > 0;
    
    return hasRowSelected;
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
    [self.playerlList.selectItem removeTracks:rows];
    
    [self.tableView removeRowsAtIndexes:rows withAnimation:YES];
    
    [self updateColumnThisPage: [self index2order: column_identifier_number ]];
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
   
    [self updateColumnThisPage: [self index2order: column_identifier_number ]];
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

- (IBAction)cmdSendToANewPlaylist:(id)sender
{
    NSAlert *alert = [[NSAlert alloc]init];
    
    NSTextField *textfield = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 240, 25)];
    textfield.placeholderString = NSLocalizedString(@"default playlist name",nil);
    alert.messageText = @"Please enter the playlist name";
    alert.accessoryView = textfield;
    alert.alertStyle = NSInformationalAlertStyle;
    [alert addButtonWithTitle:@"ok"];
    [alert addButtonWithTitle:@"cancel"];
    [alert layout];
    
    //textfield.frame = NSMakeRect(0, 0, textfield.superview.superview.bounds.size.width - 20, 30) ;
    
    if([alert runModal] == NSAlertFirstButtonReturn && textfield.stringValue.length > 0)
    {
        NSLog(@"%@",textfield.stringValue);
        NSString *playlistName = textfield.stringValue;
        
        NSIndexSet *rows = self.tableView.selectedRowIndexes;
        
        if (self.isSearchMode)
        {
            NSMutableIndexSet *rowsOrginal = [NSMutableIndexSet indexSet];
            
            [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSUInteger d = [self.searchMng getOrginalByIndex:idx].index;
                [rowsOrginal addIndex:d];
            }];
            
            rows = rowsOrginal;
        }
        
        NSArray *copied = [self.playerlList.selectItem trackAtSets:rows];
        
        PlayerList *newlist = [self.playerlList newPlayerList];
        newlist.name = playlistName;
        postEvent(EventID_to_reload_tracklist, newlist );
        
        [newlist addItems:copied];
        
        postEvent(EventID_to_reload_tracks, copied);
    }
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




#pragma mark - NSDraggingDestination
@implementation NSTracklistView

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
                     
                     if(added.count>0)
                         postEvent(EventID_to_reload_tracks, added);
                 });
    
}




@end

@implementation NSTextFieldCell (MyCategories)

-(void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSAttributedString *attrString = self.attributedStringValue;
    
    /* if your values can be attributed strings, make them white when selected */
    if (self.isHighlighted && self.backgroundStyle==NSBackgroundStyleDark) {
        NSMutableAttributedString *whiteString = attrString.mutableCopy;
        [whiteString addAttribute: NSForegroundColorAttributeName
                            value: [NSColor whiteColor]
                            range: NSMakeRange(0, whiteString.length) ];
        attrString = whiteString;
    }
    
    [attrString drawWithRect: [self titleRectForBounds:cellFrame]
                     options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin];
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    /* get the standard text content rectangle */
    NSRect titleFrame = [super titleRectForBounds:theRect];
    
    /* find out how big the rendered text will be */
    NSAttributedString *attrString = self.attributedStringValue;
    NSRect textRect = [attrString boundingRectWithSize: titleFrame.size
                                               options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin ];
    
    /* If the height of the rendered text is less then the available height,
     * we modify the titleRect to center the text vertically */
    if (textRect.size.height < titleFrame.size.height) {
        titleFrame.origin.y = theRect.origin.y + (theRect.size.height - textRect.size.height) / 2.0;
        titleFrame.size.height = textRect.size.height;
    }
    return titleFrame;
}

@end


@implementation NSTableColumnMy
+(int)objectSize
{
    return 5*sizeof(void*)+sizeof(int)*3+sizeof(float)*3;
}

+(instancetype)tableColumnWithIdentifies:(NSString*)iden title:(NSString*)title state:(bool)state width:(CGFloat)width
{
    NSTableColumnMy *t = [[NSTableColumnMy alloc]initWithIdentifier:iden];
    t.title = title;
    t.state = state;
    t.width = width;
    
    return t;
}

@end

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
