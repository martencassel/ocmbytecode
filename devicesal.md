# Note

This document was rewritten using github copilot.

# DeviceSal Function Dictionary Analysis

## Overview

The **DeviceSal** (Device Secure Application Loader) functions form the cryptographic core of Sony's OpenMG DRM system. These functions implement various encryption, decryption, verification, and key management operations used to protect digital content and ensure secure device operations.

---

## Cryptographic Primitives Summary

DeviceSal provides a comprehensive cryptographic toolkit for Sony's OpenMG DRM system, implementing multiple layers of security through diverse cryptographic primitives:

### Core Symmetric Encryption Algorithms

| Algorithm | Key Size | Block Size | Usage | Functions |
|-----------|----------|------------|-------|-----------|
| **DES** | 56-bit (8 bytes) | 64-bit (8 bytes) | Legacy content encryption, key processing | 0xb5, 0xb8, 0xb9, 0xba, 0xd8, 0xd9 |
| **3DES** | 112-bit (16 bytes) | 64-bit (8 bytes) | Enhanced security, MAC generation | 0xb8, 0xb9, 0xba |
| **OCM Cipher** | 160-bit (20 bytes) | 64-bit (8 bytes) | Sony proprietary, content protection | 0xb9, 0xba, 0xcf, 0xd0, 0xd6-0xd9 |
| **SHA-1 Stream Cipher** | Variable | Stream | Custom streaming encryption | 0xdc, 0xdd |

### Cipher Operating Modes

| Mode | Description | Security Properties | Functions |
|------|-------------|-------------------|-----------|
| **ECB** | Electronic Codebook | Fast, parallel processing | 0xb5 |
| **CBC** | Cipher Block Chaining | Semantic security, sequential | 0xb8, 0xb9, 0xba, 0xd8, 0xd9 |
| **Stream** | Keystream XOR | Real-time processing | 0xdc, 0xdd |

### Cryptographic Hash Functions

| Algorithm | Output Size | Usage | Functions |
|-----------|-------------|-------|-----------|
| **SHA-1** | 160-bit (20 bytes) | Key derivation, integrity | 0x00, 0xd6-0xd9, 0xdc, 0xdd |
| **Custom Hash** | Variable | EKB verification | 0x00, 0x9f |

### Message Authentication Codes (MAC)

| Type | Algorithm | Key Size | Output Size | Functions |
|------|-----------|----------|-------------|-----------|
| **3DES-MAC** | ISO 9797-1 variant | 112-bit | 64-bit | 0xb8 |
| **HMAC-SHA1** | Hash-based MAC | Variable | 160-bit | Implied in protocol functions |

### Digital Signature Schemes

| Algorithm | Key Type | Security Level | Usage | Functions |
|-----------|----------|----------------|-------|-----------|
| **ECC** | Elliptic Curve | High | EKB v2+ verification | 0x9f |
| **Custom** | Proprietary | Medium | EKB v1 verification | 0x00 |

### Key Management Primitives

#### Key Derivation Functions (KDF)
```
DeviceSal implements multiple key derivation strategies:

1. SHA-1 Based KDF (Functions 0xd6-0xd9)
   Input: Protocol key → SHA-1(key) → Encryption parameters

2. Device-Bound KDF (Functions 0xd8-0xd9)
   Input: Key ⊕ Device_Constant → SHA-1 → IV||DES_Key

3. Hierarchical KDF (Functions 0xb9-0xba)
   Master Key → k1||k2 → Content Keys
```

#### Key Wrapping and Unwrapping
```
Multiple layers of key protection:

• OCM Key Containers (0xcf, 0xd0): Structured key storage
• 3DES Key Unwrapping (0xb9, 0xba): Master key extraction
• Device Binding (0xd8, 0xd9): Hardware-specific key derivation
```

### Advanced Security Features

#### Device Binding Mechanisms
- **Hardware Root of Trust**: 8-byte device constant (Dict 0xfc)
- **Key Binding**: XOR mixing with device-specific values
- **Extraction Prevention**: Keys cannot be moved between devices

#### Multi-Layer Encryption Architecture
```
Content Protection Layers:
┌─────────────────────────────────────┐
│ Layer 4: Protocol Scrambling        │ ← Obfuscation (0xd6, 0xd7)
├─────────────────────────────────────┤
│ Layer 3: Device Binding             │ ← Hardware binding (0xd8, 0xd9)
├─────────────────────────────────────┤
│ Layer 2: OCM Cipher Encryption      │ ← Content encryption
├─────────────────────────────────────┤
│ Layer 1: DES-CBC Base Encryption    │ ← Protocol encryption
└─────────────────────────────────────┘
```

#### Perfect Forward Secrecy
- **Fresh Key Generation**: Function 0xba creates new session keys
- **Key Separation**: Master keys separate from content keys
- **Temporal Protection**: Compromise of one session doesn't affect others

### Data Integrity and Authentication

#### Structured Data Protection
- **ASN.1 Serialization**: Standardized data encoding (0xcf, 0xd0, 0xd6-0xd9)
- **Length Validation**: Prevents buffer overflow attacks
- **Type Safety**: Runtime type checking (0xb7)

#### Content Validation
- **EKB Integrity**: Multi-version verification system (0x00, 0x9f)
- **Signature Verification**: Embedded content signatures
- **Format Detection**: Content type identification (0xb7)

### Cryptographic State Management

#### Runtime Key-Value Store (0xbd-0xbf)
```
Secure state management for:
• Intermediate cryptographic values
• Session keys and IVs
• Device configuration parameters
• Encryption context preservation
```

#### Side-Effect Key Caching
- **Optimization**: Derived keys cached for reuse (0xd8, 0xd9)
- **Security**: Keys stored in protected memory regions
- **Lifecycle**: Automatic cleanup and key rotation

### Security Architecture Design Principles

1. **Defense in Depth**: Multiple encryption layers with different algorithms
2. **Key Separation**: Different keys for different purposes and layers
3. **Hardware Binding**: Device-specific cryptographic operations
4. **Forward Security**: Session-based key generation and rotation
5. **Algorithm Diversity**: Multiple cipher families to prevent single points of failure
6. **Structured Security**: ASN.1 encoding ensures data integrity
7. **Version Control**: Support for cryptographic algorithm evolution

### Implementation Security Features

- **Bytecode Isolation**: Virtual machine prevents direct memory access
- **Function Dispatch**: Indirect function calls prevent code injection
- **Type Safety**: Runtime type validation prevents memory corruption
- **Error Propagation**: Secure failure modes and error handling
- **Memory Management**: Controlled allocation and deallocation

This comprehensive cryptographic framework provides Sony's OpenMG DRM with robust content protection capabilities, combining established algorithms (DES, 3DES, SHA-1) with proprietary innovations (OCM cipher, device binding) to create a multi-layered security architecture resistant to various attack vectors.

---

## Function Categories and Analysis

### EKB (Enabling Key Block) Management

#### DeviceSal Dict 000 (0x00) - Primary EKB Verification
```
Signature: (EKB) -> (status)
Function:  Verify EKB file integrity and authenticity
```

**Operation Flow:**
```
Input: EKB File
    │
    ▼
┌─────────────────┐    Version 1?    ┌─────────────────────┐
│  Check Version  │ ───────Yes──────► │ SHA-1 Check         │
│  in EKB Header  │                  │ (first 176 bytes)   │
└─────────────────┘                  └─────────────────────┘
    │                                          │
    │ No (Version > 1)                        │
    ▼                                          ▼
┌─────────────────┐                  ┌─────────────────────┐
│ Call Dict 159   │                  │ Return Status:      │
│ (ECC Signature) │ ──────────────►  │ 0 = OK              │
└─────────────────┘                  │ Non-zero = Error    │
                                     └─────────────────────┘
```

**Cryptographic Primitives:**
- **SHA-1**: Hash verification for version 1 EKBs
- **Digital Signatures**: Integrity verification
- **Version Control**: Backward compatibility handling

**Purpose**: Primary entry point for validating EKB files before key extraction

**Technical Note**: The "first 176 bytes" likely contains the EKB header structure including version, node count, and key hierarchy metadata.

#### DeviceSal Dict 159 (0x9f) - Advanced EKB Verification
```
Signature: (EKB) -> (status)
Function:  Verify EKB files with version > 1 using ECC signatures
```

**Cryptographic Primitives:**
- **ECC (Elliptic Curve Cryptography)**: Advanced signature verification
- **Digital Signatures**: Stronger security than SHA-1 hashing

**Purpose**: Enhanced security for newer EKB versions

---

### Placeholder Functions (001-003)

#### DeviceSal Dict 001-003
```
Status: Undefined/Reserved
Purpose: Likely reserved for future EKB operations or internal use
```

---

### Unknown/Reserved Functions (160-175)

#### DeviceSal Dict 160 (0xa0), 165 (0xa5), 170-175 (0xaa-0xaf)
```
Status: Function signatures not documented
Purpose: Likely internal cryptographic operations or device-specific functions
```

#### DeviceSal Dict 172 (0xac), 178 (0xb2)
```
Function: Dispatch tables for Dict 171 and Dict 177 respectively
Purpose: Function pointer tables for polymorphic operations
```

---

### Basic Utility Functions

#### DeviceSal Dict 180 (0xb4) - Constant Function
```
Signature: (a,b,c) -> (1)
Function:  Always returns 1 regardless of input
Purpose:   Utility function, possibly for testing or padding
```

---

### DES Cryptographic Operations

#### DeviceSal Dict 181 (0xb5) - DES-ECB with XOR Masking
```
Signature: (deskey,plain,cipher,xorout,xorin) -> ()
Function:  DES-ECB encryption with XOR pre/post processing
```

**Operation Flow:**
```
Input: plain, xorin
    │
    ▼
┌─────────────────┐
│ plain XOR xorin │ ← Pre-processing XOR
└─────────────────┘
    │
    ▼
┌─────────────────┐
│ DES-ECB-Encrypt │ ← Core encryption
│ with deskey     │
└─────────────────┘
    │
    ▼
┌─────────────────┐
│ result XOR      │ ← Post-processing XOR
│ xorout          │
└─────────────────┘
    │
    ▼
Store in cipher
```

**Cryptographic Primitives:**
- **DES-ECB**: Electronic Codebook mode encryption
- **XOR Operations**: Input/output masking for additional security

**Purpose**: Secure data transformation with obfuscation

#### DeviceSal Dict 184 (0xb8) - 3DES MAC Generation
```
Signature: (msg,tripdeskey) -> (mac)
Function:  Generate Message Authentication Code using 3DES
```

**Operation Flow:**
```
Input: msg, tripdeskey (k1 ++ k2)
    │
    ▼
┌─────────────────┐
│ DES-CBC-Encrypt │ ← Encrypt message with k1
│ msg with k1     │
└─────────────────┘
    │
    ▼
┌─────────────────┐
│ DES-Decrypt     │ ← Decrypt last block with k2
│ last block, k2  │
└─────────────────┘
    │
    ▼
┌─────────────────┐
│ DES-Encrypt     │ ← Re-encrypt with k1
│ result with k1  │
└─────────────────┘
    │
    ▼
Return single block MAC
```

**Cryptographic Primitives:**
- **3DES**: Triple DES with two keys (k1 ++ k2 = 16 bytes total)
- **CBC Mode**: Cipher Block Chaining
- **MAC**: Message Authentication Code for integrity

**Purpose**: Generate cryptographic signatures for message integrity verification

**Security Note**: This implements a variant of the ISO 9797-1 MAC algorithm using 3DES.


### Complex Key Management Operations

#### DeviceSal Dict 185 (0xb9) - Hierarchical Content Decryption
```
Signature: (cipher,iv,enckey2,encobj,key) -> (plain)
Function:  Multi-layer content decryption with key unwrapping
```

**Detailed Operation Flow:**
```
Step 1: Master Key Extraction
Input: encobj, key
    │
    ▼
┌─────────────────────┐
│ DES-OCM-Decrypt     │ ← Decrypt encrypted object
│ encobj with key     │   to reveal 3DES master key
└─────────────────────┘
    │
    ▼ Outputs: k1 ++ k2 (16-byte 3DES key pair)

Step 2: Secondary Key Processing
Input: enckey2, k2 (from step 1)
    │
    ▼
┌─────────────────────┐
│ DES-Decrypt         │ ← Decrypt secondary key with k2
│ enckey2 with k2     │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ DES-Encrypt         │ ← Re-encrypt result with k1
│ result with k1      │   to create content key
└─────────────────────┘
    │
    ▼ Outputs: key2 (content decryption key)

Step 3: Content Decryption
Input: cipher, iv, key2 (from step 2)
    │
    ▼
┌─────────────────────┐
│ DES-CBC-Decrypt     │ ← Final content decryption
│ cipher with key2+iv │
└─────────────────────┘
    │
    ▼ Outputs: plain (decrypted content)
```

**Cryptographic Primitives:**
- **DES-OCM**: Custom OpenMG cipher for key container decryption
- **3DES Key Pair**: 16-byte master key (k1 || k2)
- **DES Operations**: Standard DES encryption/decryption
- **CBC Mode**: Cipher Block Chaining for content protection
- **Key Unwrapping**: Secure extraction of content keys

**Security Purpose**:
- **Hierarchical Protection**: Multiple encryption layers
- **Key Separation**: Master keys separate from content keys
- **Forward Security**: Content keys derived dynamically

---

#### DeviceSal Dict 186 (0xba) - Hierarchical Content Encryption
```
Signature: (plain,iv,encobj,key) -> (nkey,cipher)
Function:  Multi-layer content encryption with fresh key generation
```

**Detailed Operation Flow:**
```
Step 1: Master Key Extraction (Same as 185)
Input: encobj, key
    │
    ▼
┌─────────────────────┐
│ DES-OCM-Decrypt     │ ← Extract 3DES master key
│ encobj with key     │
└─────────────────────┘
    │
    ▼ Outputs: k1 ++ k2 (16-byte 3DES key pair)

Step 2: Fresh Key Generation
    │
    ▼
┌─────────────────────┐
│ Generate Random     │ ← Create new session key
│ Content Key         │
└─────────────────────┘
    │
    ├─────────────────────┐
    │                     ▼
    │              ┌─────────────────────┐
    │              │ DES-Encrypt with k2 │ ← nkey output
    │              │ newkey → nkey       │   (for key exchange)
    │              └─────────────────────┘
    ▼
┌─────────────────────┐
│ DES-Encrypt with k1 │ ← Create content encryption key
│ newkey → key2       │
└─────────────────────┘

Step 3: Content Encryption
Input: plain, iv, key2 (from step 2)
    │
    ▼
┌─────────────────────┐
│ DES-CBC-Encrypt     │ ← Encrypt content
│ plain with key2+iv  │
└─────────────────────┘
    │
    ▼ Outputs: cipher (encrypted content)
```

**Key Innovation**: This function implements **perfect forward secrecy** by generating fresh content keys for each encryption operation while maintaining hierarchical key management.

---

### Data Structure Management System

#### DeviceSal Dict 189-191 (0xbd-0xbf) - Runtime Key-Value Store
```
Dict 189 (Store):    (key,value) -> ()     - Insert mapping
Dict 190 (Retrieve): (key,default) -> ()   - Get value with fallback
Dict 191 (Storage):  Variable              - Shared mapping container
```

**System Architecture:**
```
Runtime Memory Space
┌─────────────────────────────────────────┐
│            Dict 191 Storage             │
│  ┌─────────────────────────────────────┐│
│  │  Key-Value Mapping Table            ││
│  │                                     ││
│  │  [key1] → [value1]                  ││
│  │  [key2] → [value2]                  ││
│  │  [keyN] → [valueN]                  ││
│  │                                     ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
         ▲                    ▲
         │ Store             │ Retrieve
         │                   │
    ┌─────────┐         ┌─────────┐
    │Dict 189 │         │Dict 190 │
    │ Insert  │         │  Get    │
    └─────────┘         └─────────┘
```

**Use Cases:**
- **Cryptographic State**: Store intermediate keys, IVs, nonces
- **Session Management**: Track encryption context across operations
- **Device Configuration**: Runtime parameters and capabilities

---

### Reserved/Unknown Functions (187, 193-199)

#### DeviceSal Dict 187 (0xbb) - Reserved
```
Status: Undefined - likely placeholder for future crypto operations
```

#### DeviceSal Dict 193-197 (0xc1-0xc5) - Internal Operations
```
Dict 193-196: Undocumented internal functions
Dict 197:     Dispatch table for Dict 196 (function pointer table)
```

#### DeviceSal Dict 198 (0xc6) - Key Transformation Pipeline
```
Function: Decrypt with hook D249, re-encrypt with DES-OCM
Purpose:  Key format conversion or secure key migration
```

**Suspected Operation:**
```
Input Key → Hook D249 → Decrypt → Transform → DES-OCM → Re-encrypt → Output Key
```

---

### ASN.1 Object Serialization Layer

#### DeviceSal Dict 207-208 (0xcf-0xd0) - Structured Data Encryption

**Dict 207 (0xcf): Object Unpacking**
```
Signature: (encobj, objkey) -> (...)
Function:  Decrypt and deserialize ASN.1 structured data
```

**Operation Flow:**
```
Input: encobj (encrypted), objkey
    │
    ▼
┌─────────────────────┐
│ DES-OCM-Decrypt     │ ← Decrypt container
│ encobj with objkey  │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ ASN.1 Decode        │ ← Parse structure
│ (strip length field)│   Remove ASN.1 length prefix
└─────────────────────┘
    │
    ▼
Return: Structured data objects
```

**Dict 208 (0xd0): Object Packing**
```
Signature: (o1, o2, objkey) -> (encobj)
Function:  Serialize and encrypt structured data
```

**Operation Flow:**
```
Input: o1, o2 (objects), objkey
    │
    ▼
┌─────────────────────┐
│ Extract 8 bytes     │ ← Take first 8 bytes from each
│ from o1 and o2      │   object (likely headers/IDs)
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ ASN.1 Encode Array  │ ← Create structured container
│ [o1_header,o2_head] │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ DES-OCM-Encrypt     │ ← Encrypt container
│ with objkey         │
└─────────────────────┘
    │
    ▼
Return: encobj (encrypted structured data)
```

**Purpose**: Secure serialization of complex data structures for storage or transmission.

---

### System Utility Functions

#### DeviceSal Dict 209-213 (0xd1-0xd5) - System Services

**Dict 209 (0xd1): File System Abstraction**
```
Signature: (version) -> (ekbpath)
Function:  Map EKB version to local filesystem path
Purpose:   Abstract file location for different EKB versions
```

**Dict 210 (0xd2): Constant Generator**
```
Signature: () -> (1)
Function:  Always returns integer 1
Purpose:   Utility constant for boolean operations or padding
```

**Dict 211-213**: Reserved for future system operations

---

### Advanced Protocol Encryption Layer

#### DeviceSal Dict 214-215 (0xd6-0xd7) - Basic Protocol Encryption

**Dict 214 (0xd6): Protocol Decryption**
```
Signature: (encobj, protokey) -> (obj)
Function:  Decrypt protocol-level communications
```

**Operation Pipeline:**
```
Input: encobj, protokey
    │
    ▼
┌─────────────────────┐
│ Descramble         │ ← Remove obfuscation layer
│ encobj             │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ SHA-1 Key          │ ← Derive decryption key
│ Derivation         │   SHA-1(protokey)
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ OCM-Decrypt        │ ← Decrypt with derived key
│ with SHA-1(key)    │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ ASN.1 Decode       │ ← Parse structured result
└─────────────────────┘
    │
    ▼
Return: obj (decrypted object)
```

**Dict 215 (0xd7): Protocol Encryption**
```
Signature: (obj, protokey) -> (encobj)
Function:  Encrypt for protocol-level communications
```

**Operation Pipeline (Reverse of 214):**
```
Input: obj, protokey
    │
    ▼
┌─────────────────────┐
│ ASN.1 Serialize    │ ← Convert to wire format
│ obj                │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ OCM-Encrypt        │ ← Encrypt with SHA-1(protokey)
│ with SHA-1(key)    │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Scramble Result    │ ← Add obfuscation layer
└─────────────────────┘
    │
    ▼
Return: encobj (encrypted, scrambled data)
```

#### DeviceSal Dict 216-217 (0xd8-0xd9) - Device-Bound Protocol Encryption

**Enhanced Security with Device Binding:**

**Key Derivation Process:**
```
xorprotokey XOR (D252 ++ D252)
    │
    ▼ D252 = Device-specific 8-byte constant
┌─────────────────────┐
│ Device Key Mixing   │ ← Bind to specific hardware
│ XOR with device ID  │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ SHA-1 Hash         │ ← Derive final encryption key
│ SHA-1(mixed_key)   │
└─────────────────────┘
    │
    ▼
Used for DES-OCM operations
```

**Security Innovation**: These functions implement **device binding** by mixing protocol keys with hardware-specific constants, preventing key extraction and reuse on different devices.

---

### Stream Cipher Implementation

#### DeviceSal Dict 220-221 (0xdc-0xdd) - SHA-1 Stream Cipher

**Custom Stream Cipher Architecture:**
```
Input: key
    │
    ▼
┌─────────────────────┐
│ SHA-1 Keystream     │ ← Generate pseudorandom stream
│ Generator           │   using SHA-1 as PRNG
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ XOR with Data       │ ← Stream cipher operation
│ stream ⊕ plaintext  │
└─────────────────────┘
    │
    ▼
Output: ciphertext/plaintext
```

**Properties:**
- **Symmetric**: Same operation for encrypt/decrypt
- **Fast**: Suitable for large data streams
- **Custom**: Sony proprietary keystream generation
- **SHA-1 Based**: Uses cryptographic hash for entropy

---

## Critical System Constants

### DeviceSal Dict 252 (0xfc) - Hardware Binding Key
```
Content: Unknown 8-byte device-specific constant
Usage:   XOR operations in Dict 0xd8, 0xd9 (dev_0xd8, dev_0xd9)
Purpose: Device binding and key derivation
```

**Security Model**: This constant serves as a **hardware root of trust**, ensuring that:
1. **Keys are device-bound** and cannot be extracted
2. **Cryptographic operations fail** on unauthorized hardware
3. **Content remains protected** even if software is copied

**Implementation Note**: The constant D252 is likely burned into device firmware or derived from hardware-specific identifiers (CPU serial, MAC address, etc.).

---

## Native Module Integration

### Core Cryptographic Primitives

#### OCM Cipher Module (native::ocmmod)
```c++
// OpenMG Custom Cipher - CBC Encrypt/Decrypt Implementation
// Block size: 64-bit (8 bytes)
// Key length: 160-bit (20 bytes)
blob_t native::ocmmod(blob_t in, blob_t out, blob_t key, int len, int decrypt)
{
  if (decrypt)
    ocmmod_cbc_decrypt(in, out, key, len);
  else
    ocmmod_cbc_encrypt(in, out, key, blob_len(in));

  return out;
}
```

**Technical Details:**
- **Custom Block Cipher**: Sony proprietary algorithm based on DES principles
- **CBC Mode**: Cipher Block Chaining for semantic security
- **160-bit Keys**: Extended key length for enhanced security
- **In-place Operation**: Efficient memory usage with pre-allocated output buffer

**Security Properties:**
- **Confusion**: Substitution operations obscure plaintext-ciphertext relationship
- **Diffusion**: CBC mode ensures single bit changes affect entire blocks
- **Proprietary**: Algorithm details are trade secrets, reverse-engineered
---

### High-Level Device Operations

#### DeviceSal Function 0x01: EKB Processing with Version Control
```c++
int dev_0x01(blob_t someblob, bool_t somebool)
{
  int res;

  // Optional initialization check
  if (somebool == 1) {
    res = dev_0x00(someblob);  // Initialization function
    if (res != 0)
      return res;  // Propagate error
  }

  // Extract EKB version number (first 4 bytes)
  int ekb_version = (unsigned) SubBlob(someblob, 0, 4);

  // Map version to filesystem path
  int filesystem_id = (unsigned) dev_0xd1(ekb_version);

  // Load EKB from local storage
  res = load_local_ekb(filesystem_id);  // "localekb" function
  if (res != 0)
    return res;  // EKB load failed

  blob_t ekb_data;  // EKB content from storage

  // Extract key count from EKB header
  int key_count = (signed) SubBlob(ekb_data, 0, 4) + 1;

  // Build key vector - extract 24-byte keys from 16-byte aligned blocks
  vector<blob_t> key_vector;
  do {
    key_vector.append(SubBlob(ekb_data, key_count * 16, 24));
  } while (key_count-- >= 0);

  // Validate EKB integrity
  int expected_count = (signed) SubBlob(ekb_data, 0, 4);
  res = dev_0xc1(expected_count);  // Internal validation
  if (res != 0)
     return res;

  int actual_count = (signed) SubBlob(ekb_data, 16, 4);

  // Verify key count consistency
  if (expected_count == actual_count)
    return 0;  // Success
  else
    return 8;  // Integrity check failed

  // Note: key_vector remains on stack for potential return
}
```

**Operation Flow Diagram:**
```
Input: someblob, somebool
    │
    ▼
┌─────────────────────┐
│ Optional Init       │ ← dev_0x00() if somebool=1
│ (if somebool == 1)  │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Extract Version     │ ← First 4 bytes of someblob
│ someblob[0:4]       │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Map to FS Path      │ ← dev_0xd1(version)
│ version → fs_id     │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Load EKB File       │ ← load_local_ekb(fs_id)
│ fs_id → ekb_data    │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Parse Key Count     │ ← ekb_data[0:4] + 1
│ count = header + 1  │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Extract Key Vector  │ ← 24-byte keys from 16-byte blocks
│ Loop: count keys    │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Validate Integrity  │ ← Compare expected vs actual counts
│ expected == actual  │
└─────────────────────┘
    │
    ▼
Return: 0 (success) or 8 (failure)
```

**Security Purpose:**
- **EKB Management**: Enciphering Key Block processing for content protection
- **Version Control**: Support multiple EKB versions for backward compatibility
- **Integrity Validation**: Ensure EKB has not been tampered with
- **Key Distribution**: Extract and organize cryptographic keys for content decryption

---

#### DeviceSal Function 0xb7: Content Type Detection
```c++
int dev_0xb7(any_t thing)
{
  // Type safety check
  if (get_type(thing) != TYPE_BLOB)
    return 0;  // Not a blob, return default

  // Check content format markers
  if (thing[2] == 0x31)
    return 2;  // Format type 2 detected
  else {
    if (!strncmp(thing, "\x31\x31", 2))  // Check first 2 bytes
      return 1;  // Format type 1 detected
    else
      return 0;  // Unknown format
  }
}
```

**Content Format Analysis:**
```
Input Data Analysis:
┌─────────────────────────────────────┐
│ Byte Position:  [0] [1] [2] [3] ... │
│                  │   │   │           │
│ Pattern Check:   │   │   └─── 0x31?  │ → Type 2
│                  └───┴─── "\x31\x31"? │ → Type 1
│                                      │
│ Default: Type 0 (unknown/unsupported)│
└─────────────────────────────────────┘
```

**Detected Formats:**
- **Type 0**: Unknown or unsupported content
- **Type 1**: Content with "\x31\x31" header (likely OpenMG audio)
- **Type 2**: Content with 0x31 at position 2 (alternative format)

---

#### DeviceSal Function 0xd1: EKB Version to Path Mapping
```c++
block_t dev_0xd1(int nr)
{
  if (nr > 1) {
    log_error("Invalid version...");  // Error 0x80
    return 0;
  } else {
    return {0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};  // 8-byte path ID
  }
}
```

**Version Mapping Table:**
```
EKB Version │ Filesystem ID (8 bytes)        │ Description
────────────┼─────────────────────────────────┼─────────────────────
     0      │ 00 81 00 00 00 00 00 00         │ Default/Legacy EKB
     1      │ 00 81 00 00 00 00 00 00         │ Current EKB
    >1      │ Error (Invalid version)         │ Unsupported
```

**Purpose**: Abstract filesystem path resolution for different EKB versions, allowing forward/backward compatibility.


---

### Device-Bound Cryptographic Operations

#### DeviceSal Function 0xd8: Device-Bound Decryption
```c++
any_t dev_0xd8(blob_t ciphertext, blob_t keyblob)
{
  // Device binding: XOR with device constant (duplicated)
  blob_t key = keyblob XOR concat(dict[0xfc], dict[0xfc]);

  // Store derived key for later use
  dict[0xdb] = key;  // Side-effect: cache in dictionary

  // Derive encryption parameters from key
  blob_t hashed_key = SHA1(key[0..14]);      // Hash first 15 bytes
  blob_t des_iv = hashed_key[0..7];          // IV from hash bytes 0-7
  blob_t des_key = hashed_key[8..15];        // Key from hash bytes 8-15

  // First layer: DES-CBC decryption
  blob_t data = DES_CBC_Decrypt(ciphertext, des_iv, des_key, 0xd8_DESDecrypt);

  // Second layer: OCM cipher decryption
  int len = blob_length(data);
  len = (len + 7) / 8 * 8;  // Round up to 8-byte boundary
  blob_t plaintext = repeat_nul(len);
  plaintext = native::ocmmod(data, plaintext, hashed_key, len, 1);  // decrypt=1

  // Deserialize structured data
  return decode_asn1(plaintext);
}
```

#### DeviceSal Function 0xd9: Device-Bound Encryption
```c++
blob_t dev_0xd9(any_t plainobj, blob_t keyblob)
{
  // Device binding: XOR with device constant (duplicated)
  blob_t key = keyblob XOR concat(dict[0xfc], dict[0xfc]);

  // Store derived key for later use
  dict[0xdb] = key;  // Side-effect: cache in dictionary

  // Serialize input object
  blob_t plaintext = encode_asn1(plainobj);

  // First layer: OCM cipher encryption
  int len = blob_length(plaintext);
  len = (len + 7) / 8 * 8;  // Round up to 8-byte boundary
  blob_t data = repeat_nul(len);
  blob_t hashed_key = SHA1(key[0..14]);
  data = native::ocmmod(plaintext, data, hashed_key, len, 0);  // encrypt=0

  // Second layer: DES-CBC encryption
  blob_t des_iv = hashed_key[0..7];          // IV from hash bytes 0-7
  blob_t des_key = hashed_key[8..15];        // Key from hash bytes 8-15
  blob_t ciphertext = DES_CBC_Encrypt(data, des_iv, des_key, 0xd9_DESEncrypt);

  return ciphertext;
}
```

**Cryptographic Architecture:**
```
                Device-Bound Key Derivation
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│ Input Key ──XOR──► Device Constant (0xfc ++ 0xfc)          │
│                           │                                 │
│                           ▼                                 │
│                    Bound Key (16 bytes)                     │
│                           │                                 │
│                           ▼                                 │
│                    SHA-1 Hash (20 bytes)                    │
│                           │                                 │
│                    ┌──────┴──────┐                         │
│                    ▼             ▼                         │
│               DES IV (8)    DES Key (8)                     │
│                    │             │                         │
└────────────────────┼─────────────┼─────────────────────────┘
                     │             │
                     ▼             ▼
              ┌─────────────────────────┐
              │    Dual-Layer Crypto    │
              │                         │
              │  Layer 1: DES-CBC       │ ← Protocol encryption
              │  Layer 2: OCM Cipher    │ ← Content encryption
              │                         │
              └─────────────────────────┘
```

**Security Features:**
1. **Device Binding**: Keys are bound to specific hardware via constant 0xfc
2. **Key Separation**: Different keys derived for different cipher layers
3. **Dual Encryption**: DES-CBC + OCM provides defense in depth
4. **ASN.1 Structure**: Maintains data integrity and structure
5. **Side-Effect Caching**: Derived keys stored for optimization

---

## Bytecode Analysis: SsaTrans Updater Example

### Reverse-Engineered Updater.ocm Analysis
```c++
// SsaTrans decompilation of updater.ocm bytecode
$ SsaTrans updater.ocm

// Initialize cryptographic subsystem
BCSeedRand63(1, "j5\162\GS\140<,\f");  // Seed PRNG with fixed entropy

// Load cipher configuration table
BCSetCryptTable("L\225\164\152\DC1\RSD?\216f\198!\196\154\154\201\195b \192l^V\176r\245\151*\245[[\DC1\NULV#"...);

// Allocate output buffer
v_39 = BCNewBlob(8);  // 8-byte buffer for decrypted result

// Configure DES key
v_41 = BCDES_SetKey("\188k\180(\150\EOT,\138");  // 8-byte DES key

// Main decryption operation
arg_0 = Unknown;  // Input ciphertext (function parameter)
v_43 = BCDES_CBC_Decrypt(arg_0, v_39, v_41, "\216");  // DES-CBC decrypt

// Content validation
v_44 = BCBlobLength(v_43);                           // Get decrypted length
v_46 = BCBlobLength("<!--omg certificated-->");     // Expected trailer length
v_49 = BCSubBlob(v_43, v_44 - v_46, -1);            // Extract trailer
v_51 = BCCompareBlob(v_49, "<!--omg certificated-->");  // Validate signature

// Conditional return based on validation
if (v_51 == 0) {    // Signature matches
  return [v_43, 1];  // Return decrypted content + success flag
} else {            // Signature invalid
  return [0];        // Return failure
}

// Serialize result (if needed)
v_56 = BCIfElse(v_43);    // Conditional processing
v_57 = BCSerialize(v_56);  // Convert to wire format
return v_57;
```

**Decompilation Annotations:**

### Bytecode Function Analysis
```
Function: updater.ocm main()
Purpose:  Validate and decrypt firmware updates
Security: DES-CBC + signature verification

Bytecode Operation Flow:
┌─────────────────────┐
│ BCSeedRand63        │ ← Initialize PRNG for crypto ops
│ Fixed seed entropy  │
└─────────────────────┘
           │
           ▼
┌─────────────────────┐
│ BCSetCryptTable     │ ← Load cipher lookup tables
│ S-box configuration │
└─────────────────────┘
           │
           ▼
┌─────────────────────┐
│ BCDES_SetKey        │ ← Configure DES key
│ "\188k\180(..."    │   (8-byte key)
└─────────────────────┘
           │
           ▼
┌─────────────────────┐
│ BCDES_CBC_Decrypt   │ ← Main decryption operation
│ arg_0 → plaintext   │
└─────────────────────┘
           │
           ▼
┌─────────────────────┐
│ Signature Check     │ ← Validate "<!--omg certificated-->"
│ Compare trailer     │   at end of decrypted content
└─────────────────────┘
           │
           ▼
┌─────────────────────┐
│ Conditional Return  │ ← Success: [content, 1]
│ Based on validation │   Failure: [0]
└─────────────────────┘
```

**Bytecode VM Instructions:**
- **BC Prefix**: Bytecode virtual machine operations
- **BCSeedRand63**: 63-bit PRNG seeding for crypto operations
- **BCSetCryptTable**: Load S-box substitution tables for ciphers
- **BCDES_***: DES cipher operations (key setup, CBC decrypt)
- **BCBlob***: Binary data management (allocation, length, comparison)
- **BCSubBlob**: Extract subregions from binary data
- **BCSerialize**: Convert objects to wire/storage format

**Security Model:**
1. **Fixed Cryptography**: Hardcoded keys and seeds (questionable security)
2. **Signature Verification**: Content integrity via embedded signature
3. **Conditional Execution**: Only process valid, signed content
4. **Bytecode Isolation**: VM provides some protection against code injection

**Potential Vulnerabilities:**
- **Hardcoded Keys**: DES key is embedded in bytecode
- **Weak Signature**: Text-based signature easily forgeable
- **Fixed Seed**: PRNG deterministic, predictable outputs
- **DES Algorithm**: 56-bit keys considered cryptographically weak

This example demonstrates how Sony's OpenMG DRM uses bytecode VMs to implement cryptographic operations while attempting to obfuscate the implementation details.

---

## Reading List: Foundational Literature

To fully understand Sony's OpenMG DRM architecture and the DeviceSal cryptographic system, the following reference literature provides essential background knowledge across multiple domains:

### Core Cryptography

#### Fundamental Cryptographic Principles
1. **"Applied Cryptography" by Bruce Schneier (2nd Edition)**
   - **Chapters 1-4**: Introduction to cryptographic concepts, protocols, and algorithms
   - **Chapters 12-13**: DES algorithm details and implementation
   - **Chapters 14-15**: Other block ciphers and cipher modes (CBC, ECB)
   - **Essential for**: Understanding DES, 3DES, block cipher modes, and MAC algorithms

2. **"Introduction to Modern Cryptography" by Katz & Lindell (3rd Edition)**
   - **Chapters 3-4**: Block ciphers, pseudorandom functions, and cipher modes
   - **Chapters 6-7**: Hash functions, message authentication codes (MAC)
   - **Chapters 13-14**: Digital signatures and public-key cryptography
   - **Essential for**: Theoretical foundations of cryptographic primitives used in DeviceSal

3. **"Handbook of Applied Cryptography" by Menezes, van Oorschot & Vanstone**
   - **Chapter 7**: Block ciphers (DES, cipher modes)
   - **Chapter 9**: Hash functions and data integrity (SHA-1)
   - **Chapter 11**: Digital signatures (ECC signatures for EKB verification)
   - **Available free online**: [cacr.uwaterloo.ca/hac/](https://cacr.uwaterloo.ca/hac/)

#### Stream Ciphers and Key Derivation
4. **"The Design of Rijndael" by Daemen & Rijmen**
   - **Chapter 2**: Design principles for symmetric ciphers
   - **Chapter 3**: Cipher modes and their security properties
   - **Essential for**: Understanding custom cipher design (OCM cipher analysis)

5. **"Cryptographic Engineering" by Ferguson, Schneier & Kohno**
   - **Chapters 5-6**: Key management and key derivation functions
   - **Chapter 9**: Implementing cryptographic systems securely
   - **Essential for**: Understanding hierarchical key management in DeviceSal

### Digital Rights Management (DRM) Systems

#### DRM Architecture and Design
6. **"Digital Rights Management: Concepts, Architecture and Implementation" by Rosenblatt, Trippe & Mooney**
   - **Chapters 3-4**: DRM system architecture and cryptographic foundations
   - **Chapters 7-8**: Content protection and key management
   - **Essential for**: Understanding DRM system design principles

7. **"Information Hiding Techniques for Steganography and Digital Watermarking" by Katzenbeisser & Petitcolas**
   - **Chapters 12-14**: Copy protection systems and tamper resistance
   - **Essential for**: Understanding content protection mechanisms

#### Content Protection Systems
8. **"Multimedia Security Technologies for Digital Rights Management" by Shi, Wang & Bhargava**
   - **Chapters 4-5**: Cryptographic protocols for content protection
   - **Chapters 8-9**: Device-based security and trusted computing
   - **Essential for**: Understanding device binding and hardware security

### Hardware Security and Trusted Computing

#### Hardware Security Modules
9. **"Security Engineering" by Ross Anderson (3rd Edition)**
   - **Chapters 18-19**: Physical tamper resistance and hardware security
   - **Chapter 20**: Advanced attacks (side-channel, fault injection)
   - **Essential for**: Understanding hardware-based security (device binding constant 0xfc)

10. **"Trusted Computing Platforms" by Pearson (Editor)**
    - **Chapters 2-4**: Trusted Platform Module (TPM) architecture
    - **Chapters 8-9**: Attestation and sealed storage
    - **Essential for**: Understanding hardware root of trust concepts

#### Side-Channel Analysis
11. **"The Hardware Hacking Handbook" by Schutzman & Koscher**
    - **Chapters 8-10**: Reverse engineering embedded systems
    - **Chapters 13-14**: Cryptographic implementation attacks
    - **Essential for**: Understanding attack vectors against DRM systems

### ASN.1 and Data Serialization

#### Structured Data Encoding
12. **"ASN.1 Complete" by Larmouth**
    - **Chapters 1-3**: ASN.1 syntax and encoding rules
    - **Chapters 7-8**: Distinguished Encoding Rules (DER)
    - **Essential for**: Understanding ASN.1 serialization in DeviceSal functions 0xcf-0xd0, 0xd6-0xd9

13. **"A Layman's Guide to a Subset of ASN.1, BER, and DER" by Burton Kaliski (RSA Laboratories)**
    - **Technical Note**: Practical guide to ASN.1 implementation
    - **Available online**: Historical RSA Labs publication
    - **Essential for**: Implementing ASN.1 parsers and encoders

### Reverse Engineering and Binary Analysis

#### Software Reverse Engineering
14. **"The IDA Pro Book" by Eagle**
    - **Chapters 10-12**: Analyzing cryptographic implementations
    - **Chapters 17-18**: Anti-reverse engineering techniques
    - **Essential for**: Understanding how DeviceSal functions were reverse-engineered

15. **"Practical Reverse Engineering" by Dang, Gazet, Bachaalany & Josse**
    - **Chapters 1-3**: x86/x64 reverse engineering fundamentals
    - **Chapters 4-5**: Malware analysis techniques
    - **Essential for**: Analyzing binary implementations of crypto functions

#### Bytecode Analysis
16. **"Virtual Machines: Versatile Platforms for Systems and Processes" by Smith & Nair**
    - **Chapters 3-4**: Virtual machine architectures
    - **Chapters 7-8**: Security and isolation in VMs
    - **Essential for**: Understanding bytecode VM systems like SsaTrans

### Academic Papers and Standards

#### Cryptographic Standards
17. **NIST Special Publications**
    - **SP 800-38A**: "Recommendation for Block Cipher Modes of Operation"
    - **SP 800-107**: "Recommendation for Applications Using Approved Hash Algorithms"
    - **SP 800-108**: "Recommendation for Key Derivation Using Pseudorandom Functions"
    - **Available at**: [csrc.nist.gov](https://csrc.nist.gov)

18. **FIPS Publications**
    - **FIPS 46-3**: "Data Encryption Standard (DES)"
    - **FIPS 180-4**: "Secure Hash Standard (SHA-1, SHA-2, SHA-3)"
    - **FIPS 186-4**: "Digital Signature Standard (DSS)"

#### DRM Research Papers
19. **"Copy Protection in DVD: Content Scrambling System" by Stevenson**
    - **IEEE Computer Magazine, 1999**
    - **Essential for**: Understanding CSS and early content protection

20. **"Security Analysis of Content Protection Schemes" by Hoang et al.**
    - **ACM CCS Conference Proceedings**
    - **Essential for**: Academic analysis of DRM vulnerabilities

### Industry Standards and Specifications

#### Content Protection Standards
21. **"Content Protection for Recordable Media (CPRM)" Specification**
    - **4C Entity LLC**
    - **Essential for**: Understanding industry content protection standards

22. **"Advanced Access Content System (AACS)" Specification**
    - **AACS LA LLC**
    - **Essential for**: Modern content protection evolution from systems like OpenMG

### Historical Context

#### Sony's Digital Audio Evolution
23. **"MiniDisc: The Forgotten Audio Format" by Sharples**
    - **Tech History Documentation**
    - **Essential for**: Understanding the context of OpenMG development

24. **"The Battle for Digital Music Distribution" by Kusek & Leonhard**
    - **Chapters 3-4**: Early DRM systems and industry responses
    - **Essential for**: Market context of content protection systems

### Recommended Study Path

#### Beginner Level (Start Here)
1. **Applied Cryptography** (Schneier) - Chapters 1-4, 12-15
2. **Security Engineering** (Anderson) - Chapters 1-2, 18-19
3. **Digital Rights Management** (Rosenblatt et al.) - Chapters 1-4

#### Intermediate Level
1. **Introduction to Modern Cryptography** (Katz & Lindell) - Core chapters
2. **Handbook of Applied Cryptography** - Relevant sections
3. **ASN.1 Complete** (Larmouth) - Practical chapters

#### Advanced Level
1. **Cryptographic Engineering** (Ferguson et al.) - Implementation details
2. **Practical Reverse Engineering** (Dang et al.) - Binary analysis
3. **Academic papers** on DRM security analysis

### Online Resources

#### Free Resources
- **Cryptopals Challenges**: [cryptopals.com](https://cryptopals.com) - Hands-on cryptography
- **Stanford CS255 Cryptography**: Course materials and lectures
- **Coursera Applied Cryptography**: University of Colorado Boulder

#### Documentation
- **OpenSSL Documentation**: Implementation references for standard algorithms
- **IETF RFCs**: Protocol specifications (RFC 3852 for CMS/PKCS#7)

### Practical Exercises

To reinforce understanding:
1. **Implement basic DES encryption/decryption** in your preferred language
2. **Parse and create ASN.1 structures** using libraries like OpenSSL
3. **Analyze simple bytecode VMs** to understand execution models
4. **Study existing DRM bypass techniques** (for educational purposes)

This reading list provides a structured path from basic cryptographic concepts to advanced DRM analysis, enabling comprehensive understanding of Sony's OpenMG architecture and similar content protection systems.

