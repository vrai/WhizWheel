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

#import "WebTableSectionDelegate.h"
#import "TextFormatter.h"

@interface WebTableWebViewDelegate : NSObject <UIWebViewDelegate>
@end

@implementation WebTableWebViewDelegate

- ( BOOL ) webView: ( UIWebView * ) webView shouldStartLoadWithRequest: ( NSURLRequest * ) request navigationType: ( UIWebViewNavigationType ) navigationType
{
    // Only allow "other" navigation requests through - this allows the page to be loaded on startup but nothing else
    // can change the content. Standard "click" requests are passed on to Safari.
    switch ( navigationType )
    {
        case UIWebViewNavigationTypeOther:
            return YES;
            
        case UIWebViewNavigationTypeLinkClicked:
            [ [ UIApplication sharedApplication ] openURL: [ request URL ] ];
            return NO;
            
        default:
            return NO;
    }
}

@end

#pragma mark -

@implementation WebTableSectionDelegate

@synthesize name;
@synthesize content;
@synthesize height;

- ( void ) dealloc
{
    [ name release ];
    [ content release ];
    [ cellDelegate release ];
    [ super dealloc ];
}

- ( id ) initWithName: ( NSString * ) theName content: ( NSString * ) theContent height: (NSUInteger ) theHeight
{
    if ( self = [ super init ] )
    {
        [ self setName: theName ];
        [ self setContent: theContent ];
        [ self setHeight: theHeight ];
        cellDelegate = [ [ WebTableWebViewDelegate alloc ] init ];
    }
    return self;
}

+ ( id ) delegateWithName: ( NSString * ) name content: ( NSString * ) content height: (NSUInteger ) height
{
    return [ [ [ WebTableSectionDelegate alloc ] initWithName: name
                                                      content: content
                                                       height: height ] autorelease ];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- ( UITableViewCell * ) tableView: ( UITableView * ) tableView cellForRowAtIndexPath: ( NSIndexPath * ) indexPath
{   
    // Create (or re-use) a single cell containing a UIWebView
    NSString * cellIdentifier = [ NSString stringWithFormat: @"WebTableSectionDelegate Cell %@", indexPath ];
    UITableViewCell * cell = [ tableView dequeueReusableCellWithIdentifier: cellIdentifier ];
    if ( ! cell )
    {
        // Create and configure the cell
        cell = [ [ [ UITableViewCell alloc ] initWithFrame: CGRectZero 
                                           reuseIdentifier: cellIdentifier ] autorelease ];
        [ cell setSelectionStyle: UITableViewCellSelectionStyleNone ];
   
        // Create the web view - the frame is a horrible hack that should keep it 10 pixels from all edges of the cell -
        // and add it to the cell.
        UIWebView * webView = [ [ UIWebView alloc ] initWithFrame: CGRectMake ( 10.0,
                                                                                10.0,
                                                                                [ cell frame ].size.width - 40.0,
                                                                                [ self tableView: tableView heightForRowAtIndexPath: indexPath ] - 20.0 ) ];
        [ [ cell contentView ] addSubview: webView ];
        
        // Wire the web view up to its delegate and then set the HTML content. As the view is already added to the cell
        // we can safely release the local reference.
        [ webView setDelegate: cellDelegate ];
        [ webView loadHTMLString: [ [ TextFormatter defaultFormatter ] formatHTMLString: content ] baseURL: nil ];
        [ webView release ];
    }
        
    return cell;
}

- ( NSInteger ) tableView: ( UITableView * ) tableView numberOfRowsInSection: ( NSInteger ) section
{
    return 1;
}

- ( NSString * ) tableView: ( UITableView * ) tableView titleForHeaderInSection: ( NSInteger ) section
{
    return name;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

-  ( CGFloat ) tableView: ( UITableView * ) tableView heightForRowAtIndexPath: ( NSIndexPath * )indexPath
{
    return height;
}

@end
