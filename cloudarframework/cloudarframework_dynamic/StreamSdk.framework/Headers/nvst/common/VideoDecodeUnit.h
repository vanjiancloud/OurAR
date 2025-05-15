// Copyright NVIDIA Corporation 2017 - 2022
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

/// \file VideoDecodeUnit.h
/// Defines encoded video units streamed from the server to the client.
/// \todo The file is pretty centered on frames. Need to account for slices, top to bottom.

#pragma once

#include <stdint.h>

#include "../common/SharedTypes.h"

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \addtogroup Video
    /// @{

    /// States that a video frame can be in.
    typedef enum NvstVideoFrameState_t
    {
        /// Invalid frame state.
        NVST_FS_DECODE_NONE = 0,
        /// Frame is being decoded.
        NVST_FS_DECODE_ONGOING = 1,
        /// Frame has been decoded successfully.
        NVST_FS_DECODE_COMPLETED = 2,
        /// Frame render has started.
        NVST_FS_RENDER_STARTED = 3,
        /// Frame decode failed.
        NVST_FS_DECODE_FAILED = 4,
        /// Frame decode skipped, will result in frame invalidation.
        NVST_FS_DECODE_SKIPPED = 5,
        /// Frame decode skipped, but no invalidation is requested.
        NVST_FS_DECODE_SKIPPED_NO_INVALIDATION = 6,
        /// Frame render has been completed.
        NVST_FS_RENDER_COMPLETED = 7,
        /// Frame was not rendered for some reason.
        /// \todo Consider removing this state.
        NVST_FS_RENDER_SKIPPED = 8,
        /// Frame has been displayed (after swapbuffers).
        /// \todo Consider removing this state.
        NVST_FS_PRESENT_COMPLETED = 9,
        /// Confirmed that frame has been presented to the screen.
        NVST_FS_PRESENT_COMPLETED_CONFIRMED = 10,
        /// Frame transcode has been completed.
        NVST_FS_TRANSCODE_COMPLETED = 11,
        /// Frame transcode has failed.
        NVST_FS_TRANSCODE_FAILED = 12,
        /// Frame transcode has been skipped.
        NVST_FS_TRANSCODE_SKIPPED = 13,
    } NvstVideoFrameState;

    /// Types of video frames.
    typedef enum NvstVideoFrameType_t
    {
        /// Invalid frame type.
        NVST_FT_NONE = 0,
        /// Contains header data for subsequent frames.
        NVST_FT_HEADER = 1,
        /// An intra-coded frame (a.k.a. I-frame),
        /// which is encoded without references to earlier frames.
        NVST_FT_INTRA = 2,
        /// The first frame of an intra-refresh wave.
        NVST_FT_INTRA_REFRESH = 3,
        /// The first frame following an invalidation of previous reference frames.
        /// It can be decoded using only those frames
        /// that are not included in the invalidation range.
        NVST_FT_REF_PIC_INTRA = 4,
        /// A progressive frame (a.k.a. P-frame) that can only be decoded
        /// if its preceding frame was not lost.
        NVST_FT_PROGRESSIVE = 5,
        /// Not a valid frame type - used only to count frame types.
        NVST_FT_TYPE_END
    } NvstVideoFrameType;

    /// Types of video decode units (VDUs).
    typedef enum NvstVideoDecodeUnitType_t
    {
        /// Invalid VDU type.
        NVST_VU_NONE = 0,
        /// Contains a frame slice (a part of a frame).
        NVST_VU_SLICE = 1,
        /// Contains the entire frame.
        NVST_VU_FRAME = 2,
        /// Not a valid VDU type - used only to count VDU types.
        NVST_VU_TYPE_END
    } NvstVideoDecodeUnitType;

    /// H264 profiles.
    typedef enum NvstH264Profile_t
    {
        /// Invalid H264 profile.
        NVST_HP_NONE = 0,
        /// Baseline profile.
        NVST_HP_BASELINE = 1,
        /// Main profile.
        NVST_HP_MAIN = 2,
        /// High profile.
        NVST_HP_HIGH = 3,
        /// Invalid H264 profile - used only to count H264 profiles.
        NVST_HP_END
    } NvstH264Profile;

    /// Video decoder state.
    typedef enum NvstVideoDecoderState_t
    {
        /// Invalid state.
        NVST_VD_STATE_UNKNOWN = 0,
        /// Initialized state.
        NVST_VD_STATE_INITIALIZED = 1,
        /// Re-configure state.
        NVST_VD_STATE_RECONFIGURE = 2,
        /// Error state.
        NVST_VD_STATE_ERROR = 3,
    } NvstVideoDecoderState;

    /// Stream recovery flags.
    /// \todo Explain in more detail - is this sent by the server, controlled by the client, etc.
    typedef enum NvstVideoStreamRecoveryFlags_t
    {
        /// None of the flags are set.
        NVST_SR_NONE = 0x0,
        /// Recovery frame will contain only intra-coded data (IDR frame).
        /// Subsequent frames will not reference frames before this one.
        NVST_SR_IDR = 0x1,
        /// Client will detect missing frames and have encoder invalidate them,
        /// so subsequent frames won't reference them.
        NVST_SR_REFERENCE_INVALIDATION = 0x2,
        /// Wave of frames that each contain intra-coded data for a part of the frame.
        /// After this wave is decoded, the full frame is recovered.
        NVST_SR_INTRA_REFRESH = 0x4,
    } NvstVideoStreamRecoveryFlags;

    /// Defines the possible settings for window alpha.
    /// \sa NvstVideoFrameWindowMetadata
    typedef enum NvstVideoFrameWindowAlphaFlags_t
    {
        /// None of the flags are set.
        NVST_WINDOW_ALPHA_NONE = 0,
        /// Use colorkey to make pixels in that color fully transparent.
        NVST_WINDOW_ALPHA_COLOR_KEY = 0x1,
        /// Use alphaValue to set alpha for the entire window.
        NVST_WINDOW_ALPHA_PER_WINDOW = 0x2,
    } NvstVideoFrameWindowAlphaFlags;

    /// Contants that define limits for certain window metadata values.
    typedef enum NvstVideoFrameWindowMetadataLimits_t
    {
        /// Maximum number of region rectangles in a single window.
        NVST_MD_MAX_REGION_RECTANGLE_COUNT = 16,
        /// Maximum size (including the terminating zero) of a window's caption.
        NVST_MD_MAX_WINDOW_CAPTION_SIZE = 64,
    } NvstVideoFrameWindowMetadataLimits;

    /// Window styles.
    typedef enum NvstWindowStyle_t
    {
        /// The window is an overlapped window.
        NVST_WS_OVERLAPPED = 0x00000000,
        /// Same as NVST_WS_OVERLAPPED style.
        NVST_WS_TILED = NVST_WS_OVERLAPPED,
        /// The windows is a pop-up window.
        NVST_WS_POPUP = 0x80000000,
        /// The window is a child window.
        NVST_WS_CHILD = 0x40000000,
        /// Same as NVST_WS_CHILD style.
        NVST_WS_CHILD_WINDOW = NVST_WS_CHILD,
        /// The window is initially minimized.
        NVST_WS_MINIMIZE = 0x20000000,
        /// Same as NVST_WS_MINIMIZE style.
        NVST_WS_ICONIC = NVST_WS_MINIMIZE,
        /// The window is initially visible.
        NVST_WS_VISIBLE = 0x10000000,
        /// The window is initially disabled.
        NVST_WS_DISABLED = 0x08000000,
        /// Clips child windows relative to each other.
        NVST_WS_CLIP_SIBLINGS = 0x04000000,
        /// Excludes the area occupied by child windows when drawing occurs within the parent window.
        NVST_WS_CLIP_CHILDREN = 0x02000000,
        /// The window is initially maximized.
        NVST_WS_MAXIMIZE = 0x01000000,
        /// The window has a thin-line border.
        NVST_WS_BORDER = 0x00800000,
        /// The window has a border of a style typically used with dialog boxes.
        NVST_WS_DLG_FRAME = 0x00400000,
        /// The window has a vertical scroll bar.
        NVST_WS_VSCROLL = 0x00200000,
        /// The window has a horizontal scroll bar.
        NVST_WS_HSCROLL = 0x00100000,
        /// The window has a window menu on its title bar.
        NVST_WS_SYS_MENU = 0x00080000,
        /// The window has a sizing border.
        NVST_WS_THICK_FRAME = 0x00040000,
        /// Same as NVST_WS_THICK_FRAME style.
        NVST_WS_SIZEBOX = NVST_WS_THICK_FRAME,
        /// The window is the first control of a group of controls.
        NVST_WS_GROUP = 0x00020000,
        /// The window is a control that can receive the keyboard focus when the user presses the TAB key.
        NVST_WS_TAB_STOP = 0x00010000,
        /// The window has a minimize button.
        NVST_WS_MINIMIZE_BOX = 0x00020000,
        /// The window has a maximize button.
        NVST_WS_MAXIMIZE_BOX = 0x00010000,
        /// The window has a title bar.
        NVST_WS_CAPTION = (NVST_WS_BORDER | NVST_WS_DLG_FRAME),
        /// The window is an overlapped window.
        NVST_WS_TILEDWINDOW =
            (NVST_WS_OVERLAPPED | NVST_WS_CAPTION | NVST_WS_SYS_MENU | NVST_WS_THICK_FRAME | NVST_WS_MINIMIZE_BOX |
             NVST_WS_MAXIMIZE_BOX),
        /// Same as NVST_WS_TILEDWINDOW style.
        NVST_WS_OVERLAPPEDWINDOW = NVST_WS_TILEDWINDOW,
        /// The window is a pop-up window.
        NVST_WS_POPUPWINDOW = (NVST_WS_POPUP | NVST_WS_BORDER | NVST_WS_SYS_MENU),
    } NvstWindowStyle;

    /// Window styles.
    typedef enum NvstWindowStyleExtended_t
    {
        /// The window has a double border.
        NVST_WSE_DLG_MODAL_FRAME = 0x00000001,
        /// The window does not send the WM_PARENTNOTIFY message to its parent window when it is created or destroyed.
        NVST_WSE_NO_PARENT_NOTIFY = 0x00000004,
        /// The window should be placed above all non-topmost windows.
        NVST_WSE_TOPMOST = 0x00000008,
        /// The window accepts drag-drop files.
        NVST_WSE_ACCEPT_FILES = 0x00000010,
        /// The window should not be painted until siblings beneath the window have been painted.
        NVST_WSE_TRANSPARENT = 0x00000020,
        /// The window is a MDI child window.
        NVST_WSE_MDI_CHILD = 0x00000040,
        /// The window is intended to be used as a floating toolbar.
        NVST_WSE_TOOL_WINDOW = 0x00000080,
        /// The window has a border with a raised edge.
        NVST_WSE_WINDOW_EDGE = 0x00000100,
        /// The window has a border with a sunken edge.
        NVST_WSE_CLIENT_EDGE = 0x00000200,
        /// The window has a context help.
        NVST_WSE_CONTEXT_HELP = 0x00000400,
        /// The window has generic "right-aligned" properties.
        NVST_WSE_RIGHT = 0x00001000,
        /// The window has generic left-aligned properties. This is the default.
        NVST_WSE_LEFT = 0x00000000,
        /// If the shell language is Hebrew, Arabic, or another language that supports reading-order alignment,
        /// the window text is displayed using right-to-left reading-order properties.
        NVST_WSE_RTL_READING = 0x00002000,
        /// The window text is displayed using left-to-right reading-order properties. This is the default.
        NVST_WSE_LTR_READING = 0x00000000,
        /// If the shell language is Hebrew, Arabic, or another language that supports reading order alignment,
        /// the vertical scroll bar (if present) is to the left of the client area.
        NVST_WSE_LEFT_SCROLLBAR = 0x00004000,
        /// The vertical scroll bar (if present) is to the right of the client area.
        NVST_WSE_RIGHT_SCROLLBAR = 0x00000000,
        /// The window itself contains child windows that should take part in dialog box navigation.
        NVST_WSE_CONTROL_PARENT = 0x00010000,
        /// The window has a three-dimensional border style intended to be used for items that do not accept user input.
        NVST_WSE_STATIC_EDGE = 0x00020000,
        /// Forces a top-level window onto the taskbar when the window is visible.
        NVST_WSE_APP_WINDOW = 0x00040000,
        /// The window is a layered window.
        NVST_WSE_LAYERED = 0x00080000,
        /// The window does not pass its window layout to its child windows.
        NVST_WSE_NO_INHERIT_LAYOUT = 0x00100000,
        /// The window does not render to a redirection surface.
        NVST_WSE_NO_REDIRECTION_BITMAP = 0x00200000,
        /// If the shell language is Hebrew, Arabic, or another language that supports reading order alignment,
        /// the horizontal origin of the window is on the right edge.
        NVST_WSE_LAYOUT_RTL = 0x00400000,
        /// Paints all descendants of a window in bottom-to-top painting order using double-buffering.
        NVST_WSE_COMPOSITED = 0x02000000,
        /// A top-level window created with this style does not become the foreground window when the user clicks it.
        NVST_WSE_NO_ACTIVATE = 0x08000000,
        /// The window is an overlapped window.
        NVST_WSE_OVERLAPPED_WINDOW = (NVST_WSE_WINDOW_EDGE | NVST_WSE_CLIENT_EDGE),
        /// The window is palette window, which is a modeless dialog box that presents an array of commands.
        NVST_WSE_PALETTE_WINDOW = (NVST_WSE_WINDOW_EDGE | NVST_WSE_TOOL_WINDOW | NVST_WSE_TOPMOST),
    } NvstWindowStyleExtended;

#pragma pack(push, 1)

    /// Window metadata for frames containing multiple windows.
    /// \remarks
    /// The client needs to extract the metadata and crop individual windows out of the frame.
    typedef struct NvstVideoFrameWindowMetadata_t
    {
        /// Server's absolute coordinates of the window to which this metadata pertains.
        NvstRect windowRect;
        /// Z-order represented as an unsigned integer. The bottom-most window has 0.
        uint16_t zOrder;
        /// The number of rectangles that make up window region.
        /// \sa regionRects
        uint16_t regionRectsCount : 14;
        /// Can be zero or more values that define window alpha.
        /// \sa NvstVideoFrameWindowAlphaFlags
        uint8_t layeringFlags : 2;
        /// Value that receives the transparency color key.
        uint32_t colorKey : 24;
        /// Alpha value used to describe the opacity of the layered window.
        /// Fully transparrent window has 0 value. Opaque window has 255 value.
        uint8_t alphaValue : 8;
        /// Window styles (bitfield).
        /// \sa NvstWindowsStyles
        uint32_t wsStyles;
        /// Extended window styles (bitfield).
        /// \sa NvstWindowStyleExtended
        uint32_t wsExStyles;
        /// Server's handle to this window.
        uint32_t windowHandle;
        /// The length of the window's caption.
        uint16_t windowCaptionLength;
        /// Zero-terminated string with the window's caption.
        /// \todo replace static array with dynamic array, remove 64 magic number.
        uint8_t windowCaption[NVST_MD_MAX_WINDOW_CAPTION_SIZE];
        /// Coordinates of region rectangles.
        /// When combined into a single shape,
        /// these rectangles define the visible region of the window.
        /// \todo replace static array with dynamic array, remove 16 magic number.
        NvstRect regionRects[NVST_MD_MAX_REGION_RECTANGLE_COUNT];
        /// Server's handle to the owner of this window.
        uint32_t ownerHandle;
        /// Server's cloaking status of this window.
        uint32_t dwmCloaked;
    } NvstVideoFrameWindowMetadata;

    /// Video frame alpha mode/format
    ///
    /// \sa RgbxaMode, \sa YuvxaFormat
    typedef enum NvstVideoFrameAlpha_t
    {
        /// No alpha.
        NVST_VFA_NONE = 0,
        /// RGBXA_MODE_444.
        NVST_VFA_RGBXA_444 = 1,
        /// RGBXA_MODE_420_BT601_FULL.
        NVST_VFA_RGBXA_420_BT601_FULL = 2,
        /// RGBXA_MODE_420_BT601_LIMITED.
        NVST_VFA_RGBXA_420_BT601_LIMITED = 3,
        /// RGBXA_MODE_420_BT709_FULL.
        NVST_VFA_RGBXA_420_BT709_FULL = 4,
        /// RGBXA_MODE_420_BT709_LIMITED.
        NVST_VFA_RGBXA_420_BT709_LIMITED = 5,
        /// YUVxA using same format and color space as video frame itself.
        NVST_VFA_YUVXA = 6,
    } NvstVideoFrameAlpha;

    /// Video frame capture hints.
    ///
    /// These are sent by the server as a part of per-frame metadata.
    /// They are presented to the client as a 32-bit wide bitfield.
    /// All of the 1-bit fields are Boolean values.
    /// The reserved part is a placeholder for new values.
    typedef struct NvstVideoFrameCaptureHints_t
    {
        /// Video frame was captured in windowed mode.
        uint32_t modeWindowed : 1;
        /// Video frame was blended against some background.
        uint32_t backgroundBlended : 1;
        /// Video frame alpha format set by the server, \sa NvstVideoFrameAlpha
        uint32_t alphaFormat : 3;
        /// Reserved for future use.
        uint32_t reserved : 27;
    } NvstVideoFrameCaptureHints;

#pragma pack(pop)

    /// Forward declaration needed for the callback's definition.
    typedef struct NvstVideoDecodeUnit_t NvstVideoDecodeUnit;

    /// Type for the callback used to release the given VDU.
    ///
    /// The module that produced the VDU (owner) provides this callback
    /// together with the data that describes the video content of the VDU.
    /// The module to which the VDU was given will invoke the release callback
    /// once it is done processing the VDU and then the owner will release it.
    /// Typical usages:
    /// - once client's video decoder calls the callback, NVSC releases the VDU.
    /// - once NVSS calls the callback, the streamed application releases the VDU.
    /// \param[in] vdu The VDU to be released.
    /// \warning The pointed at object becomes invalid after this function is invoked.
    /// The caller should not access the pointed at object after that.
    typedef void (*RELEASE_VU_PROC)(const NvstVideoDecodeUnit* vdu);

    /// Struct representing a portion of the H.264 elementary stream.
    /// \remarks
    /// The video stream is delivered through this struct.
    /// Typical usage:
    /// - NVSC will deliver the VDU to the client's decoder through this structure.
    /// - NVSS will accept the VDU to be sent through this structure.
    /// Once the receiving module processes the VDU,
    /// it will call the callback function provided as one of the fields.
    /// \sa RELEASE_VU_PROC
    typedef struct NvstVideoDecodeUnit_t
    {
        /// Capture timestamp in microseconds.
        uint64_t timeStampUs;
        /// The frame number.
        uint32_t frameNumber;
        /// The frame type.
        NvstVideoFrameType frameType;
        /// The type of video unit.
        NvstVideoDecodeUnitType vduType;
        /// Index of the slice in the current frame (if applicable).
        uint32_t sliceIndex;
        /// Number of slices in this frame (if applicable).
        uint32_t slicesInFrame;
        /// The buffer containing the encoded bitstream.
        void* streamBuffer;
        /// The size of the encoded bitstream buffer.
        uint32_t streamSizeBytes;
        /// Opaque handle associated with this struct.
        void* decodeUnitCtx;
        /// Function to release resources associated with this struct.
        /// \warning The struct becomes invalid after this function is invoked.
        /// The caller should not access the struct after that.
        RELEASE_VU_PROC releaseProc;
        /// Zero based index of the stream this decode unit belongs to.
        uint16_t streamIndex;
        /// Frame capture hints (windowed mode, blended background, etc.).
        NvstVideoFrameCaptureHints captureHints;
        /// Count of elements in the buffer holding the window metadata.
        /// Zero means no windows.
        uint16_t windowMetadataCount;
        /// Buffer holding the window metadata. NULL means no windows.
        NvstVideoFrameWindowMetadata* windowMetadata;
        /// Frame timestamp in microseconds that may be used as a measure for multi stream timing.
        uint64_t frameTimestampUs;
        /// Indicates if the frame generation was paced using FRL.
        uint8_t dynamicFRLHonored;
        /// Size of generic metadata
        uint8_t genericMetadataSize;
        /// Buffer containing the generic metadata
        void* genericMetadata;
    } NvstVideoDecodeUnit;

    /// @}

#if defined(__cplusplus)
}
#endif
