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



@interface ViewController () <NSTableViewDelegate , NSTableViewDataSource >
@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,assign) NSArray *columnNames,*columnWidths;
@property (nonatomic,strong) NSArray *trackInfoFiltered; // TrackInfo
@property (nonatomic) bool searchMode;
@end

@implementation ViewController


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
    
    
    NSLog(@"names: %@",self.columnNames);
    
    for (int i = 0; i < self.columnNames.count; i++)
    {
        NSTableColumn *cn = [[NSTableColumn alloc]initWithIdentifier: @"idn"];
        cn.title = (NSString*) self.columnNames[i];
        cn.width =((NSNumber*)self.columnWidths[i]).intValue;
        
        [self.tableView addTableColumn:cn];
    }
    
    
    self.tableView.doubleAction=@selector(doubleClicked);
    
    NSString *path = @"/Users/liaogang/Music";
    PlayerDocument *document = player().document;
    document.trackInfoList = enumAudioFiles(path);
    
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
        
        //search title first.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",key,key,key];
        
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF.artist contains[c] %@ ||SELF.album contains[c] %@",key,key,key];
        
        self.trackInfoFiltered = [player().document.trackInfoList filteredArrayUsingPredicate:predicate];
        
        self.trackInfoFiltered = [self.trackInfoFiltered arrayByAddingObjectsFromArray: [player().document.trackInfoList filteredArrayUsingPredicate:predicate2]];
        
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
    
    document.trackIndex = (int) self.tableView.clickedRow;
    
    if ( document.trackIndex >= 0)
    {
        TrackInfo *info = self.searchMode ? self.trackInfoFiltered[document.trackIndex] : player().document.trackInfoList[document.trackIndex];
        
        PlayerEngine *eg = player().engine;
        
        if ([eg isPlaying] || [eg isPaused])
        {
            [eg playPause:nil];
        }
        else if ([eg isStopped])
        {
            [eg playURL: [NSURL fileURLWithPath:info.path ]];
            postEvent(EventID_to_change_player_title, info.title);
        }
        
        
    }
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.searchMode ?self.trackInfoFiltered.count : player().document.trackInfoList.count;
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


    TrackInfo *info = self.searchMode? self.trackInfoFiltered[row]: player().document.trackInfoList[row];
    
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
    printf("key pressed: %s\n", [[theEvent description] cString]);
    
    if (theEvent.characters ) {
        
    }
}
@end
