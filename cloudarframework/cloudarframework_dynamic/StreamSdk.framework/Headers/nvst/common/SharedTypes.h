// Copyright NVIDIA Corporation 2017 - 2022
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

/// \file SharedTypes.h
/// Header file with definitions of shared types and constants.

#pragma once

#include <stdint.h>

/// \addtogroup NvscInterfaceStructs
/// @{

/// Handle of the stream instance.
///
/// This is a result of a successful stream connection (audio, video, control).
/// It is delivered through the streamConnected() callback.
/// Each stream connection will result in a separate callback.
/// Stream disconnection results in a streamDisconnected() callback.
/// It should not automatically result in a client disconnection.
/// The application decides whether to keep a client connection with a stream missing.
/// \sa streamConnected
/// \sa streamDisconnected
///
/// \todo Rewrite the description when we have the exact details about NvstStreamConnection for client side.
typedef void* NvstStreamConnection;

/// Remove these once the NVSC headers get created from out of current XML file.
/// \todo NvstTransferProtocol, NvstPortUsage and NvstPortInfo should come from NVSC.
typedef enum NvstTransferProtocol_t
{
    NVST_TP_NONE,
    NVST_TP_TCP,
    NVST_TP_UDP_ENET,
    NVST_TP_UDP,
    NVST_TP_RTP,
    NVST_TP_WS,
    NVST_TP_WSS,
    NVST_TP_COUNT,
} NvstTransferProtocol;

typedef enum NvstPortUsage_t
{
    NVST_PU_NONE,
    NVST_PU_CONTROL,
    NVST_PU_VIDEO,
    NVST_PU_AUDIO,
    NVST_PU_INPUT,
    NVST_PU_SIGNALING,
    NVST_PU_MIC,
    NVST_PU_SECURE_SIGNALING,
    NVST_PU_COUNT,
} NvstPortUsage;

/// Port information type.
typedef struct NvstPortInfo_t
{
    uint16_t portNumber;
    NvstTransferProtocol protocol;
    NvstPortUsage usage;
} NvstPortInfo;

#define NVST_MAX_TURN_SERVER_SUPPORTED 4

/// STUN/TURN server information.
/// Check out this doc for more info: https://confluence.nvidia.com/pages/viewpage.action?pageId=622201137
/// \todo add summary of confluence once everything is decided
typedef struct NvstNatServer_t
{
    /// STUN/TURN server uris.
    const char** serverUris;
    uint8_t serverCount;
    /// Username for TURN/STUN server.
    const char* username;
    /// Credential can be password/token.
    const char* credential;
} NvstNatServer;

/// Supported IP versions
typedef enum NvstIpVersion_t
{
    NVST_IP_UNKNOWN = 0,
    NVST_IPV4 = 4,
    NVST_IPV6 = 6,
} NvstIpVersion;

/// Modes for recording stats
typedef enum NvstClientServerTraceCaptureFlags_t
{
    /// Disable ETL logging on server.
    NVST_STC_NO_STATS = 0x00000000,
    /// Enable ETL logging of all stats on server.
    NVST_STC_ALL_STATS = 0x00000001,
    /// Enable ETL logging of QoS-related stats on server.
    NVST_STC_QOS_STATS = 0x00000002,
    /// Enable ETL logging of video-related stats on server.
    NVST_STC_VIDEO_STATS = 0x00000004,
    /// Enable ETL logging of external (FBC, WGF2UM, VSync, etc) stats on server.
    NVST_STC_EXTERNAL_STATS = 0x00000008,
    /// Enable ETL logging of audio-related stats on server.
    NVST_STC_AUDIO_STATS = 0x00000010,
    /// Change ETL logging to compact mode for end users.
    NVST_STC_COMPACT_MODE = 0x00000020,
    /// Enable ETL logging of Nvstreamer events (CAPTURE_FRAME_START etc) on server.
    NVST_STC_EVENTS_STATS = 0x00000040,
    /// Enable ETL logging of game events on server
    NVST_STC_GAME_STATS = 0x00000080,
    /// Enable WebRtc stats
    NVST_STC_WEBRTC_STATS = 0x00000100,
    /// Enale capture stats(Used in RtcSdk)
    NVST_STC_MJOLNIR_CAPTURE_STATS = 0x00000200,
} NvstClientServerTraceCaptureFlags;

/// Modes for recording stats
typedef enum NvstClientStatsModeFlags_t
{
    /// Disable all client and server logging.
    NVST_CSM_DISABLE_STATS_LOGGING = 0x00000000,
    /// (DEPRECATED) Enable client and server logging of packet stats on local disk.
    NVST_CSM_ENABLE_PACKET_DATA_STATS = 0x00000001,
    /// (DEPRECATED) Enable client and server logging of video frame stats on local disk.
    NVST_CSM_ENABLE_FRAME_DATA_STATS = 0x00000002,
    /// Enable sending audio stats to server.
    NVST_CSM_ENABLE_AUDIO_QOS_STATS = 0x00000004,
    /// Enable sending video frame stats to server.
    NVST_CSM_ENABLE_CLIENT_FRAME_DECODED_STATS = 0x00000008,
    /// Enable additional serverside stats. Required for End-To-End latency breakdown.
    NVST_CSM_ENABLE_PIPELINE_STATS = 0x00000010,
    /// Enable Propagation of Gamepad button press event A to RtpAudioplayer to get logged in QOS stats.
    NVST_CSM_ENABLE_CLIENT_BUTTON_STATS = 0x00000020,
    /// Enable Client Etw Print and Client generic frame stats to be logged in  ETL
    NVST_CSM_CLIENT_OWNED_TRACES = 0x00000040,
    /// Enable Propagation of Mouse Click event to RtpAudioplayer to get logged in QOS stats.
    NVST_CSM_ENABLE_CLIENT_MOUSE_STATS = 0x00000080
} NvstClientStatsModeFlags;

/// Stores indices of mouse motion parameters that are packed in an array.
typedef enum NvstClientMouseSettingsIndex_t
{
    /// Ballistics threshold parameter 1.
    NVST_MSI_THRESHOLD_1 = 0,
    /// Ballistics threshold parameter 2.
    NVST_MSI_THRESHOLD_2 = 1,
    /// Acceleration value.
    NVST_MSI_ACCELERATION = 2,
    /// Speed value (mouse sensitivity).
    NVST_MSI_SENSITIVITY = 3,
    /// Not a valid settings index - used only to count indices.
    NVST_MSI_END
} NvstClientMouseSettingsIndex;

#pragma pack(push, 1)
/// Rectangle represented as a struct of two points.
///
/// Relative to the coordinate system's origin.
/// It is inclusive of the closer point and exclusive of the farther point.
/// (The farther point is +1 pixels from the rectangles farthest point.)
typedef struct NvstRect_t
{
    /// X coordinate of the point closer to the coordinate system's origin.
    int16_t x1;
    /// Y coordinate of the point closer to the coordinate system's origin.
    int16_t y1;
    /// X coordinate of the point farther from the coordinate system's origin.
    int16_t x2;
    /// Y coordinate of the point farther from the coordinate system's origin.
    int16_t y2;
} NvstRect;
#pragma pack(pop)

enum
{
    /// Index of the default stream.
    DEFAULT_VIDEO_STREAM = 0,

    /// The maximum number of concurrent video streams.
    /// For native StreamSdk, the limit is still 4.
    /// This is just for RtcStreamSdk.
    VIDEO_STREAM_MAX_COUNT = 6,
};

// Network connection type.
typedef enum NvstConnectionType_t
{
    /// Connection type unknown.
    NVST_CT_NONE = 0,
    /// Connection type is Ethernet.
    NVST_CT_ETHERNET = 1,
    /// Connection type is 5GHz Wi-Fi.
    NVST_CT_WIFI_5_0_GHZ = 2,
    /// Connection type is 2.4GHz Wi-Fi.
    NVST_CT_WIFI_2_4_GHZ = 3,
    /// Connection type is mobile LTE.
    NVST_CT_MOBILE_LTE = 4,
    /// Connection type is mobile 5G.
    NVST_CT_MOBILE_5G = 5,
    /// Not a valid connection type - used only to count types.
    NVST_CT_END
} NvstConnectionType;

// Network connection sub type.
typedef enum NvstConnectionSubType_t
{
    /// Connection sub type unknown.
    NVST_CST_NONE = 0,
    /// Connection sub type is mobile 5G LTE CA.
    NVST_CST_MOBILE_5G_LTE_CA = 1,
    /// Connection sub type is mobile 5G LTE Advanced Pro.
    NVST_CST_MOBILE_5G_LTE_ADVANCED_PRO = 2,
    /// Connection sub type is mobile 5G NR.
    NVST_CST_MOBILE_5G_NR = 3,
    /// Connection sub type is mobile 5G NR NSA.
    NVST_CST_MOBILE_5G_NR_NSA = 4,
    /// Connection sub type is mobile 5G NR NSA MMWAVE.
    NVST_CST_MOBILE_5G_NR_NSA_MMWAVE = 5,
    /// Not a valid connection sub type - used only to count types.
    NVST_CST_END
} NvstConnectionSubType;

// Network connection info.
typedef struct NvstConnectionInfo_t
{
    /// Network connection type
    NvstConnectionType connectionType;
    /// Network connection sub type
    NvstConnectionSubType connectionSubType;
} NvstConnectionInfo;

/// Mode Flags for client transcoding stats
typedef enum NvstClientTranscodeModeFlags_t
{
    ///8-LSB per frame flags /sa ClientToServerFrameTranscodeStats
    /// Specifies the frame was not transcoded
    NVST_CTM_STATE_NONE = 0x00000000,
    /// Specifies the transcode of the frame was completed successfully
    NVST_CTM_STATE_COMPLETED = 0x00000001,
    /// Specifies the transcode of the frame was skipped
    NVST_CTM_STATE_SKIPPED = 0x00000002,
    /// Specifies the transcode of the frame has failed
    NVST_CTM_STATE_FAILED = 0x00000004,
    /// Specifies the frame was transcoded as an I-Frame
    NVST_CTM_TYPE_IFRAME = 0x00000010,
    /// Specifies the frame was transcoded as a P-Frame
    NVST_CTM_TYPE_PFRAME = 0x00000020,

    /// Reserved bits

    ///8-MSB transcode metadata flags
    /// Specifies the transcode format as H264
    NVST_CTM_FORMAT_H264 = 0x20000000,
    /// Specifies the transcode format as H265
    NVST_CTM_FORMAT_H265 = 0x40000000,
    /// Specifies the start of client recording with transcode
    NVST_CTM_RECORDING_START = 0x80000000
} NvstClientTranscodeModeFlags;

/// @}
