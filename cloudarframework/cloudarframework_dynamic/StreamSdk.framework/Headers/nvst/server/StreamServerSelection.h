// Copyright NVIDIA Corporation 2021
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

/// \file StreamServerSelection.h
/// Defines the function used to select the active implementation of Stream SDK.

#pragma once

#include <nvst/common/Result.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    /// \internal Stream SDK server API implementations
    /// \todo Remove this enumeration once porting is complete.
    /// \endinternal
    /// \warning Only to be used by internal users.
    typedef enum NvstServerApiImplementations_t
    {
        /// Implementation located in StreamServerShared.
        NVST_STREAM_SERVER_SHARED,
        /// Implementation located in StreamServerRtc.
        NVST_STREAM_SERVER_RTC
    } NvstServerApiImplementations;

    /// \internal Selects Stream SDK server API implementation to be loaded.
    /// It also unloads a previously loaded implementation (if any).
    /// \todo Remove this function once porting is complete.
    /// \endinternal
    /// \warning Only to be used by internal users.
    NVST_API NvstResult nvstSelectServerApiImplementation(NvstServerApiImplementations sdk);
#if defined(__cplusplus)
}
#endif
