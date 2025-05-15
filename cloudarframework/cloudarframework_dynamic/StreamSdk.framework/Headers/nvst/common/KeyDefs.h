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

/// \file KeyDefs.h
/// Defines the logical key codes sent from the client to the server.

#pragma once

/// Key codes.
/// \ingroup InputCallback
typedef enum NvstKeyCode_t
{
    /// Special code for unknown/invalid key
    NVST_KEY_NONE = 0,

    /// @{
    /// ASCII keys internally mapped to OEM keys
    NVST_KEY_APOSTROPHE = 0x0027,
    NVST_KEY_COMMA = 0x002c,
    NVST_KEY_MINUS = 0x002d,
    NVST_KEY_PERIOD = 0x002e,
    NVST_KEY_SLASH = 0x002f,
    NVST_KEY_SEMICOLON = 0x003b,
    NVST_KEY_EQUAL = 0x003d,
    NVST_KEY_BRACKETLEFT = 0x005b,
    NVST_KEY_BACKSLASH = 0x005c,
    NVST_KEY_BRACKETRIGHT = 0x005d,
    NVST_KEY_NONUS_BACKSLASH = 0x005e,
    NVST_KEY_YEN = 0x005f, // This key is present on 106 Japanese Keyboard [Windows ScanCode:7D]
    NVST_KEY_HANGUL = 0x0060, // This key is present on Korean Keyboard [Windows ScanCode:72]
    NVST_KEY_HANJA = 0x0061, // This key is present on Korean Keyboard [Windows ScanCode:71]
    NVST_KEY_RO = 0x0062, // This key is present on 106 Japanese Keyboard [Windows ScanCode:73]
    /// @}

    /// @{
    /// ASCII keys that exactly match logical key codes
    NVST_KEY_SPACE = 0x0020,

    NVST_KEY_0 = 0x0030,
    NVST_KEY_1 = 0x0031,
    NVST_KEY_2 = 0x0032,
    NVST_KEY_3 = 0x0033,
    NVST_KEY_4 = 0x0034,
    NVST_KEY_5 = 0x0035,
    NVST_KEY_6 = 0x0036,
    NVST_KEY_7 = 0x0037,
    NVST_KEY_8 = 0x0038,
    NVST_KEY_9 = 0x0039,

    NVST_KEY_A = 0x0041,
    NVST_KEY_B = 0x0042,
    NVST_KEY_C = 0x0043,
    NVST_KEY_D = 0x0044,
    NVST_KEY_E = 0x0045,
    NVST_KEY_F = 0x0046,
    NVST_KEY_G = 0x0047,
    NVST_KEY_H = 0x0048,
    NVST_KEY_I = 0x0049,
    NVST_KEY_J = 0x004a,
    NVST_KEY_K = 0x004b,
    NVST_KEY_L = 0x004c,
    NVST_KEY_M = 0x004d,
    NVST_KEY_N = 0x004e,
    NVST_KEY_O = 0x004f,
    NVST_KEY_P = 0x0050,
    NVST_KEY_Q = 0x0051,
    NVST_KEY_R = 0x0052,
    NVST_KEY_S = 0x0053,
    NVST_KEY_T = 0x0054,
    NVST_KEY_U = 0x0055,
    NVST_KEY_V = 0x0056,
    NVST_KEY_W = 0x0057,
    NVST_KEY_X = 0x0058,
    NVST_KEY_Y = 0x0059,
    NVST_KEY_Z = 0x005a,
    /// @}

    /// @{
    /// Extended ASCII keys internally mapped to OEM keys
    NVST_KEY_AGRAVE = 0x00c0,
    NVST_KEY_MULTIPLY = 0x00d7,
    NVST_KEY_DIVISION = 0x00f7,
    /// @}

    /// @{
    /// Misc. keys
    NVST_KEY_ESCAPE = 0x0100,
    NVST_KEY_TAB = 0x0101,
    NVST_KEY_BACKTAB = 0x0102,
    NVST_KEY_BACKSPACE = 0x0103,
    NVST_KEY_RETURN = 0x0104,
    NVST_KEY_ENTER = 0x0105,
    NVST_KEY_INSERT = 0x0106,
    NVST_KEY_DELETE = 0x0107,
    NVST_KEY_PAUSE = 0x0108,
    NVST_KEY_PRINT = 0x0109,
    NVST_KEY_CLEAR = 0x010a,
    /// @}

    /// @{
    /// Japanese 106 keyboard toggle keys
    NVST_KEY_HIRAGANA_KATAKANA = 0x01f0, // 106/109 Japanese keyboard toggle key - 2nd on right of space [ScanCode:70]
    NVST_KEY_HENKAN_ZENKOUHO = 0x01f1, // 106/109 Japanese keyboard toggle key - right of space[ScanCode:79]
    NVST_KEY_MUHENKAN = 0x01f2, // 106/109 Japanese keyboard toggle key - left of space [ScanCode:7B]
    /// @}

    /// @{
    /// Cursor movement keys
    NVST_KEY_HOME = 0x0200,
    NVST_KEY_END = 0x0201,
    NVST_KEY_LEFT = 0x0202,
    NVST_KEY_UP = 0x0203,
    NVST_KEY_RIGHT = 0x0204,
    NVST_KEY_DOWN = 0x0205,
    NVST_KEY_PAGE_UP = 0x0206,
    NVST_KEY_PAGE_DOWN = 0x0207,
    /// @}

    /// @{
    /// Modifier keys
    NVST_KEY_SHIFT = 0x0301,
    NVST_KEY_LSHIFT = 0x0302,
    NVST_KEY_RSHIFT = 0x0303,

    NVST_KEY_CONTROL = 0x0304,
    NVST_KEY_LCONTROL = 0x0305,
    NVST_KEY_RCONTROL = 0x0306,

    NVST_KEY_ALT = 0x0307,
    NVST_KEY_LALT = 0x0308,
    NVST_KEY_RALT = 0x0309,

    NVST_KEY_META = 0x0310,
    NVST_KEY_LMETA = 0x0311,
    NVST_KEY_RMETA = 0x0312,
    /// @}

    /// @{
    /// Function Keys
    NVST_KEY_F1 = 0x0400,
    NVST_KEY_F2 = 0x0401,
    NVST_KEY_F3 = 0x0402,
    NVST_KEY_F4 = 0x0403,
    NVST_KEY_F5 = 0x0404,
    NVST_KEY_F6 = 0x0405,
    NVST_KEY_F7 = 0x0406,
    NVST_KEY_F8 = 0x0407,
    NVST_KEY_F9 = 0x0408,
    NVST_KEY_F10 = 0x0409,
    NVST_KEY_F11 = 0x040a,
    NVST_KEY_F12 = 0x040b,
    NVST_KEY_F13 = 0x040c,
    NVST_KEY_F14 = 0x040d,
    NVST_KEY_F15 = 0x040e,
    NVST_KEY_F16 = 0x040f,
    NVST_KEY_F17 = 0x0410,
    NVST_KEY_F18 = 0x0411,
    NVST_KEY_F19 = 0x0412,
    NVST_KEY_F20 = 0x0413,
    NVST_KEY_F21 = 0x0414,
    NVST_KEY_F22 = 0x0415,
    NVST_KEY_F23 = 0x0416,
    NVST_KEY_F24 = 0x0417,
    /// @}

    /// @{
    /// Lock keys
    NVST_KEY_CAPS_LOCK = 0x0501,
    NVST_KEY_NUM_LOCK = 0x0502,
    NVST_KEY_SCROLL_LOCK = 0x0503,
    /// @}

    /// @{
    /// Numpad keys
    NVST_KEY_KP_0 = 0x0600,
    NVST_KEY_KP_1 = 0x0601,
    NVST_KEY_KP_2 = 0x0602,
    NVST_KEY_KP_3 = 0x0603,
    NVST_KEY_KP_4 = 0x0604,
    NVST_KEY_KP_5 = 0x0605,
    NVST_KEY_KP_6 = 0x0606,
    NVST_KEY_KP_7 = 0x0607,
    NVST_KEY_KP_8 = 0x0608,
    NVST_KEY_KP_9 = 0x0609,

    NVST_KEY_ADD = 0x060a,
    NVST_KEY_SUBTRACT = 0x060b,
    NVST_KEY_DECIMAL = 0x060c,

    NVST_KEY_KP_INSERT = 0x060d,
    NVST_KEY_KP_END = 0x060e,
    NVST_KEY_KP_DOWN = 0x060f,
    NVST_KEY_KP_PAGE_DOWN = 0x0610,
    NVST_KEY_KP_LEFT = 0x0611,
    NVST_KEY_KP_CLEAR = 0x0612,
    NVST_KEY_KP_RIGHT = 0x0613,
    NVST_KEY_KP_HOME = 0x0614,
    NVST_KEY_KP_UP = 0x0615,
    NVST_KEY_KP_PAGE_UP = 0x0616,
    NVST_KEY_KP_DELETE = 0x0617,
    /// @}

    /// Special value that is 1 higher than the highest valid key code
    NVST_KEY_MAX = 0x0618,

    /// Special code representative of all other keycodes
    NVST_KEY_ALL = 0xffff,
} NvstKeyCode;
