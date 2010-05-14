// ***************************************************************************
//              WhizWheel 1.0.0 - Copyright Vrai Stacey 2009
//
// $Id$
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
// 
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
// ***************************************************************************

#import "MoreViewController.h"
#import "Configuration.h"
#import "ConfigTableSectionDelegate.h"
#import "WebTableSectionDelegate.h"

#pragma mark Help text HTML

#define HTML_LICENSE_TEXT "<h1>WhizWheel 1.0.0</h1>\n"                                                                                               \
                          "<h2>&copy; Vrai Stacey, 2009</h2>\n"                                                                                      \
                          "<p>Licensed under the <a href=\"http://www.gnu.org/licenses/old-licenses/gpl-2.0.html\">GNU General Public License</a>, " \
                          "version 2. This software is supplied <b>without warranty</b>, see the GPL license text for more details.</p>\n"           \
                          "<p>The Whizwheel source code can be downloaded from "                                                                     \
                          "<a href=\"http://vrai.net/project.php?project=whizwheel\">http://vrai.net/project.php?project=whizwheel</a>.</p>\n"

#pragma mark -

@interface MoreViewController ( )
- ( BOOL ) isValidTableView: ( UITableView * ) tableView section: ( NSInteger ) section;
@end

#pragma mark -

@implementation MoreViewController

@synthesize contentTable;

- ( void ) dealloc
{
    [ configSectionDelegate release ];
    [ sectionDelegates release ];
    [ contentTable release ];
    [ super dealloc ];
}

- ( id ) initWithCoder: ( NSCoder * ) coder
{
    if ( self = [ super initWithCoder: coder ] )
    {
        sectionDelegates = [ [ NSMutableArray alloc ] init ];
    }
    return self;
}

- ( void ) viewDidLoad
{
    [ super viewDidLoad ];
          
    // Add the default sections to the table
    NSAutoreleasePool * pool = [ [ NSAutoreleasePool alloc ] init ];
    
    [ self addSectionDelegate: [ WebTableSectionDelegate delegateWithName: @"About WhizWheel"
                                                                  content: [ NSString stringWithCString: HTML_LICENSE_TEXT 
                                                                                               encoding: NSASCIIStringEncoding ]
                                                                   height: 200 ] ];
    [ self addSectionDelegate: ( configSectionDelegate = [ [ ConfigTableSectionDelegate delegateWithName: @"Configuration" ] retain ] ) ];
    
    // Restore the configuration
    [ configSectionDelegate loadFromConfiguration: [ Configuration defaultConfiguration ] ];
    
    [ pool release ];
}

- ( void ) viewWillDisappear: ( BOOL ) animated
{
    // Commit any configuration changes
    [ configSectionDelegate saveToConfiguration: [ Configuration defaultConfiguration ] ];

    [ super viewWillDisappear: animated ];
}

- ( void ) addSectionDelegate: ( NSObject<UITableViewDataSource, UITableViewDelegate> * ) delegate
{
    if ( delegate )
        [ sectionDelegates addObject: delegate ];
}

#pragma mark -
#pragma mark Private methods

- ( BOOL ) isValidTableView: ( UITableView * ) tableView section: ( NSInteger ) section
{
    return tableView == contentTable && section >= 0 && section < [ sectionDelegates count ];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- ( UITableViewCell * ) tableView: ( UITableView * ) tableView cellForRowAtIndexPath: ( NSIndexPath * ) indexPath
{
    if ( [ self isValidTableView: tableView section: [ indexPath section ] ] )
        return [ [ sectionDelegates objectAtIndex: [ indexPath section ] ] tableView: tableView cellForRowAtIndexPath: indexPath ];
    return nil;
}

- ( NSInteger ) numberOfSectionsInTableView: ( UITableView * ) tableView
{
    if ( tableView == contentTable )
        return [ sectionDelegates count ];
    return 1;
}

- ( NSInteger ) tableView: ( UITableView * ) tableView numberOfRowsInSection: ( NSInteger ) section
{
    if ( [ self isValidTableView: tableView section: section ] )
        return [ [ sectionDelegates objectAtIndex: section ] tableView: tableView numberOfRowsInSection: section ];
    return 0;
}

- ( NSString * ) tableView: ( UITableView * ) tableView titleForHeaderInSection: ( NSInteger ) section
{
    if ( [ self isValidTableView: tableView section: section ] )
        return [ [ sectionDelegates objectAtIndex: section ] tableView: tableView titleForHeaderInSection: section ];
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- ( CGFloat ) tableView: ( UITableView * ) tableView heightForRowAtIndexPath: ( NSIndexPath * )indexPath
{
    if ( [ self isValidTableView: tableView section: [ indexPath section ] ] )
        return [ [ sectionDelegates objectAtIndex: [ indexPath section ] ] tableView: tableView heightForRowAtIndexPath: indexPath ];
    return 40;
}

- ( NSIndexPath * ) tableView: ( UITableView * )tableView willSelectRowAtIndexPath: ( NSIndexPath * )indexPath
{
    // Don't allow cell selection
    return nil;
}

@end
