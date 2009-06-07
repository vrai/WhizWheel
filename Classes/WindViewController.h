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

@class CompassSelectorView;
@class WindDetails;
@class DirectionTextFieldDelegate;
@class NaturalNumberTextFieldDelegate;

@interface WindViewController : UIViewController
{
    IBOutlet UITextField * directionTextField;
    IBOutlet UITextField * speedTextField;
    IBOutlet CompassSelectorView * compassSelectorView;
    
    WindDetails * windDetails;
    BOOL windDetailsDirty;
    
    DirectionTextFieldDelegate * directionTextFieldDelegate;
    NaturalNumberTextFieldDelegate * speedTextFieldDelegate;
}

@property ( nonatomic, retain ) UITextField * directionTextField;
@property ( nonatomic, retain ) UITextField * speedTextField;
@property ( nonatomic, retain ) CompassSelectorView * compassSelectorView;
@property ( nonatomic, readonly ) WindDetails * windDetails;

- ( void ) setWindDirection: ( NSString * ) direction;
- ( void ) setWindSpeed: ( NSString * ) speed;

@end
