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

#import "WindRoseViewController.h"
#import "WindRoseDetails.h"
#import "WindRoseResultCell.h"
#import "WindRoseHelpCell.h"
#import "NotificationNames.h"
#import "TextSplitter.h"

// The font size and row height for the wind rose view details output
#define WINDROSEVIEWCONTROLLER_OFFSETTABLE_FONTSIZE     14.0
#define WINDROSEVIEWCONTROLLER_OFFSETTABLE_ROWHEIGHT    28.0

// Maximum number of characters in a row
#define WINDROSEVIEWCONTROLLER_MAXIMUM_ROW_CHARS        38

#pragma mark -

@interface WindRoseViewController ( )
- ( void ) handleWindRoseResultsNotification: ( NSNotification * ) notification;
- ( NSArray * ) getHelpText;
@end

#pragma mark -

static NSArray * s_helpText = nil;

@implementation WindRoseViewController

@synthesize incrementSelectionControl;
@synthesize offsetTable;
@synthesize granularity;
@synthesize roseDetails;

- ( id ) initWithCoder: ( NSCoder * ) coder
{
    if ( self = [ super initWithCoder: coder ] )
    {
        granularity = THIRTY_DEGREES;
        roseDetails = nil;
    }
    return self;
}

- ( void ) dealloc
{
    [ incrementSelectionControl release ];
    [ offsetTable release ];
    [ roseDetails release ];
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
    [ super dealloc ];
}

- ( void ) viewDidLoad
{
    [ super viewDidLoad ];
    
    // Use standard pin-strip background and set table to be see-through
    [ [ self view ] setBackgroundColor: [ UIColor groupTableViewBackgroundColor ] ];
    [ offsetTable setBackgroundColor: [ UIColor colorWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.0f ] ];
    
    // Connect the SegmentedControl's Value Changed event to the local handler
    [ incrementSelectionControl addTarget: self action: @selector ( incrementSelectionChanged: ) forControlEvents: UIControlEventValueChanged ];
    
    // Listen for wind rose result notifications
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector ( handleWindRoseResultsNotification: )
                                                    name: WindRoseResultsPublished
                                                  object: nil ];
                                                  
    // Initialise the granularity - this will force a display update
    [ incrementSelectionControl setSelectedSegmentIndex: 0 ];
    
    // This could have been created after wind/track information has already been entered, so ping the calculator to resend the results
    [ [ NSNotificationCenter defaultCenter ] postNotification: [ NSNotification notificationWithName: WindCalculatorConsumerCreated
                                                                                              object: nil ] ];
}

#pragma mark -
#pragma mark Property accessors

- ( void ) setGranularity: ( RoseGranularity ) theGranularity
{
    granularity = theGranularity;
    [ offsetTable reloadData ];
}

- ( void ) setRoseDetails: ( WindRoseDetails * ) theRoseDetails
{
    [ roseDetails release ];
    roseDetails = [ theRoseDetails retain ];
    [ offsetTable reloadData ];
}

#pragma mark -
#pragma mark Notification handling

- ( void ) handleWindRoseResultsNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == WindRoseResultsPublished )
        [ self setRoseDetails: [ notification object ] ];
}

#pragma mark -
#pragma mark UISegmentedControl actions

- ( void ) incrementSelectionChanged: ( id ) control
{
    if ( control == incrementSelectionControl )
    {
        switch ( [ incrementSelectionControl selectedSegmentIndex ] )
        {  
            case 0: [ self setGranularity: THIRTY_DEGREES ];        break;
            case 1: [ self setGranularity: FORTY_FIVE_DEGREES ];    break;
            default:
                NSLog ( @"WindRoseViewController::incrementSelectionChanged to %d - unknown increment", [ incrementSelectionControl selectedSegmentIndex ] );
                break;
        }
    }
}

#pragma mark -
#pragma mark Static text utility methods

- ( NSArray * ) getHelpText
{
    if ( ! s_helpText )
    {
        NSMutableArray * helpText = [ [ NSMutableArray alloc ] init ];
        [ helpText addObject: @"Cannot be calculated until wind speed," ];
        [ helpText addObject: @"direction and target air speed have" ];
        [ helpText addObject: @"been entered." ];
        
        s_helpText = helpText;
    }
    
    return s_helpText;
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- ( UITableViewCell * ) tableView: ( UITableView * ) tableView cellForRowAtIndexPath: ( NSIndexPath * ) indexPath
{
    if ( tableView != offsetTable )
        return nil;

    // What we display depends on whether there's any results to show. If so, use the WindRoseResultCells otherwise display
    // either the error message or the help text in WindRoseHelpCells.
    if ( roseDetails && [ roseDetails isValid ] )
    {
        // This is used to identify every cell we created - that way cell creation can be kept to a minimum via re-use
        NSString * cellIdentifier = [ NSString stringWithFormat: @"Result cell at %@", indexPath ];
        
        // Retrieve the cell or create a new instance if this is the first time the index path has been seen
        UITableViewCell * cell = [ tableView dequeueReusableCellWithIdentifier: cellIdentifier ];
        if ( ! cell )
            cell = [ [ [ WindRoseResultCell alloc ] initWithStyle: UITableViewCellStyleDefault
                                                  reuseIdentifier: cellIdentifier
                                                         fontSize: WINDROSEVIEWCONTROLLER_OFFSETTABLE_FONTSIZE ] autorelease ];
        
        // If this is the correct section of the correct table and there are details to be show, populate the cell with the offset
        // and speed for the current direction.
        if ( tableView == offsetTable && [ indexPath length ] > 1 && [ indexPath indexAtPosition: 0 ] == 0 && roseDetails )
        {
            const int angle = [ indexPath indexAtPosition: 1 ] * granularity;
            if ( angle >= 0 && angle < 360 )        
                [ ( WindRoseResultCell * ) cell setDirection: angle
                                                offset: [ roseDetails getOffsetForDirection: angle ]
                                                 speed: [ roseDetails getSpeedForDirection: angle ] ];
        }
        
        return cell;
    }
    else
    {
        // Make sure this doesn't clash with the result cell identifiers!
        NSString * cellIdentifier = [ NSString stringWithFormat: @"Help cell at %@", indexPath ];
        
        // Can we reuse a cell?
        UITableViewCell * cell = [ tableView dequeueReusableCellWithIdentifier: cellIdentifier ];
        if ( ! cell )
            cell = [ [ [ WindRoseHelpCell alloc ] initWithStyle: UITableViewCellStyleDefault
                                                reuseIdentifier: cellIdentifier
                                                       fontSize: WINDROSEVIEWCONTROLLER_OFFSETTABLE_FONTSIZE ] autorelease ];
                           
        // Either display the help text or the error message
        NSArray * textRows = roseDetails ? splitStringIntoLines ( [ roseDetails error ], WINDROSEVIEWCONTROLLER_MAXIMUM_ROW_CHARS )
                                         : [ [ self getHelpText ] retain ];
            
        const NSUInteger rowIndex = [ indexPath indexAtPosition: 1 ];
        if ( rowIndex < [ textRows count ] )
            [ ( WindRoseHelpCell * ) cell setHelpText: [ textRows objectAtIndex: rowIndex ] ];
            
        [ textRows release ];                          
        return cell;
    }
}

- ( NSInteger ) tableView: ( UITableView * ) tableView numberOfRowsInSection: ( NSInteger ) section
{
    if ( tableView != offsetTable || section != 0 )
        return 0;
        
    if ( roseDetails )
    {
        if ( [ roseDetails isValid ] )
            return 360 / granularity;               // Rose details available - number of rows depends on granularity
        else
        {
            // Error message - count the number of rows that will be needed
            NSArray * errorArray = splitStringIntoLines ( [ roseDetails error ], WINDROSEVIEWCONTROLLER_MAXIMUM_ROW_CHARS );
            const NSUInteger lineCount = [ errorArray count ];
            [ errorArray release ];
            return lineCount;
        }
    }
    else
        return [ [ self getHelpText ] count ];      // No rose details - display the help text cells
}

#pragma mark -
#pragma mark UITableViewDelegate methods

-  ( CGFloat ) tableView: ( UITableView * ) tableView heightForRowAtIndexPath: ( NSIndexPath * )indexPath
{
    return WINDROSEVIEWCONTROLLER_OFFSETTABLE_ROWHEIGHT;
}

@end
