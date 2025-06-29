# OpenMG Secure Application Loader (SAL) Architecture

## Overview

This document describes the **Secure Application Loader (SAL)** architecture used in Sony's OpenMG DRM system, particularly for NetMD device operations like checkout and checkin of protected content.

## Windows DLL Layer Architecture

### Content Operations Flow

**Primary Operations:**
- **Checkout(file)** - Transfer protected content to portable device
- **Checkin(file)** - Return content from portable device to system

### DLL Communication Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│                        APPLICATION LAYER                            │
│  ┌─────────────────┐                                               │
│  │   Checkout()    │ ← User-initiated content operations           │
│  │   Checkin()     │                                               │
│  └─────────────────┘                                               │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         NetMD.dll                                   │
│                    ┌─────────────────┐                             │
│                    │  COM Interface  │ ← AVLib Layer               │
│                    │   (C++ Code)    │                             │
│                    └─────────────────┘                             │
└─────────────────────────────────────────────────────────────────────┘
                    │                        │
                    │                        ▼
                    │        ┌─────────────────────────────────────┐
                    │        │       NetMDAPI.dll                 │
                    │        │    ┌─────────────────────────┐     │
                    │        │    │   NetMDUSB.sys         │     │
                    │        │    │    (C++ Code)          │     │
                    │        │    │                        │     │
                    │        │    │ ≡ libnetmd equivalent  │     │
                    │        │    └─────────────────────────┘     │
                    │        └─────────────────────────────────────┘
                    │                        │
                    │        ┌─────────────────────────────────────┐
                    │        │ IOmgNetMD::AttemptCheckout()       │
                    │        │ IOmgNetMD::CompleteCheckout()      │
                    │        │             ...                    │
                    │        └─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       OmgNetMD.dll                                  │
│                    ┌─────────────────┐                             │
│                    │  COM Interface  │ ← C++ Implementation        │
│                    │                 │                             │
│                    └─────────────────┘                             │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ salExec0() calls
                                │ ┌─────────────────────────────────┐
                                │ │ netmd.ocm - Encrypted bytecode │
                                │ │ Implements checkout procedures  │
                                │ └─────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        salwrap.dll                                  │
│                    ┌─────────────────┐                             │
│                    │  DLL Interface  │ ← C++ Code                  │
│                    │                 │                             │
│                    │ ┌─────────────┐ │                             │
│                    │ │Application  │ │ ← init.ocm                  │
│                    │ │    VM       │ │   (Interpreter &            │
│                    │ │             │ │    Runtime C Libraries)     │
│                    │ └─────────────┘ │                             │
│                    └─────────────────┘                             │
└─────────────────────────────────────────────────────────────────────┘
```
---

## Virtual Machine Architecture Overview

### Layered Security Model

```
┌─────────────────────────────────────────────────────────────────────┐
│                      OpenMG Module                                  │
│                                                                     │
│                 ┌─────────────────────┐                            │
│                 │ ocm_module_proc_X() │ ← Module procedure calls   │
│                 └─────────────────────┘                            │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Secure Application Loader                        │
│                         (salExec0)                                  │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │                  Secure Application                             │ │
│ │                                                                 │ │
│ │           ┌─────────────────────────────────────┐               │ │
│ │           │                                     │               │ │
│ │           │      Virtual ISA + Virtual ABI     │               │ │
│ │           │      (Library Calls)                │               │ │
│ │           │                                     │               │ │
│ │           └─────────────────────────────────────┘               │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       Virtual Machine                               │
│                     (Bytecode Interpreter)                          │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      salwrap (Host Layer)                           │
│                    ISA + ABI Implementation                         │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          Windows OS                                 │
│                        ISA + ABI                                    │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          Hardware                                   │
│                            ISA                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Architecture Definitions

**ISA (Instruction Set Architecture)**:
- **Hardware ISA**: Native processor instruction set
- **Virtual ISA**: Bytecode architecture for secure applications

**ABI (Application Binary Interface)**:
- **OS ABI**: Interface to Windows system calls
- **Virtual ABI**: Library calls to runtime libraries within VM

---

## C++ Interface to Virtual Machine

### SalBytecode Class Structure

```cpp
class SalBytecode
{
public:
    // Constructor & Destructor
    SalBytecode(unsigned int);
    ~SalBytecode();

    // Utility Methods
    clear();
    dataType();
    SalBytecode & operator=(class SalBytecode const &);

    // Input Stream Operators (Data → VM)
    operator<<(SalBytecode &, long &);
    operator<<(SalBytecode &, SalPointer const &);
    operator<<(SalBytecode &, SalNonConstPointer const &);
    operator<<(SalBytecode &, OmgString const &);
    operator<<(SalBytecode &, SalString const &);
    operator<<(SalBytecode &, SalFileContent const &);
    operator<<(SalBytecode &, SalExtrinsicsProg const &);
    operator<<(SalBytecode &, SalLoadableModule const &);
    operator<<(SalBytecode &, std::vector<unsigned char> &);
    operator<<(SalBytecode &, SalOmgId const &);
    operator<<(SalBytecode &, OmgMmap const &);
    operator<<(SalBytecode &, SalKey const &);

    // Output Stream Operators (VM → Data)
    operator>>(SalBytecode &, std::string<char> &);
    operator>>(SalBytecode &, std::vector<unsigned char> &);
    operator>>(SalBytecode &, SalAsnSeqBegin);
    operator>>(SalBytecode &, SalAsnSeqEnd &);
    operator>>(SalBytecode &, SalNonConstPointer &);
    operator>>(SalBytecode &, OmgString &);

private:
    SalBytecode::SalByteCode_impl_constr(var_size_512);

    // Internal State Variables
    uchar *StreamBuf;        // var 1 - Stream buffer pointer
    int    StreamPos;        // var 2 - Current position in stream
    long int lenStreamBuf;   // var 3 - Length of stream buffer
    int inArgSize;          // var 10: 512 - Input argument size
};

// Main VM Execution Function
void salExec0(SalBytecode& input, SalBytecode& output, int, int, int);
```

### Data Flow Architecture

```
Input Data          VM Processing           Output Data
     │                    │                     │
     ▼                    ▼                     ▼
┌─────────┐         ┌─────────────┐       ┌─────────┐
│operator │   -->   │  salExec0   │  -->  │operator │
│   <<    │         │             │       │   >>    │
│ (Input) │         │ VM Runtime  │       │(Output) │
└─────────┘         └─────────────┘       └─────────┘
```

---

## OpenMG Secure Module Implementation

### Reference Architecture

**Based on**: Sony Patent EP1 496 439 A1, Figure 6 - Client functional structure

### Patent Components

**Security Module (§53)**:
- Performs encryption/decryption operations
- Handles security-related processing requests
- Centralized cryptographic services

**DRM Module (§51)**:
- Manages content and rights data communication
- Controls digital rights enforcement
- Coordinates with Security Module for protection

### Implementation Mapping

```
Patent Architecture          Implementation Architecture
┌─────────────────┐         ┌─────────────────────────┐
│ Playback Module │  <-->   │    OmgNetMD.dll        │
│ Write Module    │         │    MemStick.dll        │
│ Read Module     │         │    omgconv2.dll        │
│ LCM Module      │         │         ...             │
└─────────────────┘         └─────────────────────────┘
         │                              │
         ▼                              ▼
┌─────────────────┐         ┌─────────────────────────┐
│   DRM Module    │  <-->   │    DLL Linkage to       │
│ Security Module │         │    pfcom/salwrap        │
└─────────────────┘         └─────────────────────────┘
```

**Key Implementation Details**:
- **Direct Communication**: Content modules communicate directly with DRM/Security modules
- **COM Interface**: Plugin layer uses COM for module communication
- **Exception Cases**: Some pfcom functions accessible through COM
- **SAL Access**: salExec0 accessible via COM through omgmisc.dll

---

## Complete System Architecture

### UI and Application Layer

```
┌─────────────────────────────────────────────────────────────────────┐
│                            UI Layer                                  │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                      SonicStage                                 ││
│  │                  (omgjukebox.exe)                               ││
│  └─────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────┘
                    │ COM                      │ COM
                    ▼                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       Plugin Layer (AVLib)                          │
│┌──────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐│
││   CheckOut   │  │    Playback     │  │       Playback              ││
││   CheckIn    │  │    Convert      │  │       Convert               ││
│└──────────────┘  └─────────────────┘  └─────────────────────────────┘│
│┌──────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐│
││  NetMD.dll   │  │   OpcOmg.dll    │  │      OpcWMA.dll             ││
│└──────────────┘  └─────────────────┘  └─────────────────────────────┘│
│┌──────────────┐                                                      │
││NetMDAPI.dll  │                                                      │
│└──────────────┘                                                      │
│┌──────────────┐                                                      │
││NetMDUSB.dll  │                                                      │
│└──────────────┘                                                      │
└─────────────────────────────────────────────────────────────────────┘
```
### OpenMG Core Layer

```
┌─────────────────────────────────────────────────────────────────────┐
│                        OpenMG Core                                  │
│                                                                     │
│  ┌─────────────┐ COM ┌─────────────┐ DLL ┌─────────────────────────┐│
│  │ pfcom.dll   │◄───►│OmgNetMD.dll │◄───►│     salwrap.dll         ││
│  │             │     │             │     │                         ││
│  │createInstan-│     │             │     │ • EkbCapabilityTable    ││
│  │ceForMp3     │     │             │     │ • OmgEkb                ││
│  │             │     │             │     │ • salExec0              ││
│  └─────────────┘     └─────────────┘     │                         ││
│                                          │   ┌─────────────────┐   ││
│  ┌─────────────┐     ┌─────────────┐     │   │    SAL VM       │   ││
│  │             │◄───►│omgconv2.dll │◄───►│   │                 │   ││
│  │             │     │             │     │   └─────────────────┘   ││
│  │             │     │             │     │                         ││
│  │             │     └─────────────┘     └─────────────────────────┘│
│  │             │                                                    │
│  │             │     ┌─────────────┐                                │
│  │             │◄───►│MemStick.dll │                                │
│  │             │     │             │                                │
│  │             │     │             │                                │
│  └─────────────┘     └─────────────┘                                │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Storage and Management Areas

```
┌─────────────────────────────────────────────────────────────────────┐
│                     File System Layout                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ ┌─────────────────────┐ ┌─────────────────────┐ ┌─────────────────┐ │
│ │License Repository   │ │Song File Storage    │ │System Data Files│ │
│ │& Management Area    │ │     Section         │ │                 │ │
│ │                     │ │                     │ │                 │ │
│ │[License Info]       │ │[Header|Music Data]  │ │ icv.dat         │ │
│ │                     │ │                     │ │ maclist1.dat    │ │
│ │<OMGDIR>\procfile\   │ │<APPDATA>\SonicStage │ │ maclist2.dat    │ │
│ │                     │ │                     │ │                 │ │
│ │                     │ │                     │ │ ekb\version.ekb │ │
│ │                     │ │                     │ │                 │ │
│ │                     │ │                     │ │OMGKEY\          │ │
│ │                     │ │                     │ │ salomgid.dat    │ │
│ │                     │ │                     │ │                 │ │
│ │                     │ │                     │ │OMGRIGHT\        │ │
│ │                     │ │                     │ │ <value>.icv     │ │
│ └─────────────────────┘ └─────────────────────┘ └─────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### File System Details

**License Repository (`<OMGDIR>\procfile\`)**:
- **License Information**: Rights management data
- **Access Control**: Device and user authorization
- **Usage Tracking**: Play counts, copy restrictions

**Song File Storage (`<APPDATA>\SonicStage`)**:
- **File Structure**: Header + Music Data
- **Encryption**: Protected audio content
- **Metadata**: Track information and DRM parameters

**System Data Files**:
- **icv.dat**: Integrity Check Values
- **maclist1.dat, maclist2.dat**: Message Authentication Codes
- **ekb\version.ekb**: Enabling Key Block version data
- **OMGKEY\salomgid.dat**: SAL OpenMG identifier
- **OMGRIGHT\<value>.icv**: Rights validation files

---

## Secure Applications Layer

### OCM Module Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Secure Applications (.ocm)                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │
│ │ device.sal  │ │  init.ocm   │ │ netmd.ocm   │ │  icv.ocm    │    │
│ │             │ │             │ │             │ │             │    │
│ │Device-      │ │Interpreter  │ │NetMD        │ │Integrity    │    │
│ │specific     │ │& Runtime    │ │Operations   │ │Check        │    │
│ │operations   │ │C Libraries  │ │& Checkout   │ │Validation   │    │
│ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘    │
│                                                                     │
│ ┌─────────────┐                               ┌─────────────┐      │
│ │maclist.ocm  │                               │    ...      │      │
│ │             │                               │             │      │
│ │MAC List     │                               │Additional   │      │
│ │Management   │                               │Secure Apps  │      │
│ │             │                               │             │      │
│ └─────────────┘                               └─────────────┘      │
├─────────────────────────────────────────────────────────────────────┤
│                       SAL Runtime                                   │
│                   (Execution Environment)                           │
└─────────────────────────────────────────────────────────────────────┘
```

### Secure Application Types

**device.sal**:
- Device-specific cryptographic operations
- Hardware abstraction layer
- Platform-dependent security functions

**init.ocm**:
- Virtual machine interpreter core
- Runtime C library implementations
- System initialization and setup

**netmd.ocm**:
- NetMD device communication protocols
- Content checkout/checkin procedures
- Device authentication and key exchange

**icv.ocm**:
- Integrity Check Value computation
- Content validation and verification
- Tamper detection mechanisms

**maclist.ocm**:
- Message Authentication Code management
- Cryptographic list operations
- Security policy enforcement

---

## Security Architecture Summary

### Multi-Layer Protection

```
Security Layer          Component              Protection Level
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Application    │    │   SonicStage    │    │   User-level    │
│     Layer       │    │   (UI)          │    │   DRM checks    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Plugin        │    │   AVLib         │    │   COM-based     │
│   Layer         │    │   Components    │    │   isolation     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OpenMG        │    │   DRM Modules   │    │   Encrypted     │
│   Core          │    │   pfcom/salwrap │    │   communication │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Secure        │    │   OCM Modules   │    │   Bytecode      │
│   Applications  │    │   (.ocm files)  │    │   execution     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   SAL           │    │   Virtual       │    │   Hardware-     │
│   Runtime       │    │   Machine       │    │   isolated      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Security Features

1. **Virtual Machine Isolation**: Secure applications run in isolated bytecode environment
2. **Encrypted Modules**: OCM files contain encrypted bytecode and C code
3. **Multi-layer DRM**: Protection enforced at multiple architectural levels
4. **Hardware Abstraction**: Platform-specific security through device.sal
5. **Integrity Validation**: ICV and MAC systems ensure tamper detection
6. **Key Management**: EKB system for hierarchical key distribution

This architecture provides **defense in depth** against reverse engineering and circumvention attempts while maintaining compatibility across different Windows configurations and hardware platforms.
