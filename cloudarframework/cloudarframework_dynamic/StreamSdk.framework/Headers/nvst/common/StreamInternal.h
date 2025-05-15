// Copyright NVIDIA Corporation 2019-2021
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

#include "../common/Result.h"
#include "../common/VideoFormat.h"
#include "../common/Util.h"
#include <stdint.h>

/// \internal Video Frame input given by internal users.
///
/// This is the input of type VideoFrame class.
/// \endinternal
/// \warning Only to be used by internal users.
typedef void* NvstVideoFrame;

/// \internal FrameCaptureInfo struct input given by internal users.
///
/// This is the input of type FrameCaptureInfo struct.
/// \endinternal
/// \warning Only to be used by internal users.
typedef void* NvstFrameCaptureInfo;

/// \internal Defines Video Frame Info type and actual payload of a video stream datum for internal users.
///
/// NvstFrameCaptureInfo is a pointer of type FrameCaptureInfo struct.
/// NvstVideoFrame is a pointer of type VideoFrame class.
/// \endinternal
/// \warning Only to be used by internal users.
typedef struct NvstVideoFrameInfoInternal_t
{
    NvstFrameCaptureInfo captureInfo;
    NvstVideoFrame videoFrame;
    bool isFrameEncoded;
} NvstVideoFrameInfoInternal;

/// \internal Internal video settings relevant to NvStreamer
///
/// These settings are only used by Nvstreamer and are part of OnStreamConnecting callback
/// \endinternal
/// \warning Only to be used by internal users.
/// \sa onStreamConnecting
typedef struct NvstInternalVideoSettings_t
{
    /// Next capture Mode
    uint8_t nextCaptureMode;

    /// Color space being used
    NvstCscMode cscMode;

    /// Enable/Disable FBC difference map feature
    bool useFbcDiffMap;

    /// Set/Reset usage of FBC Classification Map feature.
    bool useFbcClassificationMap;

    /// Client set dx9EnableNv12 flag
    bool dx9EnableNv12;

    /// Max fps expected by client
    uint32_t clientMaxFps;

    /// Client turbo mode selection
    uint32_t clientTurboModeSelection;

    /// Client requested DRC
    bool drcEnabled;

    /// Client requested DFC
    bool dfcEnabled;

    /// Timeout for FBC grab in ms for Turbo Mode Streaming
    uint8_t fbcDynamicFpsGrabTimeoutMs;

    /// Capture settings
    struct NvstCaptureSettings
    {
        /// Capture strategy.
        enum NvstCaptureStrategy
        {
            /// Capture strategy undefined (use server setting).
            NVST_CS_UNDEFINED = 0,
            /// Use NvFBC-based capture strategy.
            NVST_CS_FBC = 1,
            /// Use Desktop Duplication API-based capture strategy.
            NVST_CS_DDA = 2,
            /// Use Windows.Graphics.Capture-based capture strategy.
            NVST_CS_WGC = 3,
            /// Use CCX-based-encoded capture strategy.
            NVST_CS_CCX = 4,
            /// Use CCX-based-YUV capture strategy.
            NVST_CS_CCX_YUV = 5,
            /// Use X11 based capture strategy.
            NVST_CS_X11 = 6,
        } captureStrategy;

        /// Capture method.
        enum NvstCaptureMethod
        {
            /// Capture method undefined (use server setting).
            NVST_CM_UNDEFINED = 0,
            /// Use basic sleep capture method.
            NVST_CM_BASIC_SLEEP = 1,
            /// Use adjusted sleep capture method.
            NVST_CM_ADJUSTED_SLEEP = 2,
            /// Use constant sleep capture method.
            NVST_CM_CONSTANT_SLEEP = 3,
            /// Use wait for vblank-based capture method.
            NVST_CM_WAIT_FOR_VBLANK = 4
        } captureMethod;

        /// Sleep method.
        enum NvstSleepMethod
        {
            /// Sleep method undefined (use server setting).
            NVST_SM_UNDEFINED = 0,
            /// Use normal sleep.
            NVST_SM_NORMAL_SLEEP = 1,
            /// Use CPU polling-based sleep.
            NVST_SM_CPU_POLL_SLEEP = 2,
            /// Use timer-based sleep.
            NVST_SM_WAITABLE_TIMER = 3,
            /// Use timer-based sleep + busy wait.
            NVST_SM_WAITABLE_TIMER_BUSYWAIT = 4,
            /// Use normal sleep + busy wait.
            NVST_SM_NORMAL_SLEEP_BUSYWAIT = 5
        } sleepMethod;

        /// Sleep method accuracy in microseconds used for busy wait.
        uint16_t sleepMethodAccuracyUs;

        /// Video frame provider wait method.
        enum NvstWaitMethod
        {
            /// Wait method undefined (use server setting).
            NVST_WM_UNDEFINED = 0,
            /// Don't wait.
            NVST_WM_NO_WAIT = 1,
            /// Wait with timeout.
            NVST_WM_WAIT_WITH_TIMEOUT = 2,
            /// Wait for event w/ timeout, ignmore cursor updates.
            NVST_WM_WAIT_EVENT_NOCURSOR_WITH_TIMEOUT = 3,
        } waitMethod;

        /// Video frame provider wait method timeout in milliseconds, if applicable.
        uint16_t waitMethodTimeoutMs;
    } captureSettings;
} NvstInternalVideoSettings;

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \internal Submit server stats to Stream SDK for ETL reporting
    ///
    /// \param[in] frameId FrameId to associate event and time to.
    /// \param[in] e2eEvent E2eEvent identifier. \sa StatsReporting.h
    /// \param[in] timeMs Timestamp to report for the event. If 0, current time is reported.
    /// \endinternal
    /// \warning Only to be used by internal users.
    NVST_API NvstResult
        nvstInternalSubmitE2eStats(uint32_t streamIndex, uint32_t frameId, uint32_t e2eEvent, double timeMs);

#if defined(__cplusplus)
}
#endif
