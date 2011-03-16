// ***************************************************************************
//            WhizWheel 1.0.3 - Copyright Vrai Stacey 2009 - 2011
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

#import "WindViewController.h"
#import "CompassSelectorView.h"
#import "Configuration.h"
#import "TextValidator.h"
#import "TextFormatter.h"
#import "WindCalculator.h"
#import "DirectionTextFieldDelegate.h"
#import "NaturalNumberTextFieldDelegate.h"
#import "NotificationNames.h"
#import "WindCalculationOperation.h"

@interface WindViewController ( )
- ( void ) publishWindDirectionAndSpeed: ( BOOL ) internalOnly;
- ( void ) silentlySetWindDetails: ( WindDetails * ) newWindDetails;
- ( void ) updateTextFields;
- ( void ) handleWindDetailsNotification: ( NSNotification * ) notification;
- ( void ) handleWindDetailsRepublishNotification: ( NSNotification * ) notification;
- ( void ) handleConfigurationUpdate: ( NSNotification * ) notification;
@end

#pragma mark -

@implementation WindViewController

@synthesize directionTextField;
@synthesize speedTextField;
@synthesize compassSelectorView;
@synthesize windDetails;

- ( id ) initWithCoder: ( NSCoder * ) coder
{
    if ( self = [ super initWithCoder: coder ] )
    {
        windDetails = [ [ WindDetails alloc ] init ];
        windDetailsDirty = YES;

        // Wire up the wind notification observers
        [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                    selector: @selector ( handleWindDetailsNotification: )
                                                        name: WindDetailsPublished
                                                       object: nil ];
        [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                    selector: @selector ( handleWindDetailsNotification: )
                                                        name: WindDetailsInternalPublished
                                                       object: nil ];
                                                       
        // Wire up the configuration notification observers
        [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                    selector: @selector ( handleConfigurationUpdate: )
                                                        name: ConfigurationUpdated
                                                      object: nil ];
                                                                                   
        // Wire up the republish notification handler
        [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                    selector: @selector ( handleWindDetailsRepublishNotification: )
                                                        name: WindDetailsRepublishRequest
                                                      object: nil ];
    }
    return self;
}

- ( void ) dealloc
{
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
    [ windDetails release ];
    [ compassSelectorView release ];
    [ directionTextField release ];
    [ speedTextField release ];
    [ directionTextFieldDelegate release ];
    [ speedTextFieldDelegate release ];
    [ super dealloc ];
}

- ( void ) viewDidLoad
{
    [ super viewDidLoad ];
    
    // Use standard pin-strip background
    [ [ self view ] setBackgroundColor: [ UIColor groupTableViewBackgroundColor ] ];

    // Make sure the delegates exist
    if ( ! directionTextFieldDelegate )
        directionTextFieldDelegate = [ [ DirectionTextFieldDelegate alloc ] initWithSelector: @selector ( setWindDirection: )
                                                                                      target: self ];
    if ( ! speedTextFieldDelegate )
        speedTextFieldDelegate = [ [ NaturalNumberTextFieldDelegate alloc ] initWithSelector: @selector ( setWindSpeed: )
                                                                                      target: self
                                                                                     maximum: 100 ];
    
    // Wire up the delegates to the fields and display the current values
    [ directionTextField setDelegate: directionTextFieldDelegate ];
    [ speedTextField setDelegate: speedTextFieldDelegate ];
    [ self updateTextFields ];
    
    // Configure the compass view
    [ compassSelectorView setMaximumMagnitude: [ [ Configuration defaultConfiguration ] maximumWindMagnitude ] ];
    if ( windDetails )
        [ self publishWindDirectionAndSpeed: YES ];
}

- ( void ) viewWillDisappear: ( BOOL ) animated
{
    // The WindView is about to disappear - time to pass on the wind details to any other interest parties.
    if ( windDetailsDirty )
    {
        windDetailsDirty = NO;
        [ self publishWindDirectionAndSpeed: FALSE ];
    }
    
    [ super viewWillDisappear: animated ];
}

#pragma mark -
#pragma mark Property accessors

- ( void ) setWindDirection: ( NSString * ) direction
{
    const int newDirection = [ direction length ] > 0 ? [ direction intValue ] % 360
                                                      : - 1;
    [ direction release ];
    
    if ( newDirection != [ windDetails direction ] )
    {
        [ windDetails setDirection: newDirection ];
        [ self publishWindDirectionAndSpeed: TRUE ];
        windDetailsDirty = YES;
    }
}


- ( void ) setWindSpeed: ( NSString * ) speed
{
    const int newSpeed = [ speed length ] > 0 ? [ speed intValue ]
                                                  : -1;
    [ speed release ];
    
    if ( newSpeed != [ windDetails speed ] )
    {
        [ windDetails setSpeed: newSpeed ];
        [ self publishWindDirectionAndSpeed: TRUE ];
        windDetailsDirty = YES;
    }
}

- ( void ) silentlySetWindDetails: ( WindDetails * ) newWindDetails
{
    if ( ! [ newWindDetails isEqual: windDetails ] )
    {    
        // New wind details are different from current ones - overright the old ones
        [ windDetails setDirection: [ newWindDetails direction ] ];
        [ windDetails setSpeed: [ newWindDetails speed ] ];
        windDetailsDirty = YES;
        
        // Set the text fields to match the new values
        [ self updateTextFields ];
        [ [ Configuration defaultConfiguration ] setFromWindDetails: newWindDetails ];
    }
}

- ( void ) updateTextFields
{
    NSAutoreleasePool * pool = [ [ NSAutoreleasePool alloc ] init ];
    
    NSString * direction = [ windDetails direction ] < 0 ? [ NSString stringWithFormat: @"" ]
                                                         : [ NSString stringWithFormat: @"%d", [ windDetails direction ] ];
    NSString * speed = [ windDetails speed ] < 0 ? [ NSString stringWithFormat: @"" ]
                                                 : [ NSString stringWithFormat: @"%d", [ windDetails speed ] ];

    [ directionTextFieldDelegate setText: direction forField: directionTextField ];
    [ speedTextFieldDelegate setText: speed forField: speedTextField ];
                            
    [ pool release ];
}

#pragma mark -
#pragma mark Notification publishing logic

- ( void ) publishWindDirectionAndSpeed: ( BOOL ) internalOnly
{
    NSString * notification = internalOnly ? WindDetailsInternalPublished : WindDetailsPublished;
    [ [ NSNotificationCenter defaultCenter ] postNotification: [ NSNotification notificationWithName: notification
                                                                                              object: windDetails ] ];
}

#pragma mark -
#pragma mark NSNotification handler methods

- ( void ) handleWindDetailsNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == WindDetailsPublished || [ notification name ] == WindDetailsInternalPublished )
        [ self silentlySetWindDetails: [ notification object ] ];
}

- ( void ) handleWindDetailsRepublishNotification: ( NSNotification * ) notification
{
    [ self publishWindDirectionAndSpeed: YES ];
}

- ( void ) handleConfigurationUpdate: ( NSNotification * ) notification
{
    [ compassSelectorView setMaximumMagnitude: [ [ notification object ] maximumWindMagnitude ] ];
}

@end
