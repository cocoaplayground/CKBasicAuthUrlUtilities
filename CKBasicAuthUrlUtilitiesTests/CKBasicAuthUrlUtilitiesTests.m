//
//  Copyright (c) 2013 Cody Kimberling. All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  •  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  •  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "CKBasicAuthUrlUtilitiesTests.h"
#import "OCMock.h"
#import "CKBasicAuthUrlUtilities.h"
#import "NSString+BasicAuthUtils.h"
#import "NSURL+BasicAuthUtils.h"
#import "CKTestHelpers.h"

@interface CKBasicAuthUrlUtilitiesTests ()

@property (nonatomic) CKBasicAuthUrlUtilities *utilitiesHttpScheme;
@property (nonatomic) CKBasicAuthUrlUtilities *utilitiesHttpsScheme;
@property (nonatomic) id mockUrl;
@property (nonatomic) id mockString;

@end

@implementation CKBasicAuthUrlUtilitiesTests

- (void)setUp
{
    [super setUp];
    
    self.mockUrl = [OCMockObject niceMockForClass:NSURL.class];
    self.mockString = [OCMockObject niceMockForClass:NSString.class];
    
    self.utilitiesHttpScheme = CKBasicAuthUrlUtilities.new;
    self.utilitiesHttpScheme.schemeType = CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttp;
    
    self.utilitiesHttpsScheme = CKBasicAuthUrlUtilities.new;
}

#pragma mark - CKBasicAuthUrlUtilitiesDefaultSchemeType tests

- (void)testBasicAuthUrlUtilitiesDefaultSchemeTypes
{
    STAssertTrue(CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps == 0, nil);
    STAssertTrue(CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttp == 1, nil);
}

- (void)testBasicAuthUrlUtilitiesDefaultSchemeHttpsOnInit
{
    STAssertTrue(CKBasicAuthUrlUtilities.new.schemeType == CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps, nil);
    STAssertTrue(self.utilitiesHttpsScheme.schemeType == CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps, nil);
    STAssertTrue(self.utilitiesHttpScheme.schemeType == CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttp, nil);
}

- (void)testSchemeTranslation
{    
    STAssertEqualObjects(self.utilitiesHttpsScheme.scheme, @"https", nil);
    STAssertEqualObjects(self.utilitiesHttpScheme.scheme, @"http", nil);
}

#pragma mark - NSURL encode tests

- (void)testUrlWithUtf8EncodingForString
{
    NSString *nonEncodedString = @"http://www.google.com/?q=whoami?";
    NSString *encodedString = @"http://www.google.com/?q=whoami%3F";

    NSString *expectedUrl = [NSURL URLWithString:nonEncodedString];

//    nonEncodedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
    
    [[[self.mockString expect] andReturn:encodedString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[[self.mockUrl expect] andReturn:expectedUrl] URLWithString:encodedString];

    NSURL *actualUrl = [self.utilitiesHttpScheme urlWithUtf8EncodingForString:self.mockString];

    [self.mockString verify];
    [self.mockUrl verify];

    STAssertEquals(actualUrl, expectedUrl, nil);
}

#pragma mark - NSURL Update User/Password Tests

- (void)testUrlWithUpdatedUsername
{
    [self verifyUrlWithUpdatedUsernameWithSchemeType:CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttp];
    [self verifyUrlWithUpdatedUsernameWithSchemeType:CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps];
}

- (void)testUrlWithUpdatedPassword
{
    [self verifyUrlWithUpdatedPasswordWithSchemeType:CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttp];
    [self verifyUrlWithUpdatedPasswordWithSchemeType:CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps];
}

- (void)testUrlWithUpdatedUsernameAndPassword
{
    [self verifyUrlWithUpdatedUsernameAndPasswordWithSchemeType:CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttp];
    [self verifyUrlWithUpdatedUsernameAndPasswordWithSchemeType:CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps];
}

- (void)verifyUrlWithUpdatedUsernameWithSchemeType:(CKBasicAuthUrlUtilitiesDefaultSchemeType)schemeType
{
    CKBasicAuthUrlUtilities *utils = (schemeType == CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps) ? self.utilitiesHttpsScheme : self.utilitiesHttpScheme;
    NSURL *expectedUrl = NSURL.new;
    
    [[[self.mockUrl expect] andReturn:expectedUrl] urlWithUpdatedUsername:self.mockString withScheme:utils.scheme];
    
    NSURL *actualUrl = [utils urlWithUpdatedUsername:self.mockString forUrl:self.mockUrl];
    
    [self.mockUrl verify];
    
    STAssertEquals(actualUrl, expectedUrl, nil);
}

- (void)verifyUrlWithUpdatedPasswordWithSchemeType:(CKBasicAuthUrlUtilitiesDefaultSchemeType)schemeType
{
    CKBasicAuthUrlUtilities *utils = (schemeType == CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps) ? self.utilitiesHttpsScheme : self.utilitiesHttpScheme;
    NSURL *expectedUrl = NSURL.new;
    
    [[[self.mockUrl expect] andReturn:expectedUrl] urlWithUpdatedPassword:self.mockString withScheme:utils.scheme];
    
    NSURL *actualUrl = [utils urlWithUpdatedPassword:self.mockString forUrl:self.mockUrl];
    
    [self.mockUrl verify];
    
    STAssertEquals(actualUrl, expectedUrl, nil);
}

- (void)verifyUrlWithUpdatedUsernameAndPasswordWithSchemeType:(CKBasicAuthUrlUtilitiesDefaultSchemeType)schemeType
{
    id mockUsernameString = self.mockString;
    id mockPasswordString = [OCMockObject niceMockForClass:NSString.class];
    
    CKBasicAuthUrlUtilities *utils = (schemeType == CKBasicAuthUrlUtilitiesDefaultSchemeTypeHttps) ? self.utilitiesHttpsScheme : self.utilitiesHttpScheme;
    NSURL *expectedUrl = NSURL.new;
    
    [[[self.mockUrl expect] andReturn:expectedUrl] urlWithUpdatedUsername:mockUsernameString andPassword:mockPasswordString withScheme:utils.scheme];
    
    NSURL *actualUrl = [utils urlWithUpdatedUsername:mockUsernameString andPassword:mockPasswordString forUrl:self.mockUrl];
    
    [self.mockUrl verify];
    
    STAssertEquals(actualUrl, expectedUrl, nil);
}

#pragma mark - NSURL Strip Auth Tests

- (void)testUrlWithoutAuthenticationFromUrl
{
    NSURL *expectedUrl = NSURL.new;
    
    [[[self.mockUrl expect] andReturn:expectedUrl] urlWithoutAuthentication];
    
    NSURL *actualUrl = [self.utilitiesHttpsScheme urlWithoutAuthenticationFromUrl:self.mockUrl];
    
    [self.mockUrl verify];
    
    STAssertEquals(actualUrl, expectedUrl, nil);
}

#pragma mark BOOL methods

- (void)testUrlHasSchemeReturnsTrue
{
    BOOL returnValue = YES;
    
    [[[self.mockUrl expect] andReturnValue:OCMOCK_VALUE(returnValue)] hasScheme];
    
    BOOL result = [self.utilitiesHttpScheme urlHasScheme:self.mockUrl];
    
    [self.mockUrl verify];
    
    STAssertTrue(result, nil);
}

- (void)testUrlHasSchemeReturnsFalse
{
    BOOL returnValue = NO;
    
    [[[self.mockUrl expect] andReturnValue:OCMOCK_VALUE(returnValue)] hasScheme];
    
    BOOL result = [self.utilitiesHttpScheme urlHasScheme:self.mockUrl];
    
    [self.mockUrl verify];
    
    STAssertFalse(result, nil);
}

- (void)testUrlHasAuthenticationReturnsTrue
{
    BOOL returnValue = YES;
    
    [[[self.mockUrl expect] andReturnValue:OCMOCK_VALUE(returnValue)] hasAuthentication];
    
    BOOL result = [self.utilitiesHttpScheme urlHasAuthentication:self.mockUrl];
    
    [self.mockUrl verify];
    
    STAssertTrue(result, nil);
}

- (void)testUrlHasAuthenticationReturnsFalse
{
    BOOL returnValue = NO;
    
    [[[self.mockUrl expect] andReturnValue:OCMOCK_VALUE(returnValue)] hasAuthentication];
    
    BOOL result = [self.utilitiesHttpScheme urlHasAuthentication:self.mockUrl];
    
    [self.mockUrl verify];
    
    STAssertFalse(result, nil);
}


@end