// Copyright NVIDIA Corporation 2019
// TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SOFTWARE IS PROVIDED
// AS IS AND NVIDIA AND ITS SUPPLIERS DISCLAIM ALL WARRANTIES, EITHER EXPRESS
// OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL
// NVIDIA OR ITS SUPPLIERS BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR
// CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR
// LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS
// INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
// INABILITY TO USE THIS SOFTWARE, EVEN IF NVIDIA HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGES.

/// \file Version.h
/// Defines the Streamer's Versioning interface.

#include "../common/Util.h"

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \addtogroup nvstVersionInterface NVST Versioning interface (Client)
    /// Actions related to Versioning
    /// @{
    /// Obtain version information.
    ///
    /// \retval A const char* with version information.
    /// \note Caller should not try to release the returned buffer.
    NVST_API const char* nvstGetVersion();

    /// Convenience typedef for library consumers.
    typedef const char* (*GET_VERSION_PROC)();
    /// @}

#if defined(__cplusplus)
}
#endif
