#import "Maksimtest.h"

#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))

@implementation Maksimtest


RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(multiply,
                 multiplyWithA:(double)a withB:(double)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    NSNumber *result = @(a * b);
    resolve(result);
}


RCT_REMAP_METHOD(getPeaks,
                 getPeaksWithPath:(NSString *)path
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    //NSDictionary *request = (NSDictionary *)call.arguments;
//    path = @"nw.mp3";
    NSString *audioInPath = (NSString *)path;
    //NSString *waveOutPath = (NSString *)request[@"waveOutPath"];
    NSNumber *samplesPerPixelArg = [NSNumber numberWithFloat:12.0];//(NSNumber *)request[@"samplesPerPixel"];
    NSNumber *pixelsPerSecondArg = [NSNumber numberWithFloat:6];//(NSNumber *)request[@"pixelsPerSecond"];
    NSMutableArray *fullSongDataMaksim = [NSMutableArray array];
    NSMutableArray *tempArray = [NSMutableArray array];
    NSNumber *count = [NSNumber numberWithInt:1];//(NSNumber *)request[@"samplesPerPixel"];

    
    NSString *result =[NSString stringWithFormat:@"%@%@", @"privetiki ", audioInPath];
    NSLog(@"%@", result);
    
    
    
    
        NSString *uri =  path;
        NSURL  *remoteUrl = [NSURL URLWithString:uri];

        //NSLog(@"NSURLRequest :: %@",remoteUrl);
        
        NSData *mdata = [NSData dataWithContentsOfURL:remoteUrl];
        if ( mdata )
        {
            NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            NSMutableString *randomString = [NSMutableString stringWithCapacity: 10];
            for (int i=0; i<10; i++) {
                [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
            }
            
            NSString *fileName = [NSString stringWithFormat:@"%@.m4a",randomString];
            NSLog(@"fileName = %@", fileName);
            self->_soundPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            [mdata writeToFile:self->_soundPath atomically:YES];
        }
        
        
        
        NSURL * localUrl = [NSURL fileURLWithPath: _soundPath];
        CFURLRef cfurl = CFBridgingRetain(localUrl);
        NSLog(@":::::::::::::: localUrl %@ ::::::::::::::",localUrl);

        ExtAudioFileRef audioFileRef;
        OSStatus status;
        UInt32 size;
        CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)self->_soundPath, kCFURLPOSIXPathStyle, false);
        status = ExtAudioFileOpenURL(url, &audioFileRef);
        if (status != noErr) {
            NSLog(@"ExtAudioOpenURL error: %i", status);
            dispatch_async(dispatch_get_main_queue(), ^{
                //result([FlutterError errorWithCode:@"ExtAudioOpenURL error" message:@"ExtAudioOpenURL error" details:nil]);
            });
            return;
        }
        NSLog(@":::::::::::::: ::::::::::: ::::::::::::::");
        NSLog(@":::::::::::::: случилось 2 ::::::::::::::");
        NSLog(@":::::::::::::: ::::::::::: ::::::::::::::");
        AudioStreamBasicDescription fileFormat;
        size = sizeof(fileFormat);
        status = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileDataFormat, &size, &fileFormat);
        if (status != noErr) {
            NSLog(@"ExtAudioFileGetProperty error: %i", status);
            dispatch_async(dispatch_get_main_queue(), ^{
                //result([FlutterError errorWithCode:@"Error reading file format" message:@"Error reading file format" details:nil]);
            });
            return;
        }
        
        SInt64 expectedSampleCount = 0;
        size = sizeof(expectedSampleCount);
        status = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileLengthFrames, &size, &expectedSampleCount);
        if (status != noErr) {
            NSLog(@"ExtAudioFileGetProperty error: %i", status);
            dispatch_async(dispatch_get_main_queue(), ^{
                //result([FlutterError errorWithCode:@"Error reading sample count" message:@"Error reading sample count" details:nil]);
            });
            return;
        }
        //NSLog(@"channel count = %d", fileFormat.mChannelsPerFrame);
        //NSLog(@"Sample rate = %f", fileFormat.mSampleRate);
        //NSLog(@"expected sample count = %d", expectedSampleCount);
        
        //NSLog(@"frames per packet: %d", fileFormat.mFramesPerPacket);
        
        int samplesPerPixel;
        if (samplesPerPixelArg != (id)[NSNull null]) {
            samplesPerPixel = [samplesPerPixelArg intValue];
        } else {
            samplesPerPixel = (int)(fileFormat.mSampleRate / [pixelsPerSecondArg intValue]);
        }
        
        // Multiply by 2 since 2 bytes are needed for each short, and multiply by 2 again because for each sample we store a pair of (min,max)
        UInt32 scaledByteSamplesLength = 2*2*(UInt32)(expectedSampleCount / samplesPerPixel);
        UInt32 waveLength = (UInt32)(scaledByteSamplesLength / 2); // better name: numPixels?
        //NSLog(@"wave length = %d", waveLength);
        
        int bytesPerChannel = 2;
        AudioStreamBasicDescription clientFormat;
        clientFormat.mSampleRate = fileFormat.mSampleRate;
        clientFormat.mFormatID = kAudioFormatLinearPCM;
        clientFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger;
        clientFormat.mBitsPerChannel = bytesPerChannel * 8;
        clientFormat.mChannelsPerFrame = fileFormat.mChannelsPerFrame;
        clientFormat.mBytesPerFrame = clientFormat.mChannelsPerFrame * bytesPerChannel;
        clientFormat.mFramesPerPacket = 1;
        clientFormat.mBytesPerPacket = clientFormat.mFramesPerPacket * clientFormat.mBytesPerFrame;
        
        status = ExtAudioFileSetProperty(audioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &clientFormat);
        if (status != noErr) {
            NSLog(@"ExtAudioFileSetProperty error: %i", status);
            dispatch_async(dispatch_get_main_queue(), ^{
                //result([FlutterError errorWithCode:@"Error setting client format" message:@"Error setting client format" details:nil]);
            });
            return;
        }
        
        UInt32 packetsPerBuffer = 4096;//1160;//4096; // samples/frames per buffer
        UInt32 outputBufferSize = packetsPerBuffer * clientFormat.mBytesPerPacket;
        
        AudioBufferList convertedData;
        convertedData.mNumberBuffers = 1;
        convertedData.mBuffers[0].mNumberChannels = clientFormat.mChannelsPerFrame;
        convertedData.mBuffers[0].mDataByteSize = outputBufferSize;
        // XXX: Do we need to free this on iOS?
        convertedData.mBuffers[0].mData = (UInt8 *)malloc(sizeof(UInt8 *) * outputBufferSize);
        
        UInt32 frameCount = packetsPerBuffer;
        UInt32 sampleIdx = 0;
        short minSample = 32767;
        short maxSample = -32768;
        int waveHeaderLength = 20;
        UInt32 waveFileContentLength = waveHeaderLength + sizeof(short *) * waveLength;
        UInt8 *waveFileContent = (UInt8 *)malloc(waveFileContentLength);
        UInt32 *waveHeader = (UInt32 *)waveFileContent;
        short *wave = (short *)(waveFileContent + waveHeaderLength);
        UInt32 scaledSampleIdx = 0;
        int progress = 0;
        
        while (frameCount > 0) {
            status = ExtAudioFileRead(audioFileRef, &frameCount, &convertedData);
            if (status != noErr) {
                NSLog(@"ExtAudioFileRead error: %i", status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //result([FlutterError errorWithCode:@"ExtAudioFileRead error" message:@"ExtAudioFileRead error" details:nil]);
                });
                break;
            }
            if (frameCount > 0) {
                AudioBuffer audioBuffer = convertedData.mBuffers[0];
                short *samples = (short *)audioBuffer.mData;
                
                // Each frame may have two channels making 2*frameCount individual L/R samples.
                int sampleCount = clientFormat.mChannelsPerFrame * frameCount;
                for (int i = 0; i < sampleCount; i += clientFormat.mChannelsPerFrame) {
                    long sample = 0;
                    for (int j = 0; j < clientFormat.mChannelsPerFrame; j++) {
                        sample += samples[i+j];
                    }
                    sample /= clientFormat.mChannelsPerFrame;
                    if (sample < -32768) sample = -32768;
                    if (sample > 32767) sample = 32767;
                    if (sample < minSample) minSample = (short)sample;
                    if (sample > maxSample) maxSample = (short)sample;
                    sampleIdx++;
                    if (sampleIdx % samplesPerPixel == 0) {
                        if (scaledSampleIdx + 1 < waveLength) {
                            wave[scaledSampleIdx++] = minSample;
                            wave[scaledSampleIdx++] = maxSample;
                            int newProgress = (int)(100 * scaledSampleIdx / waveLength);
                            if (newProgress != progress && newProgress <= 100) {
                                progress = newProgress;
                                //NSLog(@"Progress: %d percent", progress);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //[_channel invokeMethod:@"onProgress" arguments:@(progress)];
                                });
                            }
                            //NSLog(@"pixel[%d] %d: %d\t%d", scaledSampleIdx - 2, sampleIdx, minSample, maxSample);
                            NSArray *ex = @[[NSNumber numberWithInteger: minSample], [NSNumber numberWithInteger: maxSample]];
                            [fullSongDataMaksim addObject:ex];

                            minSample = 32767;
                            maxSample = -32768;
                        }
                    }

                }
                //NSLog(@"%@",count);
                //count = @([count intValue] + 1);

            }
        }

    resolve(fullSongDataMaksim);

}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeMaksimtestSpecJSI>(params);
}
#endif

@end
