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

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "FBSDKCoreKit+Internal.h"
#import "TestMonitorEntry.h"

@interface FBSDKMonitorStoreTests : XCTestCase
@end

@implementation FBSDKMonitorStoreTests {
  FBSDKMonitorStore *store;
  FBSDKMonitorEntry *entry;
  id fileManagerMock;
}

- (void)setUp
{
  store = [[FBSDKMonitorStore alloc] initWithFilePath:@"foo"];
  [self clearStore];
  entry = [TestMonitorEntry testEntry];

  fileManagerMock = OCMClassMock([NSFileManager class]);
}

- (void)tearDown
{
  store = nil;
  entry = nil;
  [fileManagerMock stopMocking];
  fileManagerMock = nil;
}

- (void)testCreatingWithFilePath
{
  XCTAssertTrue([store.filePath containsString:@"Library/foo"],
                @"Monitor store should use the provided file path to create a path to the library directory");
}

- (void)testPersistingEmptyEntries
{
  [store persist:@[]];

  XCTAssertNil([store retrieveEntryData],
               @"Should not write to file if there are no entries to persist");
}

- (void)testPersistingEntries
{
  NSData *expected = [self dataFromEntries:@[entry]];

  [store persist:@[entry]];

  XCTAssertEqualObjects([store retrieveEntryData], expected,
                        @"Persisting an entry should write data to the given file path");
}

- (void)testPersistingDuplicateEntriesWithEmptyStore {
  TestMonitorEntry *entry2 = [TestMonitorEntry testEntry];
  NSArray *entries = @[entry, entry2];

  NSData *expected = [self dataFromEntries:entries];

  [store persist:entries];

  XCTAssertEqualObjects([self dataFromDisk], expected,
                        @"Should allow persisting duplicate entries");
}

- (void)testPersistingDuplicateEntriesWithNonEmptyStore
{
  TestMonitorEntry *entry2 = [TestMonitorEntry testEntry];
  NSData *expected = [self dataFromEntries:@[entry2]];

  [store persist:@[entry]];
  [store persist:@[entry2]];

  XCTAssertEqualObjects([self dataFromDisk], expected,
                        @"Should overwrite any existing stored data when persisting");
}

- (void)testPersistingUniqueEntriesWithEmptyStore
{
  TestMonitorEntry *entry2 = [TestMonitorEntry testEntryWithName:@"entry2"];
  NSArray<FBSDKMonitorEntry *> *entries = @[entry, entry2];

  NSData *expected = [self dataFromEntries:entries];

  [store persist:entries];

  XCTAssertEqualObjects([self dataFromDisk], expected,
                        @"Should allow persisting unique entries");
}

- (void)testPersistingUniqueEntriesWithNonEmptyStore
{
  TestMonitorEntry *entry2 = [TestMonitorEntry testEntryWithName:@"entry2"];

  NSData *expected = [self dataFromEntries:@[entry2]];

  [store persist:@[entry]];
  [store persist:@[entry2]];

  XCTAssertEqualObjects([self dataFromDisk], expected,
                        @"Should overwrite any existing stored data when persisting");
}

- (void)testRetrievingWithoutPersistedEntries
{
  NSData *retrievedEntries = [store retrieveEntryData];

  XCTAssertNil(retrievedEntries,
               @"Retrieving entries should return nil when no items are persisted");
}

- (void)testRetrievingClearsStore
{
  NSData *expected = [self dataFromEntries:@[entry]];

  [store persist:@[entry]];

  NSData *actual = [store retrieveEntryData];

  XCTAssertEqualObjects(actual, expected,
                        @"Retrieving should return data representing the persisted entries");

  actual = [store retrieveEntryData];

  XCTAssertNil(actual, @"Should not be data in the store after it is retrieved");
}

- (void)testRetrievingEventListsFromClearedStore {
  [store persist:@[entry]];

  [self clearStore];

  NSData *actual = [store retrieveEntryData];

  XCTAssertNil(actual, @"Should not be data in the store after it is cleared");
}

- (void)testClearingStore {
  OCMStub([NSFileManager class]).andReturn(fileManagerMock);
  OCMStub([fileManagerMock defaultManager]).andReturn(fileManagerMock);

  [self clearStore];

  OCMVerify([fileManagerMock removeItemAtPath:store.filePath error:nil]);
}

// MARK: - Helpers

- (NSData *)dataFromDisk
{
  return [NSData dataWithContentsOfFile:store.filePath];
}

- (NSData *)dataFromEntries:(NSArray<FBSDKMonitorEntry *> *)entries
{
  NSString *original = [FBSDKBasicUtility JSONStringForObject:entries error:nil invalidObjectHandler: nil];
  return [original dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)clearStore
{
  // Persisting always clears.
  // This attempts to persist an empty array to force clear the store.
  [store persist:@[]];
}

@end
