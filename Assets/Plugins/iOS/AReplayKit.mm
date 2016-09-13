#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>
#import "AReplayKit.h"
#include "UnityForwardDecls.h"

//-----

// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
    if (string)
        return [NSString stringWithUTF8String: string];
    else
        return nil;
}

// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

static AReplayKit* _replayKit;


@implementation AReplayKit
{
    NSString* _gameObjectName;
    RPPreviewViewController* _previewController;
    CGRect _cameraPreviewRect;
    BOOL _cameraPreviewRectHasBeenSet;
    
    RPBroadcastController* _broadcastController;
}

+ (AReplayKit*)Instance
{
    if (_replayKit == nil)
    {
        _replayKit = [[AReplayKit alloc] init];
    }
    return _replayKit;
}

- (void)setGameObjectName:(nonnull NSString*)name
{
    _gameObjectName = name;
}

- (void)send:(nonnull NSString*)methodName msg:(nullable NSString*)msg
{
    if (_gameObjectName == nil)
    {
        _gameObjectName = @"_replaykit";
    }
    if (msg == nil)
    {
        msg = @"";
    }
    UnitySendMessage(MakeStringCopy([_gameObjectName UTF8String]),
                     MakeStringCopy([methodName UTF8String]),
                     MakeStringCopy([msg UTF8String]));
}

- (void)debuglog:(nullable NSString*)msg
{
    [self send:@"DebugLog" msg:msg];
}


- (void)startRecording
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        [self send:@"ScreenRecorder_StartRecordingComplete" msg:@"Failed to get Screen Recorder"];
        return;
    }
    
    [recorder setDelegate:self];
    [recorder startRecordingWithHandler:^(NSError * _Nullable error) {
        if (error == nil)
        {
            [self send:@"ScreenRecorder_StartRecordingComplete" msg:nil];
            return;
        }
        else
        {
            [self send:@"ScreenRecorder_StartRecordingComplete" msg:[error description]];
        }
    }];
    
    [self debuglog:@"startRecording done"];
}

- (void)stopRecording
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        [self send:@"ScreenRecorder_StopRecordingComplete" msg:@"Failed to get Screen Recorder"];
        return;
    }
    [recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        if (error != nil)
        {
            [self send:@"ScreenRecorder_StopRecordingComplete" msg:[error description]];
            return;
        }
        
        if (previewViewController != nil)
        {
            [previewViewController setPreviewControllerDelegate:self];
            _previewController = previewViewController;
        }
        [self send:@"ScreenRecorder_StopRecordingComplete" msg:nil];
    }];
    
    [self debuglog:@"stopRecording done"];
}

- (void)discardRecording
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        [self send:@"ScreenRecorder_DiscardRecordingComplete" msg:@"Failed to get Screen Recorder"];
        return;
    }
    
    [recorder discardRecordingWithHandler:^{
        _previewController = nil;
        [self send:@"ScreenRecorder_DiscardRecordingComplete" msg:nil];
    }];
    
    [self debuglog:@"discardRecording done"];
}


- (BOOL)isRecording
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        return NO;
    }
    
    return [recorder isRecording];
}

- (BOOL)canPreview
{
    return _previewController != nil;
}

- (void)preview
{
    if (_previewController == nil)
    {
        return;
    }
    
    [_previewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [[[UnityGetGLView() window] rootViewController] presentViewController:_previewController animated:YES completion:^()
     {
         //_previewController = nil;
     }];
}

- (void)setCameraPreviewLeft:(int)left top:(int)top width:(int)width height:(int)height
{
    _cameraPreviewRect.origin.x = left;
    _cameraPreviewRect.origin.y = top;
    _cameraPreviewRect.size.width = width;
    _cameraPreviewRect.size.height = height;
    _cameraPreviewRectHasBeenSet = YES;
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        return;
    }
    UIView* view = [recorder cameraPreviewView];
    if (view != nil)
    {
        view.frame = _cameraPreviewRect;
    }
}

- (void)requestPermissionForMediaType:(NSString*)mediaType didFinish: (void (^)(NSString* error))handler
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (authStatus) 
    {
        case AVAuthorizationStatusAuthorized:
            handler(nil);
            break;
        case AVAuthorizationStatusDenied:
            handler(@"AVAuthorizationStatusDenied");
            break;
        case AVAuthorizationStatusRestricted:
            handler(@"AVAuthorizationStatusRestricted");
            break;
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if (granted)
                {
                    handler(nil);
                }
                else
                {
                    handler(@"requestAccessForMediaType NotGranted");
                }
            }];
            break;
    }
}

- (void)setCameraEnabled:(BOOL)enable
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        if (enable)
        {
            [self send:@"ScreenRecorder_EnableCameraComplete" msg:@"Failed to get Screen Recorder"];
        }
        return;
    }
    if (enable)
    {
        [self requestPermissionForMediaType:AVMediaTypeVideo didFinish:^(NSString *error) {
            
            if (error == nil)
            {
                recorder.cameraEnabled = enable;
                UIView* view = [recorder cameraPreviewView];
                if (view != nil)
                {
                    if (_cameraPreviewRectHasBeenSet)
                    {
                        view.frame = _cameraPreviewRect;
                    }
                    [UnityGetGLView() addSubview:view];
                    [self send:@"ScreenRecorder_EnableCameraComplete" msg:nil];
                }
                else
                {
                    [self send:@"ScreenRecorder_EnableCameraComplete" msg:@"cameraPreviewView nil"];
                }
                
            }
            else
            {
                [self send:@"ScreenRecorder_EnableCameraComplete" msg:error];
            }
        }];
    }
    else
    {
        recorder.cameraEnabled = enable;
        UIView* view = [recorder cameraPreviewView];
        if (view != nil)
        {
            [view removeFromSuperview];
        }
    }
}

- (BOOL)isCameraEnabled
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        return NO;
    }
    
    return recorder.cameraEnabled;
}

- (void)setMicrophoneEnabled:(BOOL)enable
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        if (enable)
        {
            [self send:@"ScreenRecorder_EnableMicrophoneComplete" msg:@"Failed to get Screen Recorder"];
        }
        return;
    }
    if (enable)
    {
        [self requestPermissionForMediaType:AVMediaTypeAudio didFinish:^(NSString *error) {
            if (error == nil)
            {
                recorder.microphoneEnabled = enable;
                [self send:@"ScreenRecorder_EnableMicrophoneComplete" msg:nil];
            }
            else
            {
                [self send:@"ScreenRecorder_EnableMicrophoneComplete" msg:error];
            }
        }];
    }
    else
    {
        recorder.microphoneEnabled = enable;
    }
}

- (BOOL)isMicrophoneEnabled
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        return NO;
    }
    
    return recorder.microphoneEnabled;
}


- (void)screenRecorder:(nonnull RPScreenRecorder*)screenRecorder didStopRecordingWithError:(nonnull NSError*)error previewViewController:(nullable RPPreviewViewController*)previewViewController
{
    _previewController = previewViewController;
    [self send:@"ScreenRecorder_DidStopRecordingWithError" msg:[error description]];
}

- (void)previewControllerDidFinish:(nonnull RPPreviewViewController*)previewController
{
    [previewController dismissViewControllerAnimated:YES completion:nil];
    [self send:@"ScreenRecorder_PreviewControllerDidFinish" msg:nil];
}

- (void)loadAndPresentBroadcastService
{
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
        if (error != nil)
        {
            [self send:@"BroadcastActivityViewController_LoadComplete" msg:[error description]];
            return;
        }
        if (broadcastActivityViewController != nil)
        {
            broadcastActivityViewController.delegate = self;
            [[[UnityGetGLView() window] rootViewController] presentViewController:broadcastActivityViewController animated:YES completion:^{
                [self send:@"BroadcastActivityViewController_LoadComplete" msg:nil];
            }];
        }
        else
        {
            [self send:@"BroadcastActivityViewController_LoadComplete" msg:@"error is nil, but no broadcastActivityViewController"];
        }
    }];
}


- (void)broadcastActivityViewController:(nonnull RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error
{
    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:^{
        if (error != nil)
        {
            [self send:@"BroadcastActivityViewController_DidFinish" msg:[error description]];
            return;
        }
        
        if (broadcastController != nil)
        {
            _broadcastController = broadcastController;
            _broadcastController.delegate = self;
            [self send:@"BroadcastActivityViewController_DidFinish" msg:nil];
        }
        else
        {
            _broadcastController = nil;
            [self send:@"BroadcastActivityViewController_DidFinish" msg:@"error is nil, but no broadcastController"];
        }
    }];
}


- (void)startBroadcast
{
    if (_broadcastController == nil)
    {
        [self send:@"Broadcast_StartBroadcastComplete" msg:@"broadcastController nil"];
        return;
    }
    [_broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (error == nil)
        {
            [self send:@"Broadcast_StartBroadcastComplete" msg:nil];
        }
        else
        {
            [self send:@"Broadcast_StartBroadcastComplete" msg:[error description]];
        }
    }];
    
    [self debuglog:@"startBroadcast done"];
}

- (void)finishBroadcast
{
    if (_broadcastController == nil)
    {
        [self send:@"Broadcast_FinishBroadcastComplete" msg:@"broadcastController nil"];
        return;
    }
    [_broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (error == nil)
        {
            [self send:@"Broadcast_FinishBroadcastComplete" msg:nil];
        }
        else
        {
            [self send:@"Broadcast_FinishBroadcastComplete" msg:[error description]];
        }
    }];
    
    [self debuglog:@"finishBroadcast done"];
}

- (BOOL)isBroadcasting
{
    if (_broadcastController == nil)
    {
        return NO;
    }
    return [_broadcastController isBroadcasting];
}


- (void)pauseBroadcast
{
    if (_broadcastController == nil)
    {
        return;
    }
    [_broadcastController pauseBroadcast];
}

- (void)resumeBroadcast
{
    if (_broadcastController == nil)
    {
        return;
    }
    [_broadcastController resumeBroadcast];
}

- (BOOL)isPaused
{
    if (_broadcastController == nil)
    {
        return NO;
    }
    return [_broadcastController isPaused];
}

- (nonnull NSString*)getServiceInfo
{
    if (_broadcastController == nil)
    {
        return @"";
    }
    return [[_broadcastController serviceInfo] description];
}


- (void)broadcastController:(nonnull RPBroadcastController *)broadcastController didFinishWithError:(nullable NSError *)error
{
    if (error != nil)
    {
        [self send:@"BroadcastController_DidFinishWithError" msg:[error description]];
    }
    else
    {
        [self send:@"BroadcastController_DidFinishWithError" msg:nil];
    }
}

- (void)broadcastController:(nonnull RPBroadcastController *)broadcastController didUpdateServiceInfo:(nonnull NSDictionary<NSString *, NSObject<NSCoding> *> *)serviceInfo
{
    [self send:@"BroadcastController_DidUpdateServiceInfo" msg:[serviceInfo description]];
}



@end



//-----

extern "C"
{
    
    void replaykitcallback_SetGameObjectName(const char* name)
    {
        [[AReplayKit Instance] setGameObjectName: CreateNSString(name)];
    }
    
    //-----
    
    void rpscreenrecorder_StartRecording()
    {
        [[AReplayKit Instance] startRecording];
    }
    
    void rpscreenrecorder_StopRecording()
    {
        if (_replayKit != nil)
        {
            [_replayKit stopRecording];
        }
    }
    
    void rpscreenrecorder_DiscardRecording()
    {
        if (_replayKit != nil)
        {
            [_replayKit discardRecording];
        }
    }
    
    int rpscreenrecorder_IsRecording()
    {
        if (_replayKit == nil)
        {
            return -1;
        }
        return [_replayKit isRecording] == YES;
    }
    
    int rpscreenrecorder_CanPreview()
    {
        if (_replayKit == nil)
        {
            return -1;
        }
        return [_replayKit canPreview] == YES;
    }
    
    void rpscreenrecorder_Preview()
    {
        if (_replayKit != nil)
        {
            [_replayKit preview];
        }
    }
    
    void rpscreenrecorder_SetCameraPreviewPositionAndSize(int left, int top, int width, int height)
    {
        [[AReplayKit Instance] setCameraPreviewLeft:left top:top width:width height:height];
    }
    
    void rpscreenrecorder_SetCameraEnabled(int enable)
    {
        [[AReplayKit Instance] setCameraEnabled: enable];
    }
    
    int rpscreenrecorder_IsCameraEnabled()
    {
        return [[AReplayKit Instance]  isCameraEnabled] == YES;
    }
    
    void rpscreenrecorder_SetMicrophoneEnabled(int enable)
    {
        [[AReplayKit Instance] setMicrophoneEnabled: enable];
    }
    
    int rpscreenrecorder_IsMicrophoneEnabled()
    {
        return [[AReplayKit Instance]  isMicrophoneEnabled] == YES;
    }
    
    
    //-----
    
    void rpbroadcast_LoadAndPresent()
    {
        [[AReplayKit Instance] loadAndPresentBroadcastService];
    }
    
    
    void rpbroadcast_StartBroadcast()
    {
        if (_replayKit != nil)
        {
            [_replayKit startBroadcast];
        }
    }
    
    void rpbroadcast_FinishRecording()
    {
        if (_replayKit != nil)
        {
            [_replayKit finishBroadcast];
        }
    }
    
    int rpbroadcast_IsBroadcasting()
    {
        if (_replayKit == nil)
        {
            return -1;
        }
        return [_replayKit isBroadcasting] == YES;
    }
    
    void rpbroadcast_PauseBroadcast()
    {
        if (_replayKit != nil)
        {
            [_replayKit pauseBroadcast];
        }
    }
    
    void rpbroadcast_ResumeBroadcast()
    {
        if (_replayKit != nil)
        {
            [_replayKit resumeBroadcast];
        }
    }
    
    int rpbroadcast_IsPaused()
    {
        if (_replayKit == nil)
        {
            return -1;
        }
        return [_replayKit isPaused] == YES;
    }
    
    const char* rpbroadcast_GetServiceInfo()
    {
        if (_replayKit == nil)
        {
            return 0;
        }
        
        return MakeStringCopy([[_replayKit getServiceInfo] UTF8String]);
    }
    
}
