// Copyright (c) 2021-2022, NVIDIA CORPORATION.  All rights reserved.
//
// NVIDIA CORPORATION and its licensors retain all intellectual property
// and proprietary rights in and to this software, related documentation
// and any modifications thereto.  Any use, reproduction, disclosure or
// distribution of this software and related documentation without an express
// license agreement from NVIDIA CORPORATION is strictly prohibited.

#pragma once

#include <nvst/common/VideoDecodeUnit.h>
#include <stdbool.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    /// Get stats IDs.
    typedef enum NvstClientGetStatsId_t
    {
        /// Invalid ID.
        NVST_GET_STATS_NONE = 0,
        /// Video stats.
        NVST_GET_STATS_VIDEO = 1,
        /// Audio stats.
        NVST_GET_STATS_AUDIO = 2,
        /// Frame pacing stats.
        NVST_GET_STATS_FRAME_PACING = 3
    } NvstClientGetStatsId;

    /// Structure for retrieving Video stats.
    typedef struct NvstClientVideoStats_t
    {
        /// Video stream index to query the stats for.
        uint16_t streamIndex;
        /// The average video streaming rate from server to client.
        uint32_t averageStreamingRateKbps;
        /// Dynamic estimate of available bandwidth from server to client.
        uint32_t bandwidthAvailableKbps;
        /// The estimated bandwidth utilization percent from server to client.
        uint32_t bandwidthUtilizationPercent;
        /// The aggregate number of lost video IP packets from server to client.
        /// It is a cumulative number of lost packets since the start of streaming.
        uint32_t packetsLost;
        /// The estimated jitter from server to client in microseconds.
        /// It is a dynamic estimate of jitter on streaming video packets.
        uint32_t jitterUs;
        /// The estimated network round trip delay between server and client in milliseconds.
        uint32_t roundTripDelayMs;
        /// The aggregate number of video packets received on the client.
        /// It is a cumulative number which represents the number of packets received since the start of streaming.
        uint32_t totalPacketsReceived;
        /// The aggregate number of video packets dropped without getting received on the client.
        /// It is a cumulative number which represents the number of packets dropped since the start of streaming.
        uint32_t totalPacketsDropped;
        /// QEC: Total number of complete invalid reference frames received by the client.
        uint32_t totalInvalidFramesReceived;
        /// QEC: Total number of invalid reference frames displayed by the client.
        uint32_t totalInvalidFramesDisplayed;
        /// QEC: Number of consecutive frames lost in the last packet loss burst.
        uint32_t lastBurstframeLossCount;
        /// QEC: Number of invalid reference frames received by the client in the last burst.
        uint32_t lastBurstInvalidFramesReceived;
        /// QEC: Number of invalid reference frames displayed by the client in the last burst.
        uint32_t lastBurstInvalidFramesDisplayed;
        /// Current video streaming quality score [0-100].
        uint8_t qualityScore;
        /// Video streaming bandwidth score [0-100].
        /// Bandwidth score is computed based on bandwidth consumption.
        uint8_t bandwidthScore;
        /// Video streaming network loss score [0-100].
        /// Networkloss score is computed based on packet loss.
        uint8_t networkLossScore;
        /// Video streaming latency score [0-100].
        /// Latency score is computed based on round trip delay.
        uint8_t latencyScore;
    } NvstClientVideoStats;

    /// Structure for retrieving audio stats.
    typedef struct NvstClientAudioStats_t
    {
        /// The maximum observed buffering delay due to usage of jitter buffer.
        uint32_t gsJbMax;
        /// The median observed buffering delay due to usage of jitter buffer.
        uint32_t gsJbMedian;
    } NvstClientAudioStats;

    /// Structure for retrieving frame pacing stats.
    typedef struct NvstClientFramePacingStats_t
    {
        /// Stream index to query the stats for.
        uint16_t streamIndex;
        /// Recommended client frame queue size in microseconds.
        uint32_t targetQueueTimeUs;
        /// Recommended client frame drop threshold in microseconds.
        /// Frames that are queued for render longer than this interval
        /// should be discarded in favor of newer ones if available.
        uint32_t frameDropThresholdUs;
        /// Approximate upper bound of frame arrival jitter in microseconds.
        uint32_t frameArrivalJitterBoundUs;
    } NvstClientFramePacingStats;

    /// Structure consists of the stats which are meant to be retrieved from the StreamSDK.
    typedef struct NvstClientGetStats_t
    {
        NvstClientGetStatsId statsId;
        union
        {
            /// Stats related to Video (param = NVST_GET_STATS_VIDEO).
            NvstClientVideoStats videoStats;
            /// Stats related to Audio (param = NVST_GET_STATS_AUDIO).
            NvstClientAudioStats audioStats;
            /// Stats governing dynamic frame pacing (param = NVST_GET_STATS_FRAME_PACING).
            NvstClientFramePacingStats framePacingStats;
        };
    } NvstClientGetStats;

    /// Update stats IDs.
    typedef enum NvstClientUpdateStatsId_t
    {
        /// Invalid ID.
        NVST_UPDATE_STATS_NONE = 0,
        /// Video frame stats.
        NVST_UPDATE_STATS_VIDEO_FRAME = 1,
        /// Decoder FPS performance stats.
        NVST_UPDATE_STATS_DECODER = 2,
        /// Wi-Fi stats.
        NVST_UPDATE_STATS_WIFI = 3,
        /// Extended stats.
        NVST_UPDATE_STATS_EXTENDED = 4
    } NvstClientUpdateStatsId;

    /// Structure to update video frame stats.
    typedef struct NvstClientVideoFrameStats_t
    {
        /// Stream index.
        uint16_t streamIndex;
        /// Frame that is being updated.
        uint32_t frameNumber;
        /// The new state of the specified frame.
        /// \todo Refine the below comment.
        /// remarks
        /// Compressed video frames handed to the NvstVideoDecoder are considered to be
        /// 'in-flight'.  Depending on the result of the decode operation, each frame's
        /// state must be updated to NVST_FS_DECODE_COMPLETED or NVST_FS_DECODE_FAILED.
        /// For successfully decoded frames, state must be updated to
        /// NVST_FS_RENDER_COMPLETED after rendering is complete.
        /// This method MUST be invoked immediately after each frame is decoded and also
        /// immediately after it is rendered.  If state is NVST_FS_DECODE_SUCCESS or
        /// NVST_FS_RENDER_COMPLETED, the NvstClient uses the specified process-time
        /// along with the timestamp of this invocation to optimize the
        /// quality-of-service.  If state is NVST_FS_DECODE_FAILED, the NvstClient
        /// takes measures to to allow the NvstVideoDecoder to recover from the error.
        /// Behavior is undefined if frame state isn't updated as specified above.
        NvstVideoFrameState state;
        /// Decode or render process time in milliseconds.
        double processTimeMs;
        /// Frame size.
        uint32_t frameSize;
        /// Display latency in milliseconds.
        uint64_t displayLatencyMs;
        /// Check if BSP has frame stats support or not.
        /// If BSP support is there then we will get to know the exact eventTime when Surfaceflinger
        /// is going to pick up the frame.
        /// If BSP support is not there then will get the eventTime as the time when frame is queued.
        /// Currently, all the Shield devices have frame stats support.
        /// Hence, All the non-shield devices should set it to False.
        bool frameStatsSupported;
        /// Represents the time at which particular pipeline stage, execution is completed.
        long double eventTime;
        /// Bitmask of additional settings correlating to NvstVideoFrameState.
        /// \sa NvstClientTranscodeModeFlags
        uint32_t flags;
    } NvstClientVideoFrameStats;

    /// Structure to update decoder stats.
    typedef struct NvstClientDecoderStats_t
    {
        /// Associated stream index.
        uint16_t streamIndex;
        /// Decoder fps used for QEC decision.
        uint32_t decoderFps;
    } NvstClientDecoderStats;

    /// Structure in which the Client applications should update the stats of its WiFi interface.
    /// It is recommended for the client applications to update these values every 1 second.
    typedef struct NvstClientWifiStats_t
    {
        /// Network speed in Mbps.
        uint32_t networkSpeedMbps;
        /// Frequency of WiFi channel in MHz.
        long frequencyMhz;
        /// RSSI value of the network interface in dBm.
        /// This value can be negative.
        int rssi;
    } NvstClientWifiStats;

    /// Structure to update generic stats.
    /// These stats will be stored in the ETL on server.
    typedef struct NvstClientExtendedStats_t
    {
        /// Associated stream index.
        uint16_t streamIndex;
        /// Frame number at which stats were calculated.
        uint32_t frameNumber;
        /// Number of elements populated in data field.
        uint16_t count;
        /// Stats value.
        int16_t data[8];
    } NvstClientExtendedStats;

    /// Stats structure consists of the stats which are meant to be update into StreamSDK .
    typedef struct NvstClientUpdateStats_t
    {
        NvstClientUpdateStatsId statsId;
        union
        {
            /// Video frame stats (param = NVST_UPDATE_STATS_VIDEO_FRAME).
            NvstClientVideoFrameStats videoFrameStats;
            /// Decoder stats (param = NVST_UPDATE_STATS_DECODER).
            NvstClientDecoderStats decoderStats;
            /// Wi-Fi stats (param = NVST_UPDATE_STATS_WIFI).
            NvstClientWifiStats wifiStats;
            /// Extended stats (param = NVST_UPDATE_STATS_EXTENDED).
            NvstClientExtendedStats extendedStats;
        };
    } NvstClientUpdateStats;

    /// API to get stats.
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] stats parameter to retrieve.
    NVST_API NvstResult nvstGetStats(NvstClient client, NvstClientGetStats* stats);

    typedef NvstResult (*CLIENT_GET_STATS)(NvstClient client, NvstClientGetStats* stats);

    /// API to update stats.
    /// \param[in] client NvstClient obtained through nvstCreateClient().
    /// \param[in] stats parameter to update.
    NVST_API NvstResult nvstUpdateStats(NvstClient client, NvstClientUpdateStats* stats);

    typedef NvstResult (*CLIENT_UPDATE_STATS)(NvstClient client, NvstClientUpdateStats* stats);

#if defined(__cplusplus)
}
#endif
