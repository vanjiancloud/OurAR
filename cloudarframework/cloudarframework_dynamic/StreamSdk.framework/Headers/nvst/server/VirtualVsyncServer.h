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

/// \file VirtualVsyncServer.h
/// Defines the interface for controlling Virtual Vsync on the server.

#pragma once

#include <nvst/common/Result.h>
#include <nvst/common/SharedTypes.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \defgroup VVSYNC VVSYNC APIs
    /// \ingroup nvstServerSdk
    /// @{

    /// Sleep for the required duration based on the current configuration and QoS data.  This is the primary
    /// method for regulating framerate.
    ///
    /// This function is only valid while a session is in progress.
    ///
    /// \param streamConnection Which stream to use.
    /// \return NvstResult::NVST_R_SUCCESS on success.
    NVST_API NvstResult nvstVirtualVsyncPresent(NvstStreamConnection streamConnection);

    /// Retrieves the Virtual Vsync server time wait interval for the next frame it renders.
    /// This function is an alternative to nvstVirtualVsyncPresent().  Don't use both together.  This function
    /// retrieves the amount of time that the application should sleep but performs no sleep.
    ///
    /// This function will return the appropriate amount of time regardless of whether VVsync is active,
    /// enabled, or not.
    ///
    /// This function is only valid while a session is in progress.
    ///
    /// \param streamConnection The stream connection to retrieve information from.
    /// \param[out] vvsyncIntervalMilliseconds The number of milliseconds to wait for applications that aren't
    /// using nvstVirtualVsyncPresent()
    /// \return NvstResult::NVST_R_SUCCESS on success.
    NVST_API NvstResult
        nvstVirtualVsyncGetFrameInterval(NvstStreamConnection streamConnection, float* vvsyncIntervalMilliseconds);

    /// Retrieves if Virtual Vsync is enabled.
    ///
    /// This function is only valid while a session is in progress.
    ///
    /// \param streamConnection The stream connection to retrieve information from.
    /// \param[out] isEnabled Returns if VVsync is currently enabled.
    /// \return NvstResult::NVST_R_SUCCESS on success.
    NVST_API NvstResult nvstVirtualVsyncIsEnabled(NvstStreamConnection streamConnection, bool* isEnabled);

    /// Sets Virtual Vsync to be enabled or disabled on the specified stream connection.
    ///
    /// This function is only valid while a session is in progress.
    ///
    /// \param streamConnection The stream connection to modify.
    /// \param shouldBeEnabled Whether this feature should be enabled or not.
    /// \return NvstResult::NVST_R_SUCCESS on success.
    NVST_API NvstResult nvstVirtualVsyncSetEnabled(NvstStreamConnection streamConnection, bool shouldBeEnabled);

    /// Determines if Virtual Vsync is active on this stream.  Virtual Vsync is active only if it is both
    /// enabled and the internal algorithm has determined that it is beneficial.
    ///
    /// This function is only valid while a session is in progress.
    ///
    /// \param streamConnection The stream connection to retrieve information from.
    /// \param[out] pIsActive Returns if VVsync is currently active.
    /// \return NvstResult::NVST_R_SUCCESS on success.
    NVST_API NvstResult nvstVirtualVsyncIsActive(NvstStreamConnection streamConnection, bool* pIsActive);

    /// Sets the current actual streaming frames per second.  This should be an estimate of the current actual
    /// framerate rather than the desired framerate.  This can be called as often as necessary.  If the actual
    /// streaming FPS is outside the range of normal VVsync operations, then the VVsync algorithm will enter
    /// an inactive state, which will cause it to use the nominal target framerate.
    ///
    /// This function is only valid while a session is in progress.
    ///
    /// \param streamConnection The stream connection to modify.
    /// \param streamingIntervalUs An estimate of the actual streaming intervals.
    /// \param renderIntervalUs An estimate of the actual render intervals.
    /// \return NvstResult::NVST_R_SUCCESS on success.
    NVST_API NvstResult nvstVirtualVsyncSetActualStreamingIntervals(
        NvstStreamConnection streamConnection,
        uint32_t streamingIntervalUs,
        uint32_t renderIntervalUs);

    /// @}

#if defined(__cplusplus)
}
#endif
