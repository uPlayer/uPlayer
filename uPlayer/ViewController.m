//
//  ViewController.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "ViewController.h"
#import "UPlayer.h"

#import "PlayerMessage.h"
#import "PlayerSerachMng.h"


@interface ViewController () <NSTableViewDelegate , NSTableViewDataSource >
@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,assign) NSArray *columnNames,*columnWidths;
@property (nonatomic) bool searchMode;
@property (nonatomic,strong) PlayerSearchMng* searchMng;
@property (nonatomic,strong) PlayerlList *playerlList;
@end

@implementation ViewController

-(void)awakeFromNib
{
    addObserverForEvent(self, @selector(reloadTrackList), EventID_to_reload_tracklist);
    
    self.playerlList = player().document.playerlList;
}

-(void)reloadTrackList
{
    /// @todo save top index.
    
    
    [self.tableView reloadData];
    int row = [self.playerlList getSelectedList].selectIndex;
    
    //int rowsPerPage = self.tableView.bounds.size.height / self.tableView.rowHeight;
    
    [self.tableView scrollRowToVisible: row ];
    
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex: row] byExtendingSelection:YES];
}

-(void)viewDidAppear
{
    [super viewDidAppear];
    
    self.view.window.title=player().document.windowName;
    
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
    
    //CGFloat heightHeader = 32;
    
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
        self.searchMode = true;
        if (self.searchMng == nil)
            self.searchMng = [[PlayerSearchMng alloc]init];
        
        self.searchMng.playerlistOriginal = [self.playerlList getSelectedList];
        
        [self.searchMng search:key];
    }
    else
    {
        self.searchMode = false;
        
    }
    
    [self.tableView reloadData];
}

-(void)doubleClicked
{
    //int col = self.tableView.clickedColumn;
    PlayerDocument *document = player().document;
    
    int row = (int) self.tableView.clickedRow;
    
    if ( row >= 0)
    {
        PlayerEngine *eg = player().engine;
        
        PlayerList *list ;
        
        PlayerTrack *track;
        if (self.searchMode )
        {
            list = self.searchMng.playerlistFilter ;
            
            track = [self.searchMng getOrginalByIndex:row];
            [list setSelectIndex:row];
        }
        else
        {
            list = [_playerlList getSelectedList];
            track = [list getItem:row];
            [list setSelectIndex:row];
        }

        
        if ( document.currPlayingiList == _playerlList.selectIndex && document.currPlayingiTrack == track.index)
        {
            [eg playPause:nil];
        }
        else
        {
            playTrack(track.info);
            
            document.currPlayingiTrack = track.index;
            
            document.currPlayingiList = _playerlList.selectIndex;
            
            postEvent(EventID_to_change_player_title, track.info.title);
        }
        
    }
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.searchMode ?[self.searchMng.playerlistFilter count ]: [[self.playerlList getSelectedList] count];
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


    PlayerTrack *track = self.searchMode? [self.searchMng.playerlistFilter getItem: (int)row ]: [[self.playerlList getSelectedList] getItem: (int)row];
    
    TrackInfo *info = track.info;
    
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
    //printf("key pressed: %s\n", [[theEvent description] cString]);
    
    if (theEvent.characters ) {
        
    }
}
@end
