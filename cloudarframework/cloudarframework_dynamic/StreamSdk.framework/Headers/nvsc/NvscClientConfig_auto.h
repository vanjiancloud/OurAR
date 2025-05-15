// Copyright (c) 2013-2020, NVIDIA CORPORATION.  All rights reserved.
//
// NVIDIA CORPORATION and its licensors retain all intellectual property
// and proprietary rights in and to this software, related documentation
// and any modifications thereto.  Any use, reproduction, disclosure or
// distribution of this software and related documentation without an express
// license agreement from NVIDIA CORPORATION is strictly prohibited.

/*!
 * THIS IS AUTOMATICALLY GENERATED FILE. DO NOT EDIT.
 * For any modifications, refer NvscClientConfig.xml
 */

#ifndef NVSC_CLIENT_CONFIG_AUTO
#define NVSC_CLIENT_CONFIG_AUTO

#include <nvst/client/AudioRenderer.h>
#include <nvst/client/ClientTypes.h>
#include <nvst/client/StreamClient.h>
#include <nvst/common/SharedTypes.h>
#include <nvst/common/VideoFormat.h>
#include <nvst/common/StreamConfig.h>
#include <nvst/common/StreamInternal.h>
#include <nvst/common/StreamConstants.h>
template <typename T>
struct MetaParams
{
    T min;
    T max;
};

/// Updates on how to enable packet pacing.
typedef enum NvscPacketPacingMode_t
{
    DISABLE_PACKET_PACING = 0,///< Disable packet pacing.
    ENABLE_DYNAMIC_PACKET_PACING = 1,///< Enable packet pacing dynamically.
    FORCE_ENABLE_PACKET_PACING = 2,///< User forced to enable the packet pacing from start of a session.
}NvscPacketPacingMode;


typedef struct NvscPacketPacing_t
{

    uint8_t version;///< Version of the dynamic packet pacing implementation.
    NvscPacketPacingMode mode;///< Specified packet pacing mode

    uint16_t numGroups;///< The number of groups that a video frame is divided for sending when packet pacing is enabled.

    uint16_t maxDelayUs;///< The maximum delay in micro seconds that is added to a group of packets after numGroupedPackets in packet pacing are sent in the same video frame.

    uint16_t minNumPacketsFrame;///< The minimum number of packets frame that is required to apply the packet pacing.

    uint32_t lossyFramePercMonitorTimeWindowMs;///< The lossy frame percentage monitor time window for enabling the packet pacing dynamically.

    uint16_t lossyFramePercThreshold;///< The lossy frame percentage threshold used for enabling the packet pacing dynamically.

    uint16_t packetLossPercThreshold;///< The packet loss percentage threshold used for enabling the packet pacing dynamically.

    uint16_t enableSmoothTransition;///< The flag controls packet pacing algorithm to allow smooth transition of packet pacing.
}NvscPacketPacing;


typedef struct NvscClientPerfBrControl_t
{

    uint8_t enable;///< Disable client perf bitrate control by default.

    uint8_t decodeAdjPercent;///< Adjustment factor for the client's decoder performance estimate.  Set to 0 to ignore this client estimate.

    uint8_t renderAdjPercent;///< Adjustment factor for the client's render performance estimate.  Set to 0 to ignore this client estimate.

    uint8_t stepPercent;///< Percentage of current bitrate to decrease if client performance is bad.

    uint32_t coolDownPeriodInMs;///< Minimum time between bitrate decreases.
}NvscClientPerfBrControl;


typedef struct NvscBWEstimator_t
{

    uint32_t iirFilterFactor;

    uint32_t owdSlidingWindowLengthInFrames;

    uint32_t minWaitToSendBWEtoServerInFrames;

    uint32_t rateLimitTriggerRatio;///< Qos rate limit is triggered when avgBitRate exceeds this threshold.

    uint32_t rateLimitRatio;///< The avg bitRate is limited to the percentage of BWE reported by client

    uint32_t rateLimitUtilizationTriggerRatio;///< Qos rate limit is triggered when utilization exceeds this threshold.

    uint32_t newQosConvergenceRate;///< This controls the step size which is used to converge to estimated BW.

    uint16_t stepUpLimitPercent;///< The maximum increase step size based on percentage of current streaming bitrate in 100 percent.

    uint8_t maxStepUpPercent;///< The maximum increase step size based on percentage of initial streaming bitrate in 100 percent.

    uint16_t stepDownPercent;///< The down step size for Qos bitrate in 100 percent.

    uint16_t lossyFrameHighThreshold;///< The lossy frame threshold used to halt bitrate increase.

    uint16_t lossyFrameLowThreshold;///< The lossy frame threshold used to reduce bitrate stepsize.

    uint16_t updatesPerSecond;///< The number of times that Qos bitrate can be increased in one second.

    uint8_t fecLimitForBitrateIncrease;///< The threshold for FEC percentage that limits bitrate increase for video stream.

    uint16_t reservedUplinkBandwidthKbps;///< The reserved bandwidth for uplink traffic.

    uint8_t useOwdCongestionControl;///< To enable Frame Rx duration based Bandwidth estimation and ignore OWD, which will be handled on the server Qos.

    uint8_t staticSceneEncUtilThreshold;///< Encoder utilization threshold to identify static scenes and skip bitrate increase. This feature is disabled by default GS 4.24 onward
}NvscBWEstimator;

/// Updates on how to use audio VBR mode.
typedef enum VbrModes_t
{
    AUDIOBITRATE_VBR_UNSUPPORTED = 0,///< Old client/server.
    AUDIOBITRATE_VBR_ALLOWED = 1,///< Old client/server.
    AUDIOBITRATE_VBR_FORCE_OFF = 2,///< User forced VBR mode off.
    AUDIOBITRATE_VBR_FORCE_ON = 3,///< User forced VBR mode on.
}VbrModes;


typedef struct NvscAudioBitrateSettings_t
{

    uint8_t adaptiveBitrateEnable;

    uint8_t bandwidthUsageLowLimit;

    uint8_t bandwidthUsageHighLimit;

    uint8_t uptickDivisor;

    uint16_t uptickThresholdMs;

    uint16_t local8chMin;

    uint16_t local8chMax;

    uint16_t local6chMin;

    uint16_t local6chMax;

    uint16_t local2chMin;

    uint16_t local2chMax;

    uint16_t remote8chMin;

    uint16_t remote8chMax;

    uint16_t remote6chMin;

    uint16_t remote6chMax;

    uint16_t remote2chMin;

    uint16_t remote2chMax;
    VbrModes VbrMode;///< Specified audio VBR mode
}NvscAudioBitrateSettings;

/// Struct storing details about mic audio settings.
typedef struct NvscMicAudioSettings_t
{

    uint8_t numChannels;///< Number of mic audio channels. Default is 1-channel mono.

    uint16_t channelMask;///< Mic Audio channel bitmask. Default is 1-channel mono.

    uint16_t version;///< Version of the mic audio implementation.

    uint8_t micSetupResultSuccess;///< RTSP setup status of mic audio. Boolean: 0 = not supported, 1 = supported, 2 = supported, but should be deferred.

    uint16_t frameSize;///< Mic packet size in ms

    uint16_t bitrate;///< Mic bitrate

    uint8_t enablePacketizer;///< if true enables Packetizer and disables FEC, if false disables Packetizer and disables FEC

    uint8_t numOfPacketToRetransmit;///< If packetizer is enable this fields configures number of packets that will be retransmitted
}NvscMicAudioSettings;

/// Struct storing details about surround audio settings.
typedef struct NvscAudioSurroundSettings_t
{

    uint8_t numChannels;///< Number of audio channels. Default is 2-channel stereo.

    uint16_t channelMask;///< Audio channel bitmask. Default is 2-channel stereo (left and right).

    uint8_t enable;///< Whether or not to enable surround audio.

    uint16_t version;///< Version of the surround audio implementation.

    uint16_t AudioQuality;///< Level of Audio Quality
}NvscAudioSurroundSettings;

/// Struct storing details about audio settings.
typedef struct NvscAudioSettings_t
{
    NvscAudioSurroundSettings surround;///< Surround audio settings
}NvscAudioSettings;

/// Available network transfer protocols for bitstream data.
/// \sa NvscServerEndpoint
typedef enum NvscTransferProtocol_t
{
    NVSC_TP_INVALID = -1,///< Not a valid transfer protocol.
    NVSC_TP_TCP,///< TCP transmission.
    NVSC_TP_RTP,///< RTP transmission.
    NVSC_TP_UDP,///< UDP transmission.
    NVSC_TP_WS,///< WS transmission.
    NVSC_TP_WSS,///< WSS transmission.
    NVSC_TP_NUM_PROTOCOLS,///< Not a valid transfer protocol.
}NvscTransferProtocol;

/// Struct storing details about remote input settings.
typedef struct NvscRiSettings_t
{
    NvscTransferProtocol protocol;///< Remote input protocol

    uint8_t usePartiallyReliableUdpChannel;///< Use partially reliable udp channel for remote input

    uint8_t timestampsEnabled;///< Enable timestamps for remote input

    uint8_t useMultipleGamepads;///< Use multiple gamepad format when sending gamepad event to the server.
}NvscRiSettings;

/// Struct storing details about runtime settings
typedef struct NvscRuntimeSettings_t
{

    uint8_t recordClientStats;///< Flag to control client side stats recording

    uint8_t recordServerStats;///< Flag to control server side stats recording

    uint8_t clientNetworkCapture;///< Flag to control client side network capturing

    uint8_t clientTraceCapture;///< Flag to control client side high performance trace capturing

    uint8_t serverNetworkCapture;///< Flag to control server side network capturing

    uint16_t serverTraceCapture;///< Flag to control server side high performance trace capturing

    uint32_t maxVerboseEtlSizeMb;///< Flag to indicate the maximum size of the trace capturing output ETL.

    uint32_t usePresentCompletedConfirmedTimestamp;///< Flag to indicate if present completed confirmed timestamp needs to be used instead of present completed.

    uint8_t mouseCursorCapture;///< Flag to control mouse capture

    uint8_t mimicRemoteCursor;///< Flag to control mimic remote cursor

    uint32_t mouseSettings[NVST_MSI_END];///< Stores mouse motion parameters- [0]: ballistics threshold1, [1]: threshold2, [2]: acceleration value, [3]: speed value

    uint8_t hapticsState;///< Flag to control state of haptics feature

    uint32_t maxVerboseGameEtlSizeMb;///< Flag to indicate the maximum size of the trace capturing game ETL.

    uint8_t audioSrtp;///< Flag to control state of audio encryption over SRTP feature

    uint8_t micSrtp;///< Flag to control state of mic encryption over SRTP feature

    uint8_t videoSrtp;///< Flag to control state of video encryption over SRTP feature

    char encryptionKey[512];///< Encryption key for control, audio, mic and video encryption.

    uint32_t encryptionKeyId;///< Encryption key ID for control, audio, mic and video encryption.

    uint16_t srtpReplayWindowSize;///< SRTP replay window size for replay attack protection.
}NvscRuntimeSettings;

/// Struct storing details about audio qos settings.
typedef struct NvscAudioQosSettings_t
{

    uint8_t enableAudioStats;///< Whether to enable/disable Audio stats 1 - enable 0 - disable

    uint32_t audioStatsUpdateIntervalMs;///< Time (ms) between Audio QOS stats sent to the server.

    uint32_t bitRate;///< Target Audio bitrate in CBR mode.

    uint32_t packetDuration;///< Target Audio Packet Duration in milli sec.

    uint32_t qosTrafficType;///< QoS Traffic type for audio which is used for DSCP setting in a flow.
}NvscAudioQosSettings;

/// Struct storing details about QoS score settings.
typedef struct NvscQosScore_t
{

    uint16_t networkStatsScoreUpdateTime;///< Time (ms) between network stats quality Score updates sent from the NVST to client

    uint8_t iirFilterFactor;///< This is the IIR filter coefficient used for Qos sciore calculation.

    uint16_t maxLatencyThresholdInMs;///< This is the maximum latency range for qos score calculation. Any latency higher or equal will get minimum score.

    uint8_t minLatencyThresholdInMs;///< This is the minimum latency range for qos score calculation. Any latency less or equal will get best score.

    uint8_t lowBandwidthUtilizationThreshold;///< This is the threshold to determine if network bandwidth is sufficient for current streaming rate.

    uint8_t bwuIirFilterFactor;///< This is the IIR filter coefficient used for smoothening Bandwidth utilization.
}NvscQosScore;


typedef struct NvscQecSettings_t
{

    uint32_t framesWithInvalidRefThreshold;///< Threshold for number of frames with invalid reference to be sent to decoder specific to QEC algorithm.

    uint32_t consecutiveFrameLostThreshold;///< Number of consecutive frames lost threshold specific to QEC algorithm.

    uint16_t lowDecoderFpsThreshold;///< Threshold for automatic application of QEC skip mode if the decoder FPS is lower than the given value.

    uint16_t multiLossThreshold;///< Threshold for numbers of frames lost after a frame with invalid reference that was recovered.

    uint16_t continuousGoodThreshold;///< Threshold for number of frames with invalid refence that were recovered by QEC.

    uint32_t mvxThreshold;///< Mean motion vector per macro-block in the X direction.

    uint32_t mvyThreshold;///< Mean motion vector per macro-block in the Y direction.

    uint32_t mvxyThreshold;///< Mean motion vector per macro-block in the XY direction.

    uint8_t intraMbPercentageThreshold;///< Threshold for percentage of intra macroblocks within the frame.
}NvscQecSettings;


typedef enum NvscTurboModeOverride_t
{
    NVSC_TURBO_MODE_NO_OVERRIDE = 0,///< Default Turbo Mode selection based on PM and SSAU decisions.
    NVSC_TURBO_MODE_FORCE_ON,///< Force Turbo Mode ON in NvStreamer. SSAU and SOPS still follow default selection logic.
    NVSC_TURBO_MODE_FORCE_OFF,///< Force Turbo Mode OFF in NvStreamer. SSAU and SOPS still follow default selection logic.
}NvscTurboModeOverride;

/// Struct storing settings for controlling the post-processing for RL bitrate model.
typedef struct NvscVqosRlInputPostprocessingSettings_t
{

    uint8_t enableBitrateDownLimitStaticScene;///< Enable limit on bitrate down step for static scenes

    uint8_t enableBitrateUpLimitMaxAvailableBw;///< Enable limit on bitrate up step for max available bandwidth

    uint32_t staticSceneUtilizationThesholdx1000;///< Utilization threshold for static scene

    uint16_t numFramesHighEncUtilThres;///< Number of frames that exceed the high encode util threshold

    uint16_t staticSceneThresFrames;///< Static scene thresold in number of frames

    uint16_t throttlingLimitScalex1000;///< Scaling factor to reduce the throttling limit being applied. If set to zero, this disables the throttling limit for RL bitrate
}NvscVqosRlInputPostprocessingSettings;

/// Struct storing settings for controlling the pre-processing of inputs for RL bitrate model.
typedef struct NvscVqosRlInputPreprocessingSettings_t
{

    uint8_t bweFilterFactor;///< IIR factor for server-side filtering of weighted Bandwidth estimation.

    uint8_t bwuFilterFactor;///< IIR factor for server-side filtering of weighted Bandwidth utilization.

    uint32_t frameDropPlWeightx1000;///< Weight on frame drop due to packet loss

    uint32_t frameDropPlThresholdPercent;///< Threshold on packet loss before the model starts to react.

    uint32_t frameDelayStutterToleranceMs;///< Tolerance for frame delay while computing frame drop estimate

    uint32_t owdFilterWeightx1000;///< Filter weight for OWD while computing normalized utilization time

    uint32_t peakFrameDelayToleranceMs;///< Tolerance for peak frame delay while computing normalized utilization time

    uint32_t minNormalizedUtilizationx10000;///< Minimum cap for normalized utilization time input

    uint32_t staticSceneEncUtilThresx1000;///< Threshold for encoder utilization to detect static scenes

    uint32_t highEncUtilWindowSize;///< Number of previous frames to  check for high encoder utilization before marking the current frame as non-static

    uint32_t maxUtilCapFrameDelayTolerancex1000;///< Maximum encoder utilization for frame delay tolerance

    uint32_t utilTimeFractionScalarx1000;///< Scalar multiplier for utilization time fraction

    uint32_t maxBwFilterFactor;///< Maximum BW filter factor

    uint32_t maxBwScaleFactorx1000;///< Scaling factor for maximum BW limit
}NvscVqosRlInputPreprocessingSettings;

/// Struct storing settings for manual mode of bitrate algorithm.
typedef struct NvscVqosRlBitrateManualModeSettings_t
{

    uint8_t enable;///< Enable manual mode to estimate bitrate when there is no qos feedback

    uint32_t thresholdL1;///< Threshold to enter L1 of manual mode bitrate, for TxRxLag (in number of frames)

    uint32_t thresholdL2x1000;///< Threshold to enter L2 to manual mode, in terms of fraction of starting bitrate (x1000 since float values are not supported)

    uint32_t thresholdL3;///< Threshold to enter L3 of manual mode bitrate, for TxRxLag (in number of frames)

    uint32_t maxFramesL3;///< Max number of frames to remain in L3 stage of manual mode bitrate

    uint32_t decayFactorL1x1000;///< Decay factor for L1 stage of manual mode (x1000 since float values are not supported)

    uint32_t decayFactorL2x1000;///< Decay factor for L2 stage of manual mode (x1000 since float values are not supported)
}NvscVqosRlBitrateManualModeSettings;

/// Struct storing settings for early update mode.
typedef struct NvscVqosRlEarlyUpdateSettings_t
{

    uint16_t bitrateThreshold;///< Threshold for bitrate early update condition

    uint16_t fecThreshold;///< Threshold for FEC early update condition

    uint16_t minimumDistance;///< Minimum distance between two frames having early update mode

    uint16_t cummRxGapThresMs;///< Threshold for cumulative gap of received frames to trigger early update

    uint16_t frameDropPlThres;///< Threshold for number of frames dropped with packet loss to trigger early update
}NvscVqosRlEarlyUpdateSettings;


typedef enum NvscVqosRlLibrary_t
{
    NVSC_VQOS_RL_LIBRARY_TENSORRT = 0,///< Use TensorRT library
    NVSC_VQOS_RL_LIBRARY_PYTHON = 1,///< Use Python library (only for local builds)
}NvscVqosRlLibrary;


typedef enum NvscVqosRlFecProfile_t
{
    NVSC_VQOS_RL_FEC_PROFILE_DEFAULT = 0,///< Enable default fec profile
}NvscVqosRlFecProfile;


typedef enum NvscVqosRlBitrateProfile_t
{
    NVSC_VQOS_RL_BITRATE_PROFILE_DEFAULT = 2,///< Enable default bitrate profile
}NvscVqosRlBitrateProfile;


typedef enum NvscVqosRlFeatures_t
{
    NVSC_VQOS_RL_DISABLED = 0x0,///< Disable all RL features
    NVSC_VQOS_RL_BITRATE = 0x1,///< Enable bitrate model
    NVSC_VQOS_RL_FEC = 0x2,///< Enable FEC model
}NvscVqosRlFeatures;

/// Struct storing settings for adaptive QoS using RL.
typedef struct NvscVqosRlSettings_t
{
    NvscVqosRlFeatures features;///< Flags to enable individual RL features
    NvscVqosRlBitrateProfile bitrateProfile;///< Option to control which bitrate profile to use
    NvscVqosRlFecProfile fecProfile;///< Option to control which fec profile to use
    NvscVqosRlLibrary library;///< Option to control which backend library to use

    uint16_t bitrateUpdateFrequency;///< Number of frames between two model updates for bitrate

    uint32_t minimumModelInputBufferOccupancy;///< Minimum size of non-zero data in the RL input buffer required to start running the model inference

    uint32_t bitrateMinActionKbps;///< Minimum action for bitrate model

    uint32_t bitrateMaxActionKbps;///< Maximum action for bitrate model

    uint32_t txRxLagIIRFactorx1000;///< IIR filter factor for average TxRxLag (x1000 since float values are not supported)

    uint8_t enableWeightedBwe;///< Option to enable the weighted bandwidth estimation.

    uint32_t weightedBwePlPercentThres;///< Packet loss threshold for weighted bwe calculation.
    NvscVqosRlEarlyUpdateSettings earlyUpdate;///< Settings for early update mode
    NvscVqosRlBitrateManualModeSettings bitrateManualMode;///< Settings for manual mode of bitrate algorithm
    NvscVqosRlInputPreprocessingSettings preprocessing;///< Settings for controlling the pre-processing of inputs for RL bitrate model
    NvscVqosRlInputPostprocessingSettings postprocessing;///< Settings for controlling the pout-processing for RL bitrate model

    uint8_t enableFeedback;///< Option to enable the RL feedback from client to the server.

    uint32_t feedbackVersion;///< Version of RL feedback structure being sent by client.

    uint8_t serverLogging;///< Whether or not the server dumps the RL input/data data to local log files. Only for internal debugging.

    uint8_t modelInputLogging;///< Whether or not the server dumps the RL model input/output data data to local csv files. Only for internal debugging.
}NvscVqosRlSettings;

/// Struct storing details about BLL-FEC settings.
typedef struct NvscBllFecSettings_t
{

    uint8_t enable;///< Whether or not to use the alternative Video QoS forward error correction.

    uint8_t adaptiveActivation;///< Whether or not to use adaptive logic for BLL-FEC increases at frame losses.

    uint8_t adaptiveActivationThresholdX100;///< Value for EMA (x100) of complete frame received at which QoS starts adapting FEC.

    uint8_t isWindowLengthFixed;///< Denotes whether the size of the window of loss observations used by BLL-FEC is fixed or dynamically adapted.

    uint16_t minWindowSize;///< Minimum window size for holding loss observations, from which the FEC protection target is extracted at runtime. Also used as the initial window size.

    uint16_t maxWindowSize;///< Maximum window size for holding loss observations, from which the FEC target is extracted at runtime. BLL-FEC will never look further in the past than this count of frames when deciding target FEC.

    uint32_t defaultBll;///< Default FEC protection intensity expressed in count Bytes.

    uint8_t repairMinPercent;///< Denotes the minimum FEC percent to be applied given the numSrcPackets for current frame.

    uint8_t minRequiredFecPackets;///< Minimum number of FEC repair packets to use per frame.

    uint16_t maxAllowedFecPackets;///< Maximum allowed number of FEC repair packets to use per frame.

    uint32_t numSrcPackets;///< Number of source packets that will be given to the FEC Encode block.

    uint8_t preserveBitrateWindowSizePercent;///< Threshold percent of difference of max and min window size below which the FEC overhead will not be accounted for in the proposed encoder rate. Set to 0 to disable the functionality.

    uint32_t skipBitrateIncreaseThresholdBytes;///< Threshold of BLL-FEC's target FEC intensity above which we decide to skip bitrate increase.

    uint8_t adjustEncoderBitrateForMinMaxFecPackets;///< Adjust encoder target bitrate according to minimum required and maximum allowed FEC packets.
}NvscBllFecSettings;

/// Struct storing details about fec settings.
typedef struct NvscFecSettings_t
{

    uint8_t enable;///< Whether or not to use Video QoS forward error correction.

    uint8_t adaptiveActivation;///< Whether or not to use adaptive logic for FEC increases at frame losses, default is disabled.

    uint8_t adaptiveActivationThresholdX100;///< Value for EMA (x100) of complete frame received at which QoS increases percent FEC, default is 95

    uint8_t maxStepsPerFecIncrement;///< Increment FEC repair percenet in steps. Maximum number of steps per FEC increment, default is disabled.

    uint32_t numSrcPackets;///< Number of source packets that will be given to the FEC Encode block.

    uint32_t repairPercent;///< FEC repair percent.

    uint32_t repairMaxPercent;///< FEC repair max percent.

    uint32_t repairMinPercent;///< FEC repair min percent.

    uint8_t minRequiredFecPackets;///< Minimum number of FEC repair packets to use per frame. Supercedes the repairMaxPercent setting.

    uint16_t maxAllowedFecPackets;///< Maximum number of FEC repair packets to use per frame. Supercedes the repairMaxPercent setting.

    uint16_t minPacketLossThreshold;///< The minimum number of packets in a frame to impact FEC percent.

    uint16_t rateDropWindow;///< The period in seconds after which FEC rate can be lowered.

    uint8_t adjustEncoderBitrateForMinMaxFecPackets;///< Adjust encoder target bitrate according to minimum required and maximum allowed FEC packets.
}NvscFecSettings;


typedef enum SmartIntraRefreshPattern_t
{
    SMART_IR_SINGLE_RATE = 1,///< Single rate refresh
    SMART_IR_DOUBLE_RATE = 2,///< Double rate refresh
    SMART_IR_TRIPLE_RATE = 3,///< Triple rate refresh
    SMART_IR_QUAD_RATE = 4,///< Quad rate refresh
}SmartIntraRefreshPattern;


typedef enum intraRMode_t
{
    INTRA_STATIC_MODE = 0x01,///< Intra Refresh is enabled throughout the session
    INTRA_DYNAMIC_MODE = 0x02,///< Intra Refresh is enabled when the network is bad
    INTRA_RECOVERY_MODE = 0x04,///< Intra Refresh is enabled when session enters recovery mode
}intraRMode;

/// Struct storing details about Intra Refresh settings.
typedef struct NvscVqosIntraR_t
{

    uint32_t length;///< Configure the length of Intra Refresh across frames.

    uint32_t period;///< Configure the period for which Intra Refresh should be generated.

    uint8_t maxScalingFactor;///< Configure the max intra refresh scaling factor for intra refresh period and length.

    uint32_t coolDownPeriodMs;///< Configure the period after which Intra Refresh will step down its length and period.

    uint8_t enableSmartIntraRefresh;///< Enable/Disable Smart Intra refresh feature. by default it will be disabled.
    intraRMode mode;///< This flag enables intra refresh only in bad network conditions

    uint16_t frameLossThreshold;///< Minimum frame loss required to trigger IR param change.

    uint16_t frameLossWindowSize;///< Number of past frames to be considered for frame loss threshold.

    uint16_t txRxLagThresholdInMs;///< Minimum TxRxlag required to trigger IR param change.
    SmartIntraRefreshPattern smartIntraRefreshPatternType;///< Flags to select Smart intra refresh pattern
}NvscVqosIntraR;

/// Struct storing details about QP Grouping settings.
typedef struct NvscVqosQpGrouping_t
{

    uint8_t enable;///< Disable QP Grouping by default.

    uint8_t maxQp;///< QPG won't target minQp values higher than this setting. Minimum value is taken from the video[streamIndex].minQp setting.

    uint32_t coolDownPeriodInMs;///< Minimum time between minQp adjustments.
}NvscVqosQpGrouping;


typedef enum DfcVersion_t
{
    DFC_ALGO_VERSION_1 = 1,///< Default DFC algorithm where streaming FPS is lowered from maxFPS (120) to minFPS (60) after which resolution downgrade is applied
    DFC_ALGO_VERSION_2 = 2,///< This DFC algorithm allows immediate resolution downgrade upon poor client decode/render perf
}DfcVersion;

/// Struct storing details about video QoS DFC settings.
typedef struct NvscVqosDfc_t
{

    uint8_t enable;///< Disable video QoS DFC by default.

    uint8_t adjustResAndFps;///< Adjust streaming resolution and FPS as part of DFC algo.

    uint8_t maxResLevels;///< Max number of DFC resolution table entries to create.

    uint8_t useAdaptiveQp;///< Use adaptive QP - dynamically adjust QP thresholds based on resolution, frequency, and bitrate.

    uint8_t minTargetFps;///< Minimum streaming FPS to target if the resolution is above a certain resolution level (for ex: 720p for DFC V2.0) or if it isn't at the lowest allowed level.

    uint8_t lowResMinTargetFps;///< Minimum streaming FPS to target below a certain resolution level (for ex: from 720p for DFC V2.0) or when the resolution is already as low as possible. Can allow lower framerates as a final effort to maintain video quality.

    uint8_t highResMinClientFps;///< Minimum fps threshold for client perf (decoder, render) at resolutions > 720p
    DfcVersion dfcAlgoVersion;///< Setting to select variant of DFC algorithm

    uint8_t decodeFpsAdjPercent;///< Scaling percentage applied to the client's decoder FPS capability estimate. Set to 0 to ignore this client estimate when adjusting target framerate.

    uint8_t renderFpsAdjPercent;///< Adjustment percentage applied to the client's render FPS capability estimate. Set to 0 to ignore this client estimate when adjusting target framerate.

    uint8_t clientFpsDecreasePercent;///< Percentage FPS decrease used to update the target streaming FPS ceiling based on client performance.

    uint8_t clientFpsIncreasePercent;///< Percentage FPS increase used to update the target streaming FPS ceiling based on client performance.

    uint8_t clientFpsMinStep;///< Minimum FPS ceiling adjustment step to take in response to client performance feedback.

    uint8_t fpsDecreasePercent;///< Percentage decrease used to update target streaming FPS based on encoder performance as measured by QP.

    uint8_t fpsIncreasePercent;///< Percentage increase used to update target streaming FPS based on encoder performance as measured by QP.

    uint8_t fpsStepSizeMin;///< Minimum FPS step by which to adjust target stream FPS. Useful for low frequencies or implementing fixed size steps.

    uint8_t qpMaxUpperLimit;///< Max allowed adaptive QP upper threshold.

    uint8_t qpMinUpperLimit;///< Min allowed adaptive QP upper threshold.

    uint8_t qpLowerLimit;///< Lower QP threshold below which DFC will attempt to raise the fps or streaming resolution.

    uint8_t qpMaxResThresholdAdj;///< Value by which the upper QP threshold will be adjusted, only for the maximum resolution level.

    uint32_t minGoodMsBeforeUpgrade;///< Minimum time we must remain at max FPS before considering a res upgrade. Helps prevent upgrades due to a few good frames.

    uint32_t upgradeCooldownMs;///< Cooldown period DFC must wait after res change before upgrading res.

    uint32_t downgradeCooldownMs;///< Cooldown period DFC must wait after res change before downgrading res.

    uint16_t ceilingUpCooldownMs;///< Time to wait after a ceiling FPS change before it can be raised.

    uint16_t ceilingDownCooldownMs;///< Time to wait after a ceiling FPS change before it can be lowered.

    uint16_t targetUpCooldownMs;///< Time to wait after a target FPS change before it can be raised.

    uint16_t targetDownCooldownMs;///< Time to wait after a target FPS change before it can be lowered.

    uint8_t initFpsIncreasePercent;///< Percentage between min and max values used for initializing targetFps.

    uint16_t promoteResolutionCoolingTimeMs;///< Adaptive QP cooling time (in ms) for promoting resolution if QP stays at low level.
}NvscVqosDfc;

/// Enabled performance history categories.
typedef enum NvscPerfHistoryFeature_t
{
    DISABLE_PERF_HISTORY = 0x0,///< Empty mask means don't run perf history logic.
    ENABLE_DECODER_PERF_HISTORY = 0x1,///< Use decoder performance history in resolution upgrade logic.
    ENABLE_RENDER_PERF_HISTORY = 0x2,///< Use render performance history in resolution upgrade logic.
}NvscPerfHistoryFeature;

/// Struct storing details about video QoS Performance History settings.
typedef struct NvscVqosPerfHistory_t
{

    uint16_t iirFilterFactor;///< IIR filter factor for computing filtered values of performance history inputs (ex. decoder time, render time).

    uint32_t minNumSamples;///< Minimum number of performance samples needed to stop a resolution upgrade to particular resolution/fps combination.

    uint32_t resetTimerMs;///< Time to wait after a resolution downgrade before that resolution's performance stats are forgotton. Set to 0 to disable the timer.

    uint16_t fpsUpgradePct;///< Percentage of new FPS to use when determining if new resolution/fps is supportable. Allows for some performance headroom / hysteresis.
    NvscPerfHistoryFeature featureMask;///< This is to control various categories of performance history tracking.
}NvscVqosPerfHistory;

/// Struct storing details about video QoS settings for client performance monitoring.
typedef struct NvscVqosClientPerformanceMonitor_t
{

    uint8_t flags;///< Disable video Qos client performance monitoring feature by default.

    uint16_t resolutionUpdateCoolDownCount;///< This is the number of frames that CPM waits before it resumes monitoring client's performance.

    uint16_t avgBeginTimeThresholdMs;///< This is the begin time threshold for new method.

    uint16_t avgDecodeTimeThresholdFactor;///< This is the decode time threshold scaling factor for CPM.

    uint16_t maxFrameBeginTimeMs;///< This is the begin time clipping upper limit.

    uint16_t maxFrameDecodeTimeFactor;///< This is the decode time clipping upper limit scaling factor.

    uint16_t iirFilterFactor;///< IIR filter factor for computing filtered values of client decoder, render fps capabilities).
}NvscVqosClientPerformanceMonitor;

/// Struct storing details about Qos GRC settings
typedef struct NvscVqosGrc_t
{

    uint8_t enable;///< Whether GRC is enabled or not

    uint8_t supported;///< Whether GRC is supported by the client or not

    uint16_t stepUpIntervalInFrames;///< Number of frames we should wait after stepping up before stepping again

    uint16_t stepUpWidth;///< Difference in width to use between resolution step ups

    uint16_t stepDownIntervalInFrames;///< Number of frames we should wait after stepping down before stepping again

    uint16_t stepDownWidth;///< Difference in width to use between resolution step downs
}NvscVqosGrc;

/// DRC table type.
typedef enum DrcTableType_t
{
    DRC_TABLE_TYPE_DYNAMIC = 1,///< Dynamically generate DRC resolutions based on the requested max resolution.
    DRC_TABLE_TYPE_STATIC = 2,///< Force usage of the static/hardcoded DRC table.
}DrcTableType;

/// Struct storing details about video QoS DRC settings.
typedef struct NvscVqosDrc_t
{

    uint8_t enable;///< enable video QoS DRC by default.
    DrcTableType tableType;///< Controls DRC table generation, i.e. static vs. dynamic.

    uint8_t iirFilterFactor;///< Factor of IIR filter in video QoS QP-based DRC.

    uint16_t bitrateIirFilterFactor;///< Factor of IIR filter for video QoS bitrate filtering, including the input to dynamic QP threshold calculations.

    uint8_t minQpHeadroom;///< Minimum QP headroom required for resolution upgrade.

    uint8_t updateCoolingTime;///< Cooling time (in sec) for updating resolution in video QoS QP-based DRC.

    uint8_t promoteCoolingTime;///< Cooling time (in sec) for promoting resolution if QP stays at low level.

    uint8_t lowerQpThreshold;///< With QP lower than this threshold, game content is easy to encode.

    uint8_t upperQpThreshold;///< With QP higher than this threshold, game content is hard to encode.

    uint8_t minAdaptiveQpThreshold;///< Lower bound of adaptive QP threshold that takes into account bpp.

    uint8_t qpMaxResThresholdAdj;///< Value by which the upper QP threshold will be adjusted, only for the maximum resolution level.

    uint16_t downgradeCostLength;///< DRC cost calculation filter length (in frames). Set it to 0 to disable DRC cost-based calculations.

    uint32_t downgradeCostX1000;///< For DRC cost calculations, this is the cost due to the reconfiguration discontinuity (x1000).

    uint32_t downgradeCostLowResMultX1000;///< For DRC cost calculations, this is the cost multiplier for changes at low resolutions (x1000).

    uint16_t lowEncoderUtilizationThreshold;///< This is the encoder utilization threshold to identify static scene.

    uint8_t minRequiredBitrateCheckEnabled;///< This is to check for average target bitrate to be greater than minimum required bitrate before doing a resolution upgrade.

    uint8_t stepDownResolutionAlignment;///< Value set by client to ensure DRC stepdown resolutions are multiple of this

    uint16_t stepDownMinHeight;///< Value set by client to request server to support lower step down resolutions

    uint16_t stepDownTargetAspectRatioX100;///< Value set by client for server to round up/down the resolution to be multiple of stepDownResolutionAlignment (x100)

    uint8_t add1440pResLevelFor4kDrcTable;///< This is to add 1440p resolution as intermediate DRC level for 4K DRC table. It is disabled by default
}NvscVqosDrc;

/// Struct storing details about video QoS bad network settings.
typedef struct NvscVqosBadNetwork_t
{

    uint32_t notifyUpBoundThreshold;///< message send out upper boundary threshold.
}NvscVqosBadNetwork;

/// Configurations for different versions of TxRxLag bitrate control module
typedef struct NvscTxRxLagModule_t
{

    uint8_t moduleVersion;///< Feature toggle between legacy and refactored (default) algo for TxRxLag

    uint32_t maxIncreaseThreshold;///< Used to limit streaming bitrate when Tx Rx Lag increase exceeds this threshold.

    uint32_t minFeedbackTxDeltaMs;///< Minimum time window of sent feedbacks to detect 0 frame increase

    uint8_t countLowFbFrameDelta;///< Consecutive count of low feedback frame number delta to skip increasing bitrate

    uint32_t maxFeedbackSilenceMs;///< Time threshold for silence of client qos feedbacks to drop bitrate
}NvscTxRxLagModule;

/// Struct storing details about video QoS bandwidth settings.
typedef struct NvscVqosBandwidth_t
{

    uint32_t flags;///< Flags that define behavior of video bandwith QoS.

    uint32_t maximumBitrateKbps;///< maximum allowed bitrate in kbps.
    MetaParams<uint32_t> maximumBitrateKbpsMetaParams;

    uint32_t minimumBitrateKbps;///< minimum allowed bitrate in kbps.
    MetaParams<uint32_t> minimumBitrateKbpsMetaParams;

    uint32_t minimumEncoderBitrateKbps;///< minimum allowed encoder bitrate in kbps.
    MetaParams<uint32_t> minimumEncoderBitrateKbpsMetaParams;

    uint32_t statsTime;///< stats time (number of milliseconds to wait before sending stats to the server).

    uint32_t lossThreshold;///< loss threshold (loss rate below which no QoS adjustment is to be done).

    uint32_t jitterThresholdUs;///< Jitter above which we need to skip increasing video bitrate.

    uint8_t maxBitrateScalePercent;///< Percentage used to scale the client's requested max bitrate. Given as a percentage of the default value. Only applied if uiAutoMode is set.
    MetaParams<uint8_t> maxBitrateScalePercentMetaParams;

    uint32_t checkBwThrottlingIntervalMs;///< Time interval in milliseconds to check for network bandwidth throttling

    uint8_t bwThrottlingThresholdPercent;///< Bandwidth throttling detection threshold percentage

    uint32_t minThrottlingCoolingTime;///< Minimum cooling time (in sec) for capping bitrate when throttling is detected

    uint16_t throttlingBitrateCapIncreasePercent;///< After throttling cooling time is complete, stepsize used to relax bitrate cap

    uint32_t rtpStatsTime;///< RTP stats time (number of frames to wait before sending stats to the server).

    uint8_t maxBitrateScalePercentL1;///< Percentage used to scale client's requested max bitrate for resolution level1.

    uint8_t maxBitrateScalePercentL2;///< Percentage used to scale client's requested max bitrate for resolution level2 and beyond.
    NvscTxRxLagModule txRxLag;///< TxRxLag bitrate control module settings
}NvscVqosBandwidth;

/// Struct storing details about video QoS settings.
typedef struct NvscVideoQosSettings_t
{
    NvscVqosBandwidth bw;///< Used to describe the video Qos bandwidth parameters.
    NvscVqosBadNetwork bn;///< Used to describe the video Qos bad network parameters.
    NvscVqosDrc drc;///< Used to describe the video Qos DRC parameters.
    NvscVqosGrc grc;///< Describes parameters to gradually change resolutions
    NvscVqosClientPerformanceMonitor cpm;///< Describe the video Qos parameters for monitoring client performance.
    NvscVqosPerfHistory perfHistory;///< Describes performance history settings, used to help determine if client performance can handle upgrading the resolution.
    NvscVqosDfc dfc;///< Used to describe the video Qos DFC parameters.
    NvscVqosQpGrouping qpg;///< Used to describe QP Grouping (QPG) settings. QP Grouping aims to reduce streaming by dynamically adjusting the encoder's minQp knob to prevent quick downward spikes in QP / increases in frame size.
    NvscVqosIntraR intraR;///< Used to configure Intra refresh feature
    NvscFecSettings fec;///< FEC Configuration Settings
    NvscBllFecSettings bllFec;///< BLL-FEC Configuration Settings
    NvscVqosRlSettings rl;///< Settings for adaptive QoS algorithm using Reinforcement Learning
    NvscTurboModeOverride turboMode;///< Turbo Mode (high-FPS streaming) override knob to force enable or disable the feature in NvStreamer.

    uint16_t fpsPeriodMsEstimate;///< Period over which the streaming FPS estimate is computed for Turbo Mode or DFC.

    uint16_t minStreamFpsEstimate;///< Minimum streaming FPS estimate to use for Turbo Mode or DFC.

    uint16_t maxStreamFpsEstimate;///< Maximum streaming FPS estimate to use for Turbo Mode or DFC.

    uint32_t periodicRefreshIntervalMs;///< Time in milliseconds between two periodic refresh requests. NVSC has a feature to periodically request an IDR or Intra-refresh from the server. Set to 0 to disable.

    uint32_t arbitraryRefreshIntervalMs;///< Time in milliseconds between two arbitrary refresh requests. Client may request at any time to get a picture refresh, but NVSC needs to prevent overtly frequent requests.

    uint32_t videoQualityScoreUpdateTime;///< Time (ms) between Quality Score updates sent from the server.

    uint32_t qosTrafficType;///< QoS Traffic type for video which is used for DSCP setting in a flow
    NvstVideoFormat bitStreamFormat;///< Bit stream format used by video encoder.

    uint8_t enableQec;///< If set then server will generate additional stats from encoder and run QEC logic
    NvscQecSettings qec;///< Settings to control QEC feature.

    uint32_t startupResolutionHoldTimeMs;///< Time (ms) at start of session that Qos will prevent any resolution changes. Helps prevent overreacting to any startup glitches, ex. initial poor client performance reports.

    uint32_t maxQosFeedbackVersion;///< Highest supported qos feedback version.

    uint32_t maxQosTimingsVersion;///< Highest supported qos client timings version.

    uint32_t maxQosBolbStatsVersion;///< Highest supported qos blob stats version.

    uint16_t highOwdJumpTriggerThreshold;///< Threshold after which OWD spike is considered as OWD jump, expressed as a percentage of the frame duration(16.66 for 60fps)

    uint32_t highOwdJumpDropThresholdMs;///< Trigger bitrate decrease if there are OWD jumps which last longer than this threshold

    uint32_t consFramesWithHighOwdThresholdMs;///< Trigger bitrate decrease if there is consecutive frames with High OWD exceeds this threshold in ms

    uint32_t highOwdThresholdUs;///< For Owd Congestion Control algo, Owd above threshold is considered as High Owd in micro seconds

    uint32_t owdBitrateDropMultiplierPercent;///< Final Owd CC algo bitrate reduction percent will be multiplied by this percentage. Then capped by bwe.stepDownPercent

    uint32_t owdSkipThresholdMs;///< Skips bitrate increase if Owd crosses this threshold for the frame

    uint8_t qosServiceIirCoefficient;///< IIR filter coefficient to estimate cadence of Qos service
}NvscVideoQosSettings;

/// Settings for dynamic packet size.
typedef struct NvscDynamicPacketSize_t
{

    uint8_t enable;///< Enable or disable dynamic packet size feature.

    uint32_t frameSizeL0ThresholdBytes;///< Level 0 frame size threshold. It is total frame send size which includes the FEC data also.

    uint32_t packetSizeL0;///< Maximum allowed packet size for frames with packet count less than level 0 threshold. Also includes 16 bytes of RTP extention header

    uint32_t frameSizeL1ThresholdBytes;///< Level 1 frame size threshold. It is total frame send size which includes the FEC data also.

    uint32_t packetSizeL1;///< Maximum allowed packet size for frames having size less than level 1 threshold. Also includes 16 bytes of RTP extention header.
}NvscDynamicPacketSize;

/// Settings for max packet size allowed detection.
typedef struct NvscMaxPacketSizeDetection_t
{

    uint8_t enable;///< Enable or disable max packet size detection.

    uint32_t minNumFrames;///< Minimum number of frames packet loss rate data required to detect the max packet size allowed.

    uint32_t packetLossRate;///< Packet loss rate used to detect the max packet size allowed.
}NvscMaxPacketSizeDetection;

/// Settings for dumping uncompressed input video frames.
typedef struct NvscVideoFrameDumpSettings_t
{

    uint8_t enabled;///< Enable video frame dumping.

    uint16_t memoryUsage;///< MiB's of server system memory to be used to store the frame ring buffer.

    uint16_t capturePeriod;///< Period in which frames are captured. Use 1 to capture all frames, 2 for every-other, etc.

    uint16_t downsampleFactor;///< Downsample scale factor to capture frames. Use 1 for full-size, 2 for half-size, etc.
}NvscVideoFrameDumpSettings;

/// Settings for dumping uncompressed input video frames when exiting.
typedef struct NvscExitVideoFrameDumpSettings_t
{

    uint8_t disabled;///< Disable video frame dumping.
}NvscExitVideoFrameDumpSettings;

/// Settings for dumping uncompressed input video frames.
typedef struct NvscVideoRawFrameDumpSettings_t
{

    uint8_t enabled;///< Enable video frame dumping.

    uint16_t numFrames;///< Number of frames to record.
}NvscVideoRawFrameDumpSettings;

/// Configures frame pacing's PID controller.
typedef struct Pid_t
{

    uint32_t kP;///< Proportional term of PID controller (multiplied by 1000, since there's no support for float fields.

    uint32_t kI;///< Integral term of PID controller (multiplied by 1000, since there's no support for float fields).

    uint32_t kL;///< Maximum allowed accumulation limit for kI (multiplied by 1000, since there's no support for float fields).

    uint32_t targetFrameTimeUs;///< Target video frame time (in microseconds).

    uint32_t minTargetFrameTimeUs;///< Minimum target video frame time (in microseconds).

    uint32_t maxTargetFrameTimeUs;///< Maximum target video frame time (in microseconds).

    uint32_t allowedDeviation;///< Maximum allowed deviation from target frame time (in per milles).

    uint32_t targetQueueTimeUs;///< Target queue time for video frames (in microseconds). Set to 0 to use adaptative target queue time based on frame arrival jitter history.
}Pid;


typedef enum NvscFramePacingRenderEstimationMode_t
{
    FRAME_PACING_RENDER_ESTIMATION_MODE_QUANTILE = 0,///< Use moving quantile estimation.
    FRAME_PACING_RENDER_ESTIMATION_MODE_NORMAL = 1,///< Use gaussian estimation.
}NvscFramePacingRenderEstimationMode;


typedef struct NvscFramePacingRenderHistory_t
{
    NvscFramePacingRenderEstimationMode renderEstimationMode;///< Method of calculating render time bound.

    uint32_t n;///< Approximate number of observations in history. Estimates variance of render times.

    uint32_t maxTimeUs;///< Maximum frame render time to add to jitter advance to compute frame target queue time.

    uint32_t minTimeUs;///< Minimum frame render time to add to jitter advance to compute frame target queue time.

    uint32_t stddevsX1000;///< Estimates render bound time. Sigma(jitter) * stddevs + jitter bound = target queue time. (x1000)

    uint32_t quantileX1000;///< Percentile of frame arrival jitter to use to estimate frame arrival jitter bound.

    uint32_t quantileConvergenceX10000;///< How quickly quantile adjusts. 20/10000 = .0020 = med/slow, 10/10000 = .001 = slow, 100/10000 = 0.01 = fast.
}NvscFramePacingRenderHistory;


typedef enum NvscFramePacingJitterEstimationMode_t
{
    FRAME_PACING_JITTER_ESTIMATION_MODE_QUANTILE = 0,///< Use moving quantile estimation.
    FRAME_PACING_JITTER_ESTIMATION_MODE_NORMAL = 1,///< Use gaussian estimation.
}NvscFramePacingJitterEstimationMode;


typedef struct NvscFramePacingJitterHistory_t
{
    NvscFramePacingJitterEstimationMode jitterEstimationMode;///< Method of calculating frame arrival jitter bound.

    uint32_t n;///< Approximate number of observations in history. Estimates variance of frame arrival jitter. Alpha = 2 / (N + 1).

    uint32_t stddevsX1000;///< Estimates frame target queue time. Sigma(jitter) * stddevs + render bound = target queue time. (x1000). Used directly in normal distribution jitter estimation mode. Used to adjust rate of movement in quantile estimation mode.

    uint32_t quantileX1000;///< Percentile of frame arrival jitter to use to estimate frame arrival jitter bound.

    uint32_t quantileConvergenceX10000;///< How quickly quantile adjusts. 25/10000 = .0020 = med/slow, 10/10000 = .001 = slow, 100/10000 = 0.01 = fast.

    uint32_t quantileWindowSize;///< Jitter data window that is used to calculate quantile. Setting this to a non-zero value means an explicit window will be used, but not smoothed moving estimate.

    uint32_t quantileWindowStep;///< Jitter data moving window offset when percentile gets recalculated. Setting this to a non-zero value means an explicit window will be used, but not smoothed moving estimate.

    uint32_t maxAdvanceUs;///< Max target queue time in microseconds.

    uint32_t minAdvanceUs;///< Min target queue time in microseconds.

    uint32_t outlierUs;///< Drop |jitter| values above this threshold to avoid skewing the variance too far.
}NvscFramePacingJitterHistory;


typedef enum NvscFramePacingFeedbackMode_t
{
    FRAME_PACING_FEEDBACK_NEVER = 0,///< Never send frame pacing feedback.
    FRAME_PACING_FEEDBACK_INTERVAL = 1,///< Send frame pacing feedback together with QoS stats.
    FRAME_PACING_FEEDBACK_PERFRAME = 2,///< Send frame pacing feedback on every frame.
}NvscFramePacingFeedbackMode;

/// Configures render frame pacing
typedef struct NvscFramePacing_t
{
/// Enable extra frame pacing debug logs.
    uint8_t enableExtraDebugLogging;///< Set to 1 to enable extra debug log messages.
    NvscFramePacingFeedbackMode feedbackMode;///< When to send this feedback: never, once per frame, or together with QoS stats.

    uint32_t feedbackTimeoutMs;///< Frame pacing feedback arrival timeout (in milliseconds seconds).

    uint32_t queueSmoothingHistoryN;///< Approximate number of observations in frame queue time history. Estimates frame queue time average.

    uint32_t queueHistoryOutlierUs;///< Clamp frame queue times above this threshold to avoid skewing the average too far.

    uint32_t frameDropThresholdMultipleX1000;///< Multiple of target queue time at which frames with a pending queue time outside this value should be dropped from the render queue.

    uint32_t deactivationThresholdFpsX1000;///< Frame pacing gets deactivated if FPS rate deviates more than the threshold value. The default value is 50, meaning 50/1000, i.e., 5%.

    uint32_t streamingFpsSmoothingHistoryLength;///< Approximate number of observations in streaming FPS history. Estimates stremaing FPS average.

    uint32_t activationDelayMs;///< Feature activation delay interval in milliseconds.

    uint32_t deactivationDelayMs;///< Feature deactivation delay interval in milliseconds.
    NvscFramePacingJitterHistory jitterHistory;///< Frame pacing frame arrival jitter history estimation parameters.
    NvscFramePacingRenderHistory renderHistory;///< Frame pacing frame client render history estimation parameters.
    Pid pid;///< Frame pacing's PID controller's parameters. See https://www.animatics.com/support/knowledge-base/pid-control for explanation of kP, kI, and kL.
}NvscFramePacing;

/// Available presets for video encoding.
typedef enum NvscEncoderPreset_t
{
    NVSC_ENC_PRESET_INVALID = -1,///< Not a valid preset.
    NVSC_ENC_PRESET_DEFAULT,///< Default preset.
    NVSC_ENC_PRESET_HP,///< High performance preset.
    NVSC_ENC_PRESET_HQ,///< High quality preset.
    NVSC_ENC_PRESET_BD,///< Blueray preset.
    NVSC_ENC_PRESET_LOW_LATENCY,///< Low latency preset.
    NVSC_ENC_PRESET_LOW_LATENCY_HQ,///< Low latency HQ preset.
    NVSC_ENC_PRESET_LOW_LATENCY_HP,///< Low latency HP preset.
    NVSC_ENC_PRESET_LOSSLESS,///< Lossless preset.
    NVSC_ENC_PRESET_LOSSLESS_HP,///< LossLess HP preset.
}NvscEncoderPreset;

/// Available encoder features.
typedef enum NvscEncoderSettings_t
{
    ENABLE_SPLIT_ENCODE = 0x1,///< Enable split encode if supported.
    ENABLE_4K_2PASS_RC = 0x2,///< Use 2-pass quality rate control mode for 4K-HEVC on Pascal.
    FEATURE_4K_1x_VBV = 0x4,///< Use 1x VBV buffer size with 2-pass quality RC mode for 4K60.
    FEATURE_SPATIAL_AQ = 0x8,///< Enable Spatial AQ in rate control for 4K60.
    FEATURE_KEY_FRAME_SCALE = 0x10,///< Enable key frame scale in NVSC_RC_CBR_TWO_PASS rate control mode.
    FEATURE_FAKE_ENCODE_FPS = 0x20,///< Enable fake encode fps for turbo mode only.
    FEATURE_EMPHASIS_MAP = 0x40,///< Enable usage of Emphasis map in the encoder.
    OVERRIDE_ENCODE_PRESET = 0x80,///< Enable override of video encoder preset.
    DISABLE_MULTI_REFERENCE = 0x100,///< Disable multi-reference encoding.
    FORCE_ENABLE_SPATIAL_AQ = 0x200,///< Force Enable Spatial AQ in rate control.
    FORCE_ENABLE_4K_2PASS_RC_WITHOUT_SPLIT_ENCODE = 0x400,///< Force enable 2-pass quality rate control mode for 4K without split encode.
}NvscEncoderSettings;

/// Available rate control modes for video encoding.
typedef enum NvscRateControlMode_t
{
    NVSC_RC_INVALID = -1,///< Not a valid RC mode.
    NVSC_RC_CONSTQP,///< Constant quantization parameter.
    NVSC_RC_VBR,///< Variable bitrate.
    NVSC_RC_CBR,///< Constant bitrate.
    NVSC_RC_VBR_MINQP,///< Variable bitrate with minimum quantization parameter.
    NVSC_RC_CBR_TWO_PASS,///< Constant bitrate using two pass encoding.
    NVSC_RC_TWO_PASS_FRAMESIZE_CAP,///< Multi pass encoding optimized for maintaining frame size.
    NVSC_RC_NUM_MODES,///< Not a valid RC mode.
}NvscRateControlMode;


typedef enum NvstWaitMethod_t
{
    NVST_WM_UNDEFINED = 0,///< Wait method undefined (use server setting).
    NVST_WM_NO_WAIT = 1,///< Don't wait.
    NVST_WM_WAIT_WITH_TIMEOUT = 2,///< Wait with timeout.
    NVST_WM_WAIT_EVENT_NOCURSOR_WITH_TIMEOUT = 3,///< Wait for event w/ timeout, ignore cursor updates.
}NvstWaitMethod;


typedef enum NvstSleepMethod_t
{
    NVST_SM_UNDEFINED = 0,///< Sleep method undefined (use server setting).
    NVST_SM_NORMAL_SLEEP = 1,///< Use normal sleep.
    NVST_SM_CPU_POLL_SLEEP = 2,///< Use CPU polling-based sleep.
    NVST_SM_WAITABLE_TIMER = 3,///< Use timer-based sleep.
    NVST_SM_WAITABLE_TIMER_BUSYWAIT = 4,///< Use timer-based sleep + busy wait.
    NVST_SM_NORMAL_SLEEP_BUSYWAIT = 5,///< Use normal sleep + busy wait.
}NvstSleepMethod;


typedef enum NvstCaptureMethod_t
{
    NVST_CM_UNDEFINED = 0,///< Capture method undefined (use server setting).
    NVST_CM_BASIC_SLEEP = 1,///< Use basic sleep capture method.
    NVST_CM_ADJUSTED_SLEEP = 2,///< Use adjusted sleep capture method.
    NVST_CM_CONSTANT_SLEEP = 3,///< Use constant sleep capture method.
    NVST_CM_WAIT_FOR_VBLANK = 4,///< Use wait for vblank-based capture method.
}NvstCaptureMethod;


typedef enum NvstCaptureStrategy_t
{
    NVST_CS_UNDEFINED = 0,///< Capture strategy undefined (use server setting).
    NVST_CS_FBC = 1,///< Use NvFBC-based capture strategy.
    NVST_CS_DDA = 2,///< Use Desktop Duplication API-based capture strategy.
    NVST_CS_WGC = 3,///< Use Windows.Graphics.Capture-based capture strategy.
    NVST_CS_CCX = 4,///< Use CCX-based capture strategy.
    NVST_CS_CCX_YUV = 5,///< Use CCX-based-YUV capture strategy.
}NvstCaptureStrategy;

/// Struct storing details about capture settings.
typedef struct NvstCaptureSettings_t
{
    NvstCaptureStrategy captureStrategy;///< Capture strategy.
    NvstCaptureMethod captureMethod;///< Capture method.
    NvstSleepMethod sleepMethod;///< Sleep method.

    uint16_t sleepMethodAccuracyUs;///< Sleep method accuracy in microseconds, used for busy wait.
    NvstWaitMethod waitMethod;///< Video frame provider wait method.

    uint16_t waitMethodTimeoutMs;///< Video frame provider wait method timeout in milliseconds, if applicable.
}NvstCaptureSettings;

/// Available H264 levels for video encoding.
typedef enum NvscH264Level_t
{
    NVSC_H264_LEVEL_INVALID = -1,///< Not a valid H264 level
    NVSC_H264_LEVEL_41 = 41,///< H264 Level 4.1
    NVSC_H264_LEVEL_42 = 42,///< H264 Level 4.2
    NVSC_H264_LEVEL_50 = 50,///< H264 Level 5.0
    NVSC_H264_LEVEL_51 = 51,///< H264 Level 5.1
}NvscH264Level;

/// Struct storing details about video configuration settings
typedef struct NvscVideoSettings_t
{

    uint8_t perfIndicatorEnabled;///< Enables perf indicator.

    uint32_t clientViewportWd;///< Width of the view port.

    uint32_t clientViewportHt;///< Height of the view port.

    uint32_t adapterNumber;///< The adapter to which the client is connecting.

    uint32_t maxFPS;///< Maximum allowed streaming framerate.
    NvscH264Level maxH264Level;///< Maximum H.264 Level.

    uint32_t maxH264Profile;///< Maximum H.264 Profile.

    uint32_t maxNumReferenceFrames;///< Override config for maximum number of reference frames. For standard compliant decoders, leave this at zero.

    uint32_t contextType;///< Video context type to be used on server side (CUDA=8/DX9=9/DX11=10), server may ignore unsupported types.
    NvstCaptureSettings captureSettings;///< Capture settings
    NvscTransferProtocol transferProtocol;///< Transfer protocol used to transmit frames.
    NvscRateControlMode rateControlMode;///< Rate control method used by encoder.
    NvscEncoderSettings encoderFeatureSetting;///< This is to control various features on encoder settings.
    NvscEncoderPreset encoderPreset;///< Preset used by encoder.

    uint32_t initialQp;///< Initial QP at the start of streaming. Set to 35 so first few frames are not too large.

    uint32_t minQp;///< Minimum possible QP used for streaming. Actual qp is limited by vqos[i].maximumBitrateKbps. Default is 18 for WAR to Kepler bug to prevent possible bitrate spikes

    uint32_t lowQpBitrateKbps;///< Below this bitrate (in kbps), allow the encoder to lower the minimum QP to the value set by minQp (see above). This will override the QPG.

    uint16_t videoBitrateIirFactor;///< Filtering factor for video bitrate estimation.

    uint32_t initialBitrateKbps;///< Target bitrate in kbps. Used before QoS is triggered.

    uint32_t initialPeakBitrateKbps;///< Peak bitrate in kbps. Used before QoS is triggered, ignored with CBR rate control mode.

    uint32_t vbvMultiplier;///< Percentage of average frame size used for VBV buffer size.

    uint8_t keyFrameScale;///< Allowed frame size increase factor for scene change frame.

    uint8_t fakeEncodeFps;///< Faked encode FPS for turbo mode only, used to limit encoded stream level to ease client processing requirements.

    uint32_t numTemporalLayers;///< No. of total layers in temporal/hierP encoding.

    uint32_t packetSize;///< Maximum allowed packet size. Also includes 16 bytes of RTP extention header

    uint8_t refPicInvalidation;///< Whether or not to allow invalidating a range of encoded reference frames based on timestamps.

    uint32_t pingBackIntervalMs;///< Interval between ping messages sent to the server to indicate that the client is still alive, in milliseconds.

    uint32_t pingBackTimeoutMs;///< Timout interval used by server to disconnect dead client, in milliseconds.

    uint32_t timeoutLengthMs;///< Length in milliseconds of timeout used when sending protocol messages. /// @todo decide where it fits best logically

    uint8_t fullFrameAssembly;///< \todo Whether frames are done as whole or as slices.

    uint8_t enableIntraRefresh;///< Whether to enable intra refresh

    uint8_t enableLongTermReferences;///< Whether to enable long term references

    uint32_t framesWithInvalidRefThreshold;///< threshold for number of frames with invalid reference to be sent to decoder

    uint32_t consecutiveFrameLostThreshold;///< number of consecutive frames lost threshold

    uint32_t videoEncoderDeblockingMode;///< H.264 encoder deblocking filter mode

    uint32_t videoEncoderSlicesPerFrame;///< No. of slices into which frames are divided

    uint32_t dynamicRangeMode;///< Dynamic range modes: 0 - SDR, 1 - HDR, 2 - EDR.

    uint8_t fbcDynamicFpsGrabTimeoutMs;///< Timeout for FBC grab in ms for Turbo Mode Streaming

    uint8_t enableVrStreamingMode;///< Whether to enable VR streaming mode
    NvstSurfaceFormat surfaceFormat;///< Surface format used by video stream.
    NvscFramePacing framePacing;///< Render frame pacing config
    NvstCscMode encoderCscMode;///< RGB Ycbcr Conversion method used by encoder.
    NvscVideoRawFrameDumpSettings rfd;///< Video Frame Dumping Settings
    NvscExitVideoFrameDumpSettings efd;///< Exit Video Frame Dumping Settings
    NvscVideoFrameDumpSettings fd;///< Video Frame Dumping Settings

    uint32_t enableFbcDiffMap;///< Enable/Disable FBC Difference map feature, by default is is disabled

    uint8_t disableFrameScaling;///< Disable video frame scaling.

    uint8_t dx9EnableNv12;///< Enable nv12 frame format for dx9 stream.

    uint8_t enableNextCaptureMode;///< Enable next capture mode.

    uint32_t sendFrameTimeoutMs;///< Timeout for the video sender thread to complete one iteration

    uint32_t sendFirstFrameTimeoutMs;///< Timeout for the video sender thread to complete the first iteration

    uint32_t senderDequeueTimeoutMs;///< Timeout for the video sender thread to dequeue from the video unit queue.

    uint16_t enableTimestampRender;///< Enable client side timestamp based video frame rendering. Values: 0 = disable on all platforms. 1 = enable on all platforms. Otherwise bitfield enabling per platform: (bit 2 = Windows, bit 3 = macOS, bit 4 = Linux, bit 5 = Android, bit 6 = iOS, ...)

    uint16_t enableAdaptiveQRender;///< Enable client side adaptive queue video frame rendering (ts render 2.0). Values: 0 = disable on all platforms. 1 = enable on all platforms. Otherwise bitfield enabling per platform: (bit 2 = Windows, bit 3 = macOS, bit 4 = Linux, bit 5 = Android, bit 6 = iOS, ...)

    uint8_t enableRtpNack;///< Disable[0]/Enable[1] retransmission of RTP packets using NACK mechanism

    uint8_t rtpNackBackoffTimeMs;///< Time in ms for which NACK logic waits before sending the next pending NACK request

    uint8_t rtpNackInitialWaitTimeMs;///< Time in ms for which NACK logic waits before sending the first pending NACK request

    uint8_t rtpNackMaxPacketCount;///< Max number of packets that can be NACKed in a single request

    uint32_t rtpNackQueueLength;///< Max number of packets (should be 2^N) that will be maintained in the RTP Queue

    uint8_t enableADJB;///< Disable[0]/Enable[1] Adaptive Dejitter Buffer

    uint8_t adjbMinLengthMs;///< Min DJB length for ADJB

    uint8_t adjbMaxLengthMs;///< Max DJB length for ADJB

    uint32_t adjbQuantile;///< Jitter history quantile for ADJB

    uint32_t adjbQuantileConvergenceFactor;///< Jitter history quantile convergence factor for ADJB

    uint8_t dejitterBufferLengthMs;///< The length of dejitter buffer in time, for 2 frames at 60fps this will be 32ms

    uint16_t nackDjbLengthMultiplyFactorx100;///< Multiplication factor for dejitter buffer length in time that used to decide the state of the NACK feature (x100 since float values are not supported)

    uint16_t nackHysteresisLengthUs;///< Hysteresis length in time that gets deducted from the dejitter buffer length to decide the state of the NACK feature when NACK feature is not enabled already

    uint16_t rtpNackQueueMaxPackets;///< Maximum packet count allowed in RTP out of order queue when NACK is active.

    uint8_t rtpNackDjbInteractionMode;///< Config to enable Nack DJB interaction.
    NvscMaxPacketSizeDetection packetSizeDetection;///< Max packet size detection settings
    NvscDynamicPacketSize dynamicPacketSize;///< Dynamic packet size settings
}NvscVideoSettings;


typedef enum ipVersionMode_t
{
    INVALID_IP = 0,///< Invalid IP
    IPV4 = 4,///< IP version 4
    IPV6 = 6,///< Ip version 6
}ipVersionMode;


typedef enum recoveryMode_t
{
    RECOVERY_MODE_DISABLED = 0,///< Recovery mode disabled
    RECOVERY_MODE_ENABLED = 1,///< recovery mode enabled
}recoveryMode;

/// The URL scheme for RTSP signaling.  Legacy is rtsp:// or rtsps://
typedef enum RtspScheme_t
{
    RTSP_SCHEME_LEGACY = 0x0,///< Use legacy scheme: rtsp:// or rtsps://
    RTSP_SCHEME_RELIABLE_UDP = 0x1,///< Use reliable UDP.
    RTSP_SCHEME_WEB_SOCKET = 0x2,///< Use an unencrypted web socket.
    RTSP_SCHEME_SECURE_WEB_SOCKET = 0x3,///< Use a secure web socket.
    RTSP_SCHEME_UNDEFINED = 0x4,///< Use the parameters provided in the connection config to determine the scheme.
}RtspScheme;

/// Features to be used on next connect call.
typedef enum NvscFeatureFlags_t
{
    NVSC_FEATURE_VIDEO = 0x1,///< Use video streaming.
    NVSC_FEATURE_AUDIO = 0x2,///< Use audio streaming.
    NVSC_FEATURE_REMOTE_INPUT = 0x4,///< Use remote input.
    NVSC_FEATURE_ENCRYPT_VIDEO = 0x10,///< Encrypt video.
    NVSC_FEATURE_ENCRYPT_AUDIO = 0x20,///< Encrypt audio.
    REMOVED_NVSC_FEATURE_ENCRYPT_REMOTE_INPUT = 0x40,///< (REMOVED) Encrypt remote input. (use NVSC_FEATURE_ENCRYPT_CONTROL_CHANNEL instead)
    NVSC_FEATURE_ENCRYPT_CONTROL_CHANNEL = 0x80,///< Encrypt control channel traffic.
}NvscFeatureFlags;

/// Available uses for network ports.
/// \sa NvscServerEndpoint
typedef enum NvscPortUsage_t
{
    NVSC_PU_INVALID = -1,///< Not a valid port usage.
    NVSC_PU_CONTROL,///< Port is used to transport control messages.
    NVSC_PU_VIDEO,///< Port is used to transport video.
    NVSC_PU_AUDIO,///< Port is used to transport audio.
    NVSC_PU_INPUT,///< Port is used to transport input event messages.
    NVSC_PU_SIGNALING,///< Port is used to transport signaling(RTSP) traffic.
    NVSC_PU_MIC,///< Port is used to transport mic audio.
    NVSC_PU_SECURE_SIGNALING,///< Port is used to transport secure signaling(RTSPS) traffic.
}NvscPortUsage;

/// Struct storing details about a server port.
typedef struct NvscServerEndpoint_t
{

    uint16_t portNumber;///< Port number.
    NvscTransferProtocol protocol;///< Protocol used.
    NvscPortUsage usage;///< Intended use.

    char serverIp[512];///< Null terminated string of the server address of this Stream. It may be Hostname or Ip address
}NvscServerEndpoint;


typedef enum EnetSequenceWindowsPartiallyReliable_t
{
    ENET_PEER_WAIT_WINDOW_PARTIALLY_RELIABLE = 2,///< Packet seq delta beyond which receiver drops missing part-reliable packet
}EnetSequenceWindowsPartiallyReliable;


typedef enum ReliabilityType_t
{
    TYPE_RELIABLE = 0,///< Fully reliable, sequenced and acked, transmitted indefinitely
    TYPE_PARTIALLY_RELIABLE,///< Partially reliable, sequenced and acked, limited transmissions
    TYPE_UNRELIABLE,///< Unreliable, unsequenced and unacked, transmitted once
}ReliabilityType;

/// Struct with mutli channel feature control flag and number of channels.
typedef struct EnetControlChannel_t
{

    uint8_t channelCount;///< Number of sub channels for the control socket
    ReliabilityType reliabilityType;///< Different types of messages for enet control channel

    uint8_t qosReliabilityType;///< Reliability type for transmission of QoS messages

    uint32_t clientQosTrafficType;///< QoS Traffic type for control channel data used in Qos flow DSCP setting

    uint8_t maxTxPartiallyReliable;///< Max number of transmissions for partially reliable messages
    EnetSequenceWindowsPartiallyReliable enetSequenceWindowsPartiallyReliable;///< Different window sizes to configure behavior of partial reliability in ENet

    uint8_t waitWindowPartiallyReliable;///< Size of wait window beyond which ENet drops missing partially reliable packets

    uint32_t mtuSize;///< MTU size to control fragmentation at the ENet layer

    uint32_t timeoutMaximumMs;///< Maximum timeout for all peers at the ENet layer

    uint32_t clientEnetStatsIntervalMs;///< Time interval in ms between successive sends of client ENet stats
}EnetControlChannel;

/// Struct storing details about nvsc client ports.
typedef struct NvscClientPorts_t
{

    char localAddress[512];

    uint8_t useReserved;///< Enable fixed ports to leverage router QoS. Value: 0 - disable, : 1 - enable

    uint8_t fallbackDynamic;///< Client port selection to fall back to using dynamic ports when the desired ports are already in use.

    uint16_t session;///< Client session initiation (currently over RTSP) port number.

    uint16_t audio;///< Client audio port number.

    uint16_t mic;///< Client mic port number.

    uint16_t video;///< Client video port number.

    uint16_t control;///< Client control port number.
}NvscClientPorts;

/// Struct storing details about a client interface.
typedef struct NvscClientInterface_t
{

    uint8_t usePreferred;///< Tell NVSC client to pick the preferred network interface to use. Value: 0 - let OS pick an interface; 1 - use the preferred interface.
}NvscClientInterface;

/// Struct storing details about general configuration settings
typedef struct NvscGeneralSettings_t
{
    NvscClientInterface clientInterface;
    NvscClientPorts clientPorts;///< Details about ports used by the clients. Unused entries must be zeroed out.
    EnetControlChannel enetControlChannel;///< Details about multi channel implementation of control socket for enet
    NvstServerNetwork serverNetwork;///< Server network the session belongs to.
    NvscServerEndpoint serverEndpoints[20];///< Details about endpoints used by the server. Unused entries must be zeroed out.

    uint32_t videoSyncAudioDelayAdjust;///< reduce delay of video frame when we synchronize the next video frame based on its capture timestamp

    uint64_t startTime;///< Reference system start time used by both audio and video thread. It is used in conjunction with Video/AudioSyncOffsets
    NvscFeatureFlags featureFlags;///< Features used in current session.

    uint8_t serverCapture;///< Whether or not to capture video stream to file on server. /// \todo Move to runtime

    uint8_t clientCapture;///< Whether or not to capture video stream to file on client. /// \todo Move to runtime

    char outputFolder[MAX_PATH];///< Client data output folder.for stats, pcaps and event tracing files.

    uint32_t rtpQueueMaxPackets;///< Maximum packet count allowed in RTP out of order queue.

    uint32_t rtpQueueMaxDurationMs;///< Maximum duration in ms permitted for RTP out of order queue.

    uint16_t rtpQueueMaxFrameWaitDurationMs;///< Maximum duration in ms permitted for RTP out of order queue to wait for packets of a frame.

    uint8_t rtpEnablePacketCounter;///< Feature enable flag for RTP packet counter for early drop of packets based on assemblable frames.

    uint8_t useReliableUdp;///< Use reliable UDP for control channel.

    uint8_t customMessageOnCC;///< Whether or not to use control channel to transfer custom message.
    RtspScheme rtspScheme;///< The URL scheme for RTSP signaling.  Legacy is rtsp:// or rtsps://

    char pemCertPath[NVST_MAX_PEM_CERT_PATH];///< Path on file system where CA for selfigned server certificate is located.

    char iceUserNameFragment[ICE_STRING_LENGTH];///< ICE username fragment.

    char icePassword[ICE_STRING_LENGTH];///< ICE password.

    char dtlsFingerprint[DTLS_FINGERPRINT_LENGTH];///< DTLS fingerprint.

    uint8_t filterLocalIp;///< Filter same local IPs for hole punching address list. Disable this for Snoopy only

    uint8_t videoStreamerCount;///< Number of video streamers.

    uint8_t useHolePunch;///< Hole Punch to server URLs.

    uint8_t rtspStunStatus;///< RTSP port STUN status.

    uint32_t serverNATType;///< The server's NAT type.

    uint32_t clientNATType;///< The client's NAT type.
    recoveryMode enableRecoveryMode;///< Recovery mode on client.

    uint8_t lightRecoveryMode;///< Light recovery mode. 0 - disabled, 1 - enabled.

    uint16_t recoveryModeTriggerThresholdMs;///< Time in msec before server recovery mode is triggered due to increased TxRxLag.

    uint8_t enableIntraRefreshInRecoveryMode;///< To enable IntraRefresh wave during Recovery mode

    uint32_t controlChannelStatsTransmitIntervalMs;///< Interval (ms) and feature toggle (0 = disable) to transmit control channel stats.

    uint32_t uplinkStatsCollectionIntervalMs;///< Interval (ms) for collection of uplink stats.

    uint8_t useQosForAudioStats;///< Use Video/Qos channel to send aggregated audio and video stats to server.

    uint32_t maxQosMessagesSize;///< Maximum allowed QoS messages buffer sie.
    ipVersionMode ipVersion;///< Ip version to create socket and addresses.
    NvstConnectionType clientConnectionType;///< Network connection type
    NvstConnectionSubType clientConnectionSubType;///< Network connection sub type

    uint8_t logSpsHeader;///< Log SPS header while sending an I-Frame: 0 - disabled, 1 - enabled

    uint8_t pingVersion;///< Provides ability to set the ping version.

    uint8_t readTosField;///< TOS feild read control: 0 - disabled, 1 - enabled

    uint8_t clientSupportsIntraRefresh;///< Whether the platform/client supports intra refresh: 1 - supported, 0 - unsupported

    uint8_t decodeFpsAdjPercent;///< Adjustment factor for the client's decoder performance estimate. Set to 0 to ignore this client estimate for Perf History.

    uint8_t renderFpsAdjPercent;///< Adjustment factor for the client's render performance estimate. Set to 0 to ignore this client estimate for Perf History.
}NvscGeneralSettings;

/// Struct storing stream configuration and options.
/// \remarks
/// Stream configuration is specified when invoking nvstConnectToServer().
/// \sa nvstConnectToServer
typedef struct NvscClientConfig_t
{

    uint8_t uiAutoMode;///< Whether or not users use auto mode to play the game.

    NvstVideoDecoder videoDecoder;///< Information about the H.264 decoder.
    NvscGeneralSettings general;///< General Configuration Settings
    NvscVideoSettings video[VIDEO_STREAM_MAX_COUNT];///< Video Configuration Settings
    NvscVideoQosSettings vqos[VIDEO_STREAM_MAX_COUNT];///< Video QoS configuration settings
    NvscQosScore qscore;///< Describe the parameters for Qos scores.
    NvscAudioQosSettings aqos;///< Audio QoS configuration settings
    NvscRuntimeSettings runtime;///< Runtime Configuration Settings
    NvscRiSettings ri;///< Remote Input Configuration Settings
    NvscAudioSettings audio;///< Audio settings
    NvscMicAudioSettings mic;///< Mic settings
    NvscAudioBitrateSettings audioBitrate;///< Audio Bitrate Configuration
    NvscBWEstimator bwe;///< Bandwidth Estimation Configuration Settings
    NvscClientPerfBrControl clientPerfBr;///< Settings to control bitrate based on client performance feedback.
    NvscPacketPacing packetPacing;///< Settings to control packet pacing feature.
}NvscClientConfig;

#endif
