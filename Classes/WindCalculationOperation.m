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

#import "WindCalculationOperation.h"
#import "WindCalculator.h"
#import "NotificationNames.h"

@interface WindCalculationOperation ( )
- ( void ) publishResults: ( id ) results asNotification: ( NSString * ) name;
@end

#pragma mark -

@implementation WindCalculationOperation

@synthesize calculator;

- ( void ) dealloc
{
    [ calculator release ];
    [ super dealloc ];
}

- ( id ) initWithCalculator: ( WindCalculator * ) theCalculator
{
    if ( self = [ super init ] )
    {
        calculator = [ theCalculator retain ];
    }
    return self;
}

#pragma mark -
#pragma mark Results notification publication methods

- ( void ) publishResults: ( id ) results asNotification: ( NSString * ) name
{
    NSNotification * notification = [ NSNotification notificationWithName: name object: results ];
    [ [ NSNotificationCenter defaultCenter ] performSelectorOnMainThread: @selector ( postNotification: )
                                                              withObject: notification
                                                           waitUntilDone: YES ];
}

#pragma mark -
#pragma mark NSOperation methods

- ( void ) main
{
    NSAutoreleasePool * pool = [ [ NSAutoreleasePool alloc ] init ];
    
    // Recalculate the navigation details and rose
    WindAdjustedPlanDetails * navigationResults = [ calculator recalculateNavigationResults ];
    WindRoseDetails * roseResults = [ calculator recalculateWindRoseResults ];
    
    // Because these results will be used by GUI components, publish the results back on the main thread
    [ self publishResults: navigationResults asNotification: NavigationResultsPublished ];
    [ self publishResults: roseResults asNotification: WindRoseResultsPublished ];
    
    [ pool release ];
}

@end
