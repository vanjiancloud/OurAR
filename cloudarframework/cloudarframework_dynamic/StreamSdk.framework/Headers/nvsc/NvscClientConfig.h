/*
 * Copyright NVIDIA Corporation 2017-2020
 * TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SOFTWARE IS PROVIDED
 * *AS IS* AND NVIDIA AND ITS SUPPLIERS DISCLAIM ALL WARRANTIES, EITHER EXPRESS
 * OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL
 * NVIDIA OR ITS SUPPLIERS BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR
 * LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS
 * INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
 * INABILITY TO USE THIS SOFTWARE, EVEN IF NVIDIA HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 */

/*!
 * \file NvscClientConfig.h
 */

#pragma once

#include <nvst/client/AudioRenderer.h>
#include <nvst/client/ClientEvent.h>
#include <nvst/client/ClientTypes.h>
#include <nvst/client/VideoDecoder.h>
#include <nvst/common/Result.h>
#include <nvst/common/SharedTypes.h>
#include <nvst/common/StreamConfig.h>

/*!< @todo Decide whether to keep this value when code gets enabled for Android.*/
/// How about:
/// if windows define NVST_MAX_PATH_LENGTH MAX_PATH
/// else define NVST_MAX_PATH_LENGTH 260 (or some other value)
#ifndef MAX_PATH
#define MAX_PATH 260
#endif

/*!
 * \brief
 * The type of the method used to query active wifi connection speed and frequency and RSSI.
 * \sa wifiProps
 * \param speed Active Wifi connection speed in Mbps.
 * \param frequency frequency of active wifi channel in MHz.
 * \param RSSI received signal strength indicator in dBm.
 */
typedef void (*WIFIPROPERTY_EXTRACTOR_PROC)(void* userData, int* speed, long* frequency, int* rssi);

#include <NvscClientConfig_auto.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    /*!
 * \brief Modes for capturing stream data.
 * \sa clientCapture
 * \sa serverCapture
 */
    typedef enum NvscStreamCaptureModeFlags_t
    {
        STREAM_CAPTURE_NONE = 0x00000000,
        STREAM_CAPTURE_VIDEO = 0x00000001,
        STREAM_CAPTURE_AUDIO = 0x00000002,
        STREAM_CAPTURE_VOICE = 0x00000004
    } NvscStreamCaptureModeFlags;

    /*!
 * \ingroup NvstClient
 * \brief Override the configuration fields passed as a serialized string.
 * \param client NvstClient obtained thorugh nvstCreateClient().
 * \param configString Serialized config string of the format:
 * config1: value1\nconfig2: value2\nconfig3: value3
 * \param configStringLength Length of the string.
 * \return
 * NVST_R_INVALID_OBJECT if client is not a legitimate value;\n
 * NVST_R_INVALID_PARAM if the configuration fails to pass validity checks;\n
 * NVST_R_SUCCESS otherwise, since this method is not implemented.\n
 * \remarks
 * If NVST_R_INVALID_PARAM is returned, the log will contain details on which
 * config parameter was invalid.
 * \remarks
 * This method must be be invoked before a connection to the server is
 * established (through nvstConnectToServer()).  In addition this method may
 * also be used to tweak mutable parameters during streaming.\n\n
 * When invoked before nvstConnectToServer(), previously stored values are
 * overwritten with the newly supplied ones.\n\n
 * Streaming doesn't begin until nvstConnectToServer() is invoked.\n\n
 * After successfully updating the configuration, the NvstClient is in the
 * NVSC_CONFIGURED state.
 * If any of the video QoS fields is not matching the value appropriate for the
 * what is specified in videoQosProfile field, there will be a warning log.
 * \sa nvstConnectToServer
 * \sa nvscGetClientConfig
 */
    NVST_API NvstResult nvscOverrideClientConfigFieldsWithString(
        NvstClient client,
        const char* configString,
        size_t configStringLength);

    /*!
 * \ingroup NvstClient
 * \brief Query the parameters for streaming.
 * \param client NvstClient obtained through nvstCreateClient().
 * \param config Struct receiving configuration details.
 * \return
 * NVST_R_INVALID_OBJECT if client is not a legitimate value;\n
 * NVST_R_INVALID_PARAM if config is NULL
 * or if videoQosProfile doesn't have a legitimate value;\n
 * NVST_R_SUCCESS otherwise.\n
 * \remarks
 * This method returns the currently stored configuration, or defaults if the
 * configuration wasn't explicitly set.
 * If value in videoQosProfile is valid and different from NVST_VQP_CURRENT,
 * video QoS settings will be set to those appropriate for the given enum.
 * If videoQosProfile value is NVST_VQP_CURRENT
 * and this is the first call to this function,
 * video QoS settings will be set to defaults as the rest of the struct;
 * for subsquent calls, video QoS settings will not be changed.
 */
    NVST_API NvstResult nvscGetClientConfig(NvstClient client, NvscClientConfig* config);

    /*! \ingroup NvstClient */
    typedef NvstResult (*GETCLIENTCONFIG_PROC)(NvstClient client, NvscClientConfig* config);

#if defined(__cplusplus)
}
#endif
