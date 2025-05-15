// Copyright (c) 2013-2021, NVIDIA CORPORATION.  All rights reserved.
//
// NVIDIA CORPORATION and its licensors retain all intellectual property
// and proprietary rights in and to this software, related documentation
// and any modifications thereto.  Any use, reproduction, disclosure or
// distribution of this software and related documentation without an express
// license agreement from NVIDIA CORPORATION is strictly prohibited.

#pragma once

#include "ConfigType_auto.h"
#ifdef WIN32
#include <qos2.h>
#endif
#include <nvsc/NvscClientConfig.h>

struct DisplayMode;

#include <map>
typedef void (*VctDefaultProvider)(
    NvscClientConfig&,
    DisplayMode&,
    NvstServerNetwork serverNetwork,
    uint32_t streamIndex,
    uint32_t streamingType);
typedef std::map<NvstVideoContentType, VctDefaultProvider> VctFunctionMap;

#define DEFAULT_NVST_VIDEO_DYNAMIC_RESOLUTION_MODE false
#define DEFAULT_NVST_VIDEO_DISPLAY_ERROR_RECOVERY_MODE false
#define DEFAULT_NVST_VIDEO_ENCODER_MULTITHREADED_DECODE_MODE false
#define DEFAULT_NVST_VIDEO_SLICES_PER_FRAME 0

#include "DefineDefaultConfigs_auto.h"

void setClientConfigDefaults(NvscClientConfig& m_config, bool bAutoConfigMetaParamsOnly = false);
void clientDefaultsAutoConfigFull(NvscClientConfig& m_config);
void clientDefaultsAutoConfigMetaParamsOnly(NvscClientConfig& m_config);
void initializeVctProviders(VctFunctionMap& m_vctProviders);

void VctProviderGaming(
    NvscClientConfig& config,
    DisplayMode& sm,
    NvstServerNetwork serverNetwork,
    uint32_t streamIndex,
    uint32_t streamingType);
void VctProviderGamingGfn(
    NvscClientConfig& config,
    DisplayMode& sm,
    NvstServerNetwork serverNetwork,
    uint32_t streamIndex,
    uint32_t streamingType);
void VctProviderGamingPc2Shield(
    NvscClientConfig& config,
    DisplayMode& sm,
    NvstServerNetwork serverNetwork,
    uint32_t streamIndex,
    uint32_t streamingType);
void VctProviderProfessional(
    NvscClientConfig& config,
    DisplayMode& sm,
    NvstServerNetwork serverNetwork,
    uint32_t streamIndex,
    uint32_t streamingType);
void VctProviderGamingHighDensityServer(
    NvscClientConfig& config,
    DisplayMode& sm,
    NvstServerNetwork serverNetwork,
    uint32_t streamIndex,
    uint32_t streamingType);

NvstResult isVctValid(NvstVideoContentType vct);
void setDefaultConfigs(void* config, size_t configSize, ConfigType type, bool initMetaParamsBoundariesOnly);
void setNvscGeneralDefaultsSettings(NvscGeneralSettings& general);
void setNvstVideoDecoderDefaultsSettings(NvstVideoDecoder& videoDecoder);
void setNvscBWEstimatorDefaults(NvscBWEstimator& bwe);
