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

#import "FBSDKMonitorStore.h"

@interface FBSDKMonitorStore ()

@property (nonatomic) BOOL skipDiskCheck;

@end

@implementation FBSDKMonitorStore

- (instancetype)initWithFilePath:(NSString *)filePath
{
  if ((self = [super init])) {
    _filePath = [FBSDKBasicUtility persistenceFilePath:filePath];
    _skipDiskCheck = YES;
  }
  return self;
}

- (void)clear
{
  [[NSFileManager defaultManager] removeItemAtPath:self.filePath
                                             error:nil];
  self.skipDiskCheck = YES;
}

- (void)persist:(NSArray<id<FBSDKDictionaryRepresentable>> *)entries
{
  // Should have retrieved and sent entries on app start so there
  // should not be anything here but clear it to be safe
  [self clear];

  if (!entries.count) {
    return;
  }

  NSString *jsonString = [FBSDKBasicUtility JSONStringForObject:entries
                                                          error:NULL
                                           invalidObjectHandler:NULL];

  [jsonString writeToFile:self.filePath
               atomically:YES
                 encoding:NSUTF8StringEncoding error:nil];

  self.skipDiskCheck = NO;
}

- (NSData * _Nullable)retrieveEntryData {
  NSData *data;

  if (!self.skipDiskCheck) {
    data = [NSData dataWithContentsOfFile:self.filePath];

    [self clear];
  }

  return data;
}

@end
