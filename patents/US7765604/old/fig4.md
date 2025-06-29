# Figure 4: Content Server Processing Flowchart

## Description
Figure 4 illustrates the server-side processing workflow when a content server responds to a client's content request (initiated in Step S2 of Figure 3). This flowchart details how the content server securely prepares and transmits protected digital content to authorized clients.

## System Architecture Note
The content server uses the same hardware architecture as the client device (shown in Figure 2), with identical component reference numbers used throughout this description.

## Detailed Process Steps

### Step S21: Client Connection Monitoring
**Server State**: Waiting for client access
- **Process**: CPU (21) monitors for incoming client connections
- **Network**: Communication unit (29) listens for access via Internet (2)
- **Trigger**: Client connection detected and established
- **Result**: Server ready to process client requests

### Step S22: Content Request Processing
**Request Reception**: Acquiring client's content specification
- **Data Source**: Information transmitted by client at Step S2 (Figure 3)
- **Processing**: CPU (21) receives and parses content specification
- **Validation**: Server validates request format and client authorization
- **Result**: Content identifier extracted and validated

### Step S23: Content Retrieval
**Storage Access**: Reading requested content from local storage
- **Location**: Content retrieved from storage unit (28)
- **Selection**: Specific content identified from stored content library
- **Format**: Content already encoded using ATRAC-3 system by codec unit (25)
- **Result**: Raw encoded content ready for security processing

### Step S24: Content Encryption
**Security Processing**: Encrypting content for secure transmission
- **Component**: CPU (21) supplies content to encryption/decryption unit (24)
- **Encryption Key**: Content encrypted using content key Kc
- **Input Format**: ATRAC-3 encoded content from storage
- **Alternative**: Pre-encrypted content can skip this step if stored encrypted
- **Result**: Securely encrypted content ready for transmission

### Step S25: Security Header Creation
**Metadata Assembly**: Adding cryptographic keys and license information
- **Header Components**:
  - **EKB (Enabling Key Block)**: Device-specific key management structure
  - **Content Key K(Kc)**: Encrypted content decryption key
  - **License ID**: Identifier for required content usage license
- **Purpose**: Enable client-side license validation and content decryption
- **Reference**: Key structure detailed in Figure 5
- **Result**: Complete transmission package with security metadata

### Step S26: Secure Content Transmission
**Data Delivery**: Transmitting formatted content package to client
- **Format Structure**: Encrypted content + security header
- **Transmission**: CPU (21) sends data via communication unit (29) and Internet (2)
- **Destination**: Client device (as specified in original request)
- **Result**: Protected content successfully delivered to client

## ASCII Flowchart Diagram

```
                    CONTENT SERVER PROCESSING FLOW

    ┌─────────────────────────────────────────────────────────────────┐
    │                        START                                    │
    │                 (Server Running)                                │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S21                                     │
    │              Connection Monitoring                              │
    │                                                                 │
    │  CPU (21) waiting for access → Communication unit (29)         │
    │  monitors Internet (2) → Client connection detected            │
    │                                                                 │
    │  Result: Ready to process client request                       │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S22                                     │
    │             Content Request Processing                          │
    │                                                                 │
    │  Receive content specification from client (Step S2, Fig 3)    │
    │  → CPU (21) acquires and parses request → Validate request     │
    │                                                                 │
    │  Result: Content identifier extracted                          │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S23                                     │
    │               Content Retrieval                                 │
    │                                                                 │
    │  CPU (21) reads specified content from Storage Unit (28)       │
    │  → Select from content library → ATRAC-3 encoded format        │
    │                                                                 │
    │  Result: Raw encoded content ready for encryption              │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S24                                     │
    │               Content Encryption                                │
    │                                                                 │
    │  CPU (21) → Encryption/Decryption Unit (24) → Encrypt with     │
    │  Content Key Kc → Apply to ATRAC-3 encoded content             │
    │                                                                 │
    │  Alternative: Skip if content pre-encrypted in storage         │
    │  Result: Securely encrypted content                            │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S25                                     │
    │            Security Header Creation                             │
    │                                                                 │
    │  CPU (21) adds to transmission header:                         │
    │  • EKB (Enabling Key Block)                                    │
    │  • Content Key K(Kc) - encrypted                               │
    │  • License ID - for license identification                     │
    │                                                                 │
    │  Result: Complete secure transmission package                  │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S26                                     │
    │             Secure Content Transmission                        │
    │                                                                 │
    │  CPU (21) → Communication Unit (29) → Internet (2) →           │
    │  Client Device                                                  │
    │                                                                 │
    │  Transmitted: Encrypted Content + Security Header              │
    │  Result: Protected content delivered to client                 │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                       END                                       │
    │            Content Successfully Transmitted                     │
    └─────────────────────────────────────────────────────────────────┘
```

## Key Security Features

### Encryption Architecture
- **Content Key Kc**: Unique key for each content item
- **ATRAC-3 Encoding**: Audio compression before encryption
- **EKB Structure**: Device-specific key management (detailed in Figure 5)
- **License Integration**: Content tied to specific license requirements

### Transmission Security
- **Encrypted Payload**: Content encrypted before transmission
- **Secure Headers**: Cryptographic metadata included
- **License Binding**: Content associated with usage permissions
- **Device Targeting**: Keys structured for specific client devices

## Content Server Components Used

### Processing Components
- **CPU (21)**: Orchestrates entire content delivery process
- **Storage Unit (28)**: Houses content library and pre-encoded media
- **Encryption/Decryption Unit (24)**: Hardware-accelerated content encryption
- **Communication Unit (29)**: Network interface for client communication

### Content Formats
- **Input**: ATRAC-3 encoded content from storage
- **Processing**: Real-time encryption with content-specific keys
- **Output**: Encrypted content with security headers
- **Alternative**: Pre-encrypted content storage option available

## Integration Points

### Client Interaction
- **Trigger**: Responds to client request from Figure 3, Step S2
- **Coordination**: Server processing enables client's Step S3 content reception
- **Security**: Prepared content requires separate license acquisition for client use

### System Security
- **Figure 5 Reference**: EKB key structure detailed in separate diagram
- **License System**: Content delivery coordinated with license server operations
- **DRM Framework**: Complete content protection through encryption and licensing

## Process Optimization
- **Pre-encryption Option**: Content can be stored encrypted to eliminate real-time encryption
- **Efficient Encoding**: ATRAC-3 provides optimal balance of quality and file size
- **Scalable Architecture**: Same hardware components as client enable flexible deployment
