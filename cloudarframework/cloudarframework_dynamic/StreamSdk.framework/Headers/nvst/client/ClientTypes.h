// Copyright NVIDIA Corporation 2017-2020
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

/// \file ClientTypes.h
/// Defines the streaming client's types.

#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \addtogroup SdkClientInterfaceStructs
    /// @{

    /// Handle of the NVST client instance.
    ///
    /// This is a result returned from nvstCreateClient() call.
    /// A new NvstClient instance is returned from every nvstCreateClient() call.
    /// Application can create multiple NvstClient instances.
    /// NvstClient is an ADT corresponding to an object
    /// that represents the core streaming client.
    /// \sa nvstCreateClient
    /// \sa nvstDestroyClient
    typedef struct NvstClient_t* NvstClient;

    /// Server network.
    typedef enum NvstServerNetwork_t
    {
        /// Unknown server network.
        NVST_SN_NONE = 0,
        /// Server reachable over LAN.
        NVST_SN_LAN = 1,
        /// Cloud server.
        NVST_SN_CLOUD = 2,
        /// Roaming server accessible over WAN or the Internet.
        NVST_SN_ROAMING = 3,
        /// Not a valid server network type - used only to count types.
        NVST_SN_END
    } NvstServerNetwork;

    /// Specifies different commands for streaming.
    typedef enum NvstStreamingCommand_t
    {
        /// Invalid command.
        NVST_STREAM_CMD_INVALID = -1,
        /// Start/resume streaming.
        NVST_STREAM_PLAY = 0,
        /// Pause streaming.
        NVST_STREAM_PAUSE = 1,
    } NvstStreamingCommand;

    /// @}

#if defined(__cplusplus)
}
#endif
