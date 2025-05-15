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

/// \file Stream.h
/// Header file with defintions of Stream functions and data types.

#pragma once

#include "Result.h"
#include "StreamConfig.h"
#include "StreamData.h"
#include "Util.h"
#include <stdbool.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \defgroup NvstStreamStruct Stream interface structs/enums
    /// \ingroup Stream

    /// \defgroup AudioData Audio Stream Data
    /// Structures used by stream APIs for Audio Stream
    /// \ingroup NvstStreamStruct

    /// \defgroup VideoData Video Stream Data
    /// Structures used by stream APIs for Video Stream
    /// \ingroup NvstStreamStruct

    /// \defgroup MessageData Message Stream Data
    /// Structures used by stream APIs for Message Stream
    /// \ingroup NvstStreamStruct

    /// \defgroup CallbackData Stream Callbacks and related structs
    /// Callabcks and Structures used explicitly by stream related callbacks
    /// \ingroup NvstStreamStruct

    /// Handle of the stream that can be announced to clients.
    typedef void* NvstStream;

    /// Information about status changes.
    /// \ingroup CallbackData
    typedef enum NvstStatusChange_t
    {
        /// Client has established a communication channel for the stream.
        NVST_SC_STREAM_CONNECTED = 101,
        /// Client has disconnected the stream.
        NVST_SC_STREAM_DISCONNECTED = 102,
        /// Notification of an update
        NVST_SC_UPDATE = 103,
        /// Server is about to disconnect the stream
        NVST_SC_STREAM_DISCONNECTING = 104,
        /// Not valid value.
        NVST_SC_LAST,
    } NvstStatusChange;

    /// Additional data about a particular event coming from the client.
    /// \todo Some of these events should not be coming from the SDK at all.
    ///       The code that triggers these events should be moved into NvStreamer.
    /// \ingroup CallbackData
    typedef enum NvstEventDetail_t
    {
        /// A streaming client has connected
        NVST_ED_CLIENT_CONNECTED = 200,
        /// An attempt to connect by a client has failed
        NVST_ED_CLIENT_CONNECT_ATTEMPT_FAILED = 202,
        /// Streaming attempt failed
        NVST_ED_STREAM_ATTEMPT_FAILED = 203,
        /// Streamer was unable to initialize
        NVST_ED_STREAMER_INIT_FAILURE = 204,
        /// Stream disconnected by client request to stop
        NVST_ED_STREAM_DISCONNECT_INTENTIONAL = 205,
        /// Stream disconnected, unable to reach client
        NVST_ED_STREAM_DISCONNECT_UNINTENTIONAL = 206,
        /// The game went into full-screen mode within specified time
        NVST_ED_FULL_SCREEN_DETECTION_SUCCESS = 207,
        /// The game did not go into full-screen mode within specified time
        NVST_ED_FULL_SCREEN_DETECTION_TIMEOUT = 208,
        /// The client sent a session pause request
        NVST_ED_CLIENT_REQUESTED_SESSION_PAUSE = 209,
        /// Session terminated as the user has been idle beyond a specified time
        NVST_ED_USER_IDLE_TIMEOUT = 210,
        /// Foreground process has changed
        NVST_ED_FOREGROUND_PROCESS_CHANGED = 211,
        /// Desktop switched from default to winlogon or vice versa
        NVST_ED_DESKTOP_SWITCHED = 213,
        /// Stream disconnected due to failure in frame capture
        NVST_ED_DISCONNECT_FRAME_CAPTURE_ERROR = 214,
        /// The client sent a request to refresh the screen
        NVST_ED_FORCE_REFRESH_SCREEN = 215,
        /// NvStreamer session teardown was successful
        NVST_ED_SESSION_TEARDOWN_SUCCESS = 216,
        /// NvStreamer rtsp teardown was successful
        NVST_ED_RTSP_TEARDOWN_SUCCESS = 217,
        /// Sent first frame
        NVST_ED_FIRST_FRAME_SENT = 218,
        /// Start Pcap capture
        NVST_ED_START_PCAP_CAPTURE = 219,
        /// Client is attempting to connect.
        NVST_ED_CLIENT_CONNECTING = 220,
        /// Remote Input handler(StreamSDK) triggers event to audio
        NVST_ED_AUDIO_LATENCY_TRIGGER = 221,
        /// Control Data Channel handler triggers event to dump pcm
        NVST_ED_AUDIO_PCM_DUMP_TRIGGER = 222,
        /// Streaming pipeline is initializing (supported for video stream only)
        NVST_ED_STREAM_PIPELINE_INITIALIZING = 223,
        /// Streaming pipeline is stopping (supported for video stream only)
        NVST_ED_STREAM_PIPELINE_STOPPING = 224,
        /// Streaming pipeline is deinitializing (supported for video stream only)
        NVST_ED_STREAM_PIPELINE_DEINITIALIZING = 225,
    } NvstEventDetail;

    /// Data about a particular stream event.
    ///
    /// This struct is provided with event-related callback.
    /// \todo NvstStreamEvent_t should not be using NvstEventDetail.
    /// It should have its own enumeration with appropriately named values.
    /// \ingroup CallbackData
    typedef struct NvstStreamEvent_t
    {
        /// New status of the stream
        NvstStatusChange eventType;
        /// Optional code to provide more details about the event.
        NvstEventDetail eventCode;
    } NvstStreamEvent;

    /// VideoSettings obtained after handshake is done.
    ///
    /// Passed to application via OnStreamConnecting callback.
    /// These video settings are obtained from client after handshake is done.
    /// They can be used by applications while creating video objects.
    /// \sa onStreamConnecting
    /// \ingroup CallbackData
    typedef struct NvstVideoContextSettings_t
    {
        /// Video context type to be used on server side (CUDA/DX9/DX11), server may ignore unsupported types.
        uint32_t adapterType;

        /// Width expected by the client.
        uint32_t clientViewportWd;

        /// Height expected by the client.
        uint32_t clientViewportHt;

        /// FPS expected by the client.
        uint32_t clientFps;

        /// Disable video frame scaling.
        uint8_t disableFrameScaling;

        /// Used to determine if stream is HDR or SDR.
        bool isHdr;

        /// Frame sender thread timeout value.
        /// This should be used by applications to determine timeout values for their threads.
        uint32_t sendFrameTimeoutMs;

        /// Flag to control remote cursor.
        /// If set to 1, client expects local cursor (send cursor info to client).
        /// \todo Validate if this param needs to be part of StreamSdk
        uint32_t mimicRemoteCursor;

        /// Flag to control server side high performance trace capturing.
        uint16_t serverTraceCapture;

        /// Flag to control mouse cursor capture.
        /// If set to 1, cursor has to be captured and in the frame.
        /// \todo Validate if this param needs to be part of StreamSdk
        uint32_t mouseCursorCapture;

        /// \internal Video settings used by internal applications.
        /// \endinternal
        /// \warning Only to be used by internal users. Will not be considered for external applications.
        NvstInternalVideoSettings internalSettings;

    } NvstVideoContextSettings;

    /// Groups all stream callbacks coming from NVST to the application.
    /// \ingroup CallbackData
    typedef struct NvstStreamCallbacks_t
    {
        /// Context pointer passed back whenever a callback is invoked.
        void* context;

        /// Stream related event was raised.
        /// \note This is called asynchronously when the stream connection is ready
        /// to receive data. It is not dependent on the order it was added or
        /// created.
        /// \param[in] context Application-supplied pointer.
        /// \param[in] connection Connection over which the stream is flowing.
        /// \param[in] streamConnection Handle to the stream connection which got connected.
        /// \param[in] stream Handle to the stream which got connected
        /// \param[in,out] streamConfig Configuration of the stream which got connected
        /// Callback gets raised when any event occurs on a StreamConnection (pertaining to a Stream)
        /// Callback to recieve video, audio and other data set during Stream creations.
        /// To change a callback for a particular Stream Connection set it in streamConfig during the call
        /// of this callback.
        /// \param[in] event Event details.
        void (*streamEventRaised)(
            void* context,
            NvstConnection connection,
            NvstStreamConnection streamConnection,
            NvstStream stream,
            NvstStreamConfig* streamConfig,
            NvstStreamEvent event);

        /// An update of NvstStreamConfig for the given 'stream' has been requested.
        ///
        /// Application should adjust accordingly
        /// (e.g. adjust streaming resolution, change the framerate, ...).
        /// \param[in] context Application-supplied pointer.
        /// \param[in] streamConnection Handle to the stream being updated.
        /// \param[in] newStreamConfig The updated configuration for the given stream.
        /// \return Approval or rejection of the update.
        NvstResult (*streamConfigUpdateRequested)(
            void* context,
            NvstStreamConnection streamConnection,
            const NvstStreamConfig* pNewStreamConfig);

        /// A subset of VideoSettings relevant to video pipeline
        /// \note This is called synchronously when after successful negotiation with the client
        /// and after the stream is setup. Values in NvstVideoContextSettings are obtained from clientContext
        /// \param[in] context Application-supplised pointer
        /// \param[in] streamConnection Handle to the stream connection which got connected.
        /// \param[in] videoContextSettings VideoSettings relevant to VideoContext, FrameProvider and CaptureThread
        /// \param[out] appSuppliedActiveConfig Optional param supplied by application. Stream SDK provides memory
        /// for the application to provide a valid video stream config for use as the active stream config. Otherwise
        /// the SDK selects a stream config among the recommended stream configs provided during nvstCreateStream.
        NvstResult (*onStreamConnecting)(
            void* context,
            NvstStreamConnection streamConnection,
            NvstStream stream,
            NvstVideoContextSettings videoContextSettings,
            NvstStreamConfig* appSuppliedActiveConfig);

    } NvstStreamCallbacks;

    /// \defgroup nvstStreamAPI NVST Stream APIs
    /// Stream related APIs used to manage streams
    /// \ingroup Stream

    /// Create a stream object.
    ///
    /// Creates a stream to be announced to clients
    /// using the signaling connection (e.g. RTSP).
    /// \param[in] streamName Identifying name for the stream. Each sender and receiver
    ///            streams' pair has to have same stream name for streaming to work.
    /// \param[in] streamTitle Human readable title of the stream.
    /// \param[in] numStreamConfigs number of NvstStreamConfigs in the streamConfigs parameter.
    /// \param[in] streamConfigs the set of available configurations for this stream that the client can choose from.
    /// Stream configurations are hints given to the client as to what kind of stream is possible to negotiate.
    /// \param[in] streamCallbacks Structure with callbacks to use on streaming events.
    /// \param[out] stream Handle of the created stream.
    /// \ingroup nvstStreamAPI
    NVST_API NvstResult nvstCreateStream(
        const char* streamName,
        const char* streamTitle,
        const uint32_t numStreamConfigs,
        NvstStreamConfig streamConfigs[],
        NvstStreamCallbacks* streamCallbacks,
        NvstStream* stream);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*CREATESTREAM_PROC)(
        const char* streamName,
        const char* streamTitle,
        const uint32_t numStreamConfigs,
        NvstStreamConfig streamConfigs[],
        NvstStreamCallbacks* streamCallbacks,
        NvstStream* stream);

    /// Push data to the stream.
    ///
    /// This function is non-blocking.
    /// Once SDK processes the given data, it will invoke a release procedure callback.
    /// Each media type in NvstStreamData has its own field for this callback.
    /// The application shall release the given data in this callback.
    /// If the data is coming in too fast for the function to handle,
    /// it will fail with an appropriate error code.
    /// In this case, the callback won't be invoked.
    /// The application can either discard the data and provide new data later
    /// (if it is time sensitive, e.g. audio or video frames),
    /// or it can choose to wait for some time and retry (e.g. input events).
    /// The wait time is app and network specific.
    /// For example, if the app is sending video at 60 FPS,
    /// waiting for 8-16ms might be adequate.
    /// But, if the network is congested, a longer wait might be required.
    /// \note The application shall not assume anything
    /// about the number of threads used by the SDK to invoke callback functions.
    /// \param[in] streamConnection Stream connection received in streamConnected callback.
    /// Can be of video, audio, or other stream type.
    /// If app provides D3D11 video texture, the texture needs to be created with
    /// D3D11_RESOURCE_MISC_SHARED_KEYEDMUTEX flag set.
    /// \todo Rewrite the description when we will know the exact details about the
    /// NvstStreamConnection for client side.
    /// \param[in] streamData Data to be pushed.
    /// The actual data type is specified in NvstStreamData::mediaType.
    /// \retval NVST_R_INVALID_PARAM if streamConnection or streamData are not valid
    /// (e.g. NULL) or have mismatching types
    /// \retval NVST_R_INVALID_OPERATION if the server is not in the right state to accept frames
    /// \retval NVST_R_BUSY if the SDK is not able to accept the data
    /// (this is an indication that the app can retry sending the same data)
    /// \retval NVST_R_FRAME_DROPPED if the sent frame is dropped by SDK
    /// (this is not an error)
    /// \retval NVST_R_GENERIC_ERROR for other errors
    /// \retval NVST_R_SUCCESS in success case
    /// \sa NvstMediaType
    /// \sa NvstStreamData
    /// \sa streamConnected
    /// \ingroup nvstStreamAPI
    NVST_API NvstResult nvstPushStreamData(NvstStreamConnection streamConnection, const NvstStreamData* streamData);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*PUSH_STREAM_DATA_PROC)(NvstStreamConnection stream, const NvstStreamData* streamData);

    /// Destroy a previously created NvstStream.
    /// \param[in] stream Stream created using nvstCreateStream(),
    /// which will become invalid after this call
    /// \ingroup nvstStreamAPI
    NVST_API NvstResult nvstDestroyStream(NvstStream stream);

    /// Convenience typedef for library consumers.
    typedef void (*DESTROYSTREAM_PROC)(NvstStream stream);

    /// Get default stream configuration.
    /// \param[in] mediaType stream media type.
    /// \param[in] streamDirection direction of stream.
    /// \param[out] streamConfig stream config struct get filled with default values.
    /// \retval NVST_R_INVALID_OBJECT if streamConfig is not a legitimate value.
    /// \retval NVST_R_INVALID_PARAM if mediaType or streamDirection is invalid.
    /// \retval NVST_R_SUCCESS otherwise.
    /// \ingroup nvstStreamAPI
    NVST_API NvstResult nvstGetDefaultStreamConfig(
        NvstMediaType mediaType,
        NvstStreamDirection streamDirection,
        NvstStreamConfig* streamConfig);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*GET_DEFAULT_STREAM_CONFIG_PROC)(
        NvstMediaType mediaType,
        NvstStreamDirection streamDirection,
        NvstStreamConfig* streamConfig);
#if defined(__cplusplus)
}
#endif
