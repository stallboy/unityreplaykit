#ifndef AReplayKit_h
#define AReplayKit_h


@interface AReplayKit : NSObject<RPScreenRecorderDelegate, RPPreviewViewControllerDelegate, RPBroadcastActivityViewControllerDelegate, RPBroadcastControllerDelegate>

//-----

- (void)setGameObjectName:(nonnull NSString*)name;

//-----

- (void)startRecording;
- (void)stopRecording;
- (void)discardRecording;
- (BOOL)isRecording;

- (BOOL)canPreview;
- (void)preview;

- (void)setCameraPreviewLeft:(int)left top:(int)top width:(int)width height:(int)height;
- (void)setCameraEnabled:(BOOL)enable;
- (BOOL)isCameraEnabled;

- (void)setMicrophoneEnabled:(BOOL)enable;
- (BOOL)isMicrophoneEnabled;


- (void)screenRecorder:(nonnull RPScreenRecorder*)screenRecorder didStopRecordingWithError:(nonnull NSError*)error previewViewController:(nullable RPPreviewViewController*)previewViewController;

- (void)previewControllerDidFinish:(nonnull RPPreviewViewController*)previewController;

//-----

- (void)loadAndPresentBroadcastService;

- (void)broadcastActivityViewController:(nonnull RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error;


- (void)startBroadcast;
- (void)finishBroadcast;
- (BOOL)isBroadcasting;

- (void)pauseBroadcast;
- (void)resumeBroadcast;
- (BOOL)isPaused;

- (nonnull NSString*)getServiceInfo;

- (void)broadcastController:(nonnull RPBroadcastController *)broadcastController didFinishWithError:(nullable NSError *)error;
- (void)broadcastController:(nonnull RPBroadcastController *)broadcastController didUpdateServiceInfo:(nonnull NSDictionary<NSString *, NSObject<NSCoding> *> *)serviceInfo;


@end



#endif
