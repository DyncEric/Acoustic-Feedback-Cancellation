//
//  IosAudioController.m
//  Aruts
//
//  Created by Kashyap Patel on 08/20/2019...
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IosAudioController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioFormat.h"
#import "IOBuffer.h"
#include <iostream>
#include <fstream>
#include <thread>
#include <chrono>
#include "Configuration.h"
using namespace std;


#define kOutputBus 0
#define kInputBus 1


IosAudioController* iosAudio;
Configuration* ConfigAudioEngine = Configuration::getInstance();
IOBuffer* ioBuffer = new IOBuffer(2*FRAME_SIZE*kNumberOfChannel);
RingBuffer* processBuffer = new RingBuffer();

int32_t frameswritten = 0;
int32_t framesread = 0;

Float32 placeHolder[FRAME_SIZE];
Float32 placeHolderOut[FRAME_SIZE];
audioData audio = {FRAME_SIZE, new Float32[FRAME_SIZE],new Float32[FRAME_SIZE]};

FILE *file;


static const int LENGTH_DATA = FRAME_SIZE * 128;
long countProcess = 0;
long sampleCounter = 0;
static const int NUM_SAMPLES = 128 * FRAME_SIZE;
float *activeBuffer;
float buffer1[LENGTH_DATA];
float buffer2[LENGTH_DATA];
float weight1[FRAME_SIZE];
float weight2[FRAME_SIZE];
float *activeWeight;
std::mutex asyncTaskLock;
Transform *X1 = newTransform(LENGTH_DATA);

static void asyncProcessData(float *data, float *w, void *userData) {
    std::mutex *lock = reinterpret_cast<std::mutex *>(userData);
    lock->lock();
    if (data != nullptr || w != nullptr) {
        CFTimeInterval startTime = CACurrentMediaTime();
        X1->doTransform(X1, data);
        CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
        printf("time: %f\n", elapsedTime);
        std::this_thread::sleep_for(std::chrono::milliseconds(10000));
        w[0]++;
        printf("w: %f\n",w[0]);
    }
    lock->unlock();
}


static void deInterleave(Float32 *someData, audioData *audio ,UInt32 inNumberFrames, int kNumChannels){
    // As number of channel are two, Data is interleaved. Since Microphone is not stereo,
    //we can just take Alternate samples and put into out left channel. In Recording left and right channel are equal.
    if (kNumChannels == 2){
        for(int sampleIdx = 0; sampleIdx < inNumberFrames; ++sampleIdx){
            audio->left[sampleIdx] = someData[2*sampleIdx];
           // printf("%f \n",audio->left[sampleIdx]);
            audio->right[sampleIdx] = someData[2*sampleIdx];
        }
    }
    else{
        for(int sampleIdx = 0; sampleIdx < inNumberFrames; ++sampleIdx){
            audio->left[sampleIdx] = someData[sampleIdx];
            audio->right[sampleIdx] = someData[sampleIdx];
        }
    }
    return;
}


static void reInterleave(Float32 *someData, audioData *audio,UInt32 inNumberFrames, int kNumChannels){
    if (kNumChannels == 2){
        for(int sampleIdx = 0; sampleIdx < inNumberFrames; ++sampleIdx){
            someData[2*sampleIdx] = audio->left[sampleIdx] ;
            someData[2*sampleIdx+1] = audio->right[sampleIdx] ;
        }
    }
    else
        for(int sampleIdx = 0; sampleIdx < inNumberFrames; ++sampleIdx){
            someData[sampleIdx] = audio->left[sampleIdx] ;
        }
    return;
}


void checkStatus(int status){
	if (status) {
		printf("Status not 0! %d\n", status);
//		exit(1);
	}
}

static void writeToFile(Float32 *data, int length){
    for(int i=0;i<length;i++){
        fprintf(file, "%f" , data[i]);
    }
    
}

/**
 This callback is called when new audio data from the microphone is
 available.
 */
static OSStatus recordingCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData) {
	
    CFTimeInterval startTime = CACurrentMediaTime();
	// Because of the way our audio format (setup below) is chosen:
	// we only need 1 buffer, since it is mono
	// Samples are 16 bits = 2 bytes.
	// 1 frame includes only 1 sample
	
	AudioBuffer buffer;
	
	buffer.mNumberChannels = kNumberOfChannel;
	buffer.mDataByteSize = inNumberFrames * sizeof(Float32) * kNumberOfChannel;
	buffer.mData = malloc( inNumberFrames * sizeof(Float32) * kNumberOfChannel );
	
	// Put buffer in a AudioBufferList
	AudioBufferList bufferList;
	bufferList.mNumberBuffers = 1;
	bufferList.mBuffers[0] = buffer;
	
    // Then:
    // Obtain recorded samples
	
    OSStatus status;	
    status = AudioUnitRender([iosAudio audioUnit], ioActionFlags,inTimeStamp,
                             inBusNumber, inNumberFrames, &bufferList);
	checkStatus(status);
	
    // Now, we have the samples we just read sitting in buffers in bufferList
	// Process the new data
	//[iosAudio processAudio:&bufferList];
    for (int i=0; i < bufferList.mNumberBuffers; i++) { // in practice we will only have 1 buffer, since audio format is mono
        AudioBuffer buffer = bufferList.mBuffers[i];
        Float32 *dataPtr = (Float32 *)buffer.mData;
        int32_t numFrames = buffer.mDataByteSize/sizeof(Float32);
        
        frameswritten =  processBuffer->write(dataPtr, numFrames);
        
        if (processBuffer->getSize() >= kNumberOfChannel*FRAME_SIZE) {
            processBuffer->read(placeHolder, kNumberOfChannel*FRAME_SIZE);
            deInterleave(placeHolder, &audio ,FRAME_SIZE, kNumberOfChannel);
            writeToFile(audio.left, FRAME_SIZE);
            if(ConfigAudioEngine->getIsAFCOn()){
                for (int i = 0; i < FRAME_SIZE; i++) {
                    activeBuffer[(sampleCounter + i) % NUM_SAMPLES] = audio.left[i];
                }
                sampleCounter += FRAME_SIZE;
               // processing(&audio, FRAME_SIZE);
                if (sampleCounter != 0 && sampleCounter % NUM_SAMPLES == 0) {
                    if (asyncTaskLock.try_lock()) {
                        float *processBuffer;
                        float *processWeight;
                        if (countProcess % 2 == 0) {
                            processBuffer = buffer1;
                            activeBuffer = buffer2;
                            processWeight = weight1;
                            activeWeight = weight2;
                        } else {
                            processBuffer = buffer2;
                            activeBuffer = buffer1;
                            processWeight = weight2;
                            activeWeight = weight1;
                        }
                        std::thread processThread(asyncProcessData, processBuffer, processWeight, &asyncTaskLock);
                        processThread.detach();
                        asyncTaskLock.unlock();
                    }
                }
            }
            reInterleave(placeHolder, &audio,FRAME_SIZE, kNumberOfChannel);
         
            // TODO process placeholder
            ioBuffer->write(placeHolder, kNumberOfChannel*FRAME_SIZE);
        }
        //printf("Frames Written %d \n",frameswritten);
    }
	// release the malloc'ed data in the buffer we created earlier
	free(bufferList.mBuffers[0].mData);
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    //printf("%f",elapsedTime);
    return noErr;
}

/**
 This callback is called when the audioUnit needs new data to play through the
 speakers. If you don't have any, just don't write anything in the buffers
 */
static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData) {    
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
	
	for (int i=0; i < ioData->mNumberBuffers; i++) { // in practice we will only ever have 1 buffer, since audio format is mono
		AudioBuffer buffer = ioData->mBuffers[i];
        framesread = ioBuffer->read((Float32*)buffer.mData,buffer.mDataByteSize/sizeof(Float32));
        //printf("%d \n",buffer.mDataByteSize/sizeof(Float32));
    }
    return noErr;
}

@implementation IosAudioController
@synthesize audioUnit;

/**
 Initialize the audioUnit and allocate our own temporary buffer.
 The temporary buffer will hold the latest data coming in from the microphone,
 and will be copied to the output when this is requested.
 */
- (id) init {
	self = [super init];
   
    [self setupIOunit];
    [self setupAudioSession];
    char buffer[256];

    //HOME is the home directory of your application
    //points to the root of your sandbox
    strcpy(buffer,getenv("HOME"));
    //concatenating the path string returned from HOME
    strcat(buffer,"/Documents/file1.txt");

    file = fopen(buffer, "w");
    if (file == NULL) {
        printf("Error opening file");
    }
    
    //Async process
    memset(weight1,0,FRAME_SIZE*sizeof(float));
    memset(weight2,0,FRAME_SIZE*sizeof(float));
    memset(buffer1,0,LENGTH_DATA*sizeof(float));
    memset(buffer2,0,LENGTH_DATA*sizeof(float));
    activeBuffer = buffer1;
    activeWeight = weight1;

	return self;
}

/**
 Start the audioUnit. This means data will be provided from
 the microphone, and requested for feeding to the speakers, by
 use of the provided callbacks.
 */
- (void) start {
	OSStatus status = AudioOutputUnitStart(audioUnit);
	checkStatus(status);
}

/**
 Stop the audioUnit
 */
- (void) stop {
	OSStatus status = AudioOutputUnitStop(audioUnit);
	checkStatus(status);
}


-(void) setupIOunit
{
    OSStatus status;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    checkStatus(status);
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    // Enable IO for playback
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    // Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate            = SAMPLING_FREQUENCY;
    audioFormat.mFormatID            = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat;
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame    = kNumberOfChannel;
    audioFormat.mBitsPerChannel        = 8*sizeof(Float32);
    audioFormat.mBytesPerPacket        = sizeof(Float32)*kNumberOfChannel;
    audioFormat.mBytesPerFrame        = sizeof(Float32)*kNumberOfChannel;
    
    // Apply format
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    // Set output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    
    // Allocate our own buffers (1 channel, 16 bits per sample, thus 16 bits per frame, thus 2 bytes per frame).
    // Practice learns the buffers used contain 512 frames, if this changes it will be fixed in processAudio.
    
    
    // Initialise
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status);
}


-(void) setupAudioSession
{
    NSError* theError = nil;
    BOOL result = YES;
    // Configure the AudioSession
    
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord
                     withOptions: AVAudioSessionCategoryOptionAllowBluetoothA2DP | AVAudioSessionCategoryOptionAllowAirPlay
                           error:NULL];  ///Play and Record
    [sessionInstance setPreferredSampleRate:SAMPLING_FREQUENCY error:NULL];
    [sessionInstance setPreferredIOBufferDuration:(float)FRAME_SIZE/SAMPLING_FREQUENCY error:NULL];
    
    
    NSArray* inputs = [sessionInstance availableInputs];
    
    // Locate the Port corresponding to the built-in microphone.
    AVAudioSessionPortDescription* builtInMicPort = nil;
    for (AVAudioSessionPortDescription* port in inputs){
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]){
            builtInMicPort = port;
            break;
        }
    }
    
    theError = nil;
    result = [sessionInstance setPreferredInput:builtInMicPort error:&theError];
    if (!result){
        // an error occurred. Handle it!
        NSLog(@"setPreferredInput failed");
    }
    
    // Set the session Active.
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    
    
    return;
}
/**
 Clean up.
 */
- (void) dealloc {
	//[super	dealloc];
    AudioOutputUnitStop(audioUnit);
	AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
   // audioUnit = NULL;
    if (file != NULL) {
        fflush(file);
        fclose(file);
    }
}

@end
