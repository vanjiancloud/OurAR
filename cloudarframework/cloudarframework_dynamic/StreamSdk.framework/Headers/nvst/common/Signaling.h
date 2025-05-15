// Copyright NVIDIA Corporation 2020
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

/// \file Signaling.h
/// Defines functions and types for use with signaling between servers and clients.

#pragma once

#include "../client/ClientTypes.h"
#include "../common/SharedTypes.h"
#include "../common/Util.h"

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \addtogroup Signaling SDK Signaling interface
    /// @{

    /// Method of validation for the signaling server's certificate.
    typedef enum NvstCertificateValidationMethod_t
    {
        /// No validation
        NVST_CVM_NONE,
        /// Validate manually, with the NvstValidateCertificate event.
        NVST_CVM_EVENT,
        /// Validate automatically, with the included Certificate Authority.
        NVST_CVM_AUTHORITY,
    } NvstCertificateValidationMethod;

    /// Header sent or received when establishing a connection to the signaling server.
    typedef struct NvstSignalingHeader_t
    {
        /// Name of the header.
        const char* name;
        /// Value for the header.
        const char* value;
    } NvstSignalingHeader;

    /// Set header to send when establishing a connection to the signaling server. This may be called multiple times
    /// to set different headers.
    /// Must be called before connecting to the signaling server.
    /// \note This is currently only implemented for the client side and has to be called before nvstConnectToServer.
    /// Currently there is no separate API to connect to the signaling server. In the future, this will change.
    /// \param[in] client NvstClient to be modified.
    /// \param[in] header Header to be sent with the connection request.
    /// \return NVST_R_SUCCESS if the header was set,
    /// NVST_R_INVALID_PARAM if the header was not valid.
    /// NVST_R_INVALID_STATE if the handshake has already started or completed successfully.
    NVST_API NvstResult nvstSetSignalingHeader(NvstClient client, const NvstSignalingHeader* header);
    /// Convenience typedef of nvstSetSignalingHeader for dynamic library consumers.
    typedef NvstResult (*NVST_SET_SIGNALING_HEADER_PROC)(NvstClient, const NvstSignalingHeader*);

    /// Clear any headers that were set with `nvstSetSignalingHeaders`.
    /// \param[in] client NvstClient to be modified.
    NVST_API void nvstClearSignalingHeaders(NvstClient client);
    /// Convenience typedef of nvstClearSignalingHeaders for dynamic library consumers.
    typedef void (*NVST_CLEAR_SIGNALING_HEADERS_PROC)(NvstClient);

    /// SignalingServer configuration options.
    /// \sa nvstStartSignalingServer
    typedef struct NvstSignalingServerConfig_t
    {
        /// Provide certificate in PEM format for SSL.
        /// Not supported.
        const char* certificatePem;

        /// Provide key in PEM format for SSL.
        /// Not supported.
        const char* keyPem;

        /// Set Ip version.
        NvstIpVersion ipVersion;

        /// Signaling port to use.
        uint16_t signalingPort;

        // Allow acks
        bool allowAcks;
    } NvstSignalingServerConfig;

    /// Start websocket signaling server with given config to facilitate negotiation between peers.
    /// If SSL information is not provided as part of signalingServerConfig, then
    /// signaling server would not support encrypted connections.
    /// This API is only supported by: i. LIBWEBRTC and ii. NATIVEWEBRTC based stacks.
    /// Current native mode using Mjolnir's proprietary stack doesn't support it.
    ///
    /// \param[in] signalingServerConfig Configuration to setup signaling server.
    /// \return NVST_R_SUCCESS if the signaling server was started,
    /// NVST_R_INVALID_PARAM if any params are not valid,
    /// NVST_R_INVALID_OPERATION if server is already started,
    /// NVST_R_GENERIC_ERROR otherwise.
    NVST_API NvstResult nvstStartSignalingServer(const NvstSignalingServerConfig* signalingServerConfig);
    /// Convenience typedef of nvstStartSignalingServer for dynamic library consumers.
    typedef NvstResult (*NVST_START_SIGNALING_SERVER)(const NvstSignalingServerConfig*);

    /// Stop the Signaling server.
    ///
    /// \return NVST_R_SUCCESS if the signaling server was stopped,
    /// NVST_R_INVALID_OPERATION if server is not running,
    /// NVST_R_GENERIC_ERROR otherwise.
    NVST_API NvstResult nvstStopSignalingServer();
    /// Convenience typedef of nvstStopSignalingServer for dynamic library consumers.
    typedef NvstResult (*NVST_STOP_SIGNALING_SERVER)();

    /// @}
#if defined(__cplusplus)
}
#endif
