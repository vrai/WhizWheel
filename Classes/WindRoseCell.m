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

#import "WindRoseCell.h"

@implementation WindRoseCell

- ( void ) dealloc
{
    [ super dealloc ];
}

- ( id ) initWithFrame: ( CGRect ) frame reuseIdentifier: ( NSString * ) reuseIdentifier
{
    return [ super initWithFrame:frame reuseIdentifier:reuseIdentifier ];
}

- ( id ) initWithFrame: ( CGRect ) frame reuseIdentifier: ( NSString * ) reuseIdentifier fontSize: ( CGFloat ) fontSize
{
    return [ super initWithFrame:frame reuseIdentifier:reuseIdentifier ];
}

#pragma mark -
#pragma mark UI utility methods

- ( UILabel * ) newLabelWithPrimaryColour: ( UIColor * ) primaryColour
                           selectedColour: ( UIColor * ) selectedColour
                         backgroundColour: ( UIColor * ) backgroundColour
                                 fontSize: ( CGFloat ) fontSize
                                     bold: ( BOOL ) bold
                            textAlignment: ( UITextAlignment ) alignment
{
    UIFont * font = bold ? [ UIFont boldSystemFontOfSize: fontSize ]
                         : [ UIFont systemFontOfSize: fontSize ];
                         
    UILabel * label = [ [ UILabel alloc ] initWithFrame: CGRectZero ];
    [ label setBackgroundColor: backgroundColour ];
    [ label setOpaque: YES ];
    [ label setTextColor: primaryColour ];
    [ label setHighlightedTextColor: selectedColour ];
    [ label setFont: font ];
    [ label setTextAlignment: alignment ];
    return label;
}

@end
