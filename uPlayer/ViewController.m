//
//  ViewController.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "ViewController.h"
#import "UPlayer.h"




@interface ViewController () <NSTableViewDelegate , NSTableViewDataSource >
@property (nonatomic,strong) NSTableView *tableView;
@property (nonatomic,assign) NSArray *columnNames,*columnWidths;
@property (nonatomic,strong) NSArray *trackInfo,*trackInfoFiltered; // TrackInfo

@property (nonatomic,strong) PlayerCore *core;

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
    
    NSMenu *menu;
    menu.delegate;
    
    NSSearchField *search;
    
    search.delegate;
    
    NSScrollView *tableContainer = [[NSScrollView alloc]initWithFrame:self.view.bounds];
    tableContainer.autoresizingMask = ~0;
    
    self.tableView = [[NSTableView alloc]initWithFrame:tableContainer.bounds];
    self.tableView.autoresizingMask = ~0;
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
    
    const NSString *path = @"/Users/liaogang/Music";
    
    self.trackInfo= enumAudioFiles(path);
    
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
        
        self.trackInfoFiltered = [self.trackInfo filteredArrayUsingPredicate:predicate];
        
        self.trackInfoFiltered = [self.trackInfoFiltered arrayByAddingObjectsFromArray: [self.trackInfo filteredArrayUsingPredicate:predicate2]];
        
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
    int row = (int)self.tableView.clickedRow;
    if ( row >= 0)
    {
        TrackInfo *info = self.searchMode ?self.trackInfoFiltered[row] : self.trackInfo[row];
        
        if (self.core)
        {
            if ([self.core isPlaying] || [self.core isPaused])
            {
                [self.core playPause:nil];
            }
            else if ([self.core isStopped])
            {
                
                [self.core playURL: [NSURL fileURLWithPath:info.path ]];
            }
        }
        else
        {
            self.core = [[PlayerCore alloc]init];
            [self.core playURL: [NSURL fileURLWithPath:info.path ]];
            
            
        }
        
    }
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.searchMode ?self.trackInfoFiltered.count : self.trackInfo.count;
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


    TrackInfo *info = self.searchMode? self.trackInfoFiltered[row]: self.trackInfo[row];
    
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

@end
