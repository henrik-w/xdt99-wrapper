//
//  SourceCodeDocument.m
//  SimpleXDT99
//
//  Created by Henrik Wedekind on 02.12.16.
//
//  SimpleXDT99IDE a simple IDE based on xdt99 that shows how to use the XDTools99.framework
//  Copyright © 2016 Henrik Wedekind (aka hackmac). All rights reserved.
//
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as
//  published by the Free Software Foundation; either version 2.1 of the
//  License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with this program; if not, see <http://www.gnu.org/licenses/>
//

#import "SourceCodeDocument.h"

#import "AppDelegate.h"



@interface SourceCodeDocument ()

- (IBAction)generateCode:(nullable id)sender;
- (IBAction)selectOutputFile:(nullable id)sender;
- (IBAction)hideShowLog:(nullable id)sender;

- (IBAction)saveLog:(id)sender;

@end


@implementation SourceCodeDocument

+ (NSSet *)keyPathsForValuesAffectingErrorMessage
{
    return [NSSet setWithObjects:@"shouldShowErrorsInLog", @"shouldShowLog", nil];
}


- (instancetype)init {
    self = [super init];
    if (nil == self) {
        return nil;
    }

    _outputBasePathURL = nil;
    _outputFileName = nil;
    _errorMessage = nil;

    return self;
}


- (void)dealloc
{
#if !__has_feature(objc_arc)
    [_outputBasePathURL release];
    [_outputFileName release];
    [_errorMessage release];
    
    [super dealloc];
#endif
}


+ (BOOL)autosavesInPlace {
    return YES;
}


- (NSString *)windowNibName {
    return @"Document";
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];

    NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
    [self setShouldShowLog:[defaults boolForKey:UserDefaultKeyDocumentOptionShowLog]];
    [self setShouldShowErrorsInLog:[defaults boolForKey:UserDefaultKeyDocumentOptionShowErrorsInLog]];
}


- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
    /* Save the latest common source code document options to user defaults before closing. */
    NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
    [defaults setBool:_shouldShowLog forKey:UserDefaultKeyDocumentOptionShowLog];
    [defaults setBool:_shouldShowErrorsInLog forKey:UserDefaultKeyDocumentOptionShowErrorsInLog];

    [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}


/* This method should be overridden from specialized class */
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}


/* This method should be overridden from specialized class */
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return NO;
}


/*
 Interesting delegate protocols are NSTextDelegate or its sub protocol NSTextViewDelegate i.e. for
 - grammar and spell checking for assembler nmemonics
 - displaying location (row, column) in source code in a status bar
 - assembling on the fly

 See hints at:
 - http://stackoverflow.com/questions/40672218/nsrulerview-how-to-correctly-align-line-numbers-with-main-text
 - http://stackoverflow.com/questions/15545857/nstextview-keydown-event#15546489
 */


#pragma mark - Accessor Methods


+ (NSSet *)keyPathsForValuesAffectingGeneratedLogMessage
{
    return [NSSet setWithObjects:@"shouldShowErrorsInLog", @"shouldShowLog", @"errorMessage", nil];
}


- (NSString *)generatedLogMessage
{
    /* This method should be overridden to implement the document typical log output */
    return @"";
}


+ (NSSet *)keyPathsForValuesAffectingHasLogContentToSave
{
    return [NSSet setWithObject:@"logView.string"];
}


- (BOOL)hasLogContentToSave
{
    return (nil != _logView) && ([[_logView string] length] > 0);
}


+ (NSSet *)keyPathsForValuesAffectingStatusImage
{
    return [NSSet setWithObjects:@"errorMessage", nil];
}


- (NSImage *)statusImage
{
    return [NSImage imageNamed:(nil == _errorMessage || [_errorMessage length] <= 0)? NSImageNameStatusAvailable : NSImageNameStatusUnavailable];
}


#pragma mark - Action Methods


- (void)checkCode:(id)sender
{
    /* This method should be overridden to implement the document typical code generator */
}


- (void)generateCode:(id)sender
{
    /* This method should be overridden to implement the document typical code generator */
}


- (void)hideShowLog:(id)sender
{
    [self setShouldShowLog:[sender state] == NSOnState];
}


- (void)selectOutputFile:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setCanCreateDirectories:YES];
    [panel setTitle:@"Select output file name"];
    [panel setDirectoryURL:[self outputBasePathURL]];
    [panel setNameFieldStringValue:[self outputFileName]];

    [panel beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
        if (NSFileHandlingPanelOKButton == result) {
            [self setOutputFileName:[[panel URL] lastPathComponent]];
            [self setOutputBasePathURL:[[panel URL] URLByDeletingLastPathComponent]];
        }
    }];
}


- (void)saveLog:(id)sender
{
    if (nil == _logView) {
        return;
    }

    NSData *logData = [[_logView string] dataUsingEncoding:NSUTF8StringEncoding];
    if (nil != logData && 0 < [logData length]) {
        /* TODO: Use a NSSavePanel to interact with user for getting the correct URL */
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        NSString *logFileName = [NSString stringWithFormat:@"Listing from %@, %@.txt", [[self fileURL] lastPathComponent], [dateString stringByReplacingOccurrencesOfString:@":" withString:@"-"]];
        NSURL *listingFileURL = [NSURL fileURLWithPath:logFileName relativeToURL:[self outputBasePathURL]];
        [logData writeToURL:listingFileURL atomically:YES];
    }
}

@end