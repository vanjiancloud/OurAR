// Copyright NVIDIA Corporation 2017 - 2019
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

/// \file AudioFrame.h
/// Defines the audio frames streamed between the server and the client.

#pragma once

#include "AudioFormat.h"
#include <stdbool.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \addtogroup AudioData
    /// @{

    /// Forward declaration needed for the callback's definition.
    typedef struct NvstAudioFrame_t NvstAudioFrame;

    /// Type for the callback used to release the given audio frame.
    ///
    /// The module that produced the frame (owner) provides this callback
    /// together with the data that describes the audio content of the frame.
    /// The module to which the frame was given will invoke the release callback
    /// once it is done processing the audio frame and then the owner will release it.
    /// Typical usages:
    /// - once client's audio renderer calls the callback, NVSC releases the frame.
    /// - once NVSS calls the callback, the streamed application releases the frame.
    /// \param[in] audioFrame The audio frame to be released.
    /// \warning The pointed at object becomes invalid after this function is invoked.
    /// The caller should not access the pointed at object after that.
    typedef void (*RELEASE_AUDIO_FRAME_PROC)(const NvstAudioFrame* audioFrame);

    /// Data about a frame of the audio stream and its release callback.
    /// \remarks
    /// The audio stream is delivered through this struct.
    /// Typical usage:
    /// - NVSC will deliver the audio frame to the client through this structure.
    /// - NVSS will accept the audio frame to be sent through this structure.
    /// Once the receiving module processes the audio frame,
    /// it will call the callback function provided as one of the fields.
    /// \sa RELEASE_AUDIO_FRAME_PROC
    typedef struct NvstAudioFrame_t
    {
        /// Capture time stamp (in milliseconds).
        uint64_t timeStampMs;
        /// Audio format descriptor.
        NvstAudioFormat format;
        /// Indicates if this audio frame is a filler that attempts to conceal packet loss.
        bool lossConcealmentFiller;
        /// The buffer containing the audio stream.
        void* streamBuffer;
        /// The size of the buffer (in bytes).
        uint32_t streamSizeBytes;
        /// Opaque handle associated with the struct.
        void* frameContext;
        /// Function to release resources associated with the struct.
        /// \warning The struct becomes invalid after this function is invoked.
        /// The caller should not access the struct after that.
        RELEASE_AUDIO_FRAME_PROC releaseProc;
    } NvstAudioFrame;

    /// @}

#if defined(__cplusplus)
}
#endif
