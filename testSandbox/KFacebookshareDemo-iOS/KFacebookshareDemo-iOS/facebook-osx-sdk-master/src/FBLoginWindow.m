#import "FBLoginWindow.h"
#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import "FBUtility.h"

static const NSTimeInterval kTimeoutInterval = 180.0;
static NSString* kUserAgent = @"FacebookConnect";

@interface FBLoginWindow ()

@property NSString *loginDialogURL;
@property NSDictionary *params;
@property (weak) id<FBLoginWindowDelegate> delegate;

@end

@implementation FBLoginWindow {
  WebView *_webView;
  BOOL _hasDoneFinalRedirect;
  BOOL _hasHandledCallback;
}


- (instancetype)initWithWindow:(NSWindow *)window
                           URL:(NSString *)loginDialogURL
                   loginParams:(NSDictionary *)params
                      delegate:(id<FBLoginWindowDelegate>)delegate
{
  if (self = [super initWithWindow:window]) {
    if (!window) {
      NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];

      self.window = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
      [self.window setTitle:@"Authorize Facebook"];
      NSRect f = self.window.frame;
      f.size = NSMakeSize(600, 300);
      [self.window setFrame:f display:YES];
      self.window.hidesOnDeactivate = mainWindow.hidesOnDeactivate;
      if (!self.window.isVisible) {
        [self.window center];
      }
    }

    _loginDialogURL = loginDialogURL;
    _params = params;
    _delegate = delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:self.window];
    
  }
  return self;
}


- (void)windowWillClose:(NSNotification *)notification
{
  [_delegate fbWindowNotLogin:YES];
}


- (void)show
{
  NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
  [mainWindow addChildWindow:self.window ordered:NSWindowAbove];
  
  _webView = [WebView new];
  [self.window setContentView:_webView];
  [self.window makeFirstResponder:_webView];

  // load the requested initial sign-in page
  [_webView setResourceLoadDelegate:self];
  [_webView setPolicyDelegate:self];

  NSString *html = [self createLoadingHTML];
  if ([html length] > 0) {
    [_webView.mainFrame loadHTMLString:html baseURL:nil];
  }

  const NSTimeInterval kJanuary2011 = 1293840000;
  BOOL isDateValid = ([[NSDate date] timeIntervalSince1970] > kJanuary2011);
  if (isDateValid) {
    // this is needed for the progress indicator to load
    [self performSelector:@selector(authenticate)
               withObject:nil
               afterDelay:0.01
                  inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
  } else {
    // clock date is invalid, so signing in would fail with an unhelpful error
    // from the server. Warn the user in an html string showing a watch icon,
    // question mark, and the system date and time. Hopefully this will clue
    // in brighter users, or at least let them make a useful screenshot to show
    // to developers.
    //
    // Even better is for apps to check the system clock and show some more
    // helpful, localized instructions for users; this is really a fallback.
    NSString *htmlTemplate = @"<html><body><div align=center><font size='7'>"
    "&#x231A; ?<br><i>System Clock Incorrect</i><br>%@"
    "</font></div></body></html>";
    NSString *errHTML = [NSString stringWithFormat:htmlTemplate, [NSDate date]];
    
    [[_webView mainFrame] loadHTMLString:errHTML baseURL:nil];
  }
  
}


- (void)authenticate
{
  NSMutableURLRequest* request =
  [NSMutableURLRequest requestWithURL:[self generateURL:_loginDialogURL params:_params]
                          cachePolicy:NSURLRequestReloadIgnoringCacheData
                      timeoutInterval:kTimeoutInterval];

  [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
  [_webView.mainFrame loadRequest:request];
}


- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
  if (params) {
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in params.keyEnumerator) {
      NSString* value = [params objectForKey:key];
      NSString* escaped_value = [FBUtility stringByURLEncodingString:value];
      [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    
    NSString* query = [pairs componentsJoinedByString:@"&"];
    NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
    return [NSURL URLWithString:url];
  } else {
    return [NSURL URLWithString:baseURL];
  }
}


- (BOOL)requestRedirectedToRequest:(NSURLRequest *)redirectedRequest
{
  // for Google's installed app sign-in protocol, we'll look for the
  // end-of-sign-in indicator in the titleChanged: method below
  NSString *redirectURI = _params[@"redirect_uri"];
  if (redirectURI == nil) return NO;
    
  // compare the redirectURI, which tells us when the web sign-in is done,
  // to the actual redirection
  NSURL *redirectURL = [NSURL URLWithString:redirectURI];
  NSURL *requestURL = [redirectedRequest URL];
  
  // avoid comparing to nil host and path values (such as when redirected to
  // "about:blank")
  NSString *requestHost = [requestURL host];
  NSString *requestPath = [requestURL path];
  BOOL isCallback;
  if (requestHost && requestPath) {
    isCallback = [[redirectURL host] isEqual:[requestURL host]]
    && [[redirectURL path] isEqual:[requestURL path]];
  } else if (requestURL) {
    // handle "about:blank"
    isCallback = [redirectURL isEqual:requestURL];
  } else {
    isCallback = NO;
  }
  
  if (!isCallback) {
    // tell the caller that this request is nothing interesting
    return NO;
  }
  
  // we've reached the callback URL
  
  // try to get the access code
  if (!_hasHandledCallback) {
    NSString *responseStr = [[redirectedRequest URL] absoluteString];

    // extract token, expiraton or error
    NSString *token = [self getStringFromUrl:responseStr needle:@"access_token="];
    NSString *expTime = [self getStringFromUrl:responseStr needle:@"expires_in="];
    NSDate *expirationDate =nil;
    
    if (expTime != nil) {
      int expVal = [expTime intValue];
      if (expVal == 0) {
        expirationDate = [NSDate distantFuture];
      } else {
        expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
      }
    }
    
    // hide window
    [self.window orderOut:nil];
    if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
      [_delegate fbWindowNotLogin:NO];
    } else {
      [_delegate fbWindowLogin:token expirationDate:expirationDate];
    }
  }
  // tell the delegate that we did handle this request
  return YES;
}


/**
 * Find a specific parameter from the url
 */
- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
  NSString * str = nil;
  NSRange start = [url rangeOfString:needle];
  if (start.location != NSNotFound) {
    // confirm that the parameter is not a partial name match
    unichar c = '?';
    if (start.location != 0) {
      c = [url characterAtIndex:start.location - 1];
    }
    if (c == '?' || c == '&' || c == '#') {
      NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
      NSUInteger offset = start.location+start.length;
      str = end.location == NSNotFound ?
      [url substringFromIndex:offset] :
      [url substringWithRange:NSMakeRange(offset, end.location)];
      str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
  }
  return str;
}

#pragma mark WebView methods

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
  if (!_hasDoneFinalRedirect) {
    _hasDoneFinalRedirect = [self requestRedirectedToRequest:request];
    if (_hasDoneFinalRedirect) {
      // signIn has told the window to close
      return nil;
    }
  }
  return request;
}


-(NSString *)createLoadingHTML
{
  return @"<html><body style=\"background: no-repeat center center url(data:image/gif;base64"
  ",R0lGODlhIAAgAPMAAP///wAAAMbGxoSEhLa2tpqamjY2NlZWVtjY2OTk5Ly8vB4eHgQEBAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh/"
  "hpDcmVhdGVkIHdpdGggYWpheGxvYWQuaW5mbwAh+QQJCgAAACwAAAAAIAAgAAAE5xDISWlhperN52JLhSSdRgwVo1ICQZRUsiwHpTJT4iowNS8"
  "vyW2icCF6k8HMMBkCEDskxTBDAZwuAkkqIfxIQyhBQBFvAQSDITM5VDW6XNE4KagNh6Bgwe60smQUB3d4Rz1ZBApnFASDd0hihh12BkE9kjAJV"
  "lycXIg7CQIFA6SlnJ87paqbSKiKoqusnbMdmDC2tXQlkUhziYtyWTxIfy6BE8WJt5YJvpJivxNaGmLHT0VnOgSYf0dZXS7APdpB309RnHOG5gD"
  "qXGLDaC457D1zZ/V/nmOM82XiHRLYKhKP1oZmADdEAAAh+QQJCgAAACwAAAAAIAAgAAAE6hDISWlZpOrNp1lGNRSdRpDUolIGw5RUYhhHukqFu"
  "8DsrEyqnWThGvAmhVlteBvojpTDDBUEIFwMFBRAmBkSgOrBFZogCASwBDEY/CZSg7GSE0gSCjQBMVG023xWBhklAnoEdhQEfyNqMIcKjhRsjEd"
  "nezB+A4k8gTwJhFuiW4dokXiloUepBAp5qaKpp6+Ho7aWW54wl7obvEe0kRuoplCGepwSx2jJvqHEmGt6whJpGpfJCHmOoNHKaHx61WiSR92E4"
  "lbFoq+B6QDtuetcaBPnW6+O7wDHpIiK9SaVK5GgV543tzjgGcghAgAh+QQJCgAAACwAAAAAIAAgAAAE7hDISSkxpOrN5zFHNWRdhSiVoVLHspR"
  "UMoyUakyEe8PTPCATW9A14E0UvuAKMNAZKYUZCiBMuBakSQKG8G2FzUWox2AUtAQFcBKlVQoLgQReZhQlCIJesQXI5B0CBnUMOxMCenoCfTCEW"
  "BsJColTMANldx15BGs8B5wlCZ9Po6OJkwmRpnqkqnuSrayqfKmqpLajoiW5HJq7FL1Gr2mMMcKUMIiJgIemy7xZtJsTmsM4xHiKv5KMCXqfyUC"
  "JEonXPN2rAOIAmsfB3uPoAK++G+w48edZPK+M6hLJpQg484enXIdQFSS1u6UhksENEQAAIfkECQoAAAAsAAAAACAAIAAABOcQyEmpGKLqzWcZR"
  "VUQnZYg1aBSh2GUVEIQ2aQOE+G+cD4ntpWkZQj1JIiZIogDFFyHI0UxQwFugMSOFIPJftfVAEoZLBbcLEFhlQiqGp1Vd140AUklUN3eCA51C1E"
  "WMzMCezCBBmkxVIVHBWd3HHl9JQOIJSdSnJ0TDKChCwUJjoWMPaGqDKannasMo6WnM562R5YluZRwur0wpgqZE7NKUm+FNRPIhjBJxKZteWuIB"
  "MN4zRMIVIhffcgojwCF117i4nlLnY5ztRLsnOk+aV+oJY7V7m76PdkS4trKcdg0Zc0tTcKkRAAAIfkECQoAAAAsAAAAACAAIAAABO4QyEkpKqj"
  "qzScpRaVkXZWQEximw1BSCUEIlDohrft6cpKCk5xid5MNJTaAIkekKGQkWyKHkvhKsR7ARmitkAYDYRIbUQRQjWBwJRzChi9CRlBcY1UN4g0/V"
  "NB0AlcvcAYHRyZPdEQFYV8ccwR5HWxEJ02YmRMLnJ1xCYp0Y5idpQuhopmmC2KgojKasUQDk5BNAwwMOh2RtRq5uQuPZKGIJQIGwAwGf6I0JXM"
  "pC8C7kXWDBINFMxS4DKMAWVWAGYsAdNqW5uaRxkSKJOZKaU3tPOBZ4DuK2LATgJhkPJMgTwKCdFjyPHEnKxFCDhEAACH5BAkKAAAALAAAAAAgA"
  "CAAAATzEMhJaVKp6s2nIkolIJ2WkBShpkVRWqqQrhLSEu9MZJKK9y1ZrqYK9WiClmvoUaF8gIQSNeF1Er4MNFn4SRSDARWroAIETg1iVwuHjYB"
  "1kYc1mwruwXKC9gmsJXliGxc+XiUCby9ydh1sOSdMkpMTBpaXBzsfhoc5l58Gm5yToAaZhaOUqjkDgCWNHAULCwOLaTmzswadEqggQwgHuQsHI"
  "oZCHQMMQgQGubVEcxOPFAcMDAYUA85eWARmfSRQCdcMe0zeP1AAygwLlJtPNAAL19DARdPzBOWSm1brJBi45soRAWQAAkrQIykShQ9wVhHCwCQ"
  "CACH5BAkKAAAALAAAAAAgACAAAATrEMhJaVKp6s2nIkqFZF2VIBWhUsJaTokqUCoBq+E71SRQeyqUToLA7VxF0JDyIQh/MVVPMt1ECZlfcjZJ9"
  "mIKoaTl1MRIl5o4CUKXOwmyrCInCKqcWtvadL2SYhyASyNDJ0uIiRMDjI0Fd30/iI2UA5GSS5UDj2l6NoqgOgN4gksEBgYFf0FDqKgHnyZ9OX8"
  "HrgYHdHpcHQULXAS2qKpENRg7eAMLC7kTBaixUYFkKAzWAAnLC7FLVxLWDBLKCwaKTULgEwbLA4hJtOkSBNqITT3xEgfLpBtzE/jiuL04RGEBg"
  "wWhShRgQExHBAAh+QQJCgAAACwAAAAAIAAgAAAE7xDISWlSqerNpyJKhWRdlSAVoVLCWk6JKlAqAavhO9UkUHsqlE6CwO1cRdCQ8iEIfzFVTzL"
  "dRAmZX3I2SfZiCqGk5dTESJeaOAlClzsJsqwiJwiqnFrb2nS9kmIcgEsjQydLiIlHehhpejaIjzh9eomSjZR+ipslWIRLAgMDOR2DOqKogTB9p"
  "CUJBagDBXR6XB0EBkIIsaRsGGMMAxoDBgYHTKJiUYEGDAzHC9EACcUGkIgFzgwZ0QsSBcXHiQvOwgDdEwfFs0sDzt4S6BK4xYjkDOzn0unFeBz"
  "OBijIm1Dgmg5YFQwsCMjp1oJ8LyIAACH5BAkKAAAALAAAAAAgACAAAATwEMhJaVKp6s2nIkqFZF2VIBWhUsJaTokqUCoBq+E71SRQeyqUToLA7"
  "VxF0JDyIQh/MVVPMt1ECZlfcjZJ9mIKoaTl1MRIl5o4CUKXOwmyrCInCKqcWtvadL2SYhyASyNDJ0uIiUd6GGl6NoiPOH16iZKNlH6KmyWFOgg"
  "HhEEvAwwMA0N9GBsEC6amhnVcEwavDAazGwIDaH1ipaYLBUTCGgQDA8NdHz0FpqgTBwsLqAbWAAnIA4FWKdMLGdYGEgraigbT0OITBcg5QwPT4"
  "xLrROZL6AuQAPUS7bxLpoWidY0JtxLHKhwwMJBTHgPKdEQAACH5BAkKAAAALAAAAAAgACAAAATrEMhJaVKp6s2nIkqFZF2VIBWhUsJaTokqUCo"
  "Bq+E71SRQeyqUToLA7VxF0JDyIQh/MVVPMt1ECZlfcjZJ9mIKoaTl1MRIl5o4CUKXOwmyrCInCKqcWtvadL2SYhyASyNDJ0uIiUd6GAULDJCRi"
  "Xo1CpGXDJOUjY+Yip9DhToJA4RBLwMLCwVDfRgbBAaqqoZ1XBMHswsHtxtFaH1iqaoGNgAIxRpbFAgfPQSqpbgGBqUD1wBXeCYp1AYZ19JJOYg"
  "H1KwA4UBvQwXUBxPqVD9L3sbp2BNk2xvvFPJd+MFCN6HAAIKgNggY0KtEBAAh+QQJCgAAACwAAAAAIAAgAAAE6BDISWlSqerNpyJKhWRdlSAVo"
  "VLCWk6JKlAqAavhO9UkUHsqlE6CwO1cRdCQ8iEIfzFVTzLdRAmZX3I2SfYIDMaAFdTESJeaEDAIMxYFqrOUaNW4E4ObYcCXaiBVEgULe0NJaxx"
  "tYksjh2NLkZISgDgJhHthkpU4mW6blRiYmZOlh4JWkDqILwUGBnE6TYEbCgevr0N1gH4At7gHiRpFaLNrrq8HNgAJA70AWxQIH1+vsYMDAzZQP"
  "C9VCNkDWUhGkuE5PxJNwiUK4UfLzOlD4WvzAHaoG9nxPi5d+jYUqfAhhykOFwJWiAAAIfkECQoAAAAsAAAAACAAIAAABPAQyElpUqnqzaciSoV"
  "kXVUMFaFSwlpOCcMYlErAavhOMnNLNo8KsZsMZItJEIDIFSkLGQoQTNhIsFehRww2CQLKF0tYGKYSg+ygsZIuNqJksKgbfgIGepNo2cIUB3V1B"
  "3IvNiBYNQaDSTtfhhx0CwVPI0UJe0+bm4g5VgcGoqOcnjmjqDSdnhgEoamcsZuXO1aWQy8KAwOAuTYYGwi7w5h+Kr0SJ8MFihpNbx+4Erq7BYB"
  "uzsdiH1jCAzoSfl0rVirNbRXlBBlLX+BP0XJLAPGzTkAuAOqb0WT5AH7OcdCm5B8TgRwSRKIHQtaLCwg1RAAAOwAAAAAAAAAAAA==);"
  "\"></body></html>";
}




@end
