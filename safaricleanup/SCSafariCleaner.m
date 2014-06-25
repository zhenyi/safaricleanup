//
//  SCSafariCleaner.m
//  safaricleanup
//
//  Created by Zhenyi Tan on 31/10/13.
//  Copyright (c) 2013 And a Dinosaur. All rights reserved.
//

#import "SCSafariCleaner.h"

NSString * const SCSafariLibraryPath        = @"Library/Safari";
NSString * const SCHistoryIndexPath         = @"Library/Safari/HistoryIndex.sk";
NSString * const SCHistoryMetadataPath      = @"Library/Caches/Metadata/Safari/History";
NSString * const SCSearchDescriptionsPath   = @"Library/Safari/SearchDescriptions.plist";
NSString * const SCCachesPath               = @"Library/Caches/com.apple.Safari";
NSString * const SCCachedDataPath           = @"Library/Caches/com.apple.Safari/fsCachedData";
NSString * const SCServicesCachesPath       = @"Library/Caches/com.apple.SafariServices";
NSString * const SCWebpagePreviewsPath      = @"Library/Caches/com.apple.Safari/Webpage Previews";
NSString * const SCLocalStoragePath         = @"Library/Safari/LocalStorage";
NSString * const SCDatabasesPath            = @"Library/Safari/Databases";
NSString * const SCTopSitesPlistPath        = @"Library/Safari/TopSites.plist";

@interface SCSafariCleaner ()

@property (copy, nonatomic) NSArray *arguments;

@end

@implementation SCSafariCleaner

- (instancetype) init {
    if (self = [super init]) {
        self.arguments = [[NSProcessInfo processInfo] arguments];
    }
    return self;
}

#pragma mark - Options

- (BOOL) shouldShowHelp {
    return ([self.arguments containsObject:@"-h"] ||
            [self.arguments containsObject:@"--help"]);
}

- (BOOL) shouldClearHistory {
    return ([self.arguments containsObject:@"-s"] ||
            [self.arguments containsObject:@"--history"]);
}

- (BOOL) shouldClearCookies {
    return ([self.arguments containsObject:@"-k"] ||
            [self.arguments containsObject:@"-cookies"]);
}

- (BOOL) shouldClearSomeCookies {
    return ([self argumentWithPrefix:@"--only="] != nil);
}

- (BOOL) shouldClearMostCookies {
    return ([self argumentWithPrefix:@"--except="] != nil);
}

- (BOOL) shouldEmptyCache {
    return ([self.arguments containsObject:@"-c"] ||
            [self.arguments containsObject:@"--cache"]);
}

- (BOOL) shouldResetTopSites {
    return ([self.arguments containsObject:@"-t"] ||
            [self.arguments containsObject:@"--topsites"]);
}

- (NSString *) argumentWithPrefix:(NSString *)prefix {
    __block NSString *matchingArgument = nil;

    [self.arguments enumerateObjectsUsingBlock:^(NSString *argument, NSUInteger index, BOOL *stop) {
        if ([argument hasPrefix:prefix]) {
            matchingArgument = argument;
            *stop = YES;
        }
    }];

    return matchingArgument;
}

#pragma mark - Help

- (void) showHelp {
    ConsoleLog(@"Usage: safaricleanup [options]\n"
               "\n"
               "\n"
               "Options:\n"
               "-s, --history                     Clear history\n"
               "-k, --cookies [options]           Delete all cookies\n"
               "              --only=foo,bar      Only delete cookies that matches foo or bar\n"
               "              --except=foo,bar    Delete all cookies except those that matches\n"
               "                                  foo or bar\n"
               "-c, --cache                       Empty the cache\n"
               "-t, --topsites                    Reset Top Sites\n"
               "-h, --help                        Show this help message\n"
               "\n"
               "\n"
               "Examples:\n"
               "safaricleanup -s -k -c -t                  Clear history, cache and all\n"
               "                                           cookies, and reset Top Sites\n"
               "safaricleanup -c -k --except=github.com    Clear cache and all cookies except\n"
               "                                           the GitHub cookies\n"
               "\n");
}

#pragma mark - Clear stuff

- (void) clearHistory {
    [self deleteFilesInDirectoryAtPathFromHomeDirectory:SCSafariLibraryPath withPrefix:@"History.db"];
    [self deleteFileAtPathFromHomeDirectory:SCHistoryIndexPath];
    [self deleteFilesInDirectoryAtPathFromHomeDirectory:SCHistoryMetadataPath withPrefix:nil];
    [self deleteFileAtPathFromHomeDirectory:SCSearchDescriptionsPath];
}

- (void) emptyCache {
    [self deleteFilesInDirectoryAtPathFromHomeDirectory:SCCachesPath withPrefix:@"Cache.db"];
    [self deleteFilesInDirectoryAtPathFromHomeDirectory:SCCachedDataPath withPrefix:nil];
    [self deleteFilesInDirectoryAtPathFromHomeDirectory:SCServicesCachesPath withPrefix:nil];
    [self deleteFilesInDirectoryAtPathFromHomeDirectory:SCWebpagePreviewsPath withPrefix:nil];
    [self deleteFilesInDirectoryAtPathFromHomeDirectory:SCLocalStoragePath withPrefix:nil];
    [self deleteFilesInDirectoryAtPathFromHomeDirectory:SCDatabasesPath withPrefix:nil];
}

- (void) resetTopSites {
    [self deleteFileAtPathFromHomeDirectory:SCTopSitesPlistPath];
}

- (void) clearAllCookies {
    [self deleteCookiesThatMatchesRegularExpression:nil options:0];
}

- (void) clearSomeCookies {
    NSString *argument = [self argumentWithPrefix:@"--only="];
    [self deleteCookiesThatMatchesRegularExpression:[self regularExpressionFromArgument:argument]
                                            options:SCMatchingAny];
}

- (void) clearMostCookies {
    NSString *argument = [self argumentWithPrefix:@"--except="];
    [self deleteCookiesThatMatchesRegularExpression:[self regularExpressionFromArgument:argument]
                                            options:SCMatchingNone];
}

#pragma mark - Utility methods

- (void) deleteFileAtPathFromHomeDirectory:(NSString *)filePath {
    NSString *fullFilePath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error:nil];
}

- (void) deleteFilesInDirectoryAtPathFromHomeDirectory:(NSString *)directoryPath
                                            withPrefix:(NSString *)prefix {
    NSString *fullDirectoryPath = [NSHomeDirectory() stringByAppendingPathComponent:directoryPath];
    NSArray *filesInDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullDirectoryPath error:nil];

    [filesInDirectory enumerateObjectsUsingBlock:^(NSString *file, NSUInteger index, BOOL *stop) {
        if (prefix == nil || (prefix != nil && [file hasPrefix:prefix])) {
            NSString *filePath = [fullDirectoryPath stringByAppendingPathComponent:file];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }];
}

- (void) deleteCookiesThatMatchesRegularExpression:(NSRegularExpression *)regularExpression
                                           options:(SCMatchingOption)options {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage.cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger index, BOOL *stop) {
        if (regularExpression != nil) {
            NSString *domain = [cookie domain];
            NSUInteger numberOfMatches = [regularExpression numberOfMatchesInString:domain
                                                                            options:0
                                                                              range:NSMakeRange(0, [domain length])];

            if ((options == SCMatchingAny && numberOfMatches > 0) ||
                (options == SCMatchingNone && numberOfMatches == 0)) {
                [cookieStorage deleteCookie:cookie];
            }
        } else {
            [cookieStorage deleteCookie:cookie];
        }
    }];
}

- (NSRegularExpression *) regularExpressionFromArgument:(NSString *)argument {
    argument = [[argument componentsSeparatedByString:@"="] lastObject];
    argument = [argument stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    argument = [argument stringByReplacingOccurrencesOfString:@"," withString:@"|"];
    NSString *pattern = [NSString stringWithFormat:@"(%@)", argument];

    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:NSRegularExpressionCaseInsensitive
                                                       error:nil];
}

#pragma mark - Run the cleaner

+ (int) run {
    SCSafariCleaner *safariCleaner = [[SCSafariCleaner alloc] init];

    if ([safariCleaner shouldShowHelp]) {
        [safariCleaner showHelp];
        return 0;
    }

    if ([safariCleaner shouldClearHistory]) {
        [safariCleaner clearHistory];
    }

    if ([safariCleaner shouldClearCookies]) {
        if ([safariCleaner shouldClearSomeCookies]) {
            [safariCleaner clearSomeCookies];
        } else if ([safariCleaner shouldClearMostCookies]) {
            [safariCleaner clearMostCookies];
        } else {
            [safariCleaner clearAllCookies];
        }
    }

    if ([safariCleaner shouldEmptyCache]) {
        [safariCleaner emptyCache];
    }

    if ([safariCleaner shouldResetTopSites]) {
        [safariCleaner resetTopSites];
    }

    return 0;
}

#pragma mark - Output to stdout

void ConsoleLog(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString *output = [[NSString alloc] initWithFormat:format
                                              arguments:arguments];
    va_end(arguments);
    
    printf("%s", [output UTF8String]);
}

@end
