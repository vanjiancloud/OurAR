// Copyright (c) 2021, NVIDIA CORPORATION.  All rights reserved.
//
// NVIDIA CORPORATION and its licensors retain all intellectual property
// and proprietary rights in and to this software, related documentation
// and any modifications thereto.  Any use, reproduction, disclosure or
// distribution of this software and related documentation without an express
// license agreement from NVIDIA CORPORATION is strictly prohibited.

/// \todo this file should be moved to source/common/config
/// once all external project stop depending on NvscClientConfig directly.
/// See https://jirasw.nvidia.com/browse/GCC-3553 for details.
#pragma once

#ifndef MAX_PATH
/// Maximum path length limitation
/// https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=cmd
#define MAX_PATH 260
#endif
/// Max length of the certificate path
#define NVST_MAX_PEM_CERT_PATH 512
#ifndef ICE_STRING_LENGTH
/// Maximum length of ICE username fragment and password SDP parameters
#define ICE_STRING_LENGTH 512
#endif
#ifndef DTLS_FINGERPRINT_LENGTH
/// Maximum length of DTLS fingerprint SDP parameters
#define DTLS_FINGERPRINT_LENGTH 512
#endif
