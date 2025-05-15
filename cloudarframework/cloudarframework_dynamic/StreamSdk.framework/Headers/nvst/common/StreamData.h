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

/// \file StreamData.h
/// Header file with defintions of data types sent through streams.

#pragma once

#include "AudioFrame.h"
#include "InputEvent.h"
#include "StreamInternal.h"
#include <limits.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

/// Indicates the type of encoded frame.
/// B frame is currently not supported.
/// \ingroup VideoData
typedef enum NvstEncodedFrameType_t
{
    NVST_EFT_NONE = 0,
    NVST_EFT_I_FRAME = 1,
    NVST_EFT_P_FRAME = 2,
    NVST_EFT_IR_FRAME = 3,
    NVST_EFT_NRP_FRAME = 4,
} NvstEncodedFrameType;

typedef enum NvstVirtualVsyncFrameStatus_t
{
    /// Virtual Vsync isn't enabled.
    NVST_VV_DISABLED = 70,
    /// Virtual Vsync is enabled, but timing wasn't used to capture this frame.
    NVST_VV_INACTIVE_THIS_FRAME = 80,
    /// Virtual Vsync timing was used to capture this frame.
    NVST_VV_ACTIVE_THIS_FRAME = 90
} NvstVirtualVsyncFrameStatus;

/// Forward declaration needed for the callback's definition.
typedef struct NvstGraphicsSurface_t NvstGraphicsSurface;

/// Graphics surface information,
/// together with the pointer to the memory containing the pixels.
/// \sa nvstPushStreamData
/// \todo Add metadata (e.g. coordinates of embedded windows, VR timestamps, etc.)
/// \ingroup VideoData
typedef struct NvstGraphicsSurface_t
{
    /// Width in pixels.
    uint16_t width;
    /// Height in pixels.
    uint16_t height;
    /// Width in pixels of useful data inside the frame, needed only for DX interfaces.
    /// If unspecified, will be assumed to be the same as width
    uint32_t dataWidth;
    /// Height in pixels of useful data inside the frame, needed only for DX interfaces.
    /// If unspecified, will be assumed to be the same as height
    uint32_t dataHeight;
    /// Width of the frame buffer in bytes.
    uint16_t pitch;
    /// Rendered frame number. This field is optional.
    /// If present, may be used to estimate stutter because of a repeated frame or a missed frame.
    uint32_t renderSequenceNumber;
    /// Surface's render/creation timestamp (in microseconds).
    uint64_t renderTimestampUs;
    /// Surface's display timestamp (in microseconds).
    /// Used to specify the expected display time on the client display.
    uint64_t displayTimestampUs;
    /// Capture start timestamp of this frame
    double captureStartTs;
    /// Capture end timestamp of this frame.
    /// captureEndTs - captureStartTs should give time taken to generate this frame by application.
    double captureEndTs;
    /// Handle to this surface.
    void* surface;
    /// Opaque handle associated with the struct.
    void* context;
    /// Size of metadata attached.
    ///
    /// Needs to be 0 if metadata is not needed.
    uint8_t metadataSize;
    /// Buffer containing the metadata.
    ///
    /// SDK users needing to send metadata along with the frame should
    /// populate metadata and metadataSize. It is a binary blob that
    /// will be transferred verbatim and received as a part of the stream.
    void* metadata;
    /// External hint count per block
    ///
    /// Should not be more than 2
    size_t sizeHintPerBlock;
    /// Array of NVENC_EXTERNAL_ME_HINT_COUNTS_PER_BLOCKTYPE
    void* meHintCountsPerBlock;
    /// Struct of NVENC_EXTERNAL_ME_HINT
    void* meExternalHints;
    /// Whether to provide per-pixel-alpha information in the encoded frame.
    bool bPerPixelAlpha;
    /// Virtual Vsync information about this frame.
    NvstVirtualVsyncFrameStatus vvsyncStatus;
} NvstGraphicsSurface;

/// Forward declaration needed for the callback's definition.
typedef struct NvstMessage_t NvstMessage;

/// Type for the callback used to release the given message.
///
/// The module that produced the message (owner) provides this callback
/// together with the data that describes the content of the message.
/// The module to which the message was given will invoke the release callback
/// once it is done processing the message and then the owner will release it.
/// Typical usages:
/// - once client calls the callback, NVSC releases the message.
/// - once NVSS calls the callback, the streamed application releases the message.
/// \param[in] message The message to be released.
/// \warning The pointed at object becomes invalid after this function is invoked.
/// The caller should not access the pointed at object after that.
typedef void (*RELEASE_MESSAGE_PROC)(const NvstMessage* message);

/// Message whose delivery is not time critical.
///
/// Typical usage: send data that is not a part of a stream (not time-critical).
/// \sa nvstPushStreamData
/// \ingroup MessageData
typedef struct NvstMessage_t
{
    /// Null terminated message type.
    const char* messageType;
    /// Pointer to the data.
    void* data;
    /// Data size in bytes.
    size_t sizeInBytes;
    /// Null terminated data MIME type.
    const char* dataType;
    /// Null terminated recipient of the message.
    const char* recipient;
    /// Opaque handle associated with the struct.
    void* context;
    /// Function to release resources associated with this struct.
    /// \warning The struct becomes invalid after this function is invoked.
    /// The caller should not access the struct after that.
    RELEASE_MESSAGE_PROC releaseProc;
} NvstMessage;

/// Custom message: generic message type delivered by control channel
typedef struct NvstCustomMessage_t
{
    /// Payload size(in bytes).
    uint16_t payloadSize;
    /// Payload bytes.
    const uint8_t* payload;
} NvstCustomMessage;

/// Forward declaration needed for the callback's definition.
typedef struct NvstPreEncodedVideo_t NvstPreEncodedVideo;
/// Pre-encoded video data.
///
/// \sa nvstPushStreamData
/// \ingroup VideoData
typedef struct NvstPreEncodedVideo_t
{
    /// Pointer to the pre-encoded frame data.
    void* frame;
    /// Data size in bytes.
    uint32_t sizeInBytes;
    /// Number of the frame. Used to identify frame in the related callback.
    uint32_t frameNumber;
    /// Encoded frame type, used only for preencoded frames.
    NvstEncodedFrameType encodedFrameType;
    /// Opaque handle associated with the struct.
    void* context;
} NvstPreEncodedVideo;

/// Media type for the stream.
/// \ingroup VideoData
typedef enum NvstMediaType_t
{
    NVST_MT_NONE = 0,
    NVST_MT_VIDEO = 1,
    NVST_MT_AUDIO = 2,
    NVST_MT_PRE_ENCODED_VIDEO = 3,
    NVST_MT_INPUT = 4,
    NVST_MT_MIC = 5,
    /// \internal
    /// Used by internal users to pass a Video Frame in StreamData
    /// \endinternal
    /// \warning Only to be used by internal users.
    NVST_MT_VIDEO_INTERNAL = 8,
    /// \internal Must always be last.  Used for bounds checking.
    NVST_MT_LAST
} NvstMediaType;

/// Defines media type and actual payload of a stream datum.
///
/// Frame information structure changes depending on the media type.
/// \ingroup streamData
typedef struct NvstStreamData_t
{
    /// Indicates the media type of these particular stream data.
    NvstMediaType mediaType;

    /// Nameless union that holds the data type designated by mediaType.
    union
    {
        /// \sa RELEASE_GRAPHICS_SURFACE_PROC
        NvstGraphicsSurface graphicsSurface;
        /// \sa RELEASE_AUDIO_FRAME_PROC
        NvstAudioFrame audioFrame;
        /// \sa RELEASE_MESSAGE_PROC
        NvstMessage message;
        /// \todo Replace this with NvstVideoDecodeUnit vdu;
        /// \todo Consider if we want to rename VDU to NvstEncodedVideoUnit (EVU).
        /// \sa RELEASE_VU_PROC
        NvstPreEncodedVideo preEncodedVideo;
        /// \todo Add RELEASE_INPUT_EVENT_PROC
        /// \sa RELEASE_INPUT_EVENT_PROC
        NvstInputEvent input;
        /// \internal
        /// Place holder for VideoFrame and related info.
        /// \endinternal
        /// \warning Only to be used by internal users.
        NvstVideoFrameInfoInternal videoFrameInfo;
    };
} NvstStreamData;
