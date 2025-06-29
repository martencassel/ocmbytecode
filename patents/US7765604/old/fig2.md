# Figure 2: Client Device Architecture

## Description
Figure 2 shows the detailed hardware and software architecture of a client device in the digital content protection system. This configuration represents the typical components required for secure content processing, license management, and media playback.

## Core Processing Components

### CPU (Central Processing Unit) - 21
- **Function**: Main processor executing all system operations
- **Responsibilities**:
  - Runs programs from ROM and loaded from storage
  - Coordinates all device operations
  - Handles license validation logic
  - Manages content access control

### Memory Systems
- **ROM (Read-Only Memory) - 22**: Stores permanent system programs and firmware
- **RAM (Random-Access Memory) - 23**:
  - Temporary storage for active programs and data
  - Working memory for CPU operations
  - Buffer for content processing

### Timer - 20
- **Function**: Time measurement and synchronization
- **Purpose**: Provides timing data to CPU for license expiration, usage tracking, and system scheduling

## Content Security Components

### Encryption/Decryption Unit - 24
- **Primary Function**: Hardware-accelerated cryptographic operations
- **Capabilities**:
  - Encrypts content for secure storage
  - Decrypts licensed content for playback
  - Handles key management operations
  - Provides secure content transformation

### Codec Unit - 25
- **Audio Processing**: ATRAC-3 (Adaptive Transform Acoustic Coding) encoding/decoding
- **Functions**:
  - Encodes audio content for efficient storage
  - Decodes content from semiconductor memory
  - Manages audio compression and decompression
  - Interfaces with storage devices through drive unit

## Storage and Media Systems

### Drive Unit - 30
- **Interface**: Connects various removable storage media
- **Supported Media**:
  - **Magnetic Disk (41)**: Traditional hard drives, floppy disks
  - **Optical Disk (42)**: CDs, DVDs, Blu-ray discs
  - **Magneto-Optical Disk (43)**: Rewritable optical storage
  - **Semiconductor Memory (44)**: Memory Stick, flash drives, SD cards

### Storage Unit - 28
- **Function**: Permanent local storage for programs and data
- **Contents**: Installed applications, cached content, license database

## User Interface and Communication

### Input Unit - 26
- **Components**: Keyboard, mouse, and other input devices
- **Function**: User interaction and system control

### Output Unit - 27
- **Display**: CRT, LCD, or other visual output devices
- **Audio**: Speakers for media playback
- **Function**: Content presentation to user

### Communication Unit - 29
- **Components**: Modem, terminal adapter, network interfaces
- **Capabilities**:
  - Internet connectivity through network infrastructure
  - Digital and analog signal processing
  - Communication with content servers, license servers, and other clients

## System Architecture Diagram

```
                          CLIENT DEVICE ARCHITECTURE

    ┌─────────────────────────────────────────────────────────────────────┐
    │                              MAIN BUS (31)                         │
    └─┬─────┬─────┬─────────────┬─────────────┬─────────────────────────┬─┘
      │     │     │             │             │                         │
      ▼     ▼     ▼             ▼             ▼                         ▼
  ┌───────┐ ┌───┐ ┌───┐    ┌─────────┐  ┌─────────┐              ┌─────────┐
  │ CPU   │ │ROM│ │RAM│    │Encrypt/ │  │ Codec   │              │  I/O    │
  │ (21)  │ │(22)│ │(23)│    │Decrypt  │  │ Unit    │              │Interface│
  │       │ │   │ │   │    │Unit(24) │  │ (25)    │              │  (32)   │
  └───┬───┘ └───┘ └───┘    └─────────┘  └────┬────┘              └────┬────┘
      │                                      │                        │
      ▼                                      │                        │
  ┌───────┐                                  │                        │
  │ Timer │                                  │                        │
  │ (20)  │                                  │                        │
  └───────┘                                  │                        │
                                             ▼                        │
                                        ┌─────────┐                   │
                                        │ Drive   │                   │
                                        │ (30)    │                   │
                                        └────┬────┘                   │
                                             │                        │
                                             ▼                        │
                               ┌──────────────────────────┐            │
                               │    REMOVABLE MEDIA       │            │
                               │                          │            │
                               │ ┌─────────┐ ┌─────────┐  │            │
                               │ │Magnetic │ │Optical  │  │            │
                               │ │Disk(41) │ │Disk(42) │  │            │
                               │ └─────────┘ └─────────┘  │            │
                               │                          │            │
                               │ ┌─────────┐ ┌─────────┐  │            │
                               │ │Magneto- │ │Semicond.│  │            │
                               │ │Opt.(43) │ │Mem.(44) │  │            │
                               │ └─────────┘ └─────────┘  │            │
                               └──────────────────────────┘            │
                                                                       │
         ┌─────────────────────────────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────────┐
    │           PERIPHERAL DEVICES            │
    │                                         │
    │  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
    │  │ Input   │  │ Output  │  │ Storage │  │
    │  │Unit(26) │  │Unit(27) │  │Unit(28) │  │
    │  │         │  │         │  │         │  │
    │  │Keyboard │  │Speaker  │  │Local    │  │
    │  │Mouse    │  │Display  │  │Storage  │  │
    │  └─────────┘  └─────────┘  └─────────┘  │
    │                                         │
    │              ┌─────────┐                │
    │              │ Comm.   │                │
    │              │Unit(29) │                │
    │              │         │                │
    │              │Modem    │◄──────────────── To Internet (2)
    │              │Terminal │                │
    │              │Adapter  │                │
    │              └─────────┘                │
    └─────────────────────────────────────────┘
```

## Key Features

### Security Architecture
- **Hardware Encryption**: Dedicated encryption/decryption unit for performance and security
- **Secure Storage**: Multiple storage options with varying security levels
- **Access Control**: CPU-managed content access based on license validation

### Media Processing
- **ATRAC-3 Support**: Advanced audio compression for efficient storage
- **Multi-format Storage**: Support for various removable media types
- **Real-time Processing**: Hardware-accelerated encoding/decoding

### Network Capabilities
- **Internet Connectivity**: Full network access for server communication
- **Protocol Support**: Digital and analog signal processing
- **Remote Operations**: License retrieval and content downloading

## Server Similarity
**Note**: The content server, license server, and charging server share the same basic hardware architecture as shown in Figure 2, with specialized software configurations for their respective roles in the content protection ecosystem.
