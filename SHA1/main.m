//
//  main.m
//  SHA1
//
//  Created by Maokebing on 8/27/15.
//  Copyright (c) 2015 Maokebing. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <getopt.h>
#import <CommonCrypto/CommonCrypto.h>

enum iOSConsoleOptions {
	OptionsHelp = 0x0,
	OptionsString,
	OptionsCount
};

static struct option long_options[OptionsCount] = {
	{"string", required_argument, 0x0, 's'}
};


NSString* GetCurrentRunPath(NSError **error) {
	char *buffer = NULL;
	if((buffer = getcwd(NULL, 0)) == NULL) {
		*error = [NSError errorWithDomain:@"GetCurrentRunPathError" code:-1 userInfo:nil];
		return nil;
	}
	
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

BOOL SHA1WithFile(NSString *fileName, NSString** outString) {
	NSString* filePath = fileName;
	
	if (![filePath hasPrefix:@"/"]) {
		NSError* error = nil;
		NSString *path =  GetCurrentRunPath(&error);
		if (!path) {
			printf("Error:%s\n", [error.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding]);
			return NO;
		}
		
		filePath = [NSString stringWithFormat:@"%@/%@", path, fileName];
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		
		NSData* data = [NSData dataWithContentsOfFile:filePath];
		CC_LONG length = (CC_LONG)data.length;
		uint8_t digest[CC_SHA1_DIGEST_LENGTH];
		CC_SHA1(data.bytes, length, digest);
		
		NSMutableString* output = [NSMutableString string];
		
		for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
			[output appendFormat:@"%02x", digest[i]];
		
		*outString = [output copy];
		
		return YES;
	}
	
	return NO;
}

NSString* SHA1WithString(NSString *input) {
	CC_LONG length = (CC_LONG)input.length;
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	const char* cChar = [input cStringUsingEncoding:NSUTF8StringEncoding];
	CC_SHA1(cChar, length, digest);
 
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
 
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
 
	return [output copy];
}



static bool optionsEnable[OptionsCount] = {};

int main(int argc, const char * argv[]) {
	bool searchArgs = true;
	
	int counter;
	while (searchArgs) {
		int option_index = 0x0;
		counter = getopt_long (argc, (char * const *)argv, "s:",long_options, &option_index);
		
		if (counter == -1) {
			break;
		}
		switch (counter) {
			case 's': {
				optionsEnable[OptionsString] = true;
				searchArgs = false;
				break;
			};
		}
	}
	if (argc == 1) {
		optionsEnable[OptionsHelp] = true;
	}
	
	if (optionsEnable[OptionsHelp]) {
		printf("usage: sha1 [-s string] [files ...]\n");
	}
	if (optionsEnable[OptionsString]) {
		NSString* input = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
		NSString* output = SHA1WithString(input);
		printf("SHA1(\"%s\") = %s\n", optarg, [output cStringUsingEncoding:NSUTF8StringEncoding]);
		return 0;
	}
	
	//直接文件
	if (argc == 2) {
		NSString *intput = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
		NSString *output = nil;
		if (SHA1WithFile(intput, &output)) {
			printf("SHA1(%s) = %s\n", argv[1], [output cStringUsingEncoding:NSUTF8StringEncoding]);
		}else {
			printf("file %s is not exsit!\n", argv[1]);
		}
		return 0;
	}
	
    return 0;
}






