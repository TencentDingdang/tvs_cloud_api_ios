//
// Created by frankenliu on 2016/12/13.
//

#ifndef VOS_TSPEEX_H
#define VOS_TSPEEX_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief TSpeex_EncodeInit
 * @return TSpeexEncodeContext
 * 0: error
 */
long long TSpeex_EncodeInit();

/**
 * @brief TSpeex_Encode
 * @param TSpeexEncodeContext
 * @param inBytes
 * @param inOff
 * @param inLen
 * @param outBytes
 * @return outLen
 * <=0: error code
 */
int TSpeex_Encode(long long TSpeexEncodeContext, char *inBytes, int inLen, char **outBytes);

/**
 * @brief TSpeex_EncodeRelease
 * @param TSpeexEncodeContext
 * @return 0
 * <0: error code
 */
int TSpeex_EncodeRelease(long long TSpeexEncodeContext);

/**
 * @brief TSpeex_DecodeInit
 * @return TSpeexDecodeContext
 * <0: error code
 */
long long TSpeex_DecodeInit();

/**
 * @brief TSpeex_Decode
 * @param TSpeexDecodeContext
 * @param inBytes
 * @param inOff
 * @param inLen
 * @param outBytes
 * @return outLen
 * <=0: error code
 */
int TSpeex_Decode(long long TSpeexDecodeContext, char *inBytes, int inLen, char **outBytes);

/**
 * @brief TSpeex_DecodeRelease
 * @param TSpeexDecodeContext
 * @return 0
 * <0: error code
 */
int TSpeex_DecodeRelease(long long TSpeexDecodeContext);

#ifdef __cplusplus
}
#endif
#endif //VOS_TSPEEX_H
