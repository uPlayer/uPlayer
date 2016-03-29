//
//  PlayerlistViewController.mm
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlaylistViewController.h"
#import "UPlayer.h"
#import "PlayerMessage.h"
#import "PlayerSerachMng.h"
#import "PlayerLayout+MemoryFileBuffer.h"

//@interface PlaylistViewControllerCoding : NSObject
//<NSCoding>
//@end
//
//@implementation PlaylistViewControllerCoding
//
//-(instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    
//}
//
//-(void)encodeWithCoder:(NSCoder *)aCoder
//{
//    
//}
//
//@end


@interface PlaylistViewController ()
<NSTableViewDelegate , NSTableViewDataSource ,NSTextFieldDelegate >

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic,strong) PlayerlList *playerlList;

//@property (nonatomic,strong) PlaylistViewControllerCoding *data;

@end

@implementation PlaylistViewController


-(void)reloadTrackList
{
    /// @todo save top index.
    
    [self.tableView reloadData];
    
    [self.tableView resignFirstResponder];
    
    PlayerTrack *track = Playing();
    
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
   
    addObserverForEvent(self, @selector(saveLayout), EventID_applicationWillTerminate);
    
    
    self.playerlList = player().document.playerlList;
    
    self.tableView.rowHeight = 40.;
    
    self.tableView.doubleAction=@selector(doubleClicked);
    
    self.tableView.usesAlternatingRowBackgroundColors = true;
    
    [self.tableView reloadData];
    
    
    addObserverForEvent( self.tableView , @selector(reloadData), EventID_tracks_changed);
    addObserverForEvent( self.tableView , @selector(reloadData), EventID_list_changed);
    
    // load ui layout
    [self loadLayout];
}

#pragma mark - @protocol PlayerLayout

-(void)saveLayout
{
    NSArray *tableColumns = self.tableView.tableColumns;
    
    MemoryFileBuffer buffer( sizeof(CGFloat)*10);
    
    for (NSTableColumn *column in tableColumns) {
        CGFloat w = column.width;
        buffer.write(w);
    }
    
    NSData *data = dataFromMemoryFileBuffer(&buffer);
    [player().layout saveData:data withKey:self.className];
}

-(void)loadLayout
{
    NSArray *tableColumns = self.tableView.tableColumns;
    
    NSData *data = [player().layout getDataByKey:self.className];
    if(data )
    {
        MemoryFileBuffer *buffer = newMemoryFileBufferFromData(data);
        
        for ( int i = 0; i < tableColumns.count ; ++i) {
            NSTableColumn *column = tableColumns[i];
            CGFloat width;
            buffer->read(width);
            column.width = width;
        }
        
        [self.tableView reloadData];
        delete buffer;
    }
}

#pragma mark -

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
    NSInteger column = tableColumn.identifier.intValue;
    
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
        textField.editable = true;
        textField.delegate=self;
        textField.tag = row;
    }
    
    return textField;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    int row = (int)control.tag;
    PlayerList * list = [self.playerlList getItem:row];
    list.name = [fieldEditor.string copy];
    
    postEvent(EventID_list_name_changed, list);
    
    return TRUE;
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
    
    /*PlayerList* nearItem =*/ [player().document.playerlList deleteItem:item];
    
    [self.tableView reloadData];
    
}

- (IBAction)cmdActiveItem:(id)sender
{
    int selectedRow = (int) self.tableView.selectedRow;
    PlayerList *l = [self.playerlList getItem:selectedRow];
    
    postEvent(EventID_to_reload_tracklist, l );
}

@end
