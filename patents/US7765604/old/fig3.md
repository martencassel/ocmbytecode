# Figure 3: Content Access Process Flowchart

## Description
Figure 3 illustrates the step-by-step process for a client device to request and receive digital content from the content server. This flowchart shows the user-initiated content access workflow from initial request to local storage.

## Process Overview
This flowchart demonstrates how users interact with the system to browse, select, and download protected digital content from remote content servers to their local devices.

## Detailed Process Steps

### Step S1: Content Server Access
**User Action**: User initiates content server access
- **Input Method**: User operates input unit (keyboard/mouse) to enter access command
- **System Response**: CPU controls communication unit to establish connection
- **Network Operation**: Communication unit connects to content server through Internet
- **Result**: Secure connection established with content server

### Step S2: Content Selection
**User Action**: User specifies desired content
- **Selection Process**: User browses available content and makes selection via input unit
- **Request Processing**: CPU accepts user's content specification
- **Communication**: Communication unit transmits content request to content server
- **Server Notification**: Content server receives and processes the content request

### Step S3: Content Reception
**Server Response**: Content server transmits requested content
- **Content Processing**: Server encodes content using process detailed in Figure 4
- **Data Transmission**: Encoded content data transmitted over Internet
- **Client Reception**: CPU receives content through communication unit
- **Verification**: System verifies data integrity and completeness

### Step S4: Local Storage
**Storage Operation**: Encoded content stored locally
- **Storage Location**: Content saved to hard disk in storage unit
- **Data Format**: Content maintained in encoded/encrypted format
- **Preparation**: Content prepared for future license-based access

## ASCII Flowchart Diagram

```
                    CONTENT ACCESS PROCESS FLOW

    ┌─────────────────────────────────────────────────────────────────┐
    │                        START                                    │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S1                                      │
    │              User Access Command                                │
    │                                                                 │
    │  User operates input unit (26) → CPU (21) → Communication      │
    │  unit (29) → Internet (2) → Content Server (3)                 │
    │                                                                 │
    │  Result: Connection established with content server             │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S2                                      │
    │               Content Selection                                 │
    │                                                                 │
    │  User specifies desired content → CPU accepts specification    │
    │  → Communication unit informs content server → Server          │
    │  receives content request                                       │
    │                                                                 │
    │  Result: Content request transmitted to server                  │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S3                                      │
    │               Content Reception                                 │
    │                                                                 │
    │  Content Server processes request (see Figure 4) →             │
    │  Server transmits encoded content → CPU receives content       │
    │  through communication unit                                     │
    │                                                                 │
    │  Result: Encoded content received by client                     │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                    STEP S4                                      │
    │                Local Storage                                    │
    │                                                                 │
    │  Encoded content data → Storage Unit (28) → Hard disk          │
    │  storage → Content ready for license-based access              │
    │                                                                 │
    │  Result: Content stored locally in encoded format              │
    └─────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │                       END                                       │
    │            Content Successfully Downloaded                      │
    └─────────────────────────────────────────────────────────────────┘
```

## Key Components Involved

### Client-Side Components
- **Input Unit (26)**: User interface for commands and content selection
- **CPU (21)**: Process coordination and control logic
- **Communication Unit (29)**: Network connectivity and data transmission
- **Storage Unit (28)**: Local hard disk storage for content

### Network Infrastructure
- **Internet (2)**: Communication medium between client and server
- **Content Server (3)**: Remote server hosting protected digital content

## Process Characteristics

### User Experience
- **Interactive Selection**: Users can browse and select from available content
- **Seamless Download**: Automated content retrieval process
- **Local Access**: Content stored locally for subsequent licensed use

### Technical Features
- **Encoded Transmission**: Content transmitted in encoded format for security
- **Efficient Storage**: Content stored locally to minimize future network usage
- **Preparation for DRM**: Content positioned for license-based access control

### Integration Points
- **Figure 4 Reference**: Content server processing detailed in separate flowchart
- **License System**: Downloaded content requires separate license acquisition for use
- **Security Framework**: Encoded content maintains protection until proper license validation

## Next Steps
After content storage completion, users must obtain appropriate licenses (as detailed in other process flows) to decrypt and access the downloaded content.
