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

#import "WindAdjustedPlanDetails.h"
#import "TextFormatter.h"

@implementation WindAdjustedPlanDetails

@synthesize heading;
@synthesize correction;
@synthesize groundSpeed;
@synthesize flightTime;
@synthesize error;

- ( id ) initWithHeading: ( int ) theHeading correction: ( int ) theCorrection groundSpeed: ( int ) theGroundSpeed flightTime: ( NSDecimalNumber * ) theFlightTime
{
    if ( self = [ super init ] )
    {
        heading = theHeading;
        correction = theCorrection;
        groundSpeed = theGroundSpeed;
        flightTime = [ theFlightTime copy ];
        error = nil;
    }
    return self;
}

- ( id ) initWithError: ( NSString * ) theError
{
    if ( self = [ super init ] )
    {
        error = [ theError retain ];
    }
    return self;
}

- ( void ) dealloc
{
    [ flightTime release ];
    [ error release ];
    [ super dealloc ];
}

- ( NSString * ) description
{
    if ( [ self isValid ] )
        return [ NSString stringWithFormat: @"WindAdjustedPlanDetails[ heading: %@, correction: %i, ground speed: %i, time: %@ ]",
                                            [ [ TextFormatter defaultFormatter ] formatDirection: heading ],
                                            correction,
                                            groundSpeed,
                                            [ [ TextFormatter defaultFormatter ] formatDecimalNumber: flightTime ] ];
    else
        return [ NSString stringWithFormat: @"WindAdjustedPlanDetails[ error: %@ ]", error ];
}

- ( BOOL ) isValid
{
    return error == nil;
}

@end
