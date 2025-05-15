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

/// \file AudioFormat.h
/// Defines the audio format to be used by server and client.

#pragma once

#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    /// Specifies type of audio (raw PCM, encoded AAC, etc).
    /// \todo Add more formats as they are supported.
    /// \ingroup audioData
    typedef enum NvstAudioFormatTag_t
    {
        /// Invalid format tag.
        NVST_AUDIO_FORMAT_TAG_NONE = 0,
        /// 16 bit raw PCM (Little Endian).
        NVST_AUDIO_FORMAT_TAG_PCMLE_16_BIT,
    } NvstAudioFormatTag;

    /// Audio channel masks.
    /// \ingroup audioData
    typedef enum NvstAudioChannelMask_t
    {
        /// Mask for front left audio channel.
        NVST_ACM_FRONT_LEFT = 0x1,
        /// Mask for front right audio channel.
        NVST_ACM_FRONT_RIGHT = 0x2,
        /// Mask for binaural configuration.
        NVST_ACM_2POINT0 = NVST_ACM_FRONT_LEFT | NVST_ACM_FRONT_RIGHT,
        /// Mask for front center audio channel.
        NVST_ACM_FRONT_CENTER = 0x4,
        /// Mask for low frequency audio channel.
        NVST_ACM_LOW_FREQUENCY = 0x8,
        /// Mask for back left audio channel.
        NVST_ACM_BACK_LEFT = 0x10,
        /// Mask for back right audio channel.
        NVST_ACM_BACK_RIGHT = 0x20,
        /// Mask for quad configuration.
        NVST_ACM_QUAD = NVST_ACM_2POINT0 | NVST_ACM_BACK_LEFT | NVST_ACM_BACK_RIGHT,
        /// Mask for 5.1 configuration.
        NVST_ACM_5POINT1 = NVST_ACM_QUAD | NVST_ACM_FRONT_CENTER | NVST_ACM_LOW_FREQUENCY,
        /// Mask for front left of center audio channel.
        NVST_ACM_FRONT_LEFT_OF_CENTER = 0x40,
        /// Mask for front right of center audio channel.
        NVST_ACM_FRONT_RIGHT_OF_CENTER = 0x80,
        /// Mask for 7.1 configuration.
        NVST_ACM_7POINT1 = NVST_ACM_5POINT1 | NVST_ACM_FRONT_LEFT_OF_CENTER | NVST_ACM_FRONT_RIGHT_OF_CENTER,
    } NvstAudioChannelMask;

    /// Data about audio format.
    /// \ingroup audioData
    typedef struct NvstAudioFormat_t
    {
        /// Type of audio encoding.
        NvstAudioFormatTag formatTag;
        /// Sampling rate (samples per second).
        uint32_t samplingRate;
        /// Channel count.
        uint32_t channelCount;
        /// Channel mask (bitmask to represent channel configuration).
        NvstAudioChannelMask channelMask;
        /// Bitrate (bytes of audio data per second).
        uint32_t bitrate;
        /// Blockalign (block alignment, minimum atomic alignment of data for specified audio type in bytes).
        uint32_t blockAlign;
    } NvstAudioFormat;

#if defined(__cplusplus)
}
#endif
