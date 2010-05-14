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

#import "ConfigTableSectionDelegate.h"
#import "Configuration.h"
#import "ConfigTableCell.h"
#import "TextFormatter.h"

#pragma mark Help text HTML

#define HTML_CONFIG_TEXT "<p>The maximum magnitude of the wind selector (e.g. maximum wind speed) can be adjusted "    \
                         "below. Note that this doesn't affect the maximum wind speed that can be entered in to the "  \
                         "<b>Wind Speed</b> box, only the touch selector.</p>"

#pragma mark -

@interface ConfigTableSectionDelegate ( )

- ( void ) windMagnitudeSliderUpdated: ( UISlider * ) slider;
- ( void ) setWindMagnitude: ( int ) magnitude;

@end

#pragma mark -

@implementation ConfigTableSectionDelegate

@synthesize name;
@synthesize cell;

- ( void ) dealloc
{
    [ name release ];
    [ cell release ];
    [ super dealloc ];
}

- ( id ) initWithName: ( NSString * ) theName
{
    if ( self = [ super init ] )
    {
        [ self setName: theName ];

        // Load the cell in from the XIB
        NSArray * nib = [ [ NSBundle mainBundle ] loadNibNamed: @"ConfigTableCell"
                                                         owner: self
                                                       options: nil ];
        [ self setCell: [ nib objectAtIndex: 0 ] ];
        
        // Configure the help text
        [ [ cell htmlLabel ]   loadHTMLString: [ [ TextFormatter defaultFormatter ]
                             formatHTMLString: [ NSString stringWithCString: HTML_CONFIG_TEXT
                                                                   encoding: NSASCIIStringEncoding ] ]
                                    baseURL: nil ];
                                    
        // Wire up the slider updates
        [ [ cell windMagnitudeSlider ] addTarget: self
                                          action: @selector ( windMagnitudeSliderUpdated: )
                                forControlEvents: UIControlEventValueChanged ];
    }
    return self;
}

- ( void ) windMagnitudeSliderUpdated: ( UISlider * ) slider
{
    [ self setWindMagnitude: [ slider value ] ];
}

- ( void ) loadFromConfiguration: ( Configuration * ) configuration
{
    [ self setWindMagnitude: [ configuration maximumWindMagnitude ] ];
}

- ( void ) saveToConfiguration: ( Configuration * ) configuration
{
    [ configuration setMaximumWindMagnitude: [ [ cell windMagnitudeSlider ] value ] ];
}

- ( void ) setWindMagnitude: ( int ) magnitude
{
    // Make sure the magnitude is within the bounds allowed by the slider - and update the label
    magnitude = fmaxl ( fminl ( magnitude, [ [ cell windMagnitudeSlider ] maximumValue ] ), [ [ cell windMagnitudeSlider ] minimumValue ] );
    [ [ cell windMagnitudeLabel ] setText: [ NSString stringWithFormat: @"%@ knots", [ [ TextFormatter defaultFormatter ] formatNaturalNumber: magnitude ] ] ];
    
    // If the magnitude differs from that within the slider, update the slider
    if ( magnitude != [ [ cell windMagnitudeSlider ] value ] )
        [ [ cell windMagnitudeSlider ] setValue: magnitude ];
}

+ ( id ) delegateWithName: ( NSString * ) name
{
    return [ [ [  ConfigTableSectionDelegate alloc ] initWithName: name ] autorelease ];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- ( UITableViewCell * ) tableView: ( UITableView * ) tableView cellForRowAtIndexPath: ( NSIndexPath * ) indexPath
{
    return cell;
}

- ( NSInteger ) tableView: ( UITableView * ) tableView numberOfRowsInSection: ( NSInteger ) section
{
    return 1;
}

- ( NSString * ) tableView: ( UITableView * ) tableView titleForHeaderInSection: ( NSInteger ) section
{
    return name;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

-  ( CGFloat ) tableView: ( UITableView * ) tableView heightForRowAtIndexPath: ( NSIndexPath * )indexPath
{
    return [ cell frame ].size.height;
}

@end
