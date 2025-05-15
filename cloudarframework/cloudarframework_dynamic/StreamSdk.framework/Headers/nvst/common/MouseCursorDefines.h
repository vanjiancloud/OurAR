// Copyright NVIDIA Corporation 2017 - 2019
// TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SOFTWARE IS PROVIDED
// *AS IS* AND NVIDIA AND ITS SUPPLIERS DISCLAIM ALL WARRANTIES, EITHER EXPRESS
// OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
// NVIDIA OR ITS SUPPLIERS BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR
// CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR
// LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS
// INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
// INABILITY TO USE THIS SOFTWARE, EVEN IF NVIDIA HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGES.

/// \file MouseCursorDefines.h
/// Defines mouse cursor constants and enums shared between client and server.

#pragma once

/// System cursor identifiers.
///
/// - "[SDL]" means "ID supported by SDL".
///   See: https://wiki.libsdl.org/SDL_CreateSystemCursor
/// - "[WIN]" means "ID supported by Windows API".
///   See: https://msdn.microsoft.com/en-us/library/windows/desktop/ms648391(v=vs.85).aspx
/// - "[NVST]" means "ID used internally".
/// \note Do not change the hard-coded values.
/// \ingroup nvstServerSdkStructs
typedef enum NvstSystemCursor_t
{
    /// [NVST] Mouse cursor is hidden.
    NVST_SYSTEM_CURSOR_HIDDEN = 0,
    /// [SDL/WIN] Arrow.
    NVST_SYSTEM_CURSOR_ARROW = 1,
    /// [SDL/WIN] I-beam.
    NVST_SYSTEM_CURSOR_I_BEAM = 2,
    /// [SDL/WIN] Wait (e.g. hourglass, spinner, etc.).
    NVST_SYSTEM_CURSOR_WAIT = 3,
    /// [SDL/WIN] Crosshair.
    NVST_SYSTEM_CURSOR_CROSSHAIR = 4,
    /// [SDL/WIN] Small wait cursor (or wait if not available). MSDN: IDC_APPSTARTING
    NVST_SYSTEM_CURSOR_WAIT_ARROW = 5,
    /// [SDL/WIN] Double arrow pointing up-left and down-right.
    NVST_SYSTEM_CURSOR_SIZE_UL_DR = 6,
    /// [SDL/WIN] Double arrow pointing up-right and down-left.
    NVST_SYSTEM_CURSOR_SIZE_UR_DL = 7,
    /// [SDL/WIN] Double arrow pointing left and right.
    NVST_SYSTEM_CURSOR_SIZE_RL = 8,
    /// [SDL/WIN] Double arrow pointing up and down.
    NVST_SYSTEM_CURSOR_SIZE_UD = 9,
    /// [SDL/WIN] Four pointed arrow pointing up, down, left, and right.
    NVST_SYSTEM_CURSOR_SIZE_ALL = 10,
    /// [SDL/WIN] Slashed circle or crossbones.
    NVST_SYSTEM_CURSOR_NO = 11,
    /// [SDL/WIN] Hand.
    NVST_SYSTEM_CURSOR_HAND = 12,
    /// [WIN] Arrow and question mark.
    NVST_SYSTEM_CURSOR_HELP = 13,
    /// [WIN] Obsolete for applications marked version 4.0 or later.
    /// \todo Update this explanation and refer MSDN value.
    NVST_SYSTEM_CURSOR_ICON = 14,
    /// [WIN] Obsolete for applications version 4.0 or later. Use _SIZEALL.
    /// \todo Update this explanation and refer MSDN value.
    NVST_SYSTEM_CURSOR_SIZE = 15,
    /// [WIN] Vertical arrow.
    NVST_SYSTEM_CURSOR_UP_ARROW = 16,
} NvstSystemCursor;
