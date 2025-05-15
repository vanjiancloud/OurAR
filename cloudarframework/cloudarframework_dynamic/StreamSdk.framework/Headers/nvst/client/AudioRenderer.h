// Copyright (c) 2017-2021, NVIDIA CORPORATION.  All rights reserved.
//
// NVIDIA CORPORATION and its licensors retain all intellectual property
// and proprietary rights in and to this software, related documentation
// and any modifications thereto.  Any use, reproduction, disclosure or
// distribution of this software and related documentation without an express
// license agreement from NVIDIA CORPORATION is strictly prohibited.

/// \file AudioRenderer.h
/// Defines the interface between the streaming core and a platform specific audio renderer.

#pragma once

#include "../common/AudioFrame.h"

#if defined(__cplusplus)
extern "C"
{
#endif

    /// The type of the callback used to deliver the audio stream to the renderer.
    /// \param[in] userData The opaque pointer specified during initialization.
    /// Provided by the client during the initialization of the NVSC API.
    /// NVSC will then provide this value at all invocations of this callback.
    /// \sa NvstAudioRenderer::userData
    /// \param[in] audioFrame Struct representing an audio frame.
    /// \warning The audio frame is guaranteed to be valid only until the render function returns.
    /// If the client application desires to handle the audio frame on a separate thread,
    /// it should deep-copy the audio frame before returning from the render function.
    typedef void (*RENDER_AUDIO_FRAME_PROC)(void* userData, const NvstAudioFrame* audioFrame);

    /// Information about the audio renderer.
    /// \remarks
    /// An instance of this struct, with the appropriate values,
    /// must be specified during initialization of the stream client.
    typedef struct NvstAudioRenderer_t
    {
        /// Specify if the render callback would be blocking.
        /// \remarks
        /// If this callback is blocking, render callback would be called periodically by the SDK. The SDK would
        /// maintain real-time playback in this case.
        /// If this callback is not blocking, render callback would be called immediately, and  client should
        /// block the callback to maintain real-time playback. This is useful in cases where a blocking audio API is
        /// used or where the audio API uses a notification mechanism (event/semaphore/callback not requiring data to
        /// be written) to notify the user that audio can be written to the API.
        bool blocking;

        /// Opaque pointer associated with the audio renderer.
        void* userData;

        /// Function to deliver audio frames to the renderer.
        RENDER_AUDIO_FRAME_PROC renderAudioFrameProc;
    } NvstAudioRenderer;

#if defined(__cplusplus)
}
#endif
