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

#import "NavigationPlanDetails.h"
#import "WindDetails.h"

@interface Configuration : NSObject <NSCoding, NSCopying>
{
    // Configuration for "Wind" tab
    int windDirection;
    int windSpeed;
    
    // Configuration for "Navigation" tab
    int track;
    int targetSpeed;
    NSDecimalNumber * distance;

    // Configuration for "More" tab
    float maximumWindMagnitude;
}

@property float maximumWindMagnitude;
@property int windDirection;
@property int windSpeed;
@property int track;
@property int targetSpeed;
@property ( copy ) NSDecimalNumber * distance;

+ ( id ) defaultConfiguration;
+ ( id ) initialiseDefaultConfigurationFromFile: ( NSString * ) path;

- ( void ) saveToArchive: ( NSString * ) path;

- ( void ) setFromWindDetails: ( WindDetails * ) details;
- ( WindDetails * ) getAsWindDetails;

- ( void ) setFromNavigationPlanDetails: ( NavigationPlanDetails * ) details;
- ( NavigationPlanDetails * ) getAsNavigationPlanDetails;

@end
