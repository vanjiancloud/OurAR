// Copyright NVIDIA Corporation 2020 - 2021
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

/// \file MessageForServer.h
/// Messages that can be dynamically send or get by server during a streaming session.

#pragma once

#if defined(__cplusplus)
extern "C"
{
#endif

#include "StreamData.h"
#include "SharedTypes.h"
#include "VideoDecodeUnit.h"

    /// \addtogroup SdkClientInterfaceStructs
    /// @{

    /// Content capture flags.
    ///
    /// Server will honor change requested by the client only when allowed
    typedef struct NvstContentCaptureFlags_t
    {
        /// Requester bit - defines which party decides on the video capture mode
        /// If it is the server (0), the rest of this nibble is ignored
        /// If it is the client (1), the rest of this nibble provides more settings
        uint32_t requesterClient : 1;
        /// Video capture mode bit - full-screen (0) or windowed (1)
        uint32_t modeWindowed : 1;
        /// Duration bit - until the end of the streaming session (0) or
        /// until the server detects a change in full-screen state (1)
        uint32_t durationUntilChange : 1;
        /// Background bit - solid black (0) or a blended image (1)
        /// Considered only when the windowed bit indicates windowed mode (1)
        uint32_t blendBackground : 1;
        /// Requested alpha format, \sa NvstAlphaFormat
        uint32_t alphaFormat : 2;
        /// Padding up to full 32 bits. Can be reused later
        uint32_t currentlyUnused : 26;
    } NvstContentCaptureFlags;

    /// Enumeration of per-pixel alpha formats
    typedef enum NvstAlphaFormat_t
    {
        NVST_ALPHA_FORMAT_NONE = 0,
        NVST_ALPHA_FORMAT_RGBXA = 1,
        NVST_ALPHA_FORMAT_YUVXA = 2,
    } NvstAlphaFormat;

    /// Send audio device related event to core audio code paths
    /// \todo Convert to a proper struct with designated fields for device, state, etc
    typedef struct NvstAudioEvent_t
    {
        /// Details about audio device and feature state
        const uint8_t* audioEventData;
        /// Size (in bytes)
        uint32_t sizeInBytes;
    } NvstAudioEvent;

    /// A free form debug information to be stored on the server
    /// \note Sending too many debug information can have impact on streaming performance
    typedef struct NvstDebugInfo_t
    {
        /// Stream to which this data is associated
        uint16_t streamIndex;
        /// Null terminated string
        char data[256];
    } NvstDebugInfo;

    /// Update the state of a video decoder
    typedef struct NvstVideoDecoderStateInfo_t
    {
        /// Stream index
        uint16_t streamIndex;
        /// Frame number at which the video decoder state is updated
        uint32_t frameNumber;
        /// The state of video decoder
        NvstVideoDecoderState decoderState;
    } NvstVideoDecoderStateInfo;

    /// Update the network change info
    typedef struct NvstNetworkInfo_t
    {
        /// Network connection info
        NvstConnectionInfo connectionInfo;
        /// Signal strength of the network
        int32_t signalStrength;
    } NvstNetworkInfo;

    /// Structure to store mouse motion parameters
    typedef struct NvstMouseSettingsInfo_t
    {
        /// Mouse motion parameters
        uint32_t mouseSettings[NVST_MSI_END];
    } NvstMouseSettingsInfo;

    /// Structure to control perf indicator
    typedef struct NvstShowPerfIndicatorInfo_t
    {
        /// Flag to control perf indicator
        bool showPerfIndicator;
    } NvstShowPerfIndicatorInfo;

    /// Set the DRC(Dynamic Resolution Change) and DFC(Dynamic Frequency Control) feature state dynamically
    typedef struct NvstDrcDfcState_t
    {
        /// Stream index
        uint16_t streamIndex;
        /// DRC(Dynamic Resolution Change) and DFC(Dynamic Frequency Control) feature new state
        bool newState;
    } NvstDrcDfcState;

    /// Change the max bitrate dynamically
    typedef struct NvstMaxBitrateChange_t
    {
        /// Stream index
        uint16_t streamIndex;
        /// Bitrate in kbps
        uint32_t bitrateKbps;
    } NvstMaxBitrateChange;

    /// Message types
    typedef enum NvstMessageType_t
    {
        /// Invalid message type
        NVST_MESSAGE_NONE,
        /// Content capture flags
        NVST_MESSAGE_CONTENT_CAPTURE,
        /// Haptics state change
        /// Deprecated
        /// please use NvstInputEvent and NvstPushStreamData() on input stream
        NVST_MESSAGE_HAPTICS_STATE_DEPRECATED,
        /// Mouse cursor capture
        NVST_MESSAGE_MOUSE_CURSOR_CAPTURE,
        /// Mimic remote cursor
        NVST_MESSAGE_MIMIC_REMOTE_CURSOR,
        /// Mouse settings
        NVST_MESSAGE_MOUSE_SETTINGS_DEPRECATED,
        /// Debug info
        NVST_MESSAGE_DEBUG_INFO,
        /// Show/hide on-screen perf indicator
        NVST_MESSAGE_SHOW_PERF_INDICATOR,
        /// Video decoder state
        NVST_MESSAGE_VIDEO_DECODER_STATE,
        /// Update network change
        NVST_MESSAGE_UPDATE_NETWORK_CHANGE,
        /// Enable/Disable DRC/DFC feature dynamically
        NVST_MESSAGE_SET_DRC_DFC_STATE,
        /// Change the max bitrate dynamically
        NVST_MESSAGE_SET_MAX_BITRATE,
        /// Custom message from the client to the server
        NVST_MESSAGE_CUSTOM_MESSAGE
    } NvstMessageType;

    /// Structure used in nvstSendMessageToServer
    typedef struct NvstMessageForServer_t
    {
        /// Type of message being sent to the server
        /// This defines how the rest of the structure is interpreted
        NvstMessageType messageType;
        union
        {
            /// Content capture flags
            /// (messageType = NVST_MESSAGE_CONTENT_CAPTURE)
            NvstContentCaptureFlags contentCaptureFlags;
            /// Flag to control state of haptics feature
            /// (messageType = NVST_MESSAGE_HAPTICS_STATE)
            uint8_t hapticsState;
            /// Flag to control mouse capture
            /// (messageType = NVST_MESSAGE_MOUSE_CURSOR_CAPTURE)
            uint8_t mouseCursorCapture;
            /// Flag to control mimic remote cursor
            /// (messageType = NVST_MESSAGE_MIMIC_REMOTE_CURSOR)
            uint8_t mimicRemoteCursor;
            /// Stores mouse motion parameters
            /// (messageType = NVSTMESSAGE_MOUSE_SETTINGS)
            NvstMouseSettingsInfo mouseSettingsInfo;
            /// Debug information related to a stream
            /// (messageType = NVST_MESSAGE_DEBUG_INFO)
            NvstDebugInfo debugInfo;
            /// To control perf indicator
            /// (messageType = NVST_MESSAGE_SHOW_PERF_INDICATOR)
            NvstShowPerfIndicatorInfo showPerfIndicatorInfo;
            /// Video decoder state info
            /// (messageType = NVST_MESSAGE_VIDEO_DECODER_STATE)
            NvstVideoDecoderStateInfo vDecoderState;
            /// Update network change info
            /// (messageType = NVST_MESSAGE_UPDATE_NETWORK_CHANGE)
            NvstNetworkInfo networkInfo;
            /// Set the DRC(Dynamic Resolution Change) and DFC(Dynamic Frequency Control) feature state dynamically
            /// (messageType = NVST_MESSAGE_SET_DRC_DFC_STATE)
            NvstDrcDfcState drcDfcState;
            /// Change the max bitrate dynamically
            /// (messageType = NVST_MESSAGE_SET_MAX_BITRATE)
            NvstMaxBitrateChange maxBitrateChange;
            /// Custom message
            /// (messageType = NVST_MESSAGE_CUSTOM_MESSAGE)
            NvstCustomMessage customMessage;
        };
    } NvstMessageForServer;

    /// @}

#if defined(__cplusplus)
}
#endif
