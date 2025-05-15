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

/// \file InputEvent.h
/// Defines the input events that are sent by the client to the server.

#pragma once

#include "../common/KeyDefs.h"
#include "../common/SharedTypes.h"
#include <stdbool.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif
/// Maximal number of gamepads that NvstGamepadEvent can contain.
#define NVST_MAX_SUPPORT_GAMEPAD_COUNT 4
/// Maximal number of touch points that NvstTouchEvent can contain.
#define NVST_TOUCH_EVENT_TOUCH_POINT_MAX_COUNT 4

    /// \defgroup InputCallback Input stream callback related structs
    /// \ingroup Input
    /// @{

    /// Modifier flags for keyboard and mouse events (bitfield layout).
    typedef enum NvstModifierFlags_t
    {
        NVST_MF_NONE = 0x0000,
        /// Shift key modifier.
        NVST_MF_SHIFT = 0x0001,
        /// Ctrl key modifier.
        NVST_MF_CONTROL = 0x0002,
        /// Alt key modifier.
        NVST_MF_ALT = 0x0004,
        /// Meta key modifier.
        NVST_MF_META = 0x0008,
        /// Right shift key modifier.
        NVST_MF_SHIFT_RIGHT = 0x0010,
        /// Right ctrl key modifier.
        NVST_MF_CONTROL_RIGHT = 0x0020,
        /// Right alt key modifier.
        NVST_MF_ALT_RIGHT = 0x0040,
        /// Right meta key modifier.
        NVST_MF_META_RIGHT = 0x0080,
        /// Absolute or relative mouse coordinates.
        /// \sa NvstMouseEvent
        /// \note In a multimonitor system, the coordinates map to the primary monitor.
        /// \todo Add tests for multimonitor systems.
        NVST_MF_ABSCOORDS = 0x0800,
        /// Virtual coordinates are used.
        /// These co-ordinates are absolute co-ordinates in the server's virtual desktop.
        /// A client should use these when streaming more than
        /// just the primary of the current server
        /// and the client wishes to use an absolute position for the mouse input.
        /// \note NVST_MF_VIRTUAL is only meaningful if NVST_MF_ABSCOORDS is set.
        NVST_MF_VIRTUAL = 0x1000,
    } NvstModifierFlags;

    /// \todo Rename this to something more general. I.e. 'NvstButtonState_t'
    /// Key states. Used for keyboard and mouse buttons.
    typedef enum NvstKeyState_t
    {
        /// Reserved value for invalid key state.
        NVST_KEYSTATE_NONE = 0,
        NVST_KEYSTATE_UP = 1,
        NVST_KEYSTATE_DOWN = 2,
    } NvstKeyState;

    /// Struct representing a keyboard event.
    typedef struct NvstKeyboardEvent_t
    {
        /// Logical key code.
        NvstKeyCode keyCode;
        /// OEM-specific scan code.
        uint16_t scanCode;
        /// Modifier flags. \sa NvstModifierFlags
        uint16_t flags;
        /// Current key state.
        NvstKeyState keyState;

        /// Event creation time on the client end.
        /// Zero value means no timestamp is available.
        uint64_t captureTimestampUs;
    } NvstKeyboardEvent;

    /// The toggle state of a lock key.
    typedef enum NvstLockKeyState_t
    {
        NVST_LK_UNCHANGED = 0,
        NVST_LK_OFF = 1,
        NVST_LK_ON = 2,
    } NvstLockKeyState;

    /// Struct representing the state of the lock keys.
    typedef struct NvstLockKeysEvent_t
    {
        /// The state of caps lock.
        NvstLockKeyState capsLock;
        /// The state of num lock.
        NvstLockKeyState numLock;
        /// The state of scroll lock.
        NvstLockKeyState scrollLock;
    } NvstLockKeysEvent;

    /// Mouse event types.
    typedef enum NvstMouseEventType_t
    {
        /// Reserved value for invalid mouse event.
        NVST_ME_NONE = 0,
        NVST_ME_MOUSE_MOVE = 1,
        NVST_ME_MOUSE_WHEEL = 2,
        NVST_ME_BUTTON = 3,
    } NvstMouseEventType;

    /// Mouse buttons
    typedef enum NvstMouseButton_t
    {
        /// Reserved value for invalid mouse button.
        NVST_MB_NONE = 0,
        NVST_MB_LEFT = 1,
        NVST_MB_MIDDLE = 2,
        NVST_MB_RIGHT = 3,
        NVST_MB_EXTRA1 = 4,
        NVST_MB_EXTRA2 = 5,
    } NvstMouseButton;

    /// Struct representing a mouse event.
    typedef struct NvstMouseEvent_t
    {
        /// Type of mouse event.
        NvstMouseEventType type;
        /// Modifier flags. \sa NvstModifierFlags
        uint16_t flags;
        /// Horizontal mouse absolute position or relative change (in pixels).
        int16_t xPos;
        /// Vertical mouse absolute position or relative change (in pixels).
        int16_t yPos;
        /// Contains additional data about the mouse event.
        ///
        /// Currently used for wheel, button, and absolute move events.
        /// Wheel: indicites the vertical scroll distance.
        /// Button: a value of type NvstMouseButton_t, indicating the button
        /// Absolute move: width (in pixels) of the rectangle to which x applies
        /// (as defined by the window handle), interpreted as uint16_t. \sa windowHandle
        /// Ratio of x and width defines normalized X coordinate
        /// of this move event on the server (server will scale x against width).
        /// - If width is non-zero,
        ///   then data1 should be set to width of the window's rectangle on the client.
        /// - If width is zero,
        ///   then scaling is done against server's width of the corresponding rectangle.
        int16_t data1;
        /// Contains additional data about the mouse event.
        ///
        /// Currently used for wheel, button, and absolute move events.
        /// Wheel: indicates the horizontal scroll distance.
        /// Button: a value of type NvstKeyState_t, indicating the state of the button.
        /// Absolute move: height (in pixels) of the rectangle to which x applies
        /// (as defined by the window handle), interpreted as uint16_t. \sa windowHandle
        /// Ratio of y and height defines normalized Y coordinate
        /// of this move event on the server (server will scale y against height).
        /// - If height is non-zero,
        ///   then data2 should be set to height of the window's rectangle on the client.
        /// - If height is zero,
        ///   then scaling is done against server's height of the corresponding rectangle.
        int16_t data2;
        /// Handle to the target window on the server.
        /// Currently intended only for absolute mouse move events.
        /// Defines the rectangle to which the given abs. mouse move event applies.
        /// The (0,0) point of this rectangle is the origin of the coordinate system.
        /// - If non-NULL, the window rectangle of the window identified by this handle.
        ///   Use this if x and y are relative to the given window.
        ///   Typical use case: streaming of individual windows.
        /// - If NULL, the rectangle of server's desktop.
        ///   Use this is x and y are relative to the entire streamed area.
        ///   Typical use case: streaming of entire desktop (full-screen streaming).
        uint32_t windowHandle;

        /// Contains additional data about the mouse event.
        /// \todo move it to data1 and data2 in accordance with data's comment and remove the fields
        int16_t vWheel;
        int16_t hWheel;

        /// Event creation time on the client end.
        /// Zero value means no timestamp is available.
        uint64_t captureTimestampUs;
    } NvstMouseEvent;

    /// Collection of mouse events.
    typedef struct NvstMouseEventGroup_t
    {
        /// Array of mouse events.
        NvstMouseEvent* events;
        /// Number of events in the array.
        uint16_t eventCount;
    } NvstMouseEventGroup;

    /// Struct representing a mouse settings event.
    typedef struct NvstMouseSettingsEvent_t
    {
        /// Mouse acceleration.
        uint32_t acceleration;
        /// Mouse Sensitivity.
        uint32_t sensitivity;
    } NvstMouseSettingsEvent;

    /// Gamepad control types.
    ///
    /// Includes various controls (buttons, axes, triggers, etc.).
    typedef enum NvstGamepadControls_t
    {
        /// Reserved value for invalid gamepad control.
        NVST_GC_NONE = 0,
        NVST_GC_BTN_START = 1,
        NVST_GC_BTN_SELECT = 2,
        NVST_GC_BTN_MODE = 3,
        NVST_GC_BTN_X = 4,
        NVST_GC_BTN_Y = 5,
        NVST_GC_BTN_Z = 6,
        NVST_GC_BTN_A = 7,
        NVST_GC_BTN_B = 8,
        NVST_GC_BTN_C = 9,
        NVST_GC_BTN_THUMBL = 10,
        NVST_GC_BTN_THUMBR = 11,
        NVST_GC_BTN_L1 = 12,
        NVST_GC_BTN_R1 = 13,
        NVST_GC_AXIS_DPAD_X = 14,
        NVST_GC_AXIS_DPAD_Y = 15,
        NVST_GC_AXIS_LSTICK_X = 16,
        NVST_GC_AXIS_LSTICK_Y = 17,
        NVST_GC_AXIS_RSTICK_X = 18,
        NVST_GC_AXIS_RSTICK_Y = 19,
        NVST_GC_TRIGGER_LEFT = 20,
        NVST_GC_TRIGGER_RIGHT = 21,
        /// Reserved value for count of supported gamepad controls.
        NVST_GC_NUM_CONTROLS,
    } NvstGamepadControls;

    /// Struct representing a gamepad event.
    /// \deprecated Prefer NvstGamepadStateEvent instead.
    typedef struct NvstGamepadEvent_t
    {
        /// The gamepad control changed during this event.
        NvstGamepadControls control;

        /// The position of the gamepad control.
        /// \remarks
        /// - If control is NVST_GC_BTN_*,
        ///   then position is interpreted as a Boolean value,
        ///   with 0 mapped to the 'released' state
        ///   and all other values mapped to the 'pressed' state.
        /// - If control is NVST_GC_AXIS_*,
        ///   then position represents the axis value ranging from -32768 to +32767,
        ///   with 0 corresponding to the 'center' state.
        /// - If control is NVST_GC_TRIGGER_*,
        ///   then position is interpreted as an unsigned short (uint16_t),
        ///   with 0 mapped to the 'released' state
        ///   and 65535 mapped to the 'fully pressed' state.
        int16_t position;

        /// The ID of the gamepad that produced this event.
        /// \remarks
        /// Currently supported values are 0 through 3.
        /// All other values will be rejected.
        uint8_t id;

        /// Event creation time on the client end.
        /// Zero value means no timestamp is available.
        uint64_t captureTimestampUs;
    } NvstGamepadEvent;

    /// Struct representing a gamepad state change event.
    typedef struct NvstGamepadsChangedEvent_t
    {
        /// A bitmap of currently connected gamepads.
        uint16_t bitmap;
    } NvstGamepadsChangedEvent;

    /// Struct representing the complete state of a single gamepad.
    typedef struct NvstGamepadStateEvent_t
    {
        /// The positions of each of the controls on the gamepad.
        int16_t positions[NVST_GC_NUM_CONTROLS];

        /// The ID of the gamepad that produced this event.
        /// \remarks
        /// Currently supported values are 0 through 3.
        /// All other values will be rejected.
        uint8_t id;

        /// Event creation time on the client end.
        /// Zero value means no timestamp is available.
        uint64_t captureTimestampUs;
    } NvstGamepadStateEvent;

    /// Struct holding Windows OS RAWINPUT data.
    typedef struct NvstWindowsOsRawInputEvent_t
    {
        /// Size of the RAWINPUT.
        uint16_t size;

        /// Actual data. Library will not try to deallocate this pointer.
        void* rawInputData;
    } NvstWindowsOsRawInputEvent;

    /// Struct holding USB gamepad raw data.
    /// \deprecated Prefer NvstGamepadStateEvent instead.
    typedef struct NvstGamepadUsbPayloadEvent_t
    {
        /// Size of the raw data.
        uint16_t size;

        /// Actual data. Library will not try to deallocate this pointer.
        void* payload;

    } NvstGamepadUsbPayloadEvent;

    /// Struct holding a gamepad haptics enable event.
    typedef struct NvstHapticsControlEvent_t
    {
        /// Whether or not to enable haptics on the gamepad
        bool enable;
    } NvstHapticsControlEvent;

    /// Struct holding a gamepad haptics event.
    typedef struct NvstHapticsEvent_t
    {
        /// Current haptic command size in bytes,
        uint16_t size;
        /// Haptic event data
        void* payload;
    } NvstHapticsEvent;

    /// Enumeration of window input events.
    typedef enum NvstWindowEventType_t
    {
        /// Not a valid or supported window event.
        NVST_WE_NONE = 0,
        /// Window needs to move.
        NVST_WE_SET_POS_MOVE = 1,
        /// Window needs to resize.
        NVST_WE_SET_POS_RESIZE = 2,
        /// Window needs to get minimized.
        NVST_WE_MINIMIZE = 3,
        /// Window needs to get maximized.
        NVST_WE_MAXIMIZE = 4,
        /// Window needs to get restored.
        NVST_WE_RESTORE = 5,
        /// Window needs to get closed.
        NVST_WE_CLOSE = 6,
        /// Window needs to gain keyboard focus.
        NVST_WE_GAIN_FOCUS = 7,
        /// Window needs to lose keyboard focus.
        NVST_WE_LOSE_FOCUS = 8,
        /// Window needs to gain mouse focus.
        NVST_WE_ENTER_WINDOW = 9,
        /// Window needs to lose mouse focus.
        NVST_WE_LEAVE_WINDOW = 10,
    } NvstWindowEventType;

    /// Struct representing a window event sent from the client to the server.
    typedef struct NvstWindowEvent_t
    {
        /// Handle to the server window which receives the event.
        uint32_t handle;

        /// Subtype of input event (type of window event).
        NvstWindowEventType subtype;

        /// New coordinates for the window.
        /// Used with NVST_WE_SET_POS_ events. Ignored otherwise.
        NvstRect windowRect;
    } NvstWindowEvent;

    /// Struct representing a payload for arbitrary input event.
    typedef struct NvstBulkPayloadInputEvent_t
    {
        /// Data size in bytes.
        /// Maximum supported size is 118 bytes for the native implemenation.
        /// The WebRTC implementation can support an arbitrary size.
        uint32_t sizeInBytes;
        /// Pointer to the data.
        uint8_t* data;
    } NvstBulkPayloadInputEvent;

    /// Enumeration of HID report types.
    typedef enum NvstHidReportType_t
    {
        /// Input/Output report. Client-to-server is input, reverse is output.
        NVST_HE_IO = 0,
        /// Feature report.
        NVST_HE_FEATURE = 1
    } NvstHidReportType;

    /// Struct holding raw HID report data
    typedef struct NvstHidReportEvent_t
    {
        /// ID of HID device to which the report will be sent.
        uint8_t id;
        /// Endpoint address for the report.
        uint8_t epAddr;
        /// Report type - input/output or feature.
        NvstHidReportType type;
        /// Data size in bytes.
        uint16_t sizeInBytes;
        /// Pointer to report data.
        /// HID report data that has been allocated by caller;
        /// it can be released after the control flow returns to the caller.
        /// Client can release the buffer after nvstClientSendDataOnDefaultStreams() returns.
        /// SDK on the server will release its internal buffer after the server app's callback returns.
        uint8_t* data;
    } NvstHidReportEvent;

    /// Enumeration of HID control events.
    typedef enum NvstHidControl_t
    {
        /// To exclude 0 from a valid control
        NVST_HC_NOOP = 0,
        /// Enable and plug-in HID device.
        NVST_HC_ENABLE = 1,
        /// Reset a HID device.
        NVST_HC_RESET = 2,
        /// Disable and unplug HID device.
        NVST_HC_DISABLE = 3,
        /// For range control
        NVST_HC_SIZE
    } NvstHidControl;

    /// Struct representing a HID device state change event.
    typedef struct NvstHidChangeEvent_t
    {
        /// HID device ID for the device that is being controlled.
        uint8_t id;
        /// Control operation to perform on the device.
        NvstHidControl control;
    } NvstHidChangeEvent;

    /// Struct holding a unicode text string in utf-8 format.
    typedef struct NvstUnicodeEvent_t
    {
        /// Text to be typed on the server, encoded in UTF-8.
        /// Not null terminated.
        const char* textUtf8;
        /// Length of text in bytes.
        uint16_t lengthInBytes;
    } NvstUnicodeEvent;

    /// Enumeration of input events.
    typedef enum NvstInputEventType_t
    {
        NVST_EVENT_NONE = 0,
        NVST_EVENT_KEYBOARD = 1,
        NVST_EVENT_MOUSE = 2,
        NVST_EVENT_MOUSE_SETTINGS = 3,
        NVST_EVENT_GAMEPAD = 4,
        NVST_EVENT_GAMEPAD_HAPTICS = 5,
        NVST_EVENT_GAMEPADS_CHANGED = 6,
        NVST_EVENT_WINDOWS_RAW_INPUT = 7,
        NVST_EVENT_GAMEPAD_USB_PAYLOAD = 8,
        NVST_EVENT_WINDOW = 9,
        NVST_EVENT_HEARTBEAT = 10,
        NVST_EVENT_BULK_PAYLOAD = 11,
        NVST_EVENT_HID_CHANGE = 12,
        NVST_EVENT_HID = 13,
        NVST_EVENT_MOUSE_GROUP = 14,
        NVST_EVENT_LOCK_KEYS = 15,
        NVST_EVENT_IME_CONTROL = 16,
        NVST_EVENT_BULK_PAYLOAD_UNRELIABLE = 17,
        NVST_EVENT_GAMEPAD_STATE = 18,
        NVST_EVENT_TOUCH = 19,
        NVST_EVENT_UNICODE = 20,
        NVST_EVENT_TOUCH_LOWLEVEL = 21
    } NvstInputEventType;

    /// Enumeration of known BULK PAYLOAD types
    typedef enum NvstBulkPayloadType_t
    {
        NVST_BULK_PAYLOAD_TYPE_VIRTUAL_VSYNC = 100,
    } NvstBulkPayloadType;

    /// Enumeration of supported IME (Input Method Editor) hotkeys.
    /// A subset of the keys listed below is valid in a given IME.
    typedef enum NvstImeHotKey_t
    {
        /// (Korean) Toggle between entering Korean (Hangul) and English (ISO basic Latin alphabet).
        NVST_IME_KHOTKEY_HANGUL = 0,
        /// (Korean) Convert Hangul to Chinese characters (hanja) or some special characters.
        NVST_IME_KHOTKEY_HANJA = 1,
    } NvstImeHotKey;

    /// Struct
    typedef struct NvstImeControlEvent_t
    {
        NvstImeHotKey hotKey;
    } NvstImeControlEvent;

    /// Struct representing a touch point.
    typedef struct NvstTouchPoint_t
    {
        /// The ID of the physical contact that produced this touch point.
        int8_t id;
        /// Horizontal touch absolute position (in pixels).
        int16_t xPos;
        /// Vertical touch absolute position (in pixels).
        int16_t yPos;
    } NvstTouchPoint;

    /// Struct representing a touch event.
    typedef struct NvstTouchEvent_t
    {
        /// Modifier flags. \sa NvstModifierFlags
        uint16_t flags;

        /// Number of touch points in the array.
        uint8_t touchCount;

        /// Array of touch points.
        /// \internal The size of the entire array should be kept small.
        NvstTouchPoint touchPoints[NVST_TOUCH_EVENT_TOUCH_POINT_MAX_COUNT];

        /// Width (in pixels) of the rectangle to which xPos of a touch point applies.
        /// Ratio of xPos and width defines normalized X coordinate
        /// of this touch event on the server (server will scale x against width).
        uint16_t width;
        /// Height (in pixels) of the rectangle to which yPos of a touch point applies.
        /// Ratio of yPos and height defines normalized Y coordinate
        /// of this touch event on the server (server will scale y against height).
        uint16_t height;

        /// Event creation time on the client end.
        /// Zero value means no timestamp is available.
        uint64_t captureTimestampUs;
    } NvstTouchEvent;

    /// Enumeration of low-level Touch point flags
    typedef enum NvstTouchPointLowLevelFlags_t
    {
        /// Touch pointer has gone down (press)
        NVST_TLL_DOWN = 0x01,
        /// Touch pointer has gone up (release)
        NVST_TLL_UP = 0x02,
        /// Touch pointer has moved
        NVST_TLL_MOVE = 0x04,
        /// Touch has been cancelled
        NVST_TLL_CANCEL = 0x08
    } NvstTouchPointLowLevelFlags;

    /// Struct representing a low-level touch point.
    typedef struct NvstTouchPointLowLevel_t
    {
        /// The (transient) ID of the touch point, consistent within a group (and potentially across events).
        uint16_t id;
        /// Touch point flags (up, down, move.
        NvstTouchPointLowLevelFlags flags;
        /// Horizontal touch absolute position (scaled 0-65535).
        uint16_t xPos;
        /// Vertical touch absolute position (scaled 0-65535).
        uint16_t yPos;
        /// X radius of the touch contact area
        uint8_t xRadius;
        /// Y radius of the touch contact area
        uint8_t yRadius;
        /// Timestamp of this touch
        uint64_t timestamp;
    } NvstTouchPointLowLevel;

/// Maximal number of touch points that NvstTouchEvent can contain.
#define NVST_TOUCH_EVENT_TOUCH_POINT_LOW_LEVEL_MAX_COUNT 11

    typedef struct NvstTouchLowLevelEvent_t
    {
        /// Number of touch points in the array.
        uint16_t touchCount;
        /// Array of touch points.
        /// \internal The array is dynamically allocated and deallocated.  For RiProtocolParser, once per instance.
        NvstTouchPointLowLevel* touchPoints;
    } NvstTouchLowLevelEvent;

    /// Union of input-event types.
    typedef union NvstInputEventUnion_t
    {
        /// Keyboard event details.
        NvstKeyboardEvent keyboardEvent;
        /// Lock keys event details.
        NvstLockKeysEvent lockKeysEvent;
        /// Mouse event details.
        NvstMouseEvent mouseEvent;
        /// Mouse event group.
        NvstMouseEventGroup mouseEventGroup;
        /// Mouse settings event details.
        NvstMouseSettingsEvent mouseSettingsEvent;
        /// Gamepad event details.
        NvstGamepadEvent gamepadEvent;
        /// Gamepad haptics enable event.
        NvstHapticsControlEvent hapticsControlEvent;
        /// Gamepad haptics event.
        NvstHapticsEvent hapticsEvent;
        /// Gamepads connected as a bitmap.
        NvstGamepadsChangedEvent gamepadsChangedEvent;
        /// Gamepad state event
        NvstGamepadStateEvent gamepadStateEvent;
        /// Windows raw input event details.
        NvstWindowsOsRawInputEvent windowsRawInputEvent;
        /// USB gamepad input event details.
        NvstGamepadUsbPayloadEvent gamepadUsbPayloadEvent;
        /// Window event details.
        NvstWindowEvent windowEvent;
        /// Bulk payload event details.
        NvstBulkPayloadInputEvent bulkPayloadEvent;
        /// HID device change (plugged in / removed).
        NvstHidChangeEvent hidChangeEvent;
        /// HID event details.
        NvstHidReportEvent hidEvent;
        /// Input method control.
        NvstImeControlEvent imeControlEvent;
        /// Touch event details.
        NvstTouchEvent touchEvent;
        /// Unicode text event.
        NvstUnicodeEvent unicodeEvent;
        /// Low-level touch event details
        NvstTouchLowLevelEvent touchLowLevelEvent;
    } NvstInputEventUnion;

    /// Struct representing an input event.
    typedef struct NvstInputEvent_t
    {
        /// Type of input event.
        NvstInputEventType type;

        /// Event details.
        NvstInputEventUnion event;
    } NvstInputEvent;

    /// @}

#if defined(__cplusplus)
}
#endif
