// Copyright NVIDIA Corporation 2017 - 2020
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

/// \file VideoDecoder.h
/// Defines the interface between the streaming core and a platform specific video decoder.

#pragma once

#include <stdbool.h>
#include <stdint.h>

#include "../common/VideoDecodeUnit.h"

#if defined(__cplusplus)
extern "C"
{
#endif

/// \addtogroup Video
/// @{

/// Use standard limits for maximum number of reference frames.
#define USE_STANDARD_LIMITS 0

    /// Used to tell the decoder whether to enable or disable the video jitter buffer.
    /// \param[in] userData The opaque pointer specified during initialization.
    /// Provided by the client during the initialization of the NVSC API.
    /// NVSC will then provide this value at all invocations of this callback.
    /// \param[in] bEnable Enable jitter buffer if this is true, disable otherwise.
    typedef void (*CONTROL_VIDEO_JITTER_BUFFER_PROC)(void* userData, bool bEnable);

    /// Struct holding video Quality of Service requirements from client.
    typedef struct NvstClientVideoQosSetting_t
    {
        /// Dynamic resolution mode.
        /// Server will generate different video resolutions based on network streaming condition.
        bool videoDynamicResolutionMode;

        /// Display error recovery mode.
        /// Due to network condition, video frame data can be lost,
        /// which causes video corruption until recovered.
        /// Decoder can choose different modes in this case.
        /// false - pause on loss of frame data.
        /// true - continue display on loss of frame data.
        bool videoDisplayContinueOnFrameLoss;

        /// H.264 encoder mode for multithreaded slice decode support.
        /// If the client wishes to decode multiple slices in parallel,
        /// then constrained encoding must be enabled.
        /// Deblocking across slice boundaries must be disabled:
        /// sliceMode = 3 and sliceModeData = slicesPerFrame.
        /// \todo Explain why is encoder mode present in client header.
        bool videoSliceDecodeMultithreaded;

        /// Multi-reference video frames are P frames that use multiple previous frames as references.
        /// Some client features may not be able to accept multi-reference frames.
        /// This flag allows clients to disable the encoder muti-reference feature.
        bool disableMultiReference;

        /// Number of slices into which frames are divided.
        /// \todo This is replicated information from the VDU struct.
        uint32_t slicesPerFrame;

        /// Maximum number of reference frames.
        /// Specify maximum number of reference frames decoder needs to maintain on client.
        /// Clients can choose values from 1 to 16.
        /// Standards specify the max at 16, hence server will cap the value even
        /// if client passes any value greater than 16. If client set this value to 0,
        /// it means maximum number of reference frames will be determined based on standard limits.
        /// \warning The value will be deprecated in one of the coming releases.
        /// \sa NvstVideoStreamConfig::maxNumReferenceFrames
        uint32_t maxNumReferenceFrames;
    } NvstClientVideoQosSetting;

    /// The type of the method used to deliver the H.264 bitstream to the decoder.
    /// \param[in] userData The opaque pointer specified during initialization.
    /// Provided by the client during the initialization of the NVSC API.
    /// NVSC will then provide this value at all invocations of this callback.
    /// \sa NvstVideoDecoder::userData
    /// \param[in] vdu Struct representing a VU (a portion of the H.264 stream).
    typedef void (*DECODE_VU_PROC)(void* userData, const NvstVideoDecodeUnit* vdu);

    /// Struct holding information about a H.264 decoder.
    /// \remarks
    /// An instance of this struct, with the appropriate values,
    /// must be specified during initialization of the stream client.
    typedef struct NvstVideoDecoder_t
    {
        /// Opaque pointer associated with the decoder.
        void* userData;

        /// Expected VU type.
        NvstVideoDecodeUnitType expectedVduType;

        /// Bitfield indicating the recovery types supported by the decoder.
        /// At least one must be supported.
        /// \todo Explain who populates this bitfield.
        uint32_t streamRecoveryType;

        /// Maximum H264 profile handled by the decoder.
        NvstH264Profile maxH264Profile;

        /// Maximum H264 level handled by the decoder.
        /// \remarks
        /// Only values from {41, 42, 50, 51} are supported.
        /// This is currently only used to compute the maximum number of reference frames.
        uint32_t maxH264Level;

        /// Maximum Reference Frames handled by the decoder.
        uint32_t maxNumReferenceFrames;

        /// Video QoS settings.
        NvstClientVideoQosSetting videoQosSetting;

        /// Function to deliver a H.264 decode unit to the decoder.
        /// \warning The callback will be deprecated in one of the coming releases.
        /// \sa NvstVideoStreamConfig::onVideoReceived
        DECODE_VU_PROC decodeVideoUnitProc;

    } NvstVideoDecoder;

    /// @}

#if defined(__cplusplus)
}
#endif
