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

/// \file StreamServer.h
/// Defines the interface between the application and the Stream SDK.

#pragma once

#include "../common/AudioFormat.h"
#include "../common/InputEvent.h"
#include "../common/KeyDefs.h"
#include "../common/Logger.h"
#include "../common/MessageForClient.h"
#include "../common/MouseCursorDefines.h"
#include "../common/Result.h"
#include "../common/Util.h"
#include "../common/SharedTypes.h"
#include "../common/Signaling.h"
#include "../common/StreamData.h"
#include "../common/Stream.h"
#include "../common/StreamConfig.h"
#include <nvst/client/ClientEvent.h>

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    typedef uint32_t NvstApiVersion;

#define NVST_API_MAJOR_VERSION 0
#define NVST_API_MINOR_VERSION 1
#define NVST_API_PATCH_VERSION 1
#define NVST_API_VERSION \
    ((NVST_API_MAJOR_VERSION << 24) | (NVST_API_MINOR_VERSION << 8) | (NVST_API_PATCH_VERSION << 0))

    /// \defgroup nvstServerSdk Server Stream SDK interface

    /// \defgroup nvstServerSdkAPIs Server Stream SDK APIs
    /// \ingroup nvstServerSdk

    /// \defgroup nvstServerSdkStructs Server Stream SDK Structs/Enums and Callbacks
    /// \ingroup nvstServerSdk

    /// Handle of the client connection instance.
    ///
    /// This is a result of a successful client connection.
    /// It is delivered through NvstCallbacks::clientEventRaised()
    /// callback with NVST_EVENT_CONNECTED.
    /// \sa NvstCallbacks::clientEventRaised()
    /// \note Version 1.0:
    /// Only one client connection allowed.
    /// Future versions may support more.
    typedef struct NvstConnection_t* NvstConnection;

    /// Client connection related events.
    /// \ingroup nvstServerSdkStructs
    typedef enum NvstClientConnectionEventType_t
    {
        NVST_CCE_NONE = 0,
        /// Client has connected to the signaling channel and finished the handshake.
        NVST_CCE_CONNECTED = 1,
        /// Client has disconnected.
        NVST_CCE_DISCONNECTED = 2,
        /// Client is attempting to connect.
        NVST_CCE_CONNECTING = 3,
    } NvstClientConnectionEventType;

    /// Data about a particular event coming from the client.
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstClientConnectionEvent_t
    {
        /// The type of event
        NvstClientConnectionEventType eventType;
        /// Optional code to provide more details about the event.
        NvstEventDetail eventCode;
        /// Additional information.  Currently this could contain either a SessionTerminationReason, an NvstResult,
        /// or an HTTP status code.
        uint32_t reason;
        /// A message coming from the source of this event.
        const char* message;
    } NvstClientConnectionEvent;

    /// Indicates source of a mouse capture or mimic remote cursor event.
    /// \ingroup nvstServerSdkStructs
    typedef enum NvstCursorEventSource_t
    {
        /// Client requested this value
        NVST_CES_CLIENT_REQUEST = 0,
        /// Server requested this value
        NVST_CES_SERVER_REQUEST = 1,
        /// The component that manages cursor state sent this value
        NVST_CES_CURSOR_MANAGER = 2,
    } NvstCursorEventSource;

    /// Signal mouse cursor capture event
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstMouseCursorCaptureCommand_t
    {
        uint8_t captureFlags;
        NvstCursorEventSource source;
    } NvstMouseCursorCaptureCommand;

    /// Signal to start/stop tracking cursor shape (mimic remote cursor)
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstMimicRemoteCursorCommand_t
    {
        uint8_t mimicRemoteCursor;
        NvstCursorEventSource source;
    } NvstMimicRemoteCursorCommand;

    /// Control fullscreen capturing
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstCaptureFullscreenCommand_t
    {
        bool enabled;
    } NvstCaptureFullscreenCommand;

    /// Used in NvstClientCommand to indicate type of the client command sent
    /// \ingroup nvstServerSdkStructs
    typedef enum NvstClientCommandType_t
    {
        NVST_CC_UNKNOWN = 0x0000,
        NVST_CC_MOUSE_CURSOR_CAPTURE = 0x0001,
        NVST_CC_MIMIC_REMOTE_CURSOR = 0x0002,
        NVST_CC_CAPTURE_FULLSCREEN = 0x0003,
        NVST_CC_CUSTOM_MESSAGE = 0x0004,
    } NvstClientCommandType;

    /// Data used for forwarding client command events to the application.
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstClientCommand_t
    {
        /// Actual type of the client command
        NvstClientCommandType type;

        /// Nameless union that holds data for the client commands
        union
        {
            NvstMouseCursorCaptureCommand mouseCursorCapture;
            NvstMimicRemoteCursorCommand mimicRemoteCursor;
            NvstCaptureFullscreenCommand captureFullscreen;
            NvstCustomMessage customMessage;
        };
    } NvstClientCommand;

    /// Used for reporting metric data.
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstMetricData_t
    {
        /// Category of the data.
        const char* category;
        /// Description of the data.
        const char* description;
        /// Optional double representation of the data.
        double data;
        /// Optional duration data.
        uint32_t duration;
    } NvstMetricData;

    /// Used for reporting telemetry data.
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstTelemetryData_t
    {
        /// Category of the data.
        const char* category;
        /// Description of the data.
        const char* description;
        /// String representation of the data.
        const char* label;
    } NvstTelemetryData;

    /// Used for reporting statistics data.
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstStatisticsData_t
    {
        /// Description of the data.
        const char* description;
        /// Optional duration data.
        uint32_t duration;
        /// Optional double representation of the data.
        double doubleValue;
        /// Optional integer representation of the data.
        int64_t intValue;
        /// Optional unsigned representation of the data.
        uint32_t unsignedValue;
    } NvstStatisticsData;

    /// Used for reporting result code data.
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstResultCodeData_t
    {
        /// Description of the data, i.e. what event this result code is for.
        const char* description;
        /// Result code data.
        uint32_t resultCode;
        /// Result details, more details on what the result code means.
        const char* resultDetails;
    } NvstResultCodeData;

    /// Used in NvstDiagnosticsData to define type of reported data.
    /// \ingroup nvstServerSdkStructs
    typedef enum NvstDiagnosticType_t
    {
        NVST_DT_STATISTICS = 0,
        NVST_DT_RESULT_CODE = 1,
        NVST_DT_METRIC_DATA = 2,
        NVST_DT_TELEMETRY_DATA = 3,
    } NvstDiagnosticsType;

    /// Data used for reporting various types of diagnostics data.
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstDiagnosticsData_t
    {
        /// Actual type of telemetry data.
        NvstDiagnosticsType diagnosticType;

        /// Nameless union that holds additional diagnostics data based on diagnosticType.
        union
        {
            NvstStatisticsData statisticsData;
            NvstResultCodeData resultCodeData;
            NvstMetricData metricData;
            NvstTelemetryData telemetryData;
        };
    } NvstDiagnosticsData;

    /// Supported server types
    /// \ingroup nvstServerSdkStructs
    typedef enum NvstServerType_t
    {
        NVST_SV_NORMAL = 0,
        NVST_SV_SHIELD = 1,
    } NvstServerType;

    /// Groups all callbacks coming from NVST to the application.
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstCallbacks_t
    {
        /// Context pointer passed back whenever a callback is invoked.
        void* context;
        /// Client connection related event was raised.
        /// \param[in] context Application-supplied pointer.
        /// \param[in] connection Connection over which the client got connected.
        /// \param[in] event Event details.
        void (*clientEventRaised)(void* context, NvstConnection connection, NvstClientConnectionEvent event);

        /// Diagnostics related event was raised.
        /// Useful for e.g. telemetry
        /// \param[in] context Application-supplied pointer.
        /// \param[in] data Nameless union that holds additional diagnostics data based on diagnosticType.
        void (*diagnosticsEventRaised)(void* context, NvstDiagnosticsData data);

        /// Client sent a command to the application
        /// \param[in] context Application-supplied pointer
        /// \param[in] clientCommand Nameless union that holds data for client commands based on the the type.
        void (*onClientMessage)(void* context, NvstConnection connection, NvstClientCommand clientCommand);

        /// Headers were received along with the signaling connection request. Accept or deny the connection by
        /// returning the corresponding NvstResult.
        /// \param[in] context Application-supplied pointer
        /// \param[in] headers Array of NvstSignalingHeaders that arrived with the connection.
        /// \param[in] numHeaders Number of NvstSignalingHeader structs in `headers`.
        /// \return NVST_R_SUCCESS to accept the headers or one of the NVST_SIGERR_* results to reject and provide
        /// an appropriate response to the client.
        /// \note If any other result besides NVST_R_SUCCESS is returned, the connection will be rejected. If none of
        /// NVST_SIGERR_* results are returned on failure, internally NVST_SIGERR_GENERIC will be used.
        /// \note The client MAY omit headers. In that case, `headers` will be NULL and `numHeaders` zero.
        /// \note If no `onSignalingHeaders` callback is provided, connections will be implicitly accepted.
        /// \todo Move this to a common location when the signaling server is moved out of the stream server.
        NvstResult (*onSignalingHeaders)(void* context, const NvstSignalingHeader* headers, uint16_t numHeaders);
    } NvstCallbacks;

    /// \ingroup nvstServerSdkStructs
    typedef enum PortSelectionMode_t
    {
        // Fixed ports uses the values from PortHelper
        FIXED_PORTS = 1,
        // Dynamic uses ephemeral ports allocated by the OS.
        DYNAMIC_PORTS = 2
    } PortSelectionMode;

/// Regardless of differing OS limitations, this is the maximum length for NvstServerConfig paths.  This path is
/// less than the maximum limitation to leave room for a file name to be appended.
#define SERVER_CONFIG_MAX_PATH 240

/// Length of server host name.
#define SERVER_URL_LENGTH 40

/// Sizes were determined by size of self signed cert which is generated by IdentityPlugin.
/// Rounded up to next even number.
/// Cert actual size: 1017
#define MAX_CERT_PEM_LENGTH 2000
/// Key actual size: 1675
#define MAX_KEY_PEM_LENGTH 2000

    /// Port range
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstPortRange_t
    {
        uint16_t minPort;
        uint16_t maxPort;
    } NvstPortRange;

    /// Endpoint information
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstEndpoint_t
    {
        uint16_t portNumber;
        const char* address;
    } NvstEndpoint;

    /// Port config type
    /// \ingroup nvstServerSdkStructs
    typedef enum NvstPortConfigType_t
    {
        NVST_PC_RANGE,
        NVST_PC_FIXED
    } NvstPortConfigType;

    /// Endpoint configuration
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstEndpointConfig_t
    {
        /// Port config type
        NvstPortConfigType configType;
        union
        {
            /// Range of UDP ports
            NvstPortRange hostPortRange;

            /// Host endpoint is local IP:port for particular UDP connection
            NvstEndpoint hostEndpoint;
        };
    } NvstEndpointConfig;

    /// Enumeration of backend modes for Server
    /// \ingroup nvstServerSdkStructs
    typedef enum NvstStreamServerBackendMode_t
    {
        /// Default - current native mode using Mjolnir's proprietary protocol.
        NVST_STREAM_SERVER_BACKEND_DEFAULT = 0,
        /// Libwebrtc - using libwebrtc, same like NvRtcStreamer.
        NVST_STREAM_SERVER_BACKEND_LIBWEBRTC = 1,
        /// Nativewebrtc - implementing standardized WebRTC protocols natively.
        NVST_STREAM_SERVER_BACKEND_NATIVEWEBRTC = 2
    } NvstStreamServerBackendMode;

    /// Server configuration options
    /// \sa nvstCreateServer
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstServerConfig_t
    {
        /// Disable split encoding
        bool disableSplitEncoding;

        /// Allow capture of network packets.  By itself, this setting doesn't turn on
        /// packet capture.  Capture also must be enabled by either "packetCaptureStartsEnabled"
        /// or by the client.
        bool allowPacketCapture;

        /// Start network capture as soon as possible.
        /// Note that if the client doesn't also enable packet capture, then capture will
        /// cease once connected to the client.
        bool packetCaptureStartsEnabled;

        /// Use the stream control interface to control the stream process
        bool enableSci;

        /// Enable variable bit-rate audio
        bool enableVbr;

        /// Force specific context types as set in the session config
        bool forceSetAdapterContextType;

        /// Force usage of the stand-alone RTSP message bus
        bool forceStandaloneRtsp;

        /// Force perf indicator to visible
        bool forcePerfIndicatorVisible;

        /// ETL logging mode. Bit field.
        NvstClientServerTraceCaptureFlags etlLoggingFlags;

        /// Enable ETL logging of game events
        bool logGameEvents;

        /// Watch for user login - Windows only.
        bool manageRemoteLogin;

        /// Maximum number of audio channels
        uint32_t maxAudioChannels;

        /// Set the maximum game ETL file size in megabytes.  If non-zero, then it overrides
        /// the setting requested by the client.
        uint32_t maxGameEtlSizeMbOverride;

        /// Max ETL size in megabytes. Circularly overwritten once max size is reached.
        uint32_t maxServerEtlSizeMb;

        /// Adjust some internal settings for clients on remote networks.
        bool networkTypeWan;

        /// Stream the given PID, set to zero to not use.
        uint32_t streamingProcessId;

        /// Directory to save output files (e.g. stream captures, ETLs and similar)
        char outDirectory[SERVER_CONFIG_MAX_PATH];

        /// Framerecorder should write exit frames to a file.
        bool recordExitFrames;

        /// Server config file directory
        char serverConfigFileDirectory[SERVER_CONFIG_MAX_PATH];

        /// The type of server.
        NvstServerType serverType;

        /// Stop streaming if frame scaling is enabled.
        bool terminateStreamingIfScalingEnabled;

        /// True if StreamSDK is being used by NvStreamer.
        bool useCaseNvStreamer;

        /// True to permit the use of virtual vsync.  If this is not set, the Virtual Vsync feature
        /// will not be negotiated with the client and will be permanently disabled.
        ///
        /// Currently these are 3 levels of enabling of Virtual Vsync:
        /// - Permitted - This turns it on/off as a feature.  This setting applies to all streams and SDP negotiation
        ///   will happen only if this setting is true.
        /// - Enabled (per stream) - This allows the application to turn VVsync off/on while running.  This is used,
        ///   for example in NvStreamer, when the DWM is being captured instead of a full screen app.
        /// - Active (per stream) - This happens when the internal algorithm decides if Vvsync timings or standard
        ///   timings should be used.  This may change from frame to frame based on timing feedback from the client.
        bool permitVirtualVsync;

        /// Use the Pascal Min QP
        bool usePascalVideoMinQp;

        /// Allow Pcap capture by the NetworkCaptureControl plugin in GRID mode.
        bool usePcapNetworkCapturePlugin;

        /// Disable transport list in onRtspSetup
        bool noTransportList;

        /// Configure logging level.
        NvstLogLevel logLevel;

        /// Provide external server url, when in use.
        char externalServerUrl[SERVER_URL_LENGTH];

        /// STUN/TURN server urls and credential
        /// Supported only in RtcStreamSdk
        NvstNatServer natServers[NVST_MAX_TURN_SERVER_SUPPORTED];

        /// Provide certificate in PEM format for sll
        char certificatePem[MAX_CERT_PEM_LENGTH];

        /// Provide key in PEM format for ssl
        char keyPem[MAX_KEY_PEM_LENGTH];

        /// Set Ip version
        NvstIpVersion ipVersion;

        /// Use CCX frame provider.
        /// \todo Remove the need for this once CCX pipeline uses encoded pipeline in SDK.
        bool useCcxProvider;

        /// Use custom congestion control factory for RTC streamer
        bool useCustomCongestionControl;

        /// Configure server UDP endpoint
        /// This param allows to set media port, and this support added only for RTC path.
        NvstEndpointConfig endpoint;

        /// Backend modes for Server
        NvstStreamServerBackendMode backendMode;

    } NvstServerConfig;

    /// Fill the provided server configuration structure with default values.
    ///
    /// \param[in, out] serverConfig The structure to fill.
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult nvstRetrieveServerDefaults(NvstServerConfig* serverConfig);

    /// Create the versioned server.
    ///
    /// \param[in] headerApiVersion version of used headers
    /// \param[in] callbacks Structure with callbacks to use on streaming events.
    /// \param[in,out] signalingPort Information about the signaling port to use.
    /// \param[in] portSelectionMode Determines if fixed or dynamic ports will be used should be used for the
    ///     video, audio and microphone streaming connections.
    /// \param[in] serverConfig Configuration settings for the server.
    /// \note To control the logging, one needs to call ::nvstUpdateLogger.
    ///     Otherwise, nvstCreateVersionedServer will default to no logging throughout the SDK.
    /// Should only be called from nvstCreateServer
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult nvstCreateVersionedServer(
        NvstApiVersion headerApiVersion,
        const NvstCallbacks* callbacks,
        NvstPortInfo* signalingPort,
        PortSelectionMode portSelectionMode,
        const NvstServerConfig* serverConfig);

    /// Create the StreamSDK server.
    ///
    /// \param[in] callbacks Structure with callbacks to use on streaming events.
    /// \param[in,out] signalingPort Information about the signaling port to use.
    /// \param[in] portSelectionMode Determines if fixed or dynamic ports will be used should be used for the
    ///     video, audio and microphone streaming connections.
    /// \param[in] serverConfig Configuration settings for the server.
    /// \note To control the logging, one needs to call ::nvstUpdateLogger.
    ///     Otherwise, nvstCreateServer will default to no logging throughout the SDK.
    /// \ingroup nvstServerSdkAPIs
    inline NvstResult nvstCreateServer(
        const NvstCallbacks* callbacks,
        NvstPortInfo* signalingPort,
        PortSelectionMode portSelectionMode,
        const NvstServerConfig* serverConfig)
    {
        return nvstCreateVersionedServer(NVST_API_VERSION, callbacks, signalingPort, portSelectionMode, serverConfig);
    }

    /// Destroy the StreamSDK server.
    ///
    /// If any connections are alive, disconnect them all.
    /// If the StreamSDK server is in the listening state, stop listening and uninitialize.
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult nvstDestroyServer();

    /// Start listening for incoming connections.
    ///
    /// This call returns once the listening is initiated.
    /// \param[in] streamCount Number of streams to be associated with this server
    /// instance
    /// \param[in] streams An array containing streamCount streams to be associated with the server
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult nvstStartServer(uint32_t streamCount, NvstStream streams[]);

    /// Disconnect the client then stop listening.
    ///
    /// If connection is lost prior to the data being sent, or if the client has
    /// already disconnected, stopData will not be delivered.
    /// \param[in] stopData Optional, arbitrary data that will be sent to the other
    /// end before being disconnected. The data is copied with this call and may be
    /// release immediately afterwards. If no delivery is desired, this should be
    /// set to NULL.
    /// \param[in] stopDataSize Size of stopData in bytes. If no delivery is
    /// desired, this should be set to 0.
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult nvstStopServer(const void* stopData, uint16_t stopDataSize);

    /// upscale state
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstUpscaleState_t
    {
        // Enable/Disable bit for Deep Isp feature for upscale
        bool deepIspEnable;
        // Ngx application App Id expected by Ngx runtime
        uint32_t appId;
        // Width specifying the in game resolution prior to upscale
        uint32_t width;
        // Height specifying the in game resolution prior to upscale
        uint32_t height;
    } NvstUpscaleState;

    /// \ingroup nvstServerSdkStructs
    typedef enum ParameterType_t
    {
        NVST_RP_AV_ENCRYPTION_KEY,
        NVST_RP_AV_ENCRYPTION_KEY_ID,
        NVST_RP_RI_ENCRYPTION_KEY,
        NVST_RP_RI_ENCRYPTION_KEY_ID,
        NVST_RP_PREFER_TURBO_MODE,
        NVST_RP_TURBO_MODE_FPS,
        NVST_RP_USER_IDLE_TERMINATION,
        NVST_RP_USER_IDLE_WARNING,
        NVST_RP_HDR_ENABLED,
        NVST_RP_NUM_AUDIO_CHANNELS,
        NVST_RP_UPSCALE_STATE,
        NVST_RP_USE_LOW_LATENCY_HIGH_PERFORMANCE_PRESET
    } ParameterType;

    /// This is the structure to pass into nvstSetServerRuntimeParam.
    /// Set the type of parameter type and fill out the corresponding structure.
    /// \sa nvstSetServerRuntimeParam
    /// \ingroup nvstServerSdkStructs
    typedef struct NvstRuntimeParameter_t
    {
        union
        {
            /// NVST_RP_RI_ENCRYPTION_KEY
            /// NVST_RP_AV_ENCRYPTION_KEY
            uint32_t encryptionKeyId;

            /// NVST_RP_RI_ENCRYPTION_KEY_ID
            /// NVST_RP_AV_ENCRYPTION_KEY_ID
            const char* encryptionKey;

            /// NVST_RP_TURBO_MODE_FPS
            /// This sets the maximum framerate when in turbo mode.
            uint32_t maxTurboModeFps;

            /// NVST_RP_PREFER_TURBO_MODE
            /// Prefer the use of turbo mode.  This can be over-ridden by the client.
            bool preferTurboMode;

            /// NVST_RP_USER_IDLE_TERMINATION
            /// Sets how long a user can be idle before their connection is terminated.
            uint32_t userIdleTerminationTimeSeconds;

            /// NVST_RP_USER_IDLE_WARNING
            /// Sets how long a user can be idle before they get an idle warning.
            uint32_t userIdleWarningTimeSeconds;

            /// NVST_RP_HDR_ENABLED
            /// Enables or disables HDR mode.  This can only be set after streaming has started.
            bool hdrEnabled;

            /// NVST_RP_NUM_AUDIO_CHANNELS
            /// Specifies the number of audio channels to use.  Defaults to 2.
            int32_t numAudioChannels;

            /// NVST_RP_UPSCALE_STATE
            /// Enables or disables deepisp mode along with other state needed for deepisp.
            /// This needs to be be set before streaming has started.
            NvstUpscaleState upscaleState;

            /// NVST_RP_USE_LOW_LATENCY_HIGH_PERFORMANCE_PRESET
            /// Enables or disables using the LLHP preset
            bool useLlhp;
        };
    } NvstServerRuntimeParam;

    /// Set a runtime parameter.
    ///
    /// These are values that can be adjusted on the fly.
    /// This function can only be called after the server has been created.
    /// \param[in] parameterType Data on the parameter and values to change.
    /// \param[in] pParameter Data on the parameter and values to change.
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult
        nvstSetServerRuntimeParam(ParameterType parameterType, const NvstServerRuntimeParam* pParameter);

    /// Notify StreamSDK of a change in maximum streaming resolution.
    ///
    /// \param[in] width New maximum width in pixels
    /// \param[in] height New maximum height in pixels.
    /// \param[in] fps New maximum frames per second.
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult nvstSetMaxStreamingResolution(uint32_t width, uint32_t height, uint32_t fps);

    /// \todo This API is a placeholder pending further agreement by interested parties.  It is being put into place
    /// and may be used so as to not block certain in-progress development.
    /// Send a message to the client
    /// \param[in] messageType The type of message to send. Determines which field in the union will be read.
    /// \param[in] message The message to send to the client.
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult nvstSendMessage(MessageType messageType, NvstMessageForClient message);

    /// [INTERNAL] Pass an ETW adapter factory into StreamSDK.
    /// \param[in] pSharedPtrToFactory The address of a shared_ptr to the factory.  The shared_ptr must have
    /// a custom deleter so that the object is deleted in the application's context.
    /// The actual type of the parameter is "std::shared_ptr<EtwAdapter::Factory>*"
    /// \note This is not necessary when the application has permission to write ETL events.
    /// \note This function will probably crash if the application and StreamSDK libs have different implementations of
    /// std::shared_ptr.  E.g. One is debug and the other is release.
    /// \ingroup nvstServerSdkAPIs
    NVST_API NvstResult nvstSetEtwAdapterFactory(void* pSharedPtrToFactory);
    /// @}

    /// \internal Handle of the VideoContext object
    typedef void* NvstVideoContext;

    /// \internal Set VideoContext in SDK. This is a temporay API that will be removed once
    /// porting is complete
    /// \todo Remove this API once porting is complete.
    /// \endinternal
    /// \warning Only to be used by internal users.
    NVST_API NvstResult nvstSetVideoContext(NvstVideoContext videoContext, NvstStream stream);

    /// \internal Get default NvEnc params
    /// \todo Remove this API once encode moves out of SDK
    /// \endinternal
    /// \warning Only to be used by internal users.
    NVST_API NvstResult nvstGetDefaultEncodeParams(void* encodeParams);

    /// \internal Recreate a StreamSdk stream pipeline without disconnecting the session.
    ///
    /// The API is synchronous and will only return once the pipeline is re-created.
    /// Once this API is called, StreamSDK does not guarantee the delivery of any pushed frames.
    /// nvstPushStreamData will fail till this API returns.
    /// If device is shared or no copy is enabled, StreamSdk expects the device or pushed frames/surface to remain valid
    /// for the duration of this API.
    /// Applications can pass a new device with the help of the activeConfig param. If this param is null, existing
    /// active stream config for passed streamConnection will be used to create the pipeline.
    /// This API will not make any stream related callbacks.
    /// \todo Remove internal tag once API is tested
    /// \param[in] streamConnection Handle to the stream connection that needs to be recreated.
    /// \param[in] activeConfig streamConfig that needs to be used as the active config for this stream. Optional param.
    /// \endinternal
    /// \warning Only to be used by internal users.
    /// \warning API only works for Video pipeline
    NVST_API NvstResult nvstRecreatePipeline(NvstStreamConnection streamConnection, NvstStreamConfig* activeConfig);
#if defined(__cplusplus)
}
#endif
