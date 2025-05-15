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

/// \file ClientEvent.h
/// Defines various NVST client events.

#pragma once

#include "ClientTypes.h"
#include "../common/Result.h"
#include "../common/SharedTypes.h"
#include "../common/VideoFormat.h"
#include "NvstClientDJBConfig.h"

#include <stdint.h>
#include <stddef.h>

#define NVST_PRIORITIZED_ENDPOINTS_COUNT 3
#define NVST_MAX_ADDRESS_LENGTH 48

/// \addtogroup SdkClientInterfaceStructs
/// @{

/// Enumeration of haptic event types.
typedef enum NvstHapticEventType_t
{
    /// Client controller has no haptic operation.
    NVST_HET_NOOP = 0,
    /// Client controller has simple rumble effect.
    NVST_HET_SIMPLE = 1,
    /// Client controller has rumble effect for a duration.
    NVST_HET_SIMPLE_DURATION = 2,
} NvstHapticEventType;

/// Struct of gamepad haptic event which sent from server to client
typedef struct NvstHapticEvent_t
{
    /// Type of haptic event command
    NvstHapticEventType type;
    /// Current haptic command size in bytes, also in SIMD case, multiple of command size in bytes
    uint16_t commandSize;
    /// Haptic event details.(simple,duration str)
    uint16_t* payload;
} NvstHapticEvent;

/// Struct for connection change event.
typedef enum NvstConnectionEventType_t
{
    /// Streaming is stopped - no longer receiving video and audio
    NVST_CONNECTION_STOPPED = 0,
    /// An irrecoverable error
    NVST_CONNECTION_ERROR = 1,
} NvstConnectionEventType;

/// Struct for connection change event.
typedef struct NvstClientConnectionChangeEvent_t
{
    /// Connection event type
    NvstConnectionEventType event;
    /// Reason code that resulted in change of streaming event
    ///
    /// If the value of event is NVST_CONNECTION_STOPPED then this will contain the
    /// reason that the connection was closed by the server.
    /// If the value of event is NVST_CONNECTION_STOPPED and the value of
    /// reasonCode is NVST_DISCONN_SERVER_TERMINATED_CLOSED then the server API
    /// nvstStopServer was called and stopData and stopDataSize may contain
    /// valid data.
    NvstResult reason;
    /// Data provided to nvstStopServer. Valid only if the event is
    /// NVST_CONNECTION_STOPPED and the value of reasonCode is
    /// NVST_DISCONN_SERVER_TERMINATED_CLOSED.
    const void* stopData;
    /// Size of stopData in bytes. Valid only if the event is
    /// NVST_CONNECTION_STOPPED and the value of reasonCode is
    /// NVST_DISCONN_SERVER_TERMINATED_CLOSED.
    uint16_t stopDataSize;
} NvstClientConnectionChangeEvent;

/// Struct storing data about handling Gamepad event.
typedef struct NvstGamepadHandlingEvent_t
{
    /// Right stick to be used as mouse or game pad
    uint16_t rightStick;
} NvstGamepadHandlingEvent;

/// Struct to specify information about the Server endpoint.
typedef struct NvstServerEndpoint_t
{
    /// Null terminated string of the server address.
    char* serverAddress;
    /// Port number.
    uint16_t portNumber;
    /// Protocol used.
    NvstTransferProtocol protocol;
    /// Usage of this endpoint whether it is for video or audio or input etc.
    NvstPortUsage usage;
} NvstServerEndpoint;

/// Enumeration of timer event types
typedef enum NvstTimerEventType_t
{
    /// The first warning before entitlement timeout.
    NVST_TE_ENTITLEMENT_WARNING_1 = 1,
    /// The second warning before entitlement timeout.
    NVST_TE_ENTITLEMENT_WARNING_2 = 2,
    /// User timeout due to entitlement.
    NVST_TE_ENTITLEMENT_FINAL = 3,
    /// Warning since there is no user input.
    NVST_TE_USER_INPUT_IDLE_WARNING = 4,
    /// User timeout since there is no user input.
    NVST_TE_USER_INPUT_IDLE_FINAL = 5,
    /// Warning since time limit of a session will be reached.
    NVST_TE_MAX_USAGE_LIMIT_WARNING = 6,
    /// User timeout since time limit of a session has been reached.
    NVST_TE_MAX_USAGE_LIMIT_FINAL = 7,
    /// User timeout since max concurrent session of each user has been reached.
    NVST_TE_MAX_CONCURRENT_SESSION_LIMIT = 8,
} NvstTimerEventType;

/// Struct storing data about timer event for the server.
typedef struct NvstTimerEvent_t
{
    /// Type of timer event
    NvstTimerEventType eventType;
    /// Time to session termination
    uint32_t timeLeftInSeconds;
} NvstTimerEvent;

/// Struct storing data about business logic event.
/// This kind of event is not interpreted by NVSC, but only passed through from the business logic on the server side.
typedef struct NvstBusinessLogicEvent_t
{
    /// Bifrost event details
    /// A zero-terminated string
    char* eventDetail;
} NvstBusinessLogicEvent;

/// Struct storing data about game session run with HDR mode or not.
typedef struct NvstHdrModeUpdateEvent_t
{
    /// HDR mode current game session is running with.
    NvstHdrMode hdrMode;
} NvstHdrModeUpdateEvent;

/// Struct storing certificate chain to be validated.
typedef struct NvstValidateCertificateEvent_t
{
    /// The PEM-formatted certificate chain to be validated
    char** certificateChain;
    /// Length of the certificate chain
    uint32_t length;
    /// Pointer to the result filled in by the client. If the result is non-zero, the certificate chain was valid
    uint32_t* result;
} NvstValidateCertificateEvent;

/// Enumeration of analytics event types.
typedef enum NvstAnalyticsEventSendType_t
{
    /// Analytics event is sent immediately.
    NVST_ANALYTICS_IMMEDIATE = 0,
    /// Analytics event when a range starts.
    NVST_ANALYTICS_RANGE_START = 1,
    /// A scheduled event when a range ends.
    NVST_ANALYTICS_RANGE_END = 2
} NvstAnalyticsEventSendType;

/// Struct describing an analytics hit.
typedef struct NvstAnalyticsEvent_t
{
    /// The hit category
    const char* category;
    /// The hit action
    const char* action;
    /// The hit label
    const char* label;
    /// The number of custom dimensions in the next arrays
    size_t customDimensionCount;
    /// The array of custom dimension names.  Array size must match customDimensionValues.
    const char** customDimensionNames;
    /// The array of custom dimension values.  Array size must match customDimensionNames.
    const char** customDimensionValues;
    /// The send type of the analytics event.
    NvstAnalyticsEventSendType sendType;
} NvstAnalyticsEvent;

/// Struct describing the server endpoints that need to be prioritized.
typedef struct NvstPrioritizeServerEndpointInfo_t
{
    // Endpoint information
    NvstServerEndpoint endpoints[NVST_PRIORITIZED_ENDPOINTS_COUNT];
} NvstPrioritizeServerEndpointInfo;

/// Struct for interface change event.
typedef struct NvstClientInterfaceChangeEvent_t
{
    /// The interface address on which packets are received.
    char address[NVST_MAX_ADDRESS_LENGTH];
} NvstClientInterfaceChangeEvent;

/// Union of input-event types.
typedef union NvstEventDataUnion_t
{
    /// Business logic event details (only passes through Stream SDK)
    NvstBusinessLogicEvent businessLogicEvent;
    /// Timer event details
    NvstTimerEvent timerEvent;
    /// Gamepad handling event details
    NvstGamepadHandlingEvent gamepadHandleEvent;
    /// Client connection change event details
    NvstClientConnectionChangeEvent clientConnectionChangeEvent;
    /// Haptic event details sent from server to client
    NvstHapticEvent hapticEvent;
    /// Validate certificate event sent from server to client
    NvstValidateCertificateEvent validateCertificateEvent;
    /// Analytics hit event sent from server to client
    NvstAnalyticsEvent analyticsEvent;
    /// Game Session runs with Hdr Mode value
    NvstHdrModeUpdateEvent hdrModeUpdateEvent;
    /// Event that publishes server endpoints to be prioritized.
    NvstPrioritizeServerEndpointInfo prioritizedEndpoints;
    /// Event with details of the network interface address on which streaming is happening
    NvstClientInterfaceChangeEvent interfaceChangeEvent;
    /// QoS requested change in the renderer's video dejitter buffer parameters.
    NvstClientDJBConfig djbConfig;
} NvstEventDataUnion;

/// Enumeration of NVST client event types.
typedef enum NvstClientEventType_t
{
    /// Event used for pass through.
    NVST_CE_BUSINESS_LOGIC_PASS_THROUGH = 2,
    /// Timer related event. \sa NvstTimerEventType
    NVST_CE_TIMER_MESSAGE_DEPRECATED = 3,
    /// Client connection is changed
    /// \todo Change to publish only connection status change GCC-2134
    NVST_CE_CONNECTION_CHANGE_EVENT = 5,
    NVST_CE_STREAMING_STATE_CHANGE_DEPRECATED = 6,
    /// Controller haptic event. \sa NvstHapticEventType
    NVST_CE_HAPTIC_GAMEPAD_EVENT = 7,
    NVST_CE_CONTROLLER_MAPPING_CHANGE_DEPRECATED = 8,
    /// Verify client certificate.
    NVST_CE_VALIDATE_CERTIFICATE = 10,
    /// Analytics event. \sa NvstAnalyticsEvent
    NVST_CE_ANALYTICS_EVENT = 12,
    /// HDR mode is updated.
    NVST_CE_GAME_SESSION_HDR_MODE_UPDATE = 13,
    /// This publishes the server endpoints. Applications like Android pass this into Modem
    /// settings to prioritize streaming traffic over other traffic.
    /// This event currently publishes only TCP control, UDP control and TCP input endpoint info.
    NVST_CE_PRIORITIZE_SERVER_ENDPOINTS_EVENT = 16,
    /// This event is published to indicate the network interface on which streaming is happening.
    /// It is sent at the start of session as well as at runtime if there is a change in interface.
    /// Applications are expected to map this address to the connection type(Ethernet/WiFi/4G etc.)
    /// and update the SDK using NVST_RUNTIME_PARAM_CONNECTION_TYPE
    NVST_CE_INTERFACE_CHANGE_EVENT = 18,
    /// This event is sent when QoS requests a change in the renderer's video dejitter buffer parameters.
    NVST_CE_ADJB_CONFIG_CHANGE_EVENT = 19,
    /// This event indicates that the signaling channel is ready to accept messages
    NVST_CE_SIGNALING_CHANNEL_READY = 20,
} NvstClientEventType;

/// Struct representing various NVST client events.
typedef struct NvstClientEvent_t
{
    /// Type of NVST client event
    NvstClientEventType type;
    /// NVST client event data details
    NvstEventDataUnion data;
} NvstClientEvent;

/// @}
