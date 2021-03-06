//
//  AirTestFairy.m
//  AirTestFairy
//
//  Created by poccaDot on 3/24/15.
//  Copyright (c) 2015 TestFairy. All rights reserved.
//

#import "AirTestFairy.h"
#import "TestFairy.h"

static FREContext context;

DEFINE_ANE_FUNCTION(AirTestFairyBegin)
{
	NSString *apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TestFairyAPIKey"];
	[TestFairy begin:apiKey];
	return nil;
}

DEFINE_ANE_FUNCTION(AirTestFairyPushFeedbackController)
{
	[TestFairy pushFeedbackController];
	return nil;
}

DEFINE_ANE_FUNCTION(AirTestFairySetCorrelationId)
{
	NSString *correlationId = FPANE_FREObjectToNSString(argv[0]);
	[TestFairy setCorrelationId:correlationId];
	return nil;
}

DEFINE_ANE_FUNCTION(AirTestFairyPause)
{
	[TestFairy pause];
	return nil;
}

DEFINE_ANE_FUNCTION(AirTestFairyResume)
{
	[TestFairy resume];
	return nil;
}

DEFINE_ANE_FUNCTION(AirTestFairyGetSessionUrl)
{
	return FPANE_NSStringToFREOBject([TestFairy sessionUrl]);
}

DEFINE_ANE_FUNCTION(AirTestFairyTakeScreenshot)
{
	[TestFairy takeScreenshot];
	return nil;
}

DEFINE_ANE_FUNCTION(AirTestFairyLog)
{
	NSString *logText = FPANE_FREObjectToNSString(argv[0]);
	TFLog(@"%@",logText);
	return nil;
}

#pragma mark - ANE Setup

void AirTestFairyContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
									  uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
	NSDictionary *functions = @{
        @"begin":					[NSValue valueWithPointer:&AirTestFairyBegin],
		@"pause":					[NSValue valueWithPointer:&AirTestFairyPause],
		@"resume":					[NSValue valueWithPointer:&AirTestFairyResume],
		@"takeScreenshot":			[NSValue valueWithPointer:&AirTestFairyTakeScreenshot],
		@"pushFeedbackController":  [NSValue valueWithPointer:&AirTestFairyPushFeedbackController],
		@"setCorrelationId":		[NSValue valueWithPointer:&AirTestFairySetCorrelationId],
		@"getSessionUrl":			[NSValue valueWithPointer:&AirTestFairyGetSessionUrl],
		@"log":						[NSValue valueWithPointer:&AirTestFairyLog],
		};
	
	*numFunctionsToTest = (uint32_t)[functions count];
	
	FRENamedFunction *func = (FRENamedFunction *)malloc(sizeof(FRENamedFunction) * [functions count]);
	
	for (NSInteger i = 0; i < [functions count]; i++)
	{
		func[i].name = (const uint8_t *)[[[functions allKeys] objectAtIndex:i] UTF8String];
		func[i].functionData = NULL;
		func[i].function = [[[functions allValues] objectAtIndex:i] pointerValue];
	}
	
	*functionsToSet = func;
	
	context = ctx;
}

void AirTestFairyContextFinalizer(FREContext ctx) { }

void AirTestFairyInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirTestFairyContextInitializer;
	*ctxFinalizerToSet = &AirTestFairyContextFinalizer;
}

void AirTestFairyFinalizer(void *extData) { }