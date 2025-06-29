# Figure 5: Content Format Structure

## Description
Figure 5 illustrates the detailed format structure of encrypted content transmitted from the content server to client devices. This format defines how protected digital content is packaged with its associated security metadata, encryption keys, and licensing information.

## Content Format Overview
The content format consists of two main sections:
- **Header**: Contains metadata, security information, and decryption keys
- **Data Portion**: Contains the actual encrypted content in multiple blocks

## Header Structure

### Content Information
- **Content ID (CID)**: Unique identifier for the specific content
- **Codec Information**: Details about the encoding system used (e.g., ATRAC-3)
- **Purpose**: Enables client to identify and properly decode the content

### DRM (Digital Rights Management) Information
**Usage Rules and Status**:
- Number of times content has been played
- Usage restrictions and permissions
- Content access policies

**License Server URL**:
- **Function**: Address for acquiring required licenses
- **Format**: URL (Uniform Resource Locator)
- **Target**: Points to license server (4) in the content exchange system
- **Purpose**: Enables automatic license acquisition when needed

### License ID
- **Function**: Unique identifier for the license required to use this content
- **Usage**: Links content to specific license in license server database
- **Security**: Ensures content can only be used with proper authorization

### EKB (Enabling Key Block)
- **Function**: Device-specific key management structure
- **Security**: Contains encrypted keys for authorized devices
- **Reference**: Detailed structure explained in Figure 15
- **Purpose**: Enables secure key distribution to multiple devices

### Encrypted Content Key K(Kc)
- **Structure**: Content key Kc encrypted using key K derived from EKB
- **Security**: Prevents direct access to content decryption key
- **Process**: Key K generated from EKB, then used to encrypt content key Kc

## Data Portion Structure

### Encrypted Block Format
Each encrypted block contains:
- **Initial Vector (IV)**: Cryptographic initialization value
- **Seed**: Random value for key derivation
- **Encrypted Data**: Content encrypted with derived key K'c

### Block-Level Security
**Key Derivation Formula**:
```
K'c = Hash(Kc, Seed)
```

**Key Properties**:
- Each block uses a unique derived key K'c
- Seed value varies per block (randomly generated)
- Hash function combines content key Kc with block-specific seed

### Encryption Method: CBC (Cipher Block Chaining)

**Block Processing**:
- Content encrypted in 8-byte units
- Each 8-byte block uses previous block's encryption result
- First block uses Initial Vector (IV) as starting point

**Security Benefits**:
- **Block Independence**: Decrypting one block doesn't compromise others
- **Chaining Protection**: Each block depends on previous encryption
- **IV Randomization**: Different IV per encrypted block prevents pattern analysis

## ASCII Format Diagram

```
                        CONTENT FORMAT STRUCTURE

    ┌─────────────────────────────────────────────────────────────────┐
    │                         HEADER                                  │
    ├─────────────────────────────────────────────────────────────────┤
    │  Content Information                                            │
    │  ┌─────────────────┐ ┌─────────────────────────────────────────┐│
    │  │ Content ID (CID)│ │     Codec System Information           ││
    │  └─────────────────┘ └─────────────────────────────────────────┘│
    ├─────────────────────────────────────────────────────────────────┤
    │  DRM Information                                                │
    │  ┌─────────────────┐ ┌─────────────────────────────────────────┐│
    │  │ Usage Rules     │ │    License Server URL                  ││
    │  │ & Status        │ │                                         ││
    │  └─────────────────┘ └─────────────────────────────────────────┘│
    ├─────────────────────────────────────────────────────────────────┤
    │  License ID                                                     │
    │  ┌─────────────────────────────────────────────────────────────┐│
    │  │          License Identifier                                 ││
    │  └─────────────────────────────────────────────────────────────┘│
    ├─────────────────────────────────────────────────────────────────┤
    │  EKB (Enabling Key Block)                                       │
    │  ┌─────────────────────────────────────────────────────────────┐│
    │  │      Device-Specific Key Management Structure               ││
    │  │             (Details in Figure 15)                         ││
    │  └─────────────────────────────────────────────────────────────┘│
    ├─────────────────────────────────────────────────────────────────┤
    │  Encrypted Content Key K(Kc)                                   │
    │  ┌─────────────────────────────────────────────────────────────┐│
    │  │    Content Key Kc encrypted with Key K from EKB            ││
    │  └─────────────────────────────────────────────────────────────┘│
    └─────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────┐
    │                      DATA PORTION                               │
    ├─────────────────────────────────────────────────────────────────┤
    │  Encrypted Block 1                                              │
    │  ┌───────────┐ ┌──────────┐ ┌─────────────────────────────────┐ │
    │  │Initial    │ │  Seed    │ │    Encrypted Data               │ │
    │  │Vector(IV) │ │(Random)  │ │    EK'c(Content)                │ │
    │  └───────────┘ └──────────┘ └─────────────────────────────────┘ │
    ├─────────────────────────────────────────────────────────────────┤
    │  Encrypted Block 2                                              │
    │  ┌───────────┐ ┌──────────┐ ┌─────────────────────────────────┐ │
    │  │Initial    │ │  Seed    │ │    Encrypted Data               │ │
    │  │Vector(IV) │ │(Random)  │ │    EK'c(Content)                │ │
    │  └───────────┘ └──────────┘ └─────────────────────────────────┘ │
    ├─────────────────────────────────────────────────────────────────┤
    │                           ...                                   │
    ├─────────────────────────────────────────────────────────────────┤
    │  Encrypted Block N                                              │
    │  ┌───────────┐ ┌──────────┐ ┌─────────────────────────────────┐ │
    │  │Initial    │ │  Seed    │ │    Encrypted Data               │ │
    │  │Vector(IV) │ │(Random)  │ │    EK'c(Content)                │ │
    │  └───────────┘ └──────────┘ └─────────────────────────────────┘ │
    └─────────────────────────────────────────────────────────────────┘

                    Key Derivation: K'c = Hash(Kc, Seed)
                    CBC Mode: 8-byte blocks with chaining
```

## Security Architecture

### Multi-Layer Protection
1. **Content Key Encryption**: Kc encrypted with EKB-derived key K
2. **Block-Level Keys**: Each block uses unique derived key K'c
3. **CBC Chaining**: Blocks cryptographically linked for enhanced security
4. **Random Seeds**: Unique seed per block prevents pattern analysis

### Key Management Hierarchy
```
EKB (Device-Specific) → Key K → Encrypts Content Key Kc
Content Key Kc + Random Seed → Hash Function → Block Key K'c
Block Key K'c → Encrypts Content Data in CBC Mode
```

### License Integration
- **Identification**: License ID links content to usage permissions
- **Server Reference**: URL enables automatic license acquisition
- **Usage Tracking**: DRM information monitors content access
- **Device Binding**: EKB ensures content tied to authorized devices

## Key Benefits

### Content Distribution
- **Free Distribution**: Content can be distributed without immediate licensing
- **Secure Packaging**: Complete protection during transmission and storage
- **Flexible Licensing**: License acquisition separate from content download

### Security Features
- **Block Independence**: Compromising one block doesn't affect others
- **Key Diversity**: Multiple keys and random elements prevent analysis
- **Device Specificity**: EKB ensures content works only on authorized devices
- **Usage Control**: DRM information enforces content access policies

### System Integration
- **Server Coordination**: URL links to license server for automatic operations
- **Client Processing**: Format designed for efficient client-side decryption
- **Scalable Architecture**: Supports arbitrary number of encrypted blocks
- **Future Extensibility**: Detailed encryption process expandable (see Figure 46)
