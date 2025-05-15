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

#pragma once

#if defined(__cplusplus)
extern "C"
{
#endif

    /// Struct representing a session parameter to pass to the server.
    typedef struct NvscSessionParams_t
    {
        /// Parameter name.
        char name[32];
        /// Parameter value.
        char value[1024];
    } NvscSessionParams;

    /// Struct representing encryption parameters for different streams.
    typedef struct NvscEncryptionConfig_t
    {
        /// Audio encyption value.
        bool audioEncryptionEnabled;
        /// Video encyption value.
        bool videoEncryptionEnabled;
        /// Control channel encyption value.
        bool controlChannelEncryptionEnabled;
    } NvscEncryptionConfig;

    /// Query NAT type parameters for the roaming case.
    ///
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] stunServer Stun Server to use to detect NAT type.
    /// \param[in] serverNetwork Current network type to determine whether roaming is in effect or not.
    /// \param[in,out] externalEndpoint external endpoint of the session.
    /// \param[in,out] natType NAT type paramater info.

    /// \retval NVST_R_INVALID_OBJECT if client is not a legitimate value.
    /// \retval NVST_R_INVALID_PARAM if the the number of parameters exceeds the size of the array provided.
    /// \retval NVST_R_NETWORK_ERROR if the client could not perform network operation.
    /// \retval NVST_R_SUCCESS otherwise.
    NVST_API NvstResult nvscClientGetNatType(
        NvstClient client,
        const char* stunServer,
        NvstServerNetwork serverNetwork,
        NvscSessionParams* externalEndpoint,
        NvscSessionParams* natType);

    /// Convenience typedef for library consumers.
    typedef NvstResult (*CLIENT_GET_NAT_TYPE)(
        NvstClient client,
        NvstServerNetwork serverNetwork,
        NvscSessionParams* externalEndpoint,
        NvscSessionParams* natType);

#if defined(__cplusplus)
}
#endif
