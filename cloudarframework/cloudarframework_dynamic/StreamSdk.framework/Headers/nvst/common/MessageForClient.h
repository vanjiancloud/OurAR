// Copyright NVIDIA Corporation 2020-2021
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

/// \file MessageForClient.h
/// Messages that can be dynamically sent to the client during a streaming session.

#pragma once

#if defined(__cplusplus)
extern "C"
{
#endif

#include "StreamData.h"
#include "MouseCursorDefines.h"
#include <nvst/client/ClientEvent.h>
#include <stdbool.h>

    /// \addtogroup nvstServerSdkStructs
    /// @{

    /// Struct storing information common to both system and bitmap cursors.
    typedef struct NvstCursorEventCommon_t
    {
        /// Indicates if mouse cursor position is valid.
        bool isCursorPositionValid;
        /// Normalized absolute cursor X coordinate (0..65535).
        uint16_t xCoordinate;
        /// Normalized absolute cursor Y coordinate (0..65535).
        uint16_t yCoordinate;
        /// Indicates if isConfined is valid.
        /// If isConfinementValid set to true, that means cursor confined( or unconfined) based on isConfined value.
        /// If isConfinementValid set to false, then cursor confinement unchanged.
        bool isConfinementValid;
        /// If true, client will confine the cursor to the streaming window.
        bool isConfined;
    } NvstCursorEventCommon;

    /// Struct storing information of system cursor
    typedef struct NvstSystemCursorEvent_t
    {
        /// Cursor identifier. If there is no cursor, the value is NVST_SYSTEM_CURSOR_HIDDEN
        NvstSystemCursor id;
        /// Data common to system and bitmap cursors.
        NvstCursorEventCommon common;
    } NvstSystemCursorEvent;

    /// Struct storing information of bitmap cursor
    typedef struct NvstBitmapCursorEvent_t
    {
        /// Custom cursor identifier.
        uint32_t id;
        /// Hotspot of the cursor - X coordinate.
        uint16_t xHotspot;
        /// Hotspot of the cursor - Y coordinate.
        uint16_t yHotspot;
        /// Payload type. E.g., raw pixel, .bmp, .tga, none - for system cursor, etc.
        /// A bitmap cursor with NONE payload should be considered hidden.
        /// 0 for NONE and 1 for BMP type
        uint16_t payloadType;
        /// Payload size(in bytes).
        uint16_t payloadSize;
        /// Payload bytes.
        const uint8_t* payload;
        /// Data common to system and bitmap cursors.
        NvstCursorEventCommon common;
    } NvstBitmapCursorEvent;

    /// Struct storing frame pacing information.
    typedef struct NvstFramePacingInfo_t
    {
        /// Stream index.
        uint32_t streamIndex;
        /// When to send this feedback.
        /// 0: Never send frame pacing feedback.
        /// 1: Send frame pacing feedback together with QoS stats.
        /// 2: Send frame pacing feedback on every frame.
        uint32_t feedbackMode;
    } NvstFramePacingInfo;

    typedef enum MessageType_t
    {
        /// Notifies the client of the maximum number of controllers for the current application.
        NVST_MS_MAX_CONTROLLERS,
        /// Send system cursor info to client.
        NVST_MS_SYSTEM_CURSOR_INFO,
        /// Send bitmap cursor info to client.
        NVST_MS_BITMAP_CURSOR_INFO,
        /// Inform client that frame pacing is enabled.
        NVST_MS_FRAME_PACING_INFO,
        /// Use constroller right stick as mouse.
        NVST_MS_GAMEPAD_HANDLING,
        /// Timer related event.
        NVST_MS_TIMER_MESSAGE,
        /// CustomMessage to client
        NVST_MS_CUSTOM_MESSAGE,
        /// Always last for bounds checking.
        NVST_MS_MESSAGE_TYPE_LAST,
    } MessageType;

    /// Structure for use by nvstSendMessage
    /// \sa nvstSendMessage
    typedef struct NvstMessageForClient_t
    {
        /// Type of message being sent to the client.
        /// This defines how the rest of the structure is interpreted.
        MessageType type;
        union
        {
            /// Maximum number of controllers for the current application.
            uint32_t maxControllers;
            /// System cursor info.
            NvstSystemCursorEvent systemCursorInfo;
            /// Bitmap cursor info.
            NvstBitmapCursorEvent bitmapCursorInfo;
            /// Send feedback mode and stream index to client. This also signals that frame pacing is enabled.
            NvstFramePacingInfo framePacingInfo;
            /// Gamepad handling event details. This takes a bool value only.
            /// \todo Convert this to a bool once merged with NvstGamepadHandlingEvent
            uint16_t gamepadHandleEvent;
            /// Timer event details
            NvstTimerEvent timerEvent;
            /// CustomMessage for client
            NvstCustomMessage nvCustomMessage;
        };
    } NvstMessageForClient;

    /// @}

#if defined(__cplusplus)
}
#endif
