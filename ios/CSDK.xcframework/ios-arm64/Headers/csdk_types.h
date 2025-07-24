/*
 * Copyright (c) 2021-2023 Arculus Holdings, L.L.C. All Rights Reserved.
 *
 * This software is confidential and proprietary information of Arculus Holdings, L.L.C.
 * All use and disclosure to third parties is subject to the confidentiality provisions
 * of the license agreement accompanying the associated software.
 *
 * This copyright notice and disclaimer shall be included with all copies of this
 * software used in derivative works.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
 * A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS OF THIS SOFTWARE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THIS SOFTWARE OR THE USE, MODIFICATION, DISTRIBUTION, OR OTHER DEALINGS IN THIS
 * SOFTWARE OR ITS DERIVATIVES.
 */

 /**
  * @file  csdk_types.h
  *
  * @brief Public API for csdk type
  *
  * Notes: XXXXXXRequest  Usually provides the bytes to send, the Client sends bytes over NFC
  * Notes: XXXXXXResponse Usually used to parse response bytes provided by client
  */
#ifndef INCLUDE_CSDK_TYPES_H_
#define INCLUDE_CSDK_TYPES_H_

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>

/**
 * @brief AppletObj is the Context Object for interacting with the Arculus Card
 * */
typedef struct AppletObj AppletObj;


#define CSDK_OK                        0        /**< Success return code */
/**************************************************************************************

                                ERRORS DEFINITION

***************************************************************************************/
#define CSDK_ERR_NULL_POINTER               -100     /**< ERR_NULL_POINTER error code */
#define CSDK_ERR_NULL_APPLETOBJ             -101     /**< ERR_NULL_WALLET error code */
#define CSDK_ERR_NULL_CALLOC                -102     /**< ERR_NULL_CALLOC error code */
#define CSDK_ERR_WRONG_RESPONSE_LENGTH      -103     /**< ERR_WRONG_RESPONSE_LENGTH error code */
#define CSDK_ERR_WRONG_RESPONSE_DATA        -104     /**< ERR_WRONG_RESPONSE_DATA error code */
#define CSDK_ERR_WRONG_STATUS_WORD          -105     /**< ERR_WRONG_STATUS_WORD error code */
#define CSDK_ERR_WRONG_DATA_LENGTH          -106     /**< ERR_WRONG_DATA_LENGTH error code */
#define CSDK_ERR_WRONG_PARAM_LENGTH         -107     /**< ERR_WRONG_PARAM_LENGTH error code */
#define CSDK_ERR_WRONG_PIN                  -108     /**< ERR_WRONG_PIN error code */
#define CSDK_ERR_INVALID_PARAM              -109
#define CSDK_ERR_ENCRYPTION_NOT_INIT        -110


/** WALLET Applet Id, for WalletSelectWalletResponse */
#define WALLET_AID_LEN 10

/** Max length of public key or chain key code */
#define KEY_MAXLEN                  33
/** Max length of wallet PIN code */
#define WALLET_PIN_MAXLEN           12
/** Min length of wallet PIN code */
#define WALLET_PIN_MINLEN           4

// ** Useful bitshifting Macros for BIP39 mnemonic sentence */
#define WBIT(x) (1LL << ((x)-1))
#define WALLET_NUM_WORDS_BITMASK (WBIT(12)|WBIT(15)|WBIT(18)|WBIT(21)|WBIT(24))

/**
 * @brief Structure to allow having return Structure containing both ChainCode Key and the Public Key in case re-derivation is needed.
 * */
typedef struct {
    unsigned char publicKey[KEY_MAXLEN];
    unsigned char chainCodeKey[KEY_MAXLEN];
    size_t pubKeyLe;
    size_t chainCodeLe;
} ExtendedKey;

/**
 * @brief Structure to grouping required data structs for applet selection
 * */
typedef struct {
    unsigned char *ApplicationAID;
    int ApplicationAIDLength;
} OperationSelectResponse;


#endif /* INCLUDE_CSDK_TYPES_H_ */
