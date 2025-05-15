// Copyright NVIDIA Corporation 2017-2021
// TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SOFTWARE IS PROVIDED
// *AS IS* AND NVIDIA AND ITS SUPPLIERS DISCLAIM ALL WARRANTIES, EITHER EXPRESS
// OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL
// NVIDIA OR ITS SUPPLIERS BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR
// CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR
// LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS
// INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
// INABILITY TO USE THIS SOFTWARE, EVEN IF NVIDIA HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGES.

/// \file StreamConfig.h
/// Header file with defintions of Stream Configs.

#pragma once

#include "../client/VideoDecoder.h"
#include "AudioFrame.h"
#include "InputEvent.h"
#include "Result.h"
#include "StreamData.h"
#include "VideoDecodeUnit.h"
#include "VideoFormat.h"

#include <stdint.h>
#include <stdbool.h>

/// \defgroup Stream Stream interface

/** \defgroup Video Video Configs
  * \ingroup NvstStreamStruct
  */

/** \defgroup Audio Audio Configs
  * \ingroup NvstStreamStruct
  */

/** \defgroup Mic Mic Configs
  * \ingroup NvstStreamStruct
  */

/** \defgroup Input Input Configs
  * \ingroup NvstStreamStruct
  */

/** \defgroup Message Message Configs
  * \ingroup NvstStreamStruct
  */

/// Direction of stream.
/// \ingroup Video
typedef enum NvstStreamDirection_t
{
    NVST_SD_SENDER = 0,
    NVST_SD_RECEIVER = 1,
} NvstStreamDirection;

typedef struct NvstConnection_t* NvstConnection;

/// Handle of a Direct3D device that is provided by client.
typedef void* NvstDxDevice;

/// Defines a streaming mode.
/// \ingroup Video
typedef struct NvstStreamingMode_t
{
    uint16_t width;
    uint16_t height;
    /// This is an estimate of the actual streaming fps and it is used for configuring the encoder
    /// so that it can maintain the desired bitrate.
    uint16_t actualStreamingFps;
    /// This param represents the desired streaming fps and it is used to control capture thread timing.
    /// Ideally, the first param (actual streaming fps) should closely match the second (target streaming fps),
    /// but they may differ, e.g. if the game can't generate frames quickly enough.
    uint16_t targetStreamingFps;
} NvstStreamingMode;

/// Defines status of a video frame after encoding.
/// \todo Find whether this struct is also needed in the client.
/// \ingroup Video
typedef struct NvstVideoFrameStatus_t
{
    uint32_t frameNumber;
    uint16_t size;
    uint16_t width;
    uint16_t height;
    /// Video frame's type (e.g. IDR, P-frame, etc.)
    /// \todo Add enum for this.
    uint16_t type;
    bool dropped;
} NvstVideoFrameStatus;

/// Defines status of QoS and recommendation for resolution.
/// \todo to find whether this struct is also needed in the client
/// \ingroup Video
typedef struct NvstQosStatus_t
{
    /// Index of the video stream in the multi-monitor use case
    uint16_t streamIndex;
    /// bitrate bps to be used for the next frame
    uint16_t qosBitrate;
    /// FEC repair percent
    uint16_t fecPercent;
    /// Capture fullscreen or not
    /// \todo This should not be part of QoS structure. Move it to config update callback.
    bool bCaptureFullScreen;
    /// SDK's recommended resolution/FPS for the application to render at.
    NvstStreamingMode recommendedMode;
    /// Reserved param
    void* reserved;
    /// Resolution pixel alignment recommendation, as configured by upper layers or client directly.
    uint8_t pixelAlignment;
    /// If pixel alignment takes place, round in favor of values close to this reference aspect ratio.
    double referenceAspectRatio;
    /// The preferred streaming resolution, before any pixel alignment adjustments.
    uint32_t preferredHeight;
    uint32_t preferredWidth;
    /// Average round trip delay in ms
    uint32_t averageRtdMs;
    /// Whether the frame provider should scale the frame for GRC.
    /// If true, the app should provide a frame with a constant encode size and a data size set to
    /// the recommended resolution
    /// \todo For now, this is only useful for internal video streams. NvstGraphicsSurface needs to be extended
    /// to let apps pass in video frame encode size
    bool bEnableGrc;

} NvstQosStatus;

/// Defines a range of frame that are to be invalidated
/// \ingroup Video
typedef struct NvstFrameInvalidationRange_t
{
    /// Start frame id that needs to be invalidated
    uint64_t rangeStart;
    /// Frame id till which frames are to be invalidated
    uint64_t rangeEnd;
} NvstFrameInvalidationRange;

/// Defines receiver-specific configuration of the audio stream.
/// \ingroup Audio
typedef struct NvstAudioReceiverStreamConfig_t
{
    /// Specify if the render callback would be blocking.
    /// \remarks
    /// If this callback is blocking, render callback would be called periodically by the SDK. The SDK would maintain
    /// real-time playback in this case.
    /// If this callback is not blocking, render callback would be called immediately, and  client should
    /// block the callback to maintain real-time playback. This is useful in cases where a blocking audio API is used
    /// or where the audio API uses a notification mechanism (event/semaphore/callback not requiring data to be
    /// written) to notify the user that audio can be written to the API.
    bool blocking;

    /// Context pointer to be passed back whenever the callback is invoked.
    void* context;

    /// Function to deliver the audio stream to the renderer.
    /// \param[in] context Application-supplied pointer.
    /// \param[in] streamConn Stream connection associated with the audio stream.
    /// \param[in] audioFrame Struct representing an audio frame.
    void (*onAudioReceived)(void* context, NvstStreamConnection streamConn, const NvstAudioFrame* audioFrame);
} NvstAudioReceiverStreamConfig;

/// Defines configuration of the audio stream.
/// \remarks
/// Audio streams may be configured in push mode or in pull mode.
/// In push mode, data to be sent would be sent by explicitly calling
/// nvstPushStreamData.
/// In pull mode, the following callback should be specified by application,
/// and server will invoke this callback to pull data to be sent.
/// \warning Pull mode is not supported in the initial release.
/// \ingroup Audio
typedef struct NvstAudioStreamConfig_t
{
    /// \warning The parameter is not operational in current release.
    bool fecEnabled;
    /// \warning The parameter is not operational in current release.
    bool encryptionEnabled;
    /// \warning The parameter is not operational in current release.
    NvstAudioFormat format;
    /// Length of the audio frame (in milliseconds)
    /// \warning The parameter is not operational in current release.
    uint16_t frameLengthMs;
    /// Enable opus multimapping mode for surround audio streaming
    bool opusMappingMode;
    /// Enable raw audio data dump (for debug purpose)
    bool pcmDumpEnabled;
    /// Channel count to be used for streaming the audio output
    uint8_t channelCountSupported;
    /// Stream direction.
    NvstStreamDirection streamDirection;
    /// Receiver-specific audio stream configuration.
    NvstAudioReceiverStreamConfig receiverConfig;
} NvstAudioStreamConfig;

/// Convenience typedef for library consumers.
typedef void (
    *ON_AUDIO_RECEIVED_PROC)(void* context, NvstStreamConnection streamConn, const NvstAudioFrame* audioFrame);

/// Defines sender-specific configuration of the mic stream.
/// \ingroup Mic
typedef struct NvstMicSenderStreamConfig_t
{
    /// Enables mic capture to be performed internally by the streaming stack.
    /// It is available only on Android platforms.
    bool performCapture;
} NvstMicSenderStreamConfig;

/// Defines reciever-specific configuration of the microphone stream.
/// \ingroup Mic
typedef struct NvstMicReceiverStreamConfig_t
{
    /// Context pointer to be passed back whenever the callback is invoked.
    void* context;

    /// Callback to receive mic stream.
    /// \param[in] context application-supplied pointer.
    /// \param[in] data struct representing mic data.
    NvstResult (*micStreamCallback)(void* context, const NvstStreamData* data);
} NvstMicReceiverStreamConfig;

// Bits to determine microphone bandwidth optimization method
/// \ingroup Mic
typedef enum MicBWOptimizationType_t
{
    // mic bandwidth optimization is disabled
    MIC_BW_OPTIMIZATION_NONE = 0,
    // server supports mic frame size of 5/10 ms and bitrate of 16K/32K
    MIC_BW_OPTIMIZATION_L1 = 0x1,
    // server supports packetizer
    MIC_BW_OPTIMIZATION_L2 = 0x2
} MicBWOptimizationType;

/// \def NVST_MIC_ARRAY_LENGTH
/// This is an arbitrary value that should be large enough for any usage needs.  It can be changed,
/// if necessary, without affecting any code.
/// \ingroup Mic
#define NVST_MIC_ARRAY_LENGTH 20

/// Defines the configuration of the microphone stream.
/// \remarks
/// Microphone stream is a receive-only stream which receives microphone
/// data from server.
/// \warning Currently receive and render for this stream is handled internally,
/// NvstMicEvent based callbacks are invoked from SDK for application's device handling
/// micStreamCallback handler for NVST_MIC_DATA_READY is responsible for maintaining the
/// real time; typically hold the callback for timeperiod = packet duration
/// \ingroup Mic
typedef struct NvstMicStreamConfig_t
{
    NvstAudioFormat format;

    /// Length of the audio frame (in milliseconds).
    uint16_t frameLengthMs;

    /// Stream direction.
    NvstStreamDirection streamDirection;

    /// A bitset of MicBWOptimizationTypes that the server will allow.
    /// If unsure, use MIC_BW_OPTIMIZATION_L1 | MIC_BW_OPTIMIZATION_L2
    int bandwidthOptimizationMethod;

    /// Frame sizes that the server will allow.  A semi-colon delimited set of integers.
    /// If unsure, use "10;5;"
    /// \todo Change this to an array of ints.
    char supportedFrameSize[NVST_MIC_ARRAY_LENGTH];

    /// Retransmit counts that the server will allow.  A semi-colon delimited set of integers.
    /// If unsure, use "3;2;1;0;"
    /// \todo Change this to an array of ints.
    char supportedPacketsRetransmitCount[NVST_MIC_ARRAY_LENGTH];

    union
    {
        /// Reciever-specific mic stream configuration.
        NvstMicReceiverStreamConfig receiverConfig;

        /// Sender-specific mic stream configuration.
        NvstMicSenderStreamConfig senderConfig;
    };
} NvstMicStreamConfig;

/// Enumeration of video content types.
/// \ingroup Video
typedef enum NvstVideoContentType_t
{
    /// Special value indicating that stream will use reasonable defaults.
    NVST_VC_NONE = 0,
    /// Gaming content.
    NVST_VC_GAMING = 1,
    /// Professional content.
    NVST_VC_PROFESSIONAL = 2,
    /// VR content.
    NVST_VC_VR = 3,
    /// Gaming content, streamed from high density server.
    NVST_VC_GAMING_HIGH_DENSITY_SERVER = 4,
    /// VR + Virtual Vsync
    NVST_VC_VR_VVSYNC = 5,
    /// Not a valid content type - used only to count types.
    NVST_VC_END,
} NvstVideoContentType;

/// Streaming latency type.
/// \ingroup Video
typedef enum NvstStreamingType_t
{
    /// Streaming with default latency.
    NVST_ST_DEFAULT = 0,
    /// Streaming in Turbo mode.
    ///
    /// Turbo mode is a variable, high-framerate streaming mode, which currently operates at up to 120 FPS,
    /// although higher framerates could be enabled in the future. The goal is latency reduction as compared
    /// to traditional 60 FPS / 30 FPS streaming modes, even if video quality is slightly degraded.
    /// Actual framerates can fall below 120 FPS if the game is running slowly, the client pipeline can’t process
    /// the video stream quickly enough, or if video quality is too poor.
    NVST_ST_TURBO_MODE = 1,
    /// Not a valid streaming type - used only to count types.
    NVST_ST_END,
} NvstStreamingType;

/// Frame pacing feedback modes.
/// \ingroup Video
typedef enum NvstFramePacingFeedbackMode_t
{
    /// Never send frame pacing feedback.
    NVST_FRAME_PACING_FEEDBACK_NEVER = 0,
    /// Send frame pacing feedback together with QoS stats.
    NVST_FRAME_PACING_FEEDBACK_INTERVAL = 1,
    /// Send frame pacing feedback on every frame.
    NVST_FRAME_PACING_FEEDBACK_PERFRAME = 2,
} NvstFramePacingFeedbackMode;

/// Defines reciever-specific configuration of the video stream.
/// \todo Put in a more elaborate explanation what these fields are.
/// \ingroup Video
typedef struct NvstVideoReceiverStreamConfig_t
{
    /// YCbCr color space conversion mode for video encoding.
    NvstCscMode cscMode;

    /// Pick recommended streaming mode if true, use provided mode if false
    bool autoMode;

    /// Maximum bitrate.
    /// \note If max bitrate set to 0, then SDK will calculate bitrate considering the resolution and fps.
    uint32_t maximumBitrateKbps;

    /// Video content type.
    NvstVideoContentType vct;

    /// Enable video scaling.
    bool enableVideoScale;

    /// Dynamic range mode.
    NvstHdrMode dynamicRangeMode;

    /// Streaming latency type.
    NvstStreamingType streamingType;

    /// Format of the encoded video which should be produced by the server.
    NvstVideoFormat format;

    /// Maximum numer of reference frames.
    /// Specify maximum number of reference frames decoder needs to maintain on client.
    /// Clients can choose values from 1 to 16.
    /// Standards specify the max at 16, hence server will cap the value even
    /// if client passes any value greater than 16. If client set this value to 0,
    /// it means maximum number of reference frames will be determined based on standard limits.
    uint32_t maximumReferenceFrames;

    /// H.264 encoder deblocking filter mode.
    uint32_t videoEncoderDeblockingMode;

    /// No. of slices into which frames are divided.
    uint32_t videoEncoderSlicesPerFrame;

    /// Video Decoder info.
    NvstVideoDecoder videoDecoder;

    /// When to send this feedback: never, once per frame, or together with QoS stats.
    NvstFramePacingFeedbackMode feedbackMode;

    /// Whether frames are done as whole or as slices.
    uint8_t fullFrameAssembly;

    /// Permit gradual resolution changes for this video stream
    /// If true, and supported by the server, the SDK will change the resolution much more frequently than usual.
    /// The resolution may even change multiple frames in a row.
    bool permitGrc;

    /// Receive a H.264 decode unit to the decoder.
    ///
    /// \param[in] context Application-supplied pointer.
    /// \param[in] streamConn Stream connection associated with the video stream.
    /// \param[in] vu Struct representing a VU (a portion of the H.264 stream).
    void (*onVideoReceived)(void* context, NvstStreamConnection streamConn, const NvstVideoDecodeUnit* vdu);

    /// Context pointer to be passed back whenever the callbacks are invoked.
    void* context;
} NvstVideoReceiverStreamConfig;

/// Convenience typedef for library consumers.
typedef void (*CONTROL_VIDEO_JITTER_BUFFER)(void* context, NvstStreamConnection streamConn, bool bEnable);

/// Convenience typedef for library consumers.
typedef void (*ON_VIDEO_RECEIVED_PROC)(void* context, NvstStreamConnection streamConn, const NvstVideoDecodeUnit* vdu);

/// \def NVST_DEFAULT_ADAPTER
/// Default adapter value.
///
/// Used to delegate adapter choice to StreamSDK. We do not use zero because
/// it is a possible real value for adapter.
#define NVST_DEFAULT_ADAPTER 0xFFFFFFFF
/// Place holder for CUDA device and context
/// \ingroup Video
typedef struct NvstCudaDeviceInfo_t
{
    /// CUDA device used by the application.
    /// This needs to be Dx9 inter-operable for SDK to be able to use low latency node.
    int cudaDevice;
    /// Context that will be used by the application thread that calls nvstPushStreamData.
    /// This cannot be NULL if cudaDevice is not NULL.
    void* cudaContext;
} NvstCudaDeviceInfo;

/// Defines sender-specific configuration of the video stream.
/// \ingroup Video
typedef struct NvstVideoSenderStreamConfig_t
{
    /// Index of adapter to send frames from. Not used for
    /// pre-encoded video streams.
    ///
    /// If set to NVST_DEFAULT_ADAPTER, StreamSDK will attempt to determine
    /// the correct adapter to use.
    uint32_t adapter;

    /// Format of the surface.
    NvstSurfaceFormat surfaceFormat;
    /// Origin of the surface.
    NvstSurfaceOrigin surfaceOrigin;
    /// Surface's color space.
    NvstCscMode surfaceColorSpace;
    /// Timeout for the encoder to receive a surface in milliseconds.
    ///
    /// This starts when streaming starts and restarts after each surface is
    /// received from nvstPushStreamData
    /// If the value is zero, there is no timeout.
    uint32_t encoderTimeoutMs;

    /// Disable frame copying
    /// When frame copy is disabled, it doesnt support frame resource
    /// reallocation. It is advised to pre-allocate max display resolution
    /// and signal actual frame size via dataSize.
    /// \todo: Add API to attach and detach resources which will enable App
    /// to reallocate resources.
    bool disableFrameCopying;
    /// Set to 1 to enable external ME hints for the current frame.
    /// For enablePtd=1 with B frames, programming L1 hints is optional
    /// for B frames since Client doesn't know internal GOP structure.
    uint32_t enableExternalMeHints;
    /// Set this to 1 to enable the Picture Type Decision is be
    /// taken by the NvEncodeAPI interface.
    uint32_t enablePtd;
    /// If Client wants to pass external motion vectors in meExternalHints
    /// buffer it must specify the maximum number of hint candidates per
    /// block per direction for the encode session. maxMEHintCountsPerBlock[0]
    /// is for L0 predictors and maxMEHintCountsPerBlock[1] is for L1 predictors.
    void* maxMeHintCountsPerBlock;
    /// Use Video Frame Provider
    /// This is set to true by NvStreamer. For SDK use-cases, a test frame provider
    /// is created since there is no frame provider.
    /// \todo: This is only temporary till we refactor VideoFrameProvider logic
    /// within SDK. Currently (for SDK), we need some frame provider to exist (hence
    /// a test frame provider created).
    bool enableFrameProvider;
    /// Disable SDK scaling
    /// This is set when application decides to do scaling by itself and not rely on
    /// SDK. Application needs to register qosStatusUpdated callback to do scaling.
    /// \todo Just used in RtcSDK. Need to implement for StreamSDK.
    bool disableSdkScaling;
    /// Permit gradual resolution changes for this video stream
    /// If true, and supported by the client, the SDK will change the resolution much more frequently than usual.
    /// The resolution may even change multiple frames in a row.
    /// If disableSdkScaling is also set to true, the app must be ready to handle these frequent changes.
    bool permitGrc;

    /// Receive information on the pushed frame data.
    ///
    /// Status is sent after transmitting (or dropping) the frame.
    /// Typical usage: Status update for a frame that is encoded and sent from server.
    /// \warning currently the callback is not supported.
    /// Setting it will result in error during nvstCreateServer call.
    /// \param[in] context Application-supplied pointer.
    /// \param[in] streamConn Stream conn. associated with the frameStatus update.
    /// \param[in] status Details about the given frame after encoding.
    void (*frameStatusUpdated)(void* context, NvstStreamConnection streamConn, NvstVideoFrameStatus frameStatus);

    /// Receive QoS update.
    ///
    /// Typical usage: QoS status update for a frame that is encoded and sent.
    /// \param[in] context Application-supplied pointer.
    /// \param[in] streamConn Stream connection associated with the QoS update.
    /// \param[in] qosStatus Details about current QoS and recommended resolution.
    void (*qosStatusUpdated)(void* context, NvstStreamConnection streamConn, NvstQosStatus qosStatus);

    /// Receive frame invalidation range.
    ///
    /// Typical usage: Start and end frame ids that are to be invalidated.
    /// \param[in] context Application-supplied pointer.
    /// \param[in] streamConn Stream connection associated with the QoS update.
    /// \param[in] invalidationRange Frame invalidation start and end ids.
    /// \note Fame ids start from 0.
    /// \warning Do not block inside this callback as it can cause SDk to misbehave.
    void (*frameInvalidationRequested)(
        void* context,
        NvstStreamConnection streamConn,
        NvstFrameInvalidationRange invalidationRange);

    /// Notifies the application that an IDR request was received.
    /// When an IDR request is received within Stream SDK, this callback will be
    ///   invoked to notify the application. Applications that are able to supply
    ///   new I frames should push an I frame as the next frame pushed to Stream
    ///   SDK. Applications that are unable to supply new I frames or provide
    ///   raw frames to the SDK should not set this pointer.
    /// \param[in] context Application-supplied pointer.
    /// \warning Do not block inside this callback as it can cause SDK to misbehave.
    /// \warning This callback will be invoked from the encoding thread.
    void (*onIdrRequestReceived)(void* context);

    /// Context pointer to be passed back whenever the callbacks are invoked.
    void* context;

    /// Device is picked based on surfaceOrigin type.
    /// Device should be valid as long as the stream is valid.
    union
    {
        /// Cuda device and context to be used by SDK for this stream
        NvstCudaDeviceInfo cudaDeviceInfo;
        /// D3D11 device to be used by SDK for this stream.
        /// This should be of the type ID3D11Device.
        NvstDxDevice d3d11Device;
        /// D3D9 device to be used by SDK for this stream.
        /// Application is expected to pass a IDirect3DDevice9Ex pointer.
        /// SDK will obtain DirectX Video Acceleration (DXVA) service object interface by
        /// calling DXVA2CreateVideoService (IDirectXVideoAccelerationService) on the shared device.
        /// This will be used if NV12 frame format is used by app.
        NvstDxDevice d3d9Device;
    };

    /// Dynamic range mode.
    NvstHdrMode dynamicRangeMode;
} NvstVideoSenderStreamConfig;

/// Defines configuration of the video stream.
/// \todo Put in a more elaborate explanation what these fields are.
/// \ingroup Video
typedef struct NvstVideoStreamConfig_t
{
    /// Streaming mode.
    NvstStreamingMode mode;

    /// Stream direction.
    NvstStreamDirection streamDirection;

    /// Encrypt video.
    bool encryptionEnabled;

    union
    {
        /// Reciever-specific video stream configuration.
        NvstVideoReceiverStreamConfig receiverConfig;

        /// Sender-specific video stream configuration.
        NvstVideoSenderStreamConfig senderConfig;
    };
} NvstVideoStreamConfig;

/// Defines configuration of the input stream.
/// \ingroup Input
typedef struct NvstInputStreamConfig_t
{
    /// Encrypt remote input.
    bool encryptionEnabled;

    /// Low-latency "input" from the client.
    ///
    /// Typical usage: input events (e.g. gamepad).
    /// Can also be used to send custom low-latency data (e.g. VR sensor data).
    /// \param[in] context Application-supplied pointer.
    /// \param[in] connection Stream connection over which the input event was received.
    /// \param[in] inputEvent Input event received.
    /// Receiver should not retain this pointer after the callback;
    /// if needed, any data from it should be copied.
    /// \sa NvstInputEvent
    void (*onInputReceived)(
        void* context,
        NvstStreamConnection streamConn,
        const NvstInputEvent* inputEvent,
        uint64_t receivedTime,
        uint64_t sentTime);

    /// Context pointer to be passed back whenever the callback is invoked.
    void* context;
} NvstInputStreamConfig;

/// Defines configuration of the message stream.
/// \ingroup Message
typedef struct NvstMessageStreamConfig_t
{
    /// Null terminated session ID of a streaming session.
    /// It is needed by NvstMessage mechanism to identify a client on the server side.
    const char* appSessionId;

    /// Receive custom message.
    ///
    /// Typical usage: send  custom data that is not time-critical.
    /// \param[in] context Application-supplied pointer.
    /// \param[in] connection Stream connection over which the message was received.
    /// \param[in] incomingMessage Message received.
    /// Receiver should call release callback when the message is no longer needed.
    /// \sa NvstMessage::releaseProc
    void (*onMessageReceived)(void* context, NvstStreamConnection streamConn, const NvstMessage* incomingMessage);

    /// Context pointer to be passed back whenever the callback is invoked.
    void* context;
} NvstMessageStreamConfig;

/// Convenience typedef for library consumers.
typedef void (
    *ON_MESSAGE_RECEIVED_PROC)(void* context, NvstStreamConnection streamConn, const NvstMessage* incomingMessage);

typedef struct NvstGraphicsSurfaceStreamConfig_t
{
    /// Application provided context pointer.
    void* context;
    /// Callback to invoke when a graphics surface object is received.
    /// `releaseProc()` must be called with `surface` passed as a parameter
    ///     in order to avoid a memory leak.
    void (*onGraphicsSurfaceReceived)(
        void* context,
        NvstGraphicsSurface* surface,
        void (*releaseProc)(const NvstGraphicsSurface*));
} NvstGraphicsSurfaceStreamConfig;

/// Convenience typedef for library consumers
typedef void (*ON_GRAPHICS_SURFACE_RECEIVED_PROC)(
    void* context,
    NvstGraphicsSurface* surface,
    void (*releaseProc)(const NvstGraphicsSurface*));

/// Generalization of the different stream configurations.
typedef struct NvstStreamConfig_t
{
    NvstMediaType mediaType;
    union
    {
        NvstVideoStreamConfig videoStream;
        NvstAudioStreamConfig audioStream;
        NvstInputStreamConfig inputStream;
        NvstMicStreamConfig micStream;
        NvstMessageStreamConfig messageStream;
    };
} NvstStreamConfig;
