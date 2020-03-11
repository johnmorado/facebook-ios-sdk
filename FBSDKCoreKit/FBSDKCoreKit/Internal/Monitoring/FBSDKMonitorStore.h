// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

#import "FBSDKCoreKit+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBSDKMonitorStore : NSObject

@property (nonatomic, weak) NSString *filePath;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithFilePath:(NSString *)filePath NS_DESIGNATED_INITIALIZER;

/**
 Persists an array of dictionary representable objects to local storage.
 Underlying storage uses a UTF8 encoded JSON string.

 - Important: Persisting always clears the underlying storage.
 If you do not want to overwrite what is on disk, call `retrieveEntryData`
 prior to calling this method.
 */
- (void)persist:(NSArray<id<FBSDKDictionaryRepresentable>> *)entries;

/**
 Retrieves any stored entries in the form of a UTF8 encoded JSON String.

 - Important: Retrieving entry data clears the underlying storage.
 If you need to persist the data after retrieving you must call `persist` again.
 */
- (NSData * _Nullable)retrieveEntryData;

@end

NS_ASSUME_NONNULL_END
