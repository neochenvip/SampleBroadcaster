/*
 
 Video Core
 Copyright (c) 2014 James G. Hurley
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "ViewController.h"
#import "VCSimpleSession.h"
#import <SIOSocket/SIOSocket.h>


@interface ViewController () <VCSessionDelegate>
@property (nonatomic, retain) VCSimpleSession* session;
@property (nonatomic, retain) SIOSocket* socket;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _session = [[VCSimpleSession alloc] initWithVideoSize:CGSizeMake(1280, 720) frameRate:30 bitrate:1000000 useInterfaceOrientation:NO];
    
    [self.previewView addSubview:_session.previewView];
    _session.previewView.frame = self.previewView.bounds;
    _session.delegate = self;
    
    
    // ...
    [SIOSocket socketWithHost: @"http://10.199.213.200:3000" response: ^(SIOSocket *socket) {
        self.socket = socket;
        self.socket.onConnect = ^()
        {
            NSLog(@"connect ");

        };
        self.socket.onError = ^(NSDictionary * error)
        {
            NSLog(@"connect error");
            
        };
        
        [self.socket on: @"new message" callback: ^(SIOParameterArray *args)
         {
            NSDictionary *data =(NSDictionary *) [args objectAtIndex:0];
             NSString *username = [data objectForKey:@"username"];
             NSString *message = [data objectForKey:@"message"];

             NSLog(@"content is %@ %@" ,username,message);
         }];
        
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"BeautyXia",@"username",@"bbb",@"room", nil];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:0
                                                             error:&error];
        
        NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self.socket emit: @"add user" args: @[str]];

    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btnConnect release];
    [_previewView release];
    [_session release];
    
    [super dealloc];
}

- (IBAction)btnConnectTouch:(id)sender {
    
    switch(_session.rtmpSessionState) {
        case VCSessionStateNone:
        case VCSessionStatePreviewStarted:
        case VCSessionStateEnded:
        case VCSessionStateError:
            [_session startRtmpSessionWithURL:@"rtmp://10.199.213.200/live/livestream" andStreamKey:@"myStream"];
            break;
        default:
            [_session endRtmpSession];
            break;
    }
}


//Switch with the availables filters
- (IBAction)btnFilterTouch:(id)sender {
    switch (_session.filter) {
        case VCFilterNormal:
            [_session setFilter:VCFilterGray];
            break;
        case VCFilterGray:
            [_session setFilter:VCFilterInvertColors];
            break;
        case VCFilterInvertColors:
            [_session setFilter:VCFilterSepia];
            break;
        case VCFilterSepia:
            [_session setFilter:VCFilterNormal];
            break;
        default:
            break;
    }
}

- (void) connectionStatusChanged:(VCSessionState) state
{
    switch(state) {
        case VCSessionStateStarting:
            [self.btnConnect setTitle:@"Connecting" forState:UIControlStateNormal];
            break;
        case VCSessionStateStarted:
            [self.btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
            break;
        default:
            [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            break;
    }
}

@end
