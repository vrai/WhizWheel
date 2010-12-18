// ***************************************************************************
//           WhizWheel 1.0.2 - Copyright Vrai Stacey 2009, 2010
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

#import "CompassSelectorView.h"
#import "AngleUtils.h"
#import "NotificationNames.h"
#import "ScalerUtils.h"
#import "TextFormatter.h"
#import "WindDetails.h"

// Missing prototype - thanks Apple! Retrieves the font current in use by the
// context.
extern CGFontRef CGContextGetFont ( CGContextRef );

#pragma mark Quartz utility methods

void drawCircle ( CGContextRef context, CGPoint centre, CGFloat radius, UIColor *  fill, UIColor * stroke, CGFloat width, int mode )
{
    CGContextSetLineWidth ( context, width );
    CGContextSetStrokeColorWithColor ( context, [ stroke CGColor ] );
    CGContextSetFillColorWithColor ( context, [ fill CGColor ] );
    
    CGContextMoveToPoint ( context, centre.x + radius, centre.y );
    CGContextAddArc ( context, centre.x, centre.y, radius, 0, 2 * M_PI, 1 );
    
    CGContextDrawPath ( context, mode );
}

void drawLine ( CGContextRef context, CGPoint start, CGPoint end, UIColor * stroke, CGFloat width, int cap )
{
    CGContextSetLineWidth ( context, width );
    CGContextSetLineCap ( context, cap );
    CGContextSetStrokeColorWithColor ( context, [ stroke CGColor ] );
    
    CGContextMoveToPoint ( context, start.x, start.y );
    CGContextAddLineToPoint ( context, end.x, end.y );
    
    CGContextDrawPath ( context, kCGPathStroke );
}

#pragma mark -

@interface CompassSelectorView ( )
- ( float ) getTickScaleForAngle: ( int ) angle;
- ( CGFloat ) getTickWidthForAngle: ( int ) angle;
- ( CGFloat ) getRadius;
- ( CGPoint ) getCentrePoint;

- ( void ) drawCompassFaceToContext: ( CGContextRef ) context rect: ( CGRect ) rect;
- ( void ) drawCompassFaceMaskToContext: ( CGContextRef ) context rect: ( CGRect ) rect; 

- ( void ) handleTouchEvent: ( UIEvent * ) event;

- ( void ) handleWindDetailsNotification: ( NSNotification * ) notification;
@end

#pragma mark -

@implementation CompassSelectorView

@synthesize maximumMagnitude;

- ( void ) dealloc
{
    CGImageRelease ( compassFace );
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
    [ super dealloc ];
}

- ( id ) initWithCoder: ( NSCoder * ) decoder
{
    if ( self = [ super initWithCoder: decoder ] )
    {
        currentAngle = -1;
        currentMagnitude = -1.0f;
        [ self setMaximumMagnitude: 50.f ];
        
        // Make the view's background transparent
        [ self setBackgroundColor: [ UIColor colorWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.0f ] ];
        
        // Subscribe the compass view to the wind details notifications
        [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                    selector: @selector ( handleWindDetailsNotification: )
                                                        name: WindDetailsPublished
                                                       object: nil ];
        [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                    selector: @selector ( handleWindDetailsNotification: )
                                                        name: WindDetailsInternalPublished
                                                      object: nil ];
        
        // Get the screen scale - the number of pixels per point
        screenScale = [ [ UIScreen mainScreen ] scale ];
    }
    
    return self;
}

- ( void ) drawRect: ( CGRect ) rect
{   
    [ super drawRect: rect ];

    const float radius = [ self getRadius ];    
    const CGPoint centrePoint = [ self getCentrePoint ];

    CGContextRef context = UIGraphicsGetCurrentContext ( );
    
    // If this is the first call to drawRect, render the compass face to an image buffer
    if ( compassFace == nil )
    {    
        // Both the compass face and its mask will be drawn to this bitmap - it's the same size, colour space and depth as the view
        CGContextRef bitmapContext = CGBitmapContextCreate ( 0,
                                                            [ self bounds ].size.width * screenScale,
                                                            [ self bounds ].size.height * screenScale,
                                                            CGBitmapContextGetBitsPerComponent ( context ),
                                                            CGBitmapContextGetBytesPerRow ( context ),
                                                            CGBitmapContextGetColorSpace ( context ),
                                                            CGBitmapContextGetBitmapInfo ( context ) );
                                                            
        // Draw the mask to the bitmap, then use the bitmap to construct an image (still in the view's colour space). This image can
        // then be used to create *another* image in the correct colour space for use as the mask. The temporary image can be deleted.
        [ self drawCompassFaceMaskToContext: bitmapContext rect: rect ];
        CGImageRef maskImageSource = CGBitmapContextCreateImage ( bitmapContext );
        CGImageRef maskImage = CGImageMaskCreate ( CGImageGetWidth ( maskImageSource ),
                                                   CGImageGetHeight ( maskImageSource ),
                                                   CGImageGetBitsPerComponent ( maskImageSource ),
                                                   CGImageGetBitsPerPixel ( maskImageSource ),
                                                   CGImageGetBytesPerRow ( maskImageSource ),
                                                   CGImageGetDataProvider ( maskImageSource),
                                                   NULL,
                                                   YES );
        CGImageRelease ( maskImageSource );

        // The mask has been created, now draw the compass face proper to the bitmap and use it to construct an image 
        [ self drawCompassFaceToContext: bitmapContext rect: rect ];
        CGImageRef mainImage = CGBitmapContextCreateImage ( bitmapContext );

        // The main image can now be combined with the mask image to create the final, correctly transparent, compass face image.
        compassFace = CGImageCreateWithMask ( mainImage, maskImage );

        
        // Only the final image is required, the bitmap and the two intermediate images can be released.
        CGContextRelease ( bitmapContext );
        CGImageRelease ( mainImage );
        CGImageRelease ( maskImage );
    }
    
    // Copy in the compass face from the previously rendered image buffer
    CGContextDrawImage ( context, rect, compassFace);
    
    // Render with shadows
    CGContextSetShadow ( context, CGSizeMake ( -2.0f, -2.0f ), 3.0 );
    
    // Draw the pointer (if it's not trivally small)
    if ( currentMagnitude >= 0.0f && currentMagnitude < 0.99f && currentAngle >= 0 && currentAngle < 360 )
    {
        // The base of the pointer is perpendicular to the pointer axis, as such 90 degrees in radians is going to be used a lot
        const static double HALF_PI = M_PI / 2.0;
        
        const CGFloat outerDeviation = ( ( 1.0f - currentMagnitude ) * M_PI / 16.0 ),    // By how much the pointer base deviates from the centre line
                      pointerLength = radius * currentMagnitude,                         // The length of the pointer centre line
                      angleInRadians = degreesToRadians ( currentAngle );                // The angle of the pointer, in usable units
        
        // Setup the pointer drawing style
        UIColor * pointerColour = [ UIColor colorWithRed: 0.75f green: 0.0f blue: 0.0f alpha: 0.75f ];
        CGContextSetLineWidth ( context, 1.0f );
        CGContextSetFillColorWithColor ( context, [ pointerColour CGColor ] );
        
        // Calculate the pointer point
        CGPoint pointerPoint = CGPointMake ( sin ( angleInRadians ) * pointerLength + centrePoint.x,
                                             cos ( angleInRadians ) * -pointerLength + centrePoint.y );
        
        // Draw the pointer
        CGContextMoveToPoint ( context, pointerPoint.x, pointerPoint.y );
        CGContextAddArc ( context,
                          centrePoint.x,
                          centrePoint.y,
                          radius,
                          angleInRadians - HALF_PI - outerDeviation,    // The HALF_PI offset is because the arc functions operates with the
                          angleInRadians - HALF_PI + outerDeviation,    // x-axis as a base rather than the usual y-axis.
                          0 );

        CGContextClosePath ( context );        
        CGContextDrawPath ( context, kCGPathFillStroke );
        
        // Draw a centre line down the pointer once it gets reasonably large
        if ( currentMagnitude < 0.8f )
        {
            CGContextMoveToPoint ( context, pointerPoint.x, pointerPoint.y );
            CGContextAddLineToPoint ( context,
                                      sin ( angleInRadians ) * radius + centrePoint.x,
                                      cos ( angleInRadians ) * -radius + centrePoint.y );
            CGContextDrawPath ( context, kCGPathStroke );
        }
    }
}


- ( void ) setCurrentAngle: ( int ) angle magnitude: ( float ) magnitude
{
    // If there's no change - ignore it
    if ( currentAngle == angle && fabsf ( magnitude - currentMagnitude ) < 0.0001f )
        return;
        
    if ( magnitude < 0.0f )
        magnitude = -1.0f;
    else if ( magnitude > 1.0f )
        magnitude = 1.0f;
        
    currentAngle = angle % 360;
    currentMagnitude = magnitude;
        
    [ self setNeedsDisplay ];
}

- ( void ) setMaximumMagnitude: ( float ) newMaximumMagnitude
{
    // Ignore minute changes and stupid values
    if ( newMaximumMagnitude < 0.0001f || fabsf ( maximumMagnitude - newMaximumMagnitude ) < 0.1f )
        return;
        
    // Update the maximum value and request that the wind details be resent
    maximumMagnitude = newMaximumMagnitude;
    [ [ NSNotificationCenter defaultCenter ] postNotification: [ NSNotification notificationWithName: WindDetailsRepublishRequest
                                                                                              object: nil ] ];
}

#pragma mark -
#pragma mark Compass face rendering

- ( void ) drawCompassFaceToContext: ( CGContextRef ) context rect: ( CGRect ) rect;
{
    // Need to apply the points/pixel radio to the coords/radius
    const float radius = [ self getRadius ] * screenScale;
    const CGPoint centrePoint = scalePoint ( [ self getCentrePoint ], screenScale );
    rect = scaleRect ( rect, screenScale );

    // Render with shadows
    CGContextSetShadow ( context, CGSizeMake ( -2.0f, -2.0f ), 3.0 );

    // Clear the background
    CGContextSetFillColorWithColor ( context, [ [ UIColor whiteColor ] CGColor ] );
    CGContextFillRect ( context, rect );

    // Select the font for the labels and the font rendering mode
    UIFont * labelFont = [ UIFont fontWithName: @"Helvetica" size: 10.0f * screenScale ];
    CGContextSelectFont ( context, [ [ labelFont fontName ] UTF8String ], [ labelFont pointSize ], kCGEncodingMacRoman );
    CGContextSetTextDrawingMode ( context, kCGTextFill );
    
    // Draw the outer base of the compass
    drawCircle ( context, centrePoint, radius, [ UIColor whiteColor ], [ UIColor blackColor ], 2.0f, kCGPathFillStroke );
    
    // Draw the compass ticks and labels
    for ( int angle = 0; angle < 360; angle += 15 )
    {
        // Calculate the draw angle
        const double angleInRadians = degreesToRadians ( angle );
        
        const float xMove = cos ( angleInRadians ) * radius,
                    yMove = sin ( angleInRadians ) * radius;
                    
        const float tickScale = 1.0f - [ self getTickScaleForAngle: angle ];
    
        const CGPoint endPoint = CGPointMake ( centrePoint.x + xMove , centrePoint.y + yMove ),
                      startPoint = CGPointMake ( centrePoint.x + xMove * tickScale, centrePoint.y + yMove * tickScale );
                      
        // First - the tick
        drawLine ( context, startPoint, endPoint, [ UIColor blackColor ], [ self getTickWidthForAngle: angle ], kCGLineCapRound );
        
        // Second - the label, but only for primary and secondary compass points
        if ( angle % 45 == 0 )
        {            
            // The radian system starts horizontal (i.e. at 90 degrees) so the label has to be shifted anticlockwise by the same amount
            NSString * label = [ [ TextFormatter defaultFormatter ] formatDirection: angle >= 270 ? angle - 270 : angle + 90 ];
            
            CGContextSetFillColorWithColor ( context, [ [ UIColor blackColor ] CGColor ] );
            
            // The initial transformation rotates the text such that it will be perpendicular to the ticks 
            CGAffineTransform transform = CGAffineTransformMake ( 1.0, 0.0, 0.0, -1.0, 0.0, 0.0 ); 
            transform = CGAffineTransformConcat ( transform, CGAffineTransformMakeRotation ( degreesToRadians ( 90 ) ) );
            
            // Now translate the label - the horizontal offset moves it out to the correct distance from the compass' centre
            // while the vertical offset (of half the text's width) centres the label. This is then rotated in to position.
            CGAffineTransform positionalRotateTransform = CGAffineTransformMakeRotation ( degreesToRadians ( angle ) );
            positionalRotateTransform = CGAffineTransformTranslate ( positionalRotateTransform,
                                                                     radius * 0.7f,
                                                                     -( [ label sizeWithFont: labelFont ].width / 2.0f ) );    
            transform = CGAffineTransformConcat ( transform, positionalRotateTransform );
            
            // All of the previous translations/rotations have been about the origin - this final transformation moves the
            // origin to the centre of the compass.
            transform = CGAffineTransformConcat ( transform, CGAffineTransformMakeTranslation ( centrePoint.x, centrePoint.y ) );   
            
            CGContextSetTextMatrix ( context, transform );
            CGContextShowText ( context, [ label UTF8String ], [ label length ] );
        }
    }
        
    // Draw the compass central hub
    drawCircle ( context, centrePoint, radius * 0.025, [ UIColor blackColor ], [ UIColor blackColor ], 2.0f, kCGPathFillStroke );
}

- ( void ) drawCompassFaceMaskToContext: ( CGContextRef ) context rect: ( CGRect ) rect
{
    rect = scaleRect ( rect, screenScale );

    // Render with shadows
    CGContextSetShadow ( context, CGSizeMake ( -2.0f, -2.0f ), 3.0 );

    // Clear the background - it must be white to allow the background to show through whatever this masks
    CGContextSetFillColorWithColor ( context, [ [ UIColor whiteColor ] CGColor ] );
    CGContextFillRect ( context, rect );

    // Draw the outer base of the compass - as this is the mask it's all black
    drawCircle ( context,
                 scalePoint ( [ self getCentrePoint ], screenScale ),
                 [ self getRadius ] * screenScale,
                 [ UIColor blackColor ],
                 [ UIColor blackColor ],
                 2.0f,
                 kCGPathFillStroke );
}

#pragma mark -
#pragma mark Compass drawing format methods

- ( float ) getTickScaleForAngle: ( int ) angle
{
    return angle % 45 == 0 ? 0.2f : 0.1f;
}

- ( CGFloat ) getTickWidthForAngle: ( int ) angle
{
    return angle % 45 == 0 ? 2.0f : 1.0f;
}

- ( CGFloat ) getRadius
{
    const float width = [ self bounds ].size.width,
               height = [ self bounds ].size.height;
    return ( width < height ? width : height ) * 0.45;
}

- ( CGPoint ) getCentrePoint
{
    return CGPointMake ( [ self bounds ].size.width / 2.0f,  [ self bounds ].size.height / 2.0f );
}

#pragma mark -
#pragma mark Touch handling logic

- ( void ) handleTouchEvent: ( UIEvent * ) event
{
    // Multi-touch shouldn't be enabled so we can just grab the touch instance and use that
    UITouch * touch = [ [ event touchesForView: self ] anyObject ];
    if ( ! touch )
        return;
    CGPoint point = [ touch locationInView: self ];

    // Convert the point from "compass" space to a standard ( 0, 0 ) coordinates system
    const CGPoint centrePoint = [ self getCentrePoint ];
    point.x -= centrePoint.x;
    point.y -= centrePoint.y;
    
    // Calculate the distance from the centre and use that to generate the "scaling factor". When applied to the point
    // this will rescale the vector ( 0, 0 ) -> ( point.x, point.y ) such that it has a magnitude of 1.0.
    // The exact centre of the compass is treated as a dead zone to avoid subsequent divide-by-zero errors.
    CGFloat magnitude = sqrtf ( powf ( point.x, 2.0f ) + powf ( point.y, 2.0f ) );
    if ( fabsf ( magnitude ) < 0.0001f )
        return;
    const CGFloat scalingFactor = 1.0f / magnitude;
    
    point.x *= scalingFactor;
    point.y *= scalingFactor;
    
    // Calculate the angle between the point vector and the vector ( 0, 0 ) -> ( 0, -1 ) - i.e. the y-axis.
    int angle = radiansToDegrees ( atan2 ( point.x, -point.y ) );
    if ( angle < 0 )
        angle += 360;
        
    // To normalize the magnitude - scale it such that the compass radius is considered a magnitude of 1.0.
    // Touches beyond the edge of the compass face are ignored.
    magnitude /= [ self getRadius ];
    if ( magnitude > 1.0f )
        return;
        
    // If the magnitude or angle has changed, update the member variables (which will trigger a display update) and send
    // a notification.
    if ( angle != currentAngle || fabsf ( magnitude - currentMagnitude ) > ( 1.0f / maximumMagnitude ) )
    {
        [ self setCurrentAngle: angle magnitude: magnitude ];
        
        WindDetails * windDetails = [ [ WindDetails alloc ] initWithDirection: currentAngle
                                                                        speed: ( 1.0f - currentMagnitude ) * maximumMagnitude ];
        [ [ NSNotificationCenter defaultCenter ] postNotification: [ NSNotification notificationWithName: WindDetailsInternalPublished
                                                                                                  object: windDetails ] ];
        [ windDetails release ];
    }
}

#pragma mark -
#pragma mark UIResponder methods

- ( void ) touchesBegan: ( NSSet * ) touches withEvent: ( UIEvent * ) event
{
    [ super touchesBegan: touches withEvent: event ];
    [ self handleTouchEvent: event ];
}

- ( void ) touchesMoved: ( NSSet * ) touches withEvent: ( UIEvent * ) event
{
    [ super touchesMoved: touches withEvent: event ];
    [ self handleTouchEvent: event ];
}

#pragma mark -
#pragma mark NSNotification handler methods

- ( void ) handleWindDetailsNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == WindDetailsPublished || [ notification name ] == WindDetailsInternalPublished )
    {
        WindDetails * windDetails = [ notification object ];
        int newAngle = [ windDetails direction ];
        float newMagnitude = [ windDetails speed ] < 0.0f ? -1.0f
                                                          : 1.0f - fmin ( [ windDetails speed ] / maximumMagnitude, 1.0f );
        
        // Only update the display if the angle or magnitude have changed
        if ( newAngle != currentAngle || fabsf ( newMagnitude - currentMagnitude ) > ( 1.0f / maximumMagnitude ) )
            [ self setCurrentAngle: newAngle magnitude: newMagnitude ];
    }
}

@end
