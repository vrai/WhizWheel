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

@class NavigationPlanDetails;
@class WindAdjustedPlanDetails;
@class DecimalNumberTextFieldDelegate;
@class DirectionTextFieldDelegate;
@class NaturalNumberTextFieldDelegate;

@interface NavigationViewController : UIViewController
{
    IBOutlet UITextField * trackTextField;
    IBOutlet UITextField * distanceTextField;
    IBOutlet UITextField * tasTextField;
    
    IBOutlet UILabel * headingLabel;
    IBOutlet UILabel * groundSpeedLabel;
    IBOutlet UILabel * windCorrectionLabel;
    
    IBOutlet UILabel * flightTimeLabel;
    
    NavigationPlanDetails * navigationPlanDetails;
    WindAdjustedPlanDetails * navigationPlanResults;
    
    DirectionTextFieldDelegate * trackTextFieldDelegate;
    NaturalNumberTextFieldDelegate * tasTextFieldDelegate;
    DecimalNumberTextFieldDelegate * distanceTextFieldDelegate;
}

@property ( nonatomic, retain ) UITextField * trackTextField;
@property ( nonatomic, retain ) UITextField * distanceTextField;
@property ( nonatomic, retain ) UITextField * tasTextField;
@property ( nonatomic, retain ) UILabel * headingLabel;
@property ( nonatomic, retain ) UILabel * groundSpeedLabel;
@property ( nonatomic, retain ) UILabel * windCorrectionLabel;
@property ( nonatomic, retain ) UILabel * flightTimeLabel;
@property ( nonatomic, retain ) NavigationPlanDetails * navigationPlanDetails;
@property ( nonatomic, retain ) WindAdjustedPlanDetails * navigationPlanResults;

- ( void ) setNavigationTrack: ( NSString * ) track;
- ( void ) setNavigationDistance: ( NSString * ) distance;
- ( void ) setNavigationTAS: ( NSString * ) tas;

@end
