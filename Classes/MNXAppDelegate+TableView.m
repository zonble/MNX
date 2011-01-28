#import "MNXAppDelegate.h"
#import "NSLocale+MNXExtension.h"
#import "NSString+Extension.h"

@implementation MNXAppDelegate(TableView)

#pragma mark -
#pragma mark NSTableViewDataSource and NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)inTableView
{
	if (inTableView == tracksTableView) {
		return [dataManager.tracks count];
	}
	else if (inTableView == pointsTableView) {
		return [currentTrack.points count];
	}
	else if (inTableView == paceTableView) {
		if ([NSLocale usingUSMeasurementUnit]) {
			return [currentTrack.splitMile count];
		}
		return [currentTrack.splitKM count];
	}	
	return 0;
}
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (aTableView == tracksTableView) {
	}
	else if (aTableView == pointsTableView) {
		[aCell setFont:[NSFont systemFontOfSize:10.0]];
	}
	else if (aTableView == paceTableView) {
		[aCell setFont:[NSFont systemFontOfSize:10.0]];
	}
	
}
- (id)tableView:(NSTableView *)inTableView objectValueForTableColumn:(NSTableColumn *)inTableColumn row:(NSInteger)inRow
{
	if (inTableView == tracksTableView) {
		MNXTrack *track = [dataManager.tracks objectAtIndex:inRow];
		NSString *title = [track title];
		return title;
	}
	else if (inTableView == pointsTableView) {
		NSString *ci = [inTableColumn identifier];
		MNXPoint *point = [currentTrack.points objectAtIndex:inRow];
		if ([ci isEqualToString:@"date"]) {
			return [dateFormatter stringFromDate:point.date];
		}
		if ([ci isEqualToString:@"longitude"]) {
			return [NSString stringWithFormat:@"%.4f", point.longitude];
		}
		if ([ci isEqualToString:@"latitude"]) {
			return [NSString stringWithFormat:@"%.4f", point.latitude];
		}
		if ([ci isEqualToString:@"speed"]) {
			return [NSNumber numberWithFloat:point.speed];
		}
		if ([ci isEqualToString:@"elevation"]) {
			return [NSNumber numberWithFloat:point.elevation];
		}
	}
	else if (inTableView == paceTableView) {
		NSString *ci = [inTableColumn identifier];
		NSDictionary *split = nil;
		if ([NSLocale usingUSMeasurementUnit]) {
			split = [currentTrack.splitMile objectAtIndex:inRow];
		}
		else {
			split= [currentTrack.splitKM objectAtIndex:inRow];
		}
	
		if ([ci isEqualToString:@"unit"]) {
			return [split objectForKey:@"distance"];
		}		
		if ([ci isEqualToString:@"pace"]) {
			return NSStringFromNSTimeInterval([[split objectForKey:@"pace"] doubleValue]);
		}		
		
	}
	return nil;
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSTableView *inTableView = [aNotification object];
	if (inTableView == tracksTableView) {
		NSInteger selectedRow = [inTableView selectedRow];
		if (selectedRow < 0) {
			self.currentTrack = nil;
			[self refresh];
			[[webView mainFrame] loadHTMLString:@"" baseURL:nil];
		}
		else {		
			MNXTrack *aTrack = [dataManager.tracks objectAtIndex:selectedRow];
			self.currentTrack = aTrack;
			[self refresh];
			if ([self.currentTrack.points count]) {
				[pointsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
				[pointsTableView scrollRowToVisible:0];
			}
			[[webView mainFrame] loadHTMLString:[self.currentTrack HTML] baseURL:nil];
		}
	}
}

@end