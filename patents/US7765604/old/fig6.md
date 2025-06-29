# Figure 6: Client Content Playback Process

## Description
Figure 6 shows the flowchart for client-side content playback processing. This process describes how a client device validates licenses, decrypts content, and plays back media after receiving encrypted content from the content server.

## Process Flow

### Step S41: Content Selection and License ID Retrieval
**User Action**: User specifies desired content for playback
- **Input**: User operates input unit (26) to select content
- **Processing**: CPU (21) acquires content identification (CID)
- **Content ID Components**: Title, assigned number, and other identifiers
- **License Lookup**: CPU reads license ID for the specified content
- **Result**: License ID obtained for content authorization

### Step S42: License Validation Check
**License Verification**: Check if required license exists locally
- **Processing**: CPU forms judgment on license availability
- **Storage Check**: Verify if license indicated by license ID is stored in storage unit (28)
- **Decision Point**:
  - If license exists → Continue to Step S44
  - If license missing → Proceed to Step S43

### Step S43: License Acquisition (if needed)
**License Retrieval**: Acquire missing license from license server
- **Process Reference**: Detailed in Figure 7 flowchart
- **Network Operation**: Connect to license server for license download
- **Result**: License obtained and stored locally

### Step S44: License Validity Check
**Time-based Validation**: Verify license is still valid
- **Validation Method**: Compare license term of validity with current date/time
- **Timer Reference**: Uses timer (20) for current time measurement
- **License Structure**: Validity term specified in license (detailed in Figure 8)
- **Decision Point**:
  - If valid → Continue to Step S46
  - If expired → Proceed to Step S45

### Step S45: License Update (if expired)
**License Renewal**: Update expired license
- **Process Reference**: Detailed in Figure 8 flowchart
- **Server Communication**: Contact license server for license renewal
- **Result**: Updated license with extended validity

### Step S46: Content Loading
**Content Preparation**: Load encrypted content into memory
- **Source**: Read encrypted content from storage unit (28)
- **Destination**: Store content in RAM (23) for processing
- **Format**: Content in encrypted block format as per Figure 5

### Step S47: Content Decryption
**Security Processing**: Decrypt content using validated license
- **Processing Unit**: CPU (21) supplies encrypted data to encryption/decryption unit (24)
- **Block Processing**: Content processed in encrypted-block units from data portion
- **Key Management**:
  - Content key Kc acquired using method detailed in Figure 15
  - Key K obtained from EKB using device node key (DNK) from Figure 8
  - Content key Kc extracted from K(Kc) using key K
- **Result**: Decrypted content ready for codec processing

### Step S48: Content Decoding and Output
**Media Processing**: Decode and present content to user
- **Codec Processing**: CPU supplies decrypted content to codec unit (25)
- **Decoding**: Content decoded from ATRAC-3 or other format
- **Output Path**: Decoded data sent to output unit (27) via I/O interface (32)
- **Final Output**: Digital-to-analog conversion for speaker output
- **Result**: Content successfully played back to user

## Key Security Features

### License-Based Access Control
- **Mandatory Licensing**: Content cannot be played without valid license
- **Time-based Validity**: Licenses have expiration dates for usage control
- **Automatic Renewal**: System can update expired licenses automatically

### Multi-layer Decryption
- **EKB Processing**: Device-specific key extraction from Enabling Key Block
- **Content Key Management**: Hierarchical key structure for secure access
- **Block-level Security**: Content encrypted in discrete blocks for enhanced protection

### Error Handling
- **License Failures**: System prevents playback if license acquisition fails
- **Validity Checks**: Multiple validation points ensure proper authorization
- **Graceful Degradation**: Clear error messages for failed operations

## Integration Points

### Related Processes
- **Figure 3**: Content download process that precedes playback
- **Figure 7**: License acquisition detailed process
- **Figure 8**: License update and renewal procedures
- **Figure 15**: EKB and key management structure

### System Components
- **Storage Integration**: Seamless access to locally stored content and licenses
- **Network Connectivity**: Automatic license server communication when needed
- **Hardware Acceleration**: Dedicated encryption/decryption and codec units
- **User Interface**: Input/output units for user interaction and content presentation

## Process Benefits

### User Experience
- **Seamless Playback**: Automatic license handling transparent to user
- **Offline Capability**: Locally stored licenses enable offline content access
- **Content Protection**: Strong DRM ensures content creator rights

### System Security
- **Comprehensive Validation**: Multiple checkpoints prevent unauthorized access
- **Time-based Control**: License expiration enables flexible usage models
- **Device Binding**: EKB system ensures content tied to authorized devices
