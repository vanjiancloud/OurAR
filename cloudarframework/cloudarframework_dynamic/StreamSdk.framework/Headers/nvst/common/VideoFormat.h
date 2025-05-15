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

/// \file VideoFormat.h
/// Video related definitions.

#pragma once

#include <stdbool.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    /// The format of a surface
    ///
    /// \warning NVST_SF_YCbCr420p and NVST_SF_YCbCr444p are not yet supported
    /// \ingroup Video
    typedef enum NvstSurfaceFormat_t
    {
        /// Invalid surface format.
        NVST_SF_NONE = 0,

        /// 32bpp packed A8R8G8B8
        /// The pitch is obtained from the GPU on allocation and can later be obtained with pitch().
        /// \warning Only supported with the following SurfaceOrigin: D3D9, D3D11 and SYSMEM
        NVST_SF_ARGB = 1,

        /// Y'CbCr "YUV" 4:2:0 planar
        /// Width and height must be even on this format.
        /// Pitch is not used for this format and will be set to 0.
        /// \warning Currently not supported
        NVST_SF_YCbCr420p = 2,

        /// NV12: Y'CbCr "YUV" 4:2:0 planar with interleaved chroma.
        /// Both the luma and the interleaved chroma lines use the same pitch, which is obtained from the GPU.
        /// Width and height must be even on this format.
        /// \warning Only supported with NVMEDIA SurfaceOrigin
        NVST_SF_NV12 = 3,

        /// Y'CbCr "YUV" 4:4:4 planar
        /// Pitch is not used for this format and will be set to 0.
        /// \warning Currently not supported
        NVST_SF_YCbCr444p = 4,

        /// 32bpp packed A2B10G10R10
        /// The pitch is obtained from the GPU on allocation and can later be obtained with pitch().
        /// \warning Only supported with CUDA SurfaceOrigin
        NVST_SF_ABGR10 = 5,

        /// 32bpp packed B8G8R8A8
        /// The pitch is obtained from the GPU on allocation and can later be obtained with pitch().
        /// \warning Only supported with CUDA SurfaceOrigin and DDA frame provider
        NVST_SF_BGRA = 6,

        /// 32bpp packed A8B8G8R8
        /// The pitch is obtained from the GPU on allocation and can later be obtained with pitch().
        NVST_SF_ABGR = 7,

        /// Encoded H.264
        NVST_SF_H264_VIDEO = 8,
    } NvstSurfaceFormat;

    /// Colorspace of input surface
    ///
    /// \ingroup Video
    typedef enum NvstCscMode_t
    {
        /// BT601 limited range YCbCr ([16, 235] for Y and [16, 240] for CbCr).
        NVST_CSCM_LIMITED_YCBCR_BT601 = 0,
        /// BT601 full range YCbCr ([0, 255] for Y and [0, 255] for CbCr).
        NVST_CSCM_FULL_YCBCR_BT601 = 1,
        /// BT709 limited range YCbCr ([16, 235] for Y and [16, 240] for CbCr).
        NVST_CSCM_LIMITED_YCBCR_BT709 = 2,
        /// BT709 full range YCbCr ([0, 255] for Y and [0, 255] for CbCr).
        NVST_CSCM_FULL_YCBCR_BT709 = 3,
        /// BT2020 limited range YCbCr ([16, 235] for Y and [16, 240] for CbCr).
        NVST_CSCM_LIMITED_YCBCR_BT2020 = 4,
        /// BT2020 full range YCbCr ([0, 255] for Y and [0, 255] for CbCr).
        NVST_CSCM_FULL_YCBCR_BT2020 = 5,
        /// Has the same color primaries and white points as Rec.709, but uses its own transfer characteristic.
        NVST_CSCM_LIMITED_SRGB = 6,
        /// Has the same color primaries and white points as Rec.709, but uses its own transfer characteristic.
        NVST_CSCM_FULL_SRGB = 7
    } NvstCscMode;

    const char* NvstCscModeToString(NvstCscMode cscMode);
    bool IsValidCscMode(NvstCscMode cscMode);

    /// The memory type of a graphics surface.
    /// \ingroup Video
    typedef enum NvstSurfaceOrigin_t
    {
        /// Invalid surface origin.
        NVST_SO_NONE = 0,

        /// Frame located in system memory.
        NVST_SO_SYSMEM = 1,

        /// CUDA surface.
        /// \note Not supported on 32bit Windows builds
        NVST_SO_CUDA = 2,
        NVST_SO_D3D9 = 3,
        NVST_SO_D3D11 = 4,

        /// \warning Currently not supported
        NVST_SO_D3D12 = 5,

        /// \warning Currently not supported
        NVST_SO_OPENGL = 6,

        /// \warning Currently not supported
        NVST_SO_VULKAN = 7,
        NVST_SO_NVMEDIA = 8,

        /// Pre-Encoded
        /// Special case for video data that is already encoded.
        NVST_SO_PRE_ENCODED = 9,
    } NvstSurfaceOrigin;

    /// Format of the encoded video which will be produced by the server.
    /// \sa NvstVideoStreamConfig for additional information related to encoding.
    /// \todo Add lossless compression.
    /// \ingroup Video
    typedef enum NvstVideoFormat_t
    {
        /// H264/AVC video format
        NVST_VF_H264 = 0,

        /// H265/HEVC video format
        NVST_VF_H265 = 1,
    } NvstVideoFormat;

    /// HDR modes
    /// \todo add comments to values
    /// \ingroup Video
    typedef enum NvstHdrMode_t
    {
        NVST_HM_SDR = 0,
        NVST_HM_HDR = 1,
        NVST_HM_EDR = 2,

        /// Not a valid HDR mode - used only to count enum values.
        NVST_HM_TYPE_END
    } NvstHdrMode;

#if defined(__cplusplus)
}
#endif
