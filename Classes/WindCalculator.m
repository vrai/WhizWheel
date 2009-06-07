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

#import "WindCalculator.h"
#import "AngleUtils.h"

@interface WindCalculator ( )
+ ( WindAdjustedPlanDetails * ) calculateWindEffectForWindDirection: ( int ) windDirection
                                                          windSpeed: ( double ) windSpeed
                                                              track: ( int ) track
                                                     targetAirSpeed: ( double ) targetAirSpeed
                                                           distance: ( NSDecimalNumber * ) distance;
+ ( WindRoseDetails * ) calculateWindRoseForWindDirection: ( int ) windDirection
                                                windSpeed: ( double ) windSpeed
                                                 airSpeed: ( double ) airSpeed;
@end

#pragma mark -

@implementation WindCalculator

@synthesize windDetails;
@synthesize navigationPlanDetails;

- ( NSString * ) description
{
    NSString * description;
    @synchronized ( self )
    {
        description = [ NSString stringWithFormat: @"WindCalculator[ wind: %@, navplan: %@ ]", windDetails, navigationPlanDetails ];
    }
    return description;
}

- ( WindAdjustedPlanDetails * ) recalculateNavigationResults
{   
    WindAdjustedPlanDetails * navResults = nil;
    
    @try
    {
        @synchronized ( self )
        {
            if ( windDetails && navigationPlanDetails )
                navResults = [ [ self class ] calculateWindEffectForWindDirection: [ windDetails direction ]
                                                                        windSpeed: ( double ) [ windDetails speed ]
                                                                            track: [ navigationPlanDetails track ]
                                                                   targetAirSpeed: ( double ) [ navigationPlanDetails targetAirSpeed ]
                                                                         distance: [ navigationPlanDetails distance ] ];
        }
    }
    @catch ( NSException * exception )
    {
        NSLog ( @"%@ recalculateNavigationResults threw an exception: %@", self, [ exception reason ] );
        navResults = [ [ [ WindAdjustedPlanDetails alloc ] initWithError: [ exception reason ] ] autorelease ];
    }
    
    return navResults;
}

- ( WindRoseDetails * ) recalculateWindRoseResults
{   
    WindRoseDetails * roseResults = nil;

    @try
    {   
        @synchronized ( self )
        {
            if ( windDetails && navigationPlanDetails )
                roseResults = [ [ self class ] calculateWindRoseForWindDirection: [ windDetails direction ]
                                                                       windSpeed: ( double ) [ windDetails speed ]
                                                                        airSpeed: ( double ) [ navigationPlanDetails targetAirSpeed ] ];
        }
    }
    @catch ( NSException * exception )
    {
        NSLog ( @"%@ recalculateWindRoseResults threw an exception: %@", self, [ exception reason ] );
        roseResults = [ [ [ WindRoseDetails alloc ] initWithError: [ exception reason ] ] autorelease ];
    }
    
    return roseResults;
}

#pragma mark -
#pragma mark Static Accessor

+ ( id ) defaultCalculator
{
    static WindCalculator * defaultInstance;
    
    @synchronized ( self )
    {
        if ( ! defaultInstance )
            defaultInstance = [ [ WindCalculator alloc ] init ];
    }
    
    return defaultInstance;
}

#pragma mark -
#pragma mark Wind Effect Calculation logic

+ ( WindAdjustedPlanDetails * ) calculateWindEffectForWindDirection: ( int ) windDirection
                                                          windSpeed: ( double ) windSpeed
                                                              track: ( int ) track
                                                     targetAirSpeed: ( double ) targetAirSpeed
                                                           distance: ( NSDecimalNumber * ) distance
{
    const static double twoPi = 2 * M_PI;

    // Check for "invalid" magic values (or just a user being stupid)
    if ( targetAirSpeed < 0.0 || track < 0 || windSpeed < 0.0 || windDirection < 0 )
        return nil;

    // Convert the angles in to radians
    const double windDirectionInRadians = degreesToRadians ( windDirection ),
                         trackInRadians = degreesToRadians ( track );
    
    // Not only does this make no sense, it can also causes a divide-by-zero error
    if ( targetAirSpeed <= 0.00001 )
    {
        @throw [ NSException exceptionWithName: @"CalculateWindException"
                                        reason: @"Air speed is too low! Aircraft must be moving."
                                      userInfo: nil ];
    }
   
    // Calculate the difference between the track vector and the wind vector - make sure it's within a valid range
    const double windSpeedDelta = ( windSpeed / targetAirSpeed ) * sin ( windDirectionInRadians - trackInRadians );
    if ( fabs ( windSpeedDelta ) > 1.0 )
    {
        @throw [ NSException exceptionWithName: @"CalculateWindException"
                                        reason: @"Wind too strong relative to air speed to allow course correction to be calculated."
                                      userInfo: nil ];
    }
    
    // Apply the difference to the track to get the heading, then make sure its within a range of 0 > 2Pi
    double headingInRadians = trackInRadians + asin ( windSpeedDelta );
    if ( headingInRadians < 0.0 )
        headingInRadians += twoPi;
    else if ( headingInRadians > twoPi )
        headingInRadians -= twoPi;
        
    // Calculate the ground speed
    const int groundSpeed = round ( targetAirSpeed * sqrt ( 1 - pow ( windSpeedDelta, 2 ) ) - ( windSpeed * cos ( windDirectionInRadians - trackInRadians ) ) );
    
    if ( groundSpeed < 1 )
    {
        @throw [ NSException exceptionWithName: @"CalculateWindException"
                                        reason: @"Wind too strong relative to air speed."
                                      userInfo: nil ];
    }
    
    // Calculate the wind correction angle, the difference between the track and the heading. This is done in degrees
    // rather than radians.
    int windCorrectionAngle = round ( radiansToDegrees ( headingInRadians ) ) - track;
    if ( windCorrectionAngle < 0 )
        windCorrectionAngle += 360;

    // As there are two "ways" to get between two angles, pick the smaller of the two. If the smaller one is not the one
    // calculated above, then the angle is negative.
    int inverseWCA = 360 - windCorrectionAngle;
    if ( inverseWCA < windCorrectionAngle )
        windCorrectionAngle = inverseWCA * -1;
        
    // The ground speed calculation is option - need to be multiplied by 60 as the time must be in minutes
    NSDecimalNumber * flightTime = nil;
    if ( distance )
        flightTime = [ [ distance decimalNumberByDividingBy: [ NSDecimalNumber decimalNumberWithMantissa: groundSpeed exponent: 0 isNegative: NO ] ]
                               decimalNumberByMultiplyingBy: [ NSDecimalNumber decimalNumberWithMantissa: 60 exponent: 0 isNegative: NO ] ];

    return [ [ [ WindAdjustedPlanDetails alloc ] initWithHeading: radiansToDegrees ( headingInRadians )
                                                      correction: windCorrectionAngle
                                                     groundSpeed: groundSpeed
                                                      flightTime: flightTime ] autorelease ];
}

+ ( WindRoseDetails * ) calculateWindRoseForWindDirection: ( int ) windDirection
                                                windSpeed: ( double ) windSpeed
                                                 airSpeed: ( double ) airSpeed
{
    // Quick idiot check
    if ( airSpeed < 0.0 || windSpeed < 0.0 )
        return nil;
        
    WindRoseDetails * results = [ [ [ WindRoseDetails alloc ] init ] autorelease ];

    // Calculate the effect of wind for all multiples of 15 degrees
    for ( int angle = 0; angle < 360; angle += 15 )
    {
        WindAdjustedPlanDetails * adjusted = [ self calculateWindEffectForWindDirection: windDirection
                                                                              windSpeed: windSpeed
                                                                                  track: angle
                                                                         targetAirSpeed: airSpeed
                                                                               distance: nil ];
        if ( ! adjusted )
            return nil;
        [ results setOffset: [ adjusted correction ] speed: [ adjusted groundSpeed ] forDirection: angle ];
    }

    return results;
}

@end
