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

#pragma once

#include <stdbool.h>

/// \addtogroup SdkClientInterfaceStructs
/// @{

//! Reason for an NvstClientDJBConfig message being sent.
typedef enum NvstClientDJBChangeReason_t
{
    //!< Initial state / no reason given
    NVST_DJB_CHANGE_UNKNOWN = 0,
    //!< QoS requests change (e.g. due to nack)
    NVST_DJB_CHANGE_QOS = 1,
    //!< Dejitter buffer mode changed
    NVST_DJB_CHANGE_MODE = 2,
} NvstClientDJBChangeReason;

//! Method used by the client for implementing dejitter
typedef enum NvstClientDJBMode_t
{
    //!< Initial state / unspecified dejitter mode.
    NVST_DJB_MODE_UNKNOWN = 0,
    //!< Using VVsync buffer sizing
    NVST_DJB_MODE_VVSYNC = 1,
    //!< Using timestamp buffer sizing
    NVST_DJB_MODE_TIMESTAMP = 2,
    //!< Using fixed buffer sizing
    NVST_DJB_MODE_FIXED = 3
} NvstClientDJBMode;

/*! Client dejitter buffer config change event.
 *  This event is used in two directions:
 *  1. From QoS => Client Video Renderer (via NvscClientEvent callback)
 *  2. From Client Video Renderer => QoS (via nvstSetRuntimeParam)
 *
 *  In the first direction, it allows QoS to state its desired video buffering properties.
 *  In response, the client should use nvstSetRuntimeParam to acknowledge the request,
 *  with any modifications set according to its internal limits.
 *
 *  In the second direction, it allows the client video renderer to update QoS when
 *  its rendering mode or buffering characteristics have changed. For example,
 *  if the client enters or exits VVsync mode.
 */
typedef struct NvstClientDJBConfig_t
{
    //! The reason for the buffer config update
    NvstClientDJBChangeReason reason;

    //! The current dejitter implementation in use, if any.
    NvstClientDJBMode mode;

    //! The minimum video queue depth for the client to target.
    //  Set to 0 for no limit.
    uint32_t minDepthUs;

    //! The maximum video queue depth for the client to target.
    //  Set to 0 for no defined limit (client will use default limit for its render type)
    uint32_t maxDepthUs;

    //! QoS may set force to true to indicate that the client should
    //  allow its configured maximum limits to be bypassed while this
    //  configuration is in effect.
    //
    //  For example, if QoS wants 75000us for minDepthUs, and the client
    //  normally restricts its max buffer depth to 32000us, the client
    //  is instructed to attempt to use 75000us anyway, or the maximum
    //  limit allowed by its implementation, whichever is lower.
    //
    //  If force is false, the client is expected to honor the requested
    //  buffer depths only to the limits of its own configuration.
    bool force;
} NvstClientDJBConfig;

/// @}
