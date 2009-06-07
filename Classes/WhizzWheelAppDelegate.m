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

#import "WhizzWheelAppDelegate.h"
#import "Configuration.h"
#import "WindCalculator.h"
#import "WindCalculationOperation.h"
#import "NotificationNames.h"

#define CONFIGURATION_FILENAME  @"WhizWheelConfig"

#pragma mark -

@interface WhizzWheelAppDelegate ( )
- ( void ) handleWindDetailsNotification: ( NSNotification * ) notification;
- ( void ) handleNavigationDetailsNotification: ( NSNotification * ) notification;
- ( void ) handleWindCalculatorConsumerNotification: ( NSNotification * ) notification;

- ( void ) doHandleDetailsNotificationWithObject: ( id ) object calculatorSetter: ( SEL ) setter;
- ( void ) doQueueRecalculationOperation;
@end

#pragma mark -

@implementation WhizzWheelAppDelegate

@synthesize window;
@synthesize tabBarController;

- ( void ) dealloc
{
    [ tabBarController release ];
    [ window release ];
    [ backgroundQueue release ];
    [ super dealloc ];
}

#pragma mark -
#pragma mark UIApplicationDelegate methods

- ( void ) applicationDidFinishLaunching: ( UIApplication * ) application
{
    // Make sure the configuration gets initialised
    [ Configuration initialiseDefaultConfigurationFromFile: CONFIGURATION_FILENAME ];
    
    // Create the background operation queue if required
    if ( ! backgroundQueue )
    {
        backgroundQueue = [ [ NSOperationQueue alloc ] init ];
        [ backgroundQueue setMaxConcurrentOperationCount: 1 ];
    }

    // Add the tab bar controller's current view as a subview of the window
    [ window addSubview: tabBarController.view ];
    
    // Wire up the notification handlers
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector ( handleWindDetailsNotification: )
                                                    name: WindDetailsPublished
                                                  object: nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector ( handleNavigationDetailsNotification: )
                                                    name: NavigationDetailsPublished
                                                  object: nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector ( handleWindCalculatorConsumerNotification: )
                                                    name: WindCalculatorConsumerCreated
                                                  object: nil ];
}

- ( void ) applicationWillTerminate: ( UIApplication * ) application
{
    // Save the configuration
    [ [ Configuration defaultConfiguration ] saveToArchive: CONFIGURATION_FILENAME ];
}

#pragma mark -
#pragma mark Notification handlers methods

- ( void ) handleWindDetailsNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == WindDetailsPublished )
        [ self doHandleDetailsNotificationWithObject: [ notification object ] calculatorSetter: @selector ( setWindDetails: ) ];
}

- ( void ) handleNavigationDetailsNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == NavigationDetailsPublished )
        [ self doHandleDetailsNotificationWithObject: [ notification object ] calculatorSetter: @selector ( setNavigationPlanDetails: ) ];
}

- ( void ) handleWindCalculatorConsumerNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == WindCalculatorConsumerCreated )
        [ self doQueueRecalculationOperation ];
}

#pragma mark -
#pragma mark Notification handler helper methods

- ( void ) doHandleDetailsNotificationWithObject: ( id ) object calculatorSetter: ( SEL ) setter
{    
    [ [ WindCalculator defaultCalculator ] performSelector: setter withObject: object ];
    [ self doQueueRecalculationOperation ];
}

- ( void ) doQueueRecalculationOperation
{
    NSOperation * operation = [ [ WindCalculationOperation alloc ] initWithCalculator: [ WindCalculator defaultCalculator ] ];
    [ backgroundQueue addOperation: operation ];
    [ operation release ];
}

@end

