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

/// \file RuntimeParam.h
/// Client-side parameters that can be dynamically set or queried during a streaming session.
/// \todo Consider whether to move some of these paramters to common part,
/// so that the server-side code can use them as well.

#pragma once

#if defined(__cplusplus)
extern "C"
{
#endif

#include <nvst/client/NvstClientDJBConfig.h>
#include <nvst/common/SharedTypes.h>
#include <nvst/common/VideoDecodeUnit.h>

#include <stdbool.h>

    /// \addtogroup SdkClientInterfaceStructs
    /// @{

    /// Stream IDs.
    /// \todo Move this to nvst/SharedTypes.h and reconcile with other stream related defines.
    typedef enum NvstClientStreamId_t
    {
        /// Invalid stream id
        NVST_STREAM_ID_NONE = 0,
        /// Remote input stream
        NVST_STREAM_ID_REMOTE_INPUT = 1,
        /// Video stream
        NVST_STREAM_ID_VIDEO = 2,
        /// Audio stream
        NVST_STREAM_ID_AUDIO = 3,

        // Preserve "some" compatibility with Legacy code
        // although the AV stream ID is used only for video
        // with audio now having its own stream ID
        NVST_STREAM_ID_AUDIO_VIDEO = NVST_STREAM_ID_VIDEO,
    } NvstClientStreamId;

    /// Key types.
    typedef enum NvstClientKeyType_t
    {
        /// No encryption. key parameter is ignored
        NVST_KEY_TYPE_NONE = 0,
        /// AES128-CBC. The size of key parameter is 16 bytes
        NVST_KEY_TYPE_AES128_CBC = 1,
        /// AES192-CBC. The size of key parameter is 24 bytes
        NVST_KEY_TYPE_AES192_CBC = 2,
        /// AES256-CBC. The size of key parameter is 32 bytes
        NVST_KEY_TYPE_AES256_CBC = 3,
    } NvstClientKeyType;

    /// Constants for key lengths (in bytes).
    typedef enum NvstClientKeyLengths_t
    {
        /// Maximum key length for AES256 is 32 bytes.
        NVST_KEY_MAX_LENGTH = 32,
        /// Maximum IV length is 16 bytes.
        NVST_KEY_MAX_IV_LENGTH = 16,
    } NvstClientKeyLengths;

    /// Encryption key.
    /// \remarks
    /// This key is optional.
    /// If not set, the stream identified by streamId is presumed to be in the clear,
    /// which may result in certain features of the server (e.g. remote login) to be disabled.
    typedef struct NvstClientRuntimeEncryptionKey_t
    {
        /// The ID of the key being set.
        /// \note Currently ignored; reserved for future use to support key rotation.
        uint32_t keyId;
        /// The ID of the stream to set this key on.
        /// \note Currently ignored; reserved for future use to support A/V encryption.
        /// So, at this time key is assumed to be set for remote input stream only.
        NvstClientStreamId streamId;
        /// The type of the key being set.
        NvstClientKeyType keyType;
        /// The key data. The size of this data depends on keyType.
        /// For all key types other than NVST_KEY_TYPE_NONE,
        /// this field must carry the key in it.
        /// \note Providing the key of all zeros turns encryption off
        /// and is the same as using NVST_KEY_TYPE_NONE.
        uint8_t key[NVST_KEY_MAX_LENGTH];
    } NvstClientRuntimeEncryptionKey;

    /// Set the vsync interval, for the display on which the video at
    /// streamIndex will be shown, as an interval in microseconds.
    ///
    /// For example, for 60Hz video set 16667, 59.94 set 16683
    ///
    /// This interval may be used as a hint by the server to adjust the
    /// rate at which it captures and sends video frames.
    typedef struct NvstClientRuntimeVsyncInterval_t
    {
        uint16_t streamIndex;
        uint32_t intervalUs;
    } NvstClientRuntimeVsyncInterval;

    /// Check if HEVC streaming is supported.
    ///
    /// \todo Add stats for codec supported, feature capability and max perf.
    /// \todo Move NVST_RUNTIME_PARAM_DECODER_FPS inside this structure.
    typedef struct NvstClientRuntimeHevcSupport_t
    {
        /// Check if HEVC streaming is supported or not.
        bool hevcSupported;
    } NvstClientRuntimeHevcSupport;

    /// \todo Remove fixed value assignments as we won't send them over the network.
    /// Paramter type IDs
    typedef enum NvstClientRuntimeParamId_t
    {
        /// Invalid runtime parameter id.
        NVST_RUNTIME_PARAM_NONE = 0,
        /// QoS statistics.
        /// Check HEVC support info.
        NVST_RUNTIME_PARAM_HEVC_SUPPORT = 7,
        /// Extended stats.
        NVST_RUNTIME_PARAM_EXTENDED_STATS_DEPRECATED = 21,
        /// Enable/disable microphone (if decided dynamically, eg, on Android)
        NVST_RUNTIME_PARAM_MIC_ENABLE = 24,
        /// Set video playback device vsync interval
        NVST_RUNTIME_PARAM_VSYNC_INTERVAL = 30,
        /// Set connection Type
        NVST_RUNTIME_PARAM_CONNECTION_TYPE = 31,
        /// Enable/disable speaker
        NVST_RUNTIME_PARAM_SPEAKER_ENABLE = 32,
        /// ADJB Configuration
        NVST_RUNTIME_PARAM_ADJB_CONFIG = 33
    } NvstClientRuntimeParamId;

    /// Struct storing runtime session parameters.
    /// \remarks
    /// Runtime session parameters can be set, queried, or both,
    /// dependent on the particular parameter.
    /// \sa nvstClientGetRuntimeParam
    /// \sa nvstClientSetRuntimeParam
    typedef struct NvstClientRuntimeParam_t
    {
        /// ID of the parameter being set or queried.
        /// This defines how the rest of the structure is interpreted.
        NvstClientRuntimeParamId paramId;
        union
        {
            /// Check HEVC support (param = NVST_RUNTIME_PARAM_HEVC_SUPPORT).
            NvstClientRuntimeHevcSupport hevcSupport;
            /// Flag to control mic capture, if decided dynamically
            bool micEnable;
            /// Set video playback device vsync interval
            NvstClientRuntimeVsyncInterval vsyncInterval;
            /// Update the change in connection info
            NvstConnectionInfo connectionInfo;
            NvstClientDJBConfig djbConfig;
        };
    } NvstClientRuntimeParam;

    /// @}

#if defined(__cplusplus)
}
#endif
