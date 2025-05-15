// Copyright NVIDIA Corporation 2020-2021
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

#pragma once

#if defined(__cplusplus)
extern "C"
{
#endif

    /// \addtogroup SdkClientDiagnostics Client Diagnostics interface
    /// \ingroup SdkClientInterface
    /// @{

    /// Diagnostic parameter type IDs.
    typedef enum NvstClientDiagnosticParamId_t
    {
        /// Invalid runtime parameter ID.
        NVST_CLIENT_DIAGNOSTIC_NONE = 0,
        /// Folder to store client output.
        NVST_CLIENT_DIAGNOSTIC_OUTPUT_FOLDER = 1,
        /// Client network capture.
        NVST_CLIENT_DIAGNOSTIC_CLIENT_NETWORK_CAPTURE = 2,
        /// Record client stats.
        NVST_CLIENT_DIAGNOSTIC_RECORD_CLIENT_STATS = 3,
        /// Record client bitstream capture.
        /// Has to be set before calling nvstConnectToServer.
        NVST_CLIENT_DIAGNOSTIC_CLIENT_BITSTREAM_CAPTURE = 4,
        /// Record server bitstream capture.
        /// Has to be set before calling nvstConnectToServer.
        NVST_CLIENT_DIAGNOSTIC_SERVER_BITSTREAM_CAPTURE = 5,
        /// Server network capture.
        NVST_CLIENT_DIAGNOSTIC_SERVER_NETWORK_CAPTURE = 6,
        /// Record server etl trace file.
        NVST_CLIENT_DIAGNOSTIC_SERVER_TRACE_CAPTURE = 7,
    } NvstClientDiagnosticParamId;

    /// Struct storing flag to control client side network capturing.
    typedef struct NvstClientNetworkCapture_t
    {
        /// Enable/disable NvstClientNetworkCapture value.
        bool enable;
    } NvstClientNetworkCapture;

    /// Struct storing flag to control client side stats recording.
    typedef struct NvstRecordClientStats_t
    {
        /// Value of client stats.
        uint8_t value;
    } NvstRecordClientStats;

    /// Struct storing flag to control client side bitstream capture.
    typedef struct NvstClientBitstreamCapture_t
    {
        /// Value of client bitstream capture.
        uint8_t value;
    } NvstClientBitstreamCapture;

    /// Struct storing flag to control server side bitstream capture.
    typedef struct NvstServerBitstreamCapture_t
    {
        /// Value of server bitstream capture.
        uint8_t value;
    } NvstServerBitstreamCapture;

    /// Struct storing flag to control server side network capturing.
    typedef struct NvstServerNetworkCapture_t
    {
        /// Enable/disable NvstServerNetworkCapture value.
        bool enable;
    } NvstServerNetworkCapture;

    /// Struct storing flag to control server side etl trace files.
    typedef struct NvstServerTraceCapture_t
    {
        /// Value to control server side high performance trace capturing.
        uint16_t value;
    } NvstServerTraceCapture;

    /// Struct storing diagnostic session parameters.
    typedef struct NvstClientDiagnosticParam_t
    {
        /// ID of the parameter being set or queried.
        /// This defines how the rest of the structure is interpreted.
        NvstClientDiagnosticParamId paramId;

        union
        {
            /// Client data output folder.for stats, pcaps and event tracing files.
            /// (param = NVST_CLIENT_DIAGNOSTIC_OUTPUT_FOLDER).
            const char* outputFolder;
            /// (param = NVST_CLIENT_DIAGNOSTIC_CLIENT_NETWORK_CAPTURE).
            NvstClientNetworkCapture clientNetworkCapture;
            /// (param = NVST_CLIENT_DIAGNOSTIC_RECORD_CLIENT_STATS).
            NvstRecordClientStats recordClientStats;
            /// (param = NVST_CLIENT_DIAGNOSTIC_CLIENT_BITSTREAM_CAPTURE).
            NvstClientBitstreamCapture clientBitstreamCapture;
            /// (param = NVST_CLIENT_DIAGNOSTIC_SERVER_BITSTREAM_CAPTURE).
            NvstServerBitstreamCapture serverBitstreamCapture;
            /// (param = NVST_CLIENT_DIAGNOSTIC_SERVER_NETWORK_CAPTURE).
            NvstServerNetworkCapture serverNetworkCapture;
            /// (param = NVST_CLIENT_DIAGNOSTIC_SERVER_TRACE_CAPTURE).
            NvstServerTraceCapture serverTraceCapture;
        };
    } NvstClientDiagnosticParam;

    /// API to set diagnostic param
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] param parameter to set.
    NVST_API NvstResult nvstSetDiagnosticParam(NvstClient client, NvstClientDiagnosticParam* param);

    typedef NvstResult (*CLIENT_SET_DIAGNOSTIC_PARAMS)(NvstClient client, NvstClientDiagnosticParam* param);

    /// API to get diagnostic param
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] param parameter to get.
    NVST_API NvstResult nvstGetDiagnosticParam(NvstClient client, NvstClientDiagnosticParam* param);

    typedef NvstResult (*CLIENT_GET_DIAGNOSTIC_PARAMS)(NvstClient client, NvstClientDiagnosticParam* param);

    /// @}

#if defined(__cplusplus)
}
#endif
