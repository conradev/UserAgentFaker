#import <CFNetwork/CFNetwork.h>

#import <substrate.h>
#import <notify.h>
#import <unistd.h>

// This is no longer compiled as a part of User Agent Faker

static NSString *userAgent;
static BOOL isEnabled = NO;

enum CFURLRequestCachePolicy { };
typedef const struct __CFURL* CFURLRef;
typedef const struct _CFURLRequest* CFURLRequestRef;
typedef struct _CFURLRequest* CFMutableURLRequestRef;

extern "C" { 

    CFMutableURLRequestRef CFURLRequestCreateMutable(CFAllocatorRef allocator, CFURLRef url, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL);
    CFURLRequestRef CFURLRequestCreate(CFAllocatorRef allocator, CFURLRef url, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL);

    CFURLRequestRef CFURLRequestCreateHTTPRequest(CFAllocatorRef allocator, CFHTTPMessageRef httpMessage, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL);
    CFMutableURLRequestRef CFURLRequestCreateMutableHTTPRequest(CFAllocatorRef allocator, CFHTTPMessageRef httpMessage, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL);
    
    void CFURLRequestSetHTTPHeaderFieldValue(CFURLRequestRef request, CFStringRef headerField, CFStringRef value);
}

static CFMutableURLRequestRef (*original_CFURLRequestCreateMutable)(CFAllocatorRef allocator, CFURLRef url, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL);
static CFURLRequestRef (*original_CFURLRequestCreateHTTPRequest)(CFAllocatorRef allocator, CFHTTPMessageRef httpMessage, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL);
static CFMutableURLRequestRef (*original_CFURLRequestCreateMutableHTTPRequest)(CFAllocatorRef allocator, CFHTTPMessageRef httpMessage, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL);
static void (*original_CFURLRequestSetHTTPHeaderFieldValue)(CFURLRequestRef request, CFStringRef headerField, CFStringRef value);


CFMutableURLRequestRef custom_CFURLRequestCreateMutable(CFAllocatorRef allocator, CFURLRef url, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL) {
    CFMutableURLRequestRef mutableRequest = original_CFURLRequestCreateMutable(allocator, url, cachePolicy, timeout, mainDocumentURL);
    
    if (userAgent && isEnabled) {
        CFURLRequestSetHTTPHeaderFieldValue(mutableRequest, CFSTR("User-Agent"), (CFStringRef)userAgent);
    }
    
    return mutableRequest;
}

CFURLRequestRef custom_CFURLRequestCreateHTTPRequest(CFAllocatorRef allocator, CFHTTPMessageRef httpMessage, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL) {
    if (userAgent && isEnabled) {
        CFHTTPMessageSetHeaderFieldValue (httpMessage, CFSTR("User-Agent"), (CFStringRef)userAgent);
    }
    
    return original_CFURLRequestCreateMutableHTTPRequest(allocator, httpMessage, cachePolicy, timeout, mainDocumentURL);
}

CFMutableURLRequestRef custom_CFURLRequestCreateMutableHTTPRequest(CFAllocatorRef allocator, CFHTTPMessageRef httpMessage, CFURLRequestCachePolicy cachePolicy, double timeout, CFURLRef mainDocumentURL) {
    if (userAgent && isEnabled) {
        CFHTTPMessageSetHeaderFieldValue (httpMessage, CFSTR("User-Agent"), (CFStringRef)userAgent);
    }
    
    return original_CFURLRequestCreateMutableHTTPRequest(allocator, httpMessage, cachePolicy, timeout, mainDocumentURL);
}

void custom_CFURLRequestSetHTTPHeaderFieldValue(CFURLRequestRef request, CFStringRef headerField, CFStringRef value) {
    if (CFStringCompare(headerField, CFSTR("User-Agent"), 0) == kCFCompareEqualTo && userAgent && isEnabled) {
        original_CFURLRequestSetHTTPHeaderFieldValue(request, headerField, (CFStringRef)userAgent);
    } else {
        original_CFURLRequestSetHTTPHeaderFieldValue(request, headerField, value);
    }
}

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    MSHookFunction(CFURLRequestCreateMutable, custom_CFURLRequestCreateMutable, &original_CFURLRequestCreateMutable);
    MSHookFunction(CFURLRequestCreateHTTPRequest, custom_CFURLRequestCreateHTTPRequest, &original_CFURLRequestCreateHTTPRequest);
    MSHookFunction(CFURLRequestCreateMutableHTTPRequest, custom_CFURLRequestCreateMutableHTTPRequest, &original_CFURLRequestCreateMutableHTTPRequest);
    MSHookFunction(CFURLRequestSetHTTPHeaderFieldValue, custom_CFURLRequestSetHTTPHeaderFieldValue, &original_CFURLRequestSetHTTPHeaderFieldValue);

    [pool release];
}
