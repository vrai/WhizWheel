// ***************************************************************************
//            WhizWheel 1.0.1 - Copyright Vrai Stacey 2009 - 2010
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

#import "NavigationViewController.h"
#import "TextValidator.h"
#import "TextFormatter.h"
#import "WindCalculator.h"
#import "DecimalNumberTextFieldDelegate.h"
#import "DirectionTextFieldDelegate.h"
#import "NaturalNumberTextFieldDelegate.h"
#import "NotificationNames.h"

@interface NavigationViewController ( )
- ( void ) updateNavigationResults;
- ( void ) updateNavigationPlanDetails;
- ( void ) publishNavigationPlanDetails;
- ( void ) handleNavigationResultNotification: ( NSNotification * ) notification;
- ( void ) handleNavigationLoadedNotification: ( NSNotification * ) notification;
@end

#pragma mark -

@implementation NavigationViewController

@synthesize trackTextField;
@synthesize distanceTextField;
@synthesize tasTextField;
@synthesize headingLabel;
@synthesize groundSpeedLabel;
@synthesize flightTimeLabel;
@synthesize navigationPlanDetails;
@synthesize navigationPlanResults;
@synthesize windCorrectionLabel;

- ( id ) initWithCoder: ( NSCoder * ) coder
{
    if ( self = [ super initWithCoder: coder ] )
    {
        navigationPlanDetails = [ [ NavigationPlanDetails alloc ] init ];
        navigationPlanResults = nil;
        
        // Listen for navigation details being loaded from the config file
        [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                    selector: @selector ( handleNavigationLoadedNotification: )
                                                        name: NavigationDetailsLoaded
                                                      object: nil ];
        
    }
    return self;
}

- ( void ) dealloc
{
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
    [ navigationPlanDetails release ];
    [ navigationPlanResults release ];
    [ trackTextField release ];
    [ distanceTextField release ];
    [ tasTextField release ];
    [ headingLabel release ];
    [ groundSpeedLabel release ];
    [ flightTimeLabel release ];
    [ trackTextFieldDelegate release ];
    [ tasTextFieldDelegate release ];
    [ distanceTextFieldDelegate release ];
    [ super dealloc ];
}

- ( void ) viewDidLoad
{
    [ super viewDidLoad ];
    
    // Use standard pin-strip background
    [ [ self view ] setBackgroundColor: [ UIColor groupTableViewBackgroundColor ] ];
    
    // Make sure the delegates exist
    if ( ! trackTextFieldDelegate )
        trackTextFieldDelegate = [ [ DirectionTextFieldDelegate alloc ] initWithSelector: @selector ( setNavigationTrack: )
                                                                                  target: self ];
    if ( ! tasTextFieldDelegate )
        tasTextFieldDelegate = [ [ NaturalNumberTextFieldDelegate alloc ] initWithSelector: @selector ( setNavigationTAS: )
                                                                                    target: self ];
    if ( ! distanceTextFieldDelegate )
        distanceTextFieldDelegate = [ [ DecimalNumberTextFieldDelegate alloc ] initWithSelector: @selector ( setNavigationDistance: )
                                                                                         target: self ];
                                                                                    
    // Wire up the delegates to the fields
    [ trackTextField setDelegate: trackTextFieldDelegate ];
    [ tasTextField setDelegate: tasTextFieldDelegate ];
    [ distanceTextField setDelegate: distanceTextFieldDelegate ];

    // Listen for navigation result notifications
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector ( handleNavigationResultNotification: )
                                                    name: NavigationResultsPublished
                                                  object: nil ];

    // Make sure the display is ready
    [ self updateNavigationPlanDetails ];
    [ self updateNavigationResults ];
}

#pragma mark -
#pragma mark Data accessors

- ( void ) setNavigationTrack: ( NSString * ) track
{
    [ navigationPlanDetails setTrack: [ track length ] > 0 ? [ track intValue ]
                                                           : -1 ];
    [ track release ];

    [ self publishNavigationPlanDetails ];
}

- ( void ) setNavigationDistance: ( NSString * ) distance
{
    [ navigationPlanDetails setDistance: [ distance length ] > 0 ? [ NSDecimalNumber decimalNumberWithString: distance ]
                                                                 : nil ];
    [ distance release ];

    [ self publishNavigationPlanDetails ];
}

- ( void ) setNavigationTAS: ( NSString * ) tas
{
    [ navigationPlanDetails setTargetAirSpeed: [ tas length ] > 0 ? [ tas intValue ]
                                                                  : -1 ];
    [ tas release ];

    [ self publishNavigationPlanDetails ];
}

#pragma mark -
#pragma mark Display updaters

- ( void ) updateNavigationResults
{
    // If the results are present but invalid, display the error message
    if ( navigationPlanResults && ! [ navigationPlanResults isValid ] )
    {
        UIAlertView * errorView = [ [ [ UIAlertView alloc ] initWithTitle: @"Wind effect calculation failed"
                                                                  message: [ navigationPlanResults error ]
                                                                 delegate: nil
                                                        cancelButtonTitle: @"Continue"
                                                        otherButtonTitles: nil ] autorelease ];
        [ errorView show ];
    }

    const id allLabels [ 3 ] = { headingLabel, groundSpeedLabel, windCorrectionLabel };

    // Either display the result contents or the placeholder text
    UIColor * textColour;
    BOOL autoAdjustTextSize;
    CGFloat fontSize;

    if ( navigationPlanResults && [ navigationPlanResults isValid ] )
    {
        [ headingLabel setText: [ NSString stringWithFormat: @"%@ degrees", [ [ TextFormatter defaultFormatter ] formatDirection: [ navigationPlanResults heading ] ] ] ];
        [ groundSpeedLabel setText: [ NSString stringWithFormat: @"%@ knots", [ [ TextFormatter defaultFormatter ] formatNaturalNumber: [ navigationPlanResults groundSpeed ] ] ] ];
        [ windCorrectionLabel setText: [ NSString stringWithFormat: @"%@ degrees", [ [ TextFormatter defaultFormatter ] formatSignedInteger: [ navigationPlanResults correction ] ] ] ];
        textColour = [ UIColor blackColor ];
        autoAdjustTextSize = TRUE;
        fontSize = [ UIFont systemFontSize ] * 1.1;
    }
    else
    {
        [ headingLabel setText: @"Cannot be calculated until" ];
        [ groundSpeedLabel setText: @"wind, track and target speed" ];
        [ windCorrectionLabel setText: @"have been entered" ];
        textColour = [ UIColor darkGrayColor ];
        autoAdjustTextSize = FALSE;
        fontSize = [ UIFont systemFontSize ] * 0.8;
    }
    
    for ( int labelIndex = 0; labelIndex < 3; ++labelIndex )
    {
        id label = allLabels [ labelIndex ];
        [ label setTextColor: textColour ];
        [ label setAdjustsFontSizeToFitWidth: autoAdjustTextSize ];
        [ label setFont: [ [ label font ] fontWithSize: fontSize ] ];
    }

    // Handle the distance separately
    if ( navigationPlanResults && [ navigationPlanResults isValid ] && [ navigationPlanResults flightTime ] )
    {
        [ flightTimeLabel setText: [ NSString stringWithFormat: @"%.1f minutes", [ [ navigationPlanResults flightTime ] doubleValue ] ] ];
        textColour = [ UIColor blackColor ];
        autoAdjustTextSize = TRUE;
        fontSize = [ UIFont systemFontSize ] * 1.1;
    }
    else
    {
        [ flightTimeLabel setText: @"Cannot be calculated yet" ];
        textColour = [ UIColor darkGrayColor ];
        autoAdjustTextSize = FALSE;
        fontSize = [ UIFont systemFontSize ] * 0.8;
    }
    
    [ flightTimeLabel setTextColor: textColour ];
    [ flightTimeLabel setAdjustsFontSizeToFitWidth: autoAdjustTextSize ];
    [ flightTimeLabel setFont: [ [ flightTimeLabel font ] fontWithSize: fontSize ] ];
}

- ( void ) updateNavigationPlanDetails
{
    if ( ! ( [ self isViewLoaded ] && navigationPlanDetails ) )
        return;
        
    NSAutoreleasePool * pool = [ [ NSAutoreleasePool alloc ] init ];
      
    if ( [ navigationPlanDetails track ] >= 0 )
        [ trackTextFieldDelegate setText: [ NSString stringWithFormat: @"%d", [ navigationPlanDetails track ] ]
                                forField: trackTextField ];
    if ( [ navigationPlanDetails targetAirSpeed ] >= 0 )
        [ tasTextFieldDelegate setText: [ NSString stringWithFormat: @"%d", [ navigationPlanDetails targetAirSpeed ] ]
                              forField: tasTextField ];
    if ( [ navigationPlanDetails distance ] )
        [ distanceTextFieldDelegate setText: [ [ navigationPlanDetails distance ] stringValue ]
                                   forField: distanceTextField ];
    
    [ pool release ];
}

#pragma mark -
#pragma mark Notification handler and publishing logic

- ( void ) publishNavigationPlanDetails
{
    [ [ NSNotificationCenter defaultCenter ] postNotification: [ NSNotification notificationWithName: NavigationDetailsPublished
                                                                                              object: navigationPlanDetails ] ];
}

- ( void ) handleNavigationResultNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == NavigationResultsPublished )
    {
        [ self setNavigationPlanResults: [ notification object ] ];
        [ self updateNavigationResults ];
    }
}

- ( void ) handleNavigationLoadedNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == NavigationDetailsLoaded )
    {
        navigationPlanDetails = [ [ notification object ] retain ];
        [ self updateNavigationPlanDetails ];
        [ self publishNavigationPlanDetails ];
    }
}

@end
