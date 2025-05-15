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

/// \file StreamClient.h
/// Defines the streaming client's interface.

#pragma once

#include "ClientEvent.h"
#include "ClientTypes.h"
#include "RuntimeParam.h"
#include "Stats.h"
#include "Version.h"

#include <nvst/common/InputEvent.h>
#include <nvst/common/KeyDefs.h>
#include <nvst/common/Logger.h>
#include <nvst/common/MessageForClient.h>
#include <nvst/common/MessageForServer.h>
#include <nvst/common/MouseCursorDefines.h>
#include <nvst/common/Result.h>
#include <nvst/common/Util.h>
#include <nvst/common/SharedTypes.h>
#include <nvst/common/Signaling.h>
#include <nvst/common/Stream.h>

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#if defined(__cplusplus)
extern "C"
{
#endif
#define NVST_MAX_PEM_CERT_PATH 512

    /// \defgroup SdkClientInterface Client Stream SDK interface

    /// \addtogroup SdkClientInterfaceStructs Client Stream SDK Structs/Enums
    /// \ingroup SdkClientInterface
    /// @{

    /// Groups all callbacks coming from client-side SDK to the client application.
    typedef struct NvstClientCallbacks_t
    {
        /// Context pointer passed back whenever a callback is invoked.
        /// An application can pass it's own user data in this pointer that will be sent
        /// when the event is fired.
        void* context;

        /// Invoked when an NvstClient raises an event.
        ///
        /// \param[in] context Application-supplied pointer.
        /// \param[in] clientEvent Details about the raised event.
        /// \warning Any pointer fields in the event structure
        /// are only valid during the duration of the callback.
        /// The application is required to make a copy of pointed data,
        /// if it needs to use it after the callback returns.
        void (*eventRaised)(void* context, NvstClientEvent clientEvent);

        /// Server sents message to the application
        /// \param[in] context Application-supplied pointer
        /// \param[in] message holds server message info
        void (*onServerMessage)(void* context, NvstMessageForClient message);

        /// Server sent a signaling message to the application
        /// \param[in] context Application-supplied pointer
        /// \param[in] message holds server signaling message info
        void (*onServerSignalingMessage)(void* context, const NvstMessage* message);
    } NvstClientCallbacks;

    /// Convenience typedefs for library consumers.
    typedef void (*ON_EVENT_RAISED_PROC)(void* context, NvstClientEvent event);
    typedef void (*ON_SERVER_MESSAGE_PROC)(void* context, NvstMessageForClient message);
    typedef void (*ON_SIGNALING_MESSAGE_RECEIVED_PROC)(void* context, const NvstMessage* message);

    /// Data about the connection to be made to the server.
    typedef struct NvstConnectionConfig_t
    {
        /// Details about the endpoints used by the server.
        /// Note that only two server addresses are supported. A signaling server for RTSP[S]
        /// and a streaming server for all RTP traffic and control channel.
        /// Signaling ports are supported only on TCP protocol and streaming ports are supported on UDP.
        NvstServerEndpoint serverEndpoints[NVST_PU_COUNT];
        /// Whether to perform continouous hole punch to server URLs during the streaming session.
        bool useHolePunch;
        /// Whether to do a faster non blocking disconnect in specific cases during termination.
        bool nonBlockingDisconnect;
        /// Server network the session belongs to.
        NvstServerNetwork serverNetwork;
        /// Network connection info.
        NvstConnectionInfo clientConnectionInfo;
        /// STUN/TURN server urls and credential
        /// Supported only in RtcStreamSdk
        NvstNatServer natServers[NVST_MAX_TURN_SERVER_SUPPORTED];
        /// Path on local file system that holds the CA for the server's self-signed certificate.
        /// Default is 'cert.pem' in same directory as executable, see NvstTestClient.cpp for details.
        char pemCertPath[NVST_MAX_PEM_CERT_PATH];
        /// Set Ip version
        NvstIpVersion ipVersion;
        /// Method of validation for the signaling server's certificate if the signaling endpoint is configured to be
        /// secure.
        NvstCertificateValidationMethod validationMethod;
        /// Null terminated session ID of a streaming session.
        /// It is needed by NvstMessage mechanism to identify a client on the server side
        const char* appSessionId;
    } NvstConnectionConfig;

    /// @}

    /// \addtogroup SdkClientAPI Client Stream SDK APIs
    ///
    /// None of the API functions below are thread safe.
    /// Ensuring that these functions are called in a synchronized manner
    /// in a multithreaded environment is left to the consumer of this API.
    /// \ingroup SdkClientInterface
    /// @{

    /// Create a NvstClient instance.
    ///
    /// A newly created NvstClient is in the NVSC_INITIAL state.
    /// nvstDestroyClient() must be invoked during termination
    /// to release resources acquired during creation.
    /// \param[in] callbacks Callbacks structure for the client to use.
    /// \param[out] client The resulting stream client.
    /// \retval NVST_R_INVALID_OBJECT if any of the parameters is not a legitimate value.
    /// \retval NVST_R_OUT_OF_MEMORY_ERROR if the NvstClient could not be created.
    /// \retval NVST_R_SUCCESS otherwise.
    NVST_API NvstResult nvstCreateClient(const NvstClientCallbacks* callbacks, NvstClient* client);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*CREATE_CLIENT_PROC)(const NvstClientCallbacks* callbacks, NvstClient* client);

    /// Destroy the NvstClient.
    ///
    /// If any connections are alive, disconnect them all.
    /// NvstClient handle will be invalid after this.
    /// \param[in] client Handle of the NvstClient instance to destroy.
    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value.
    /// \retval NVST_R_INVALID_OPERATION if the NvstClient is still connected to the server.
    /// \retval NVST_R_GENERIC_ERROR if the NvstClient could not be destroyed.
    /// \retval NVST_R_SUCCESS otherwise.
    /// \note
    /// The client must be disconnected from the server before destruction.
    /// Do not call this before all audio and video buffers have been deallocated and
    /// before client has entered NVST_STATE_DISCONNECTED state.
    /// Destruction of the NvstClient is permanent and deep.
    /// The handle passed to this function may not be used again.
    /// However, if NVST_R_INVALID_OPERATION is returned,
    /// destruction may be attempted again after disconnecting from the Server.
    /// \sa nvscDisconnectFromServer
    NVST_API NvstResult nvstDestroyClient(NvstClient client);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*DESTROY_CLIENT_PROC)(NvstClient client);

    /// Prepare signaling serverEndpoint.
    ///
    /// Prepare a default signaling serverEndpoint from a given server IP.
    /// \param[in] signalingServerIp IP address of the signaling server.
    /// \param[in] port A user provided port number. If it is set to 0, SDK will use the default port.
    /// \param[out] pSignalingServerEndpoint to hold the signaling serverEndpoint.
    /// \retval NVST_R_INVALID_PARAM if arguments are not valid.
    /// \retval NVST_R_GENERIC_ERROR if operation is failed.
    /// \retval NVST_R_SUCCESS otherwise.
    NVST_API NvstResult nvstPrepareSignalingServerEndpoint(
        const char* signalingServerIp,
        uint16_t port,
        NvstServerEndpoint* pSignalingServerEndpoint);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*PREPARE_SIGNALING_SERVER_ENDPONT_PROC)(
        const char* signalingServerIp,
        uint32_t port,
        NvstServerEndpoint* pSignalingServerEndpoint);

    /// Connect to the server.
    ///
    /// Returns once the connection to the server is established.
    /// Streaming will not start as a result of this function.
    /// The application needs to invoke another function to start/stop streaming.
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] config Properties associated with the connection being attempted with the server.
    /// \param[in] numStreams Number of streams to be associated with the server.
    /// \param[in] streams An array containing numStreams streams to be associated with the server.
    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value.
    /// \retval NVST_R_INVALID_OPERATION if the configuration isn't fully specified.
    /// \retval NVST_R_NETWORK_ERROR if the NvstClient could not connect to the server.
    /// \retval NVST_R_SUCCESS otherwise.
    /// \sa nvstControlStreaming
    NVST_API NvstResult nvstConnectToServer(
        NvstClient client,
        const NvstConnectionConfig* config,
        uint32_t numStreams,
        NvstStream streams[]);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*CONNECT_TO_SERVER_PROC)(
        NvstClient client,
        const NvstConnectionConfig* config,
        uint32_t numStreams,
        NvstStream streams[]);

    /// Control streaming from an already connected server.
    ///
    /// Returns once the streaming control command is sent to the server.
    /// Streaming will start or pause as a result of this function.
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] streamCommand command to start or pause streaming.
    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value.
    /// \retval NVST_R_INVALID_OPERATION if the connection isn't established.
    /// \retval NVST_R_NETWORK_ERROR if the command didn't go through.
    /// \retval NVST_R_SUCCESS otherwise.
    /// \warning The function is a blocking function.
    /// It doesn't return until all needed operations are completed.
    /// As a result, video and audio streams might start arriving
    /// before the function returns control to the caller.
    /// Failing to call this function within 20s of a successful connection
    /// would automatically disconnect the session.
    NVST_API NvstResult nvstControlStreaming(NvstClient client, NvstStreamingCommand streamCommand);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*CLIENT_CONTROL_STREAMING_PROC)(NvstClient client, NvstStreamingCommand streamCommand);

    /// Disconnect from server.
    /// \param[in] client Client that should disconnect.
    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value.
    /// \retval NVST_R_SUCCESS otherwise.
    NVST_API NvstResult nvstDisconnectFromServer(NvstClient client);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*DISCONNECT_FROM_SERVER_PROC)(NvstClient client);

    /// Specify runtime session parameters.
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] param Parameter to set.
    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value;
    /// \retval NVST_R_INVALID_PARAM for invalid parameter;
    /// \retval NVST_R_SUCCESS otherwise.
    NVST_API NvstResult nvstSetRuntimeParam(NvstClient client, NvstClientRuntimeParam* param);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*SET_RUNTIME_PARAM)(NvstClient client, NvstClientRuntimeParam* param);

    /// Query runtime session parameters.
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[out] param Parameter to query.
    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value;
    /// \retval NVST_R_INVALID_PARAM for invalid parameter;
    /// \retval NVST_R_SUCCESS otherwise.
    NVST_API NvstResult nvstGetRuntimeParam(NvstClient client, NvstClientRuntimeParam* param);

    typedef NvstResult (*GET_RUNTIME_PARAM)(NvstClient client, NvstClientRuntimeParam* param);

    /// Send message to the server
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] message Message to send to the server.
    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value;
    /// \retval NVST_R_INVALID_ENUM for invalid enum type;
    /// \retval NVST_R_SUCCESS otherwise.
    NVST_API NvstResult nvstSendMessageToServer(NvstClient client, NvstMessageForServer* message);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*SEND_MESSAGE_TO_SERVER)(NvstClient client, NvstMessageForServer* message);

    /// Send data to the server on signaling channel
    ///
    /// Applications can use this API to send a message to the server even while
    /// the connection is in progress. This API is supposed to be called only after
    /// receiving NVST_CE_SIGNALING_CHANNEL_READY event.
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] message Message to send to the server.
    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value;
    /// \retval NVST_R_INVALID_ENUM for invalid enum type;
    /// \retval NVST_R_SUCCESS otherwise.
    NVST_API NvstResult nvstPushDataOnSignalingChannel(NvstClient client, const NvstMessage* message);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*PUSH_DATA_ON_SIGNALING_CHANNEL)(NvstClient client, const NvstMessage* message);

    /// @}

#if defined(__cplusplus)
}
#endif
