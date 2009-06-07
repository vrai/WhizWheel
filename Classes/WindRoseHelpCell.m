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

#import "WindRoseHelpCell.h"

@implementation WindRoseHelpCell

@synthesize contentLabel;

- ( void ) dealloc
{
    [ contentLabel release ];
    [ super dealloc ];
}

- ( id ) initWithFrame: ( CGRect ) frame reuseIdentifier: ( NSString * ) reuseIdentifier fontSize: ( CGFloat ) fontSize
{
    if ( self = [ super initWithFrame: frame reuseIdentifier: reuseIdentifier ] )
    {
        // Create the colours we'll use on the label
        UIColor * textColour = [ UIColor darkGrayColor ];
        UIColor * backgroundColour = [ UIColor colorWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.0f ];
        
        // Create the label, add it to the view and then release the local reference (the view will keep hold of one)
        contentLabel = [ self newLabelWithPrimaryColour: textColour selectedColour: textColour backgroundColour: backgroundColour fontSize: fontSize bold: NO textAlignment: UITextAlignmentCenter ];
        [ [ self contentView ] addSubview: contentLabel ];
        [ contentLabel release ];
    }
    return self;
}

- ( void ) setSelected: ( BOOL ) selected animated: ( BOOL ) animated
{
    // Don't allow selection
   [ super setSelected: NO animated: NO ];
}

- ( void ) layoutSubviews
{
    [ super layoutSubviews ];
    
    // Set the content label's frame: the same as the bounding view's but shorter.
    const CGRect viewBounds = [ [ self contentView ] bounds ];
    CGRect contentFrame = CGRectMake ( viewBounds.origin.x, viewBounds.origin.y, viewBounds.size.width, 20 );
    [ contentLabel setFrame: contentFrame ];
}

#pragma mark -
#pragma mark Data setters

- ( void ) setHelpText: ( NSString * ) text
{
    [ contentLabel setText: text ];
}

@end
