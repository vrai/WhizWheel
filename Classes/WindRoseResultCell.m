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

#import "WindRoseResultCell.h"
#import "TextFormatter.h"

#pragma mark -

@implementation WindRoseResultCell

@synthesize directionLabel;
@synthesize offsetLabel;
@synthesize speedLabel;
@synthesize splitterLabel;

- ( id ) initWithFrame: ( CGRect ) frame reuseIdentifier: ( NSString * ) reuseIdentifier fontSize: ( CGFloat ) fontSize
{
    if ( self = [ super initWithFrame: frame reuseIdentifier: reuseIdentifier ] )
    {
        // Create the colours we'll use on the labels
        UIColor * textColour = [ UIColor blackColor ];
        UIColor * backgroundColour = [ UIColor colorWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.0f ];
    
        // Create the labels
        directionLabel = [ self newLabelWithPrimaryColour: textColour selectedColour: textColour backgroundColour: backgroundColour fontSize: fontSize bold: YES textAlignment: UITextAlignmentCenter ];
        offsetLabel = [ self newLabelWithPrimaryColour: textColour selectedColour: textColour backgroundColour: backgroundColour fontSize: fontSize bold: NO textAlignment: UITextAlignmentRight ];
        speedLabel = [ self newLabelWithPrimaryColour: textColour selectedColour: textColour backgroundColour: backgroundColour fontSize: fontSize bold: NO textAlignment: UITextAlignmentLeft ];
        splitterLabel = [ self newLabelWithPrimaryColour: textColour selectedColour: textColour backgroundColour: backgroundColour fontSize: fontSize bold: YES textAlignment: UITextAlignmentCenter ];
        
        // Add the labels to the view
        UIView * contentView = [ self contentView ];
        [ contentView addSubview: directionLabel ];
        [ contentView addSubview: offsetLabel ];
        [ contentView addSubview: speedLabel ];
        [ contentView addSubview: splitterLabel ];
        
        // Release the local references to the labels (the content view will hold one and stop them being destroyed)
        [ directionLabel release ];
        [ offsetLabel release ];
        [ speedLabel release ];
        [ splitterLabel release ];
        
        // The splitter always defaults to same value
        [ splitterLabel setText: @"/" ];
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
    
    // Get the left origin
    const CGRect contentRect = [ [ self contentView ] bounds ];    
    const CGFloat boundsX = contentRect.origin.x;
    const CGFloat boundsY = contentRect.origin.y;
    
    // This isn't hard coded as there's no real restriction on its value (rather than being a speed or direction)
    const CGSize splitterLabelSize = [ [ splitterLabel text ] sizeWithFont: [ splitterLabel font ] ];
    
    // Construct the label frames
    CGRect directionFrame = CGRectMake ( boundsX, boundsY + 4, 40, 20 );
    CGRect offsetFrame = CGRectMake ( directionFrame.origin.x + directionFrame.size.width + 10, directionFrame.origin.y, 40, 20 );
    CGRect splitterFrame = CGRectMake ( offsetFrame.origin.x + offsetFrame.size.width + 4, directionFrame.origin.y, splitterLabelSize.width, 20 );
    CGRect speedFrame = CGRectMake ( splitterFrame.origin.x + splitterFrame.size.width + 4, directionFrame.origin.y, 40, 20 );
    
    // Center the frames
    const CGFloat labelsWidth = speedFrame.origin.x + speedFrame.size.width - boundsX;
    const CGFloat labelsIndent = contentRect.size.width / 2.0f - labelsWidth / 2.0f;
    
    directionFrame.origin.x += labelsIndent;
    offsetFrame.origin.x += labelsIndent;
    splitterFrame.origin.x += labelsIndent;
    speedFrame.origin.x += labelsIndent;
    
    // Apply the frames
    [ directionLabel setFrame: directionFrame ];
    [ offsetLabel setFrame: offsetFrame ];
    [ splitterLabel setFrame: splitterFrame ];
    [ speedLabel setFrame: speedFrame ];
}

- ( void ) dealloc
{
    [ directionLabel release ];
    [ offsetLabel release ];
    [ speedLabel release ];
    [ splitterLabel release ];
    [ super dealloc ];
}

#pragma mark -
#pragma mark Data setter

- ( void ) setDirection: ( int ) direction offset: ( int ) offset speed: ( int ) speed
{
    [ directionLabel setText: [ [ TextFormatter defaultFormatter ] formatDirection: direction ] ];
    [ offsetLabel setText: [ [ TextFormatter defaultFormatter ] formatSignedInteger: offset ] ];
    [ speedLabel setText: [ [ TextFormatter defaultFormatter ] formatNaturalNumber: speed ] ];
}

@end
