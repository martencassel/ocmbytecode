# OCM Bytecode Machine Reference

> **Reference:**
> This document is a reformatted programming reference for the OCM Bytecode Machine, based on the original documentation at
> [https://wiki.physik.fu-berlin.de/linux-minidisc/ocmbytecode](https://wiki.physik.fu-berlin.de/linux-minidisc/ocmbytecode)


## Overview

The **OCM bytecode machine** is an interpreter for a stack-based language. Operands are pushed onto a stack, and operations consume operands from the stack and push results back. This is similar to RPN calculators, PostScript, Forth, and the Java VM.

### Key Properties

- **256 global variables** (addressed by a single byte)
  - `0xFC`: 8-byte blob from `gettimeofday`
  - `0xFD`: 1024-byte blob (function pointers for byte codes)
  - `0xFE`: shortint, hiword/loword = major/minor OCM version (e.g., 3.3 for OpenMG 3.4)
  - `0xFF`: shortint, constant 1 in OpenMG 3.4
- **Hash table** for additional global variables (indexed by 32-bit number)
- **Alternate stack** for context (call/return, operands, general storage)
- **Multithreading** support
- **Stream RNG** for instruction decoding (can be enabled/disabled)
- **User RNG** with 63-byte state (separate from stream RNG)
- **Native x86 code execution** ("backdoor")

---

## Data Types

### Stack Value Representation

```c
struct stack_value {
  union {
    unsigned int value : 30;
    void *handle_div_4;
  };
  unsigned int type : 2;
};
```

### Handles

```c
struct bigint_handle {
  uint8_t refcount;
  uint8_t is_negative;
  uint16_t len_in_32bitwords;
  uint32_t payload[0]; // Variable-length-array
};

struct blob_handle {
  uint8_t refcount;
  uint8_t heap_allocated;
  uint8_t unknown;
  uint8_t zero; // Location of data pointer for 0 byte blocks.
  uint32_t length;
  void *data;
};

struct array_handle {
  uint8_t refcount;
  uint8_t unused;
  uint16_t nr_elements;
  stack_value data[0]; // Variable length array, entries are handles/smallints
};
```

### Type Tags

| Tag | Type         | Description                                 |
|-----|--------------|---------------------------------------------|
| 0   | Smallint     | Signed 16-bit numbers (value type)          |
| 1   | Bigint       | Arbitrary precision integers (reference)    |
| 2   | Blob         | Binary blobs (reference)                    |
| 3   | Array        | Heterogeneous array of OCM objects          |

#### Serialization

- **Smallint/Bigint**: ASN.1 length, then two's complement little-endian
- **Blob**: ASN.1 length, then bytes
- **Array**: ASN.1 heterogeneous sequence

---

## Opcodes

### Legend

- **Stack Input**: What is consumed from the stack
- **Stack Output**: What is pushed to the stack
- **Effect**: Description of the operation

---

### 0x00–0x0F: Stack Manipulation

| Opcode | Name                | Stack Input / Output | Effect |
|--------|---------------------|---------------------|--------|
| 0x00   | NOP                 | —                   | No operation |
| 0x01   | Immediate Byte      | — → smallint        | Pushes unsigned 8-bit immediate |
| 0x02   | Immediate Word      | — → smallint        | Pushes signed 16-bit immediate |
| 0x03   | Immediate BigInt    | — → bigint          | Pushes deserialized big int |
| 0x04   | Immediate Blob      | — → blob            | Pushes deserialized blob |
| 0x05   | DUP                 | x → x, x            | Duplicates top of stack |
| 0x06   | DUPNONZERO          | x → x, x?           | Duplicates if not zero (smallint) |
| 0x07   | POP                 | x → —               | Removes top of stack (pushes 0 if empty) |
| 0x08   | DESTROY             | x → —               | Removes and deletes object immediately |
| 0x09   | EXCH                | x, y → y, x         | Swaps top two stack values |
| 0x0A   | INDEX (1 index)     | x, y → x, y, x      | Pushes copy of next-to-top |
| 0x0B   | FETCHSTACK          | n, ... → ...        | Pushes copy at n below input operand |
| 0x0C   | 3 -1 ROLL           | x, y, z → y, z, x   | Moves top-2 to top |
| 0x0D   | ROLLIN              | n, ... → ...        | Moves n-th operand below input to top |
| 0x0E   | SETUDICT            | v, key → —          | Set in user dictionary (key: 4-byte blob) |
| 0x0F   | SETDICT             | v, key → —          | Set in system/user dictionary (key: smallint/blob) |

---

### 0x10–0x1F: Smallint Arithmetic

| Opcode | Name        | Stack Input / Output | Effect |
|--------|-------------|---------------------|--------|
| 0x10   | GETDICT     | key → value         | Lookup in system/user dictionary |
| 0x11   | ADD         | a, b → a+b          | Add smallints |
| 0x12   | SUB         | a, b → a-b          | Subtract smallints |
| 0x13   | MUL         | a, b → a*b          | Multiply smallints (low 16 bits) |
| 0x14   | DIV         | a, b → a/b          | Divide smallints |
| 0x15   | MODDIV      | a, b → a/b, a%b     | Divide and modulus |
| 0x16   | DIVMOD      | a, b → a%b          | Modulus only |
| 0x17   | XOR         | a, b → a^b          | Bitwise XOR |
| 0x18   | AND         | a, b → a&b          | Bitwise AND |
| 0x19   | OR          | a, b → a\|b         | Bitwise OR |
| 0x1A   | NEG         | a → ~a              | Bitwise NOT |
| 0x1B   | SHL         | a, n → a << n       | Shift left |
| 0x1C   | SHR         | a, n → a >> n       | Logical shift right |
| 0x1D   | SAR         | a, n → a >> n       | Arithmetic shift right |
| 0x1E   | CMP.GT      | a, b → 1/0          | 1 if a > b, else 0 |
| 0x1F   | CMP.LT      | a, b → 1/0          | 1 if a < b, else 0 |

---

### 0x20–0x2F: DWORD Arithmetic

| Opcode | Name        | Stack Input / Output | Effect |
|--------|-------------|---------------------|--------|
| 0x20   | CMP.EQ      | a, b → 1/0          | 1 if a == b, else 0 |
| 0x21   | ISZEROW     | x → 1/0             | 1 if smallint zero |
| 0x22   | ADD.DWORD   | a, b → bigint       | Add (unsigned, 32 bits) |
| 0x23   | SUB.DWORD   | a, b → bigint       | Subtract (unsigned, 32 bits) |
| 0x24   | MUL.DWORD   | a, b → bigint       | Multiply (unsigned, 32 bits) |
| 0x25   | DIV.DWORD   | a, b → bigint       | Divide (unsigned, 32 bits) |
| 0x26   | DIVMOD.DWORD| a, b → q, r         | Quotient and remainder |
| 0x27   | MODDIV.DWORD| a, b → r            | Remainder only |
| 0x28   | XOR.DWORD   | a, b → bigint       | Bitwise XOR |
| 0x29   | AND.DWORD   | a, b → bigint       | Bitwise AND |
| 0x2A   | OR.DWORD    | a, b → bigint       | Bitwise OR |
| 0x2B   | NOT.DWORD   | a → bigint          | Bitwise NOT |
| 0x2C   | SHL.DWORD   | a, n → bigint       | Shift left |
| 0x2D   | SHR.DWORD   | a, n → bigint       | Shift right |
| 0x2E   | CMP.LT.DWORD| a, b → 1/0          | 1 if a < b, else 0 |
| 0x2F   | CMP.GT.DWORD| a, b → 1/0          | 1 if a > b, else 0 |

---

### 0x30–0x3F: Control Flow, Stack Constants

| Opcode | Name        | Stack Input / Output | Effect |
|--------|-------------|---------------------|--------|
| 0x30   | CMP.EQ.DWORD| a, b → 1/0          | 1 if a == b, else 0 |
| 0x31   | EXEC        | blob → —            | Execute bytecode blob |
| 0x32   | IFELSE      | sel, t, f → —       | If sel != 0, exec t else f |
| 0x33   | WHILE       | flag (alt: blob)    | While flag != 0, exec blob |
| 0x34   | TOALT       | x → (alt: x)        | Move to alternate stack |
| 0x35   | FROMALT     | (alt: x) → x        | Move from alternate stack |
| 0x36   | PEEKALT     | (alt: x) → x        | Copy from alternate stack |
| 0x37–0x3F | PUSH 0–8 | — → smallint        | Push smallint 0–8 |

---

### 0x40–0x4F: Stack Constants, Indexing, Inc/Dec

| Opcode | Name        | Stack Input / Output | Effect |
|--------|-------------|---------------------|--------|
| 0x40   | PUSH 9      | — → smallint 9      | Push 9 |
| 0x41   | PUSH -1     | — → smallint -1     | Push -1 |
| 0x42   | PUSH -2     | — → smallint -2     | Push -2 |
| 0x43   | PUSH -3     | — → smallint -3     | Push -3 |
| 0x44   | ISPOS       | a → 1/0             | 1 if a > 0 |
| 0x45   | ISNEG       | a → 1/0             | 1 if a < 0 |
| 0x46   | ISZERO      | a → 1/0             | 1 if a == 0 |
| 0x47–0x4A | INDEX.N  | —                   | Duplicate N-th-to-top |
| 0x4B–0x4D | ROLLIN.N | —                   | Move N-th-to-top to top |
| 0x4E   | INC.W       | a → a+1             | Increment smallint |
| 0x4F   | DEC.W       | a → a-1             | Decrement smallint |

---

### 0x50–0x5F: Type Conversion, Arrays, ASN.1

| Opcode | Name        | Stack Input / Output | Effect |
|--------|-------------|---------------------|--------|
| 0x50   | CVTNUM.S    | a → bigint          | Convert to signed number |
| 0x51   | CVTNUM.U    | a → bigint          | Convert to unsigned number |
| 0x52   | CVTBLOB     | a → blob            | Convert to blob |
| 0x53   | NUMUNSIGNED | a → bigint          | Make operand unsigned |
| 0x54   | TRUNC16     | a → smallint        | Truncate to smallint |
| 0x55   | ARRAY.ASTORE| n, ... → array      | Pack to array |
| 0x56   | ALOAD.LENGTH| array → ..., n      | Unpack array |
| 0x57   | LENGTH.ARR  | array → n           | Array length |
| 0x58   | AINSERT     | entry, arr, idx → array | Insert to array |
| 0x59   | ACUT        | arr, idx → array    | Delete from array |
| 0x5A   | GET         | arr, k → value      | Get array element |
| 0x5B   | SET         | x, arr, k → old     | Set array element |
| 0x5C   | ARRAY       | n → array           | Create array of n zeros |
| 0x5D   | ASN1ENCODE  | x → blob            | ASN.1 encode |
| 0x5E   | ASN1ARRAY   | n, ... → blob       | ASN.1 sequence |
| 0x5F   | ASN1DECODE  | blob → x            | ASN.1 decode |

---

### 0x60–0x6F: Miscellaneous

| Opcode | Name        | Stack Input / Output | Effect |
|--------|-------------|---------------------|--------|
| 0x60   | ENCLOSE     | smallint → blob     | Enclose smallint in blob |
| 0x61   | DISCLOSE    | blob → smallint     | Extract smallint from blob |
| 0x62   | COUNTBITS   | x → n               | Number of significant bits |
| 0x63–0x66 | IMMEDIATE CRYPTED | —         | Push immediate (encrypted) |
| 0x67   | THREADS     | arg, n blobs, n → — | Start threads |
| 0x68   | TIMESLICE   | len → —             | Set time slice length |
| 0x69   | KILLTHREADS | —                   | Cancel threaded execution |
| 0x6A–0x6C | TO/FROM/PEEKMAIN | —          | Main thread stack ops |
| 0x6D   | GETTIMEOFDAY| — → sec, usec       | Get time of day |
| 0x6E   | MKTIME      | s, m, h, d, mo, y → ts | Make unix timestamp |
| 0x6F   | LOCALTIME   | ts → s, m, h, d, mo, y | Unix timestamp to fields |

---

### 0x70–0x7F: RNG, Modules, Misc

| Opcode | Name        | Stack Input / Output | Effect |
|--------|-------------|---------------------|--------|
| 0x70   | TYPE        | x → tag             | Get type tag |
| 0x71   | RNG.SKIPGET | n → value           | Get random number after skipping n |
| 0x72   | RNG.AUTOSKIP| n → —               | Set user RNG autoskip |
| 0x73   | DECRYPTSEED | n → —               | Enable stream decryptor |
| 0x74   | DECRYPTTABLE| blob → —            | Load stream decryptor table |
| 0x75–0x7D | MODULE OPS | ...                | Native/bytecode module management |
| 0x7E   | RNG.SEED    | n, blob → —         | Seed user RNG |
| 0x7F   | NOP         | —                   | No operation |

---

## Extended Opcodes

### 0x80–0xC1: Advanced Math, Crypto, Elliptic Curves

- **0x87–0x8F**: Big integer arithmetic (add, sub, mul, div, mod, cmp)
- **0x90–0x9F**: Bitwise ops, modular arithmetic, fuzzed integers
- **0xA0–0xC1**: Fuzzed arithmetic, power contexts, elliptic curve operations (mod-p, GF, GFES)

---

## "compat" Module (0xC2–0xE0)

| Opcode | Name/Effect                        | Stack Input / Output |
|--------|------------------------------------|----------------------|
| 0xC2   | `blob.part`                        | blob, idx, len → subblob |
| 0xC3   | `concat`                           | blob1, blob2 → concat |
| 0xC4   | `compareblob`                      | blob1, blob2 → cmpresult |
| 0xC5   | `comparen`                         | blob1, blob2, count → cmpresult |
| 0xC6   | `indexblob`                        | blob, idx → char_at_idx |
| 0xC7   | `bloblen`                          | blob → length |
| 0xC8   | `xorblobs`                         | blob1, blob2 → blob1^blob2 |
| 0xC9   | `xorblobsrepeating`                | blob1, blob2 → blob1^blob2 (repeat) |
| 0xCA   | `repeatnul`                        | count → blob |
| 0xCB   | `replacesubblob`                   | bigblob, offset, newdata → patchedblob |
| 0xCC–0xD2 | Floating point arithmetic       | ... |
| 0xD3   | `floatttoint`                      | float → int |
| 0xD4   | `atof`                             | ascii-blob → float |
| 0xD5   | `nop`                              | — |
| 0xD6–0xDA | DES crypto                      | ... |
| 0xDB–0xDD | SHA1                            | ... |
| 0xDE   | `getprngbytes`                     | count → blob |
| 0xDF–0xE0 | DES CBC                         | ... |

---

## Notes

- **Reference Counting**: All reference types use refcounting, but can be made permanent.
- **Alternate Stack**: Used for call/return context and some instructions.
- **Multithreading**: Each thread has its own stack and alternate stack.
- **Native Code**: Can load and execute native x86 code.

---

## See Also

- [ASN.1 Encoding](https://en.wikipedia.org/wiki/X.690)
- [Elliptic Curve Cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography)
- [Stack Machine](https://en.wikipedia.org/wiki/Stack_machine)

---

*This document is a reformatted reference for the OCM Bytecode Machine, based on the original documentation.*
