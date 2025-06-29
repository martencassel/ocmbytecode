# ...existing code...

## **Compiler Type Inference Rules**

### **1. Integer Literals**

#### **1a. Decimal Literals**
```python
# Range-based automatic inference
0 to 127           → imm.byte     # Fits in unsigned 8-bit
128 to 255         → imm.byte     # Unsigned 8-bit range
256 to 32767       → imm.word     # Positive 16-bit signed
-1 to -128         → imm.word     # Negative fits in 16-bit
-129 to -32768     → imm.word     # Negative 16-bit signed range
32768 to 65535     → imm.word     # Fits in 16-bit (promoted to signed)
> 65535            → imm.bigint   # Exceeds 16-bit
< -32768           → imm.bigint   # Below 16-bit minimum
```

#### **1b. Hexadecimal Literals**
```python
# Length-based inference for hex
0x00 to 0xFF       → imm.byte     # 2 hex digits = 8 bits
0x100 to 0xFFFF    → imm.word     # 3-4 hex digits = 16 bits
0x10000+           → imm.bigint   # 5+ hex digits = arbitrary precision

# Special cases
0x80 to 0xFF       → imm.byte     # Unsigned interpretation
0x8000 to 0xFFFF   → imm.word     # Unsigned 16-bit, stored as signed
```

#### **1c. Binary Literals**
```python
# Bit-length based inference
0b0 to 0b11111111      → imm.byte     # 1-8 bits
0b100000000 to 0b1111111111111111  → imm.word     # 9-16 bits
0b10000000000000000+   → imm.bigint   # 17+ bits
```

#### **1d. Octal Literals**
```python
# Similar to hex, based on value range
0o0 to 0o377       → imm.byte     # Fits in 8-bit
0o400 to 0o177777  → imm.word     # Fits in 16-bit
0o200000+          → imm.bigint   # Exceeds 16-bit
```

### **2. Blob Literals**

#### **2a. Hexadecimal Blob Syntax**
```python
# Multi-byte hex sequences always become blobs
0x123456789        → imm.blob [0x12,0x34,0x56,0x78,0x09]
0x1234567890ABCDEF → imm.blob [0x12,0x34,0x56,0x78,0x90,0xAB,0xCD,0xEF]

# Rule: If hex literal has odd number of digits, left-pad with zero
0x123             → imm.blob [0x01,0x23]   # Padded to byte boundary
```

#### **2b. String Literals**
```python
# String literals always become blobs
"hello"           → imm.blob [0x68,0x65,0x6C,0x6C,0x6F]  # UTF-8 encoding
"device.sal"      → imm.blob [0x64,0x65,0x76,0x69,0x63,0x65,0x2E,0x73,0x61,0x6C]
""                → imm.blob []  # Empty blob
```

#### **2c. Byte Array Literals**
```python
# Explicit byte array syntax
[0x01, 0x02, 0x03]     → imm.blob [0x01,0x02,0x03]
[65, 66, 67]           → imm.blob [0x41,0x42,0x43]  # Decimal bytes
[0b11110000, 0xFF]     → imm.blob [0xF0,0xFF]      # Mixed formats
```

### **3. Type Promotion Rules**

#### **3a. Arithmetic Context**
```python
# Operands are promoted to compatible types
byte + byte        → Use smallint arithmetic (ADD)
word + word        → Use smallint arithmetic (ADD)
bigint + bigint    → Use bigint arithmetic (0x87)
byte + bigint      → Promote byte to bigint, use bigint arithmetic
word + bigint      → Promote word to bigint, use bigint arithmetic

# DWORD arithmetic (unsigned 32-bit)
dword + dword      → Use DWORD arithmetic (0x22+)
```

#### **3b. Comparison Context**
```python
# Use appropriate comparison instruction
byte cmp byte      → Use smallint comparison (0x1E-0x20)
bigint cmp bigint  → Use bigint comparison (0x8D-0x8F)
mixed types        → Promote to larger type, then compare
```

### **4. Edge Cases and Special Rules**

#### **4a. Ambiguous Cases**
```python
# Programmer intent disambiguation
x = 255            → imm.byte 255    # Fits in byte
x = 256            → imm.word 256    # Requires word
x: bigint = 255    → imm.bigint 255  # Explicit type annotation

# Negative values
x = -1             → imm.word -1     # Negative requires signed type
x = -129           → imm.word -129   # Still fits in word
x = -32769         → imm.bigint -32769 # Exceeds word range
```

#### **4b. Overflow Behavior**
```python
# Compile-time overflow detection
x = 65536          → imm.bigint 65536   # Auto-promote to prevent overflow
x = 0x10000        → imm.bigint 65536   # Same for hex
x = 2**16          → imm.bigint 65536   # Expression evaluation
```

#### **4c. Contextual Inference**
```python
# Function parameter context
def encrypt(key: blob, data: blob) -> blob: ...
encrypt(0x1234, "hello")  # 0x1234 → blob [0x12,0x34], "hello" → blob

# Array indexing context
arr[255]           → 255 as smallint (array indices are smallints)
arr[0x100]         → 256 as smallint (promoted for indexing)
```

### **5. Type Annotation Override**

#### **5a. Explicit Type Hints**
```python
# Force specific types
value: byte = 200      → imm.byte 200
value: word = 200      → imm.word 200
value: bigint = 200    → imm.bigint 200
value: blob = 0x1234   → imm.blob [0x12,0x34]
```

#### **5b. Type Conversion Functions**
```python
# Explicit conversions
byte(300)              → Runtime error (overflow)
word(70000)            → Runtime error (overflow)
bigint(255)            → imm.bigint 255
blob(0x1234)           → imm.blob [0x12,0x34]
blob("text")           → imm.blob [0x74,0x65,0x78,0x74]
```

### **6. Error Conditions**

#### **6a. Compile-Time Errors**
```python
# Value out of range for explicit type
x: byte = 256          # ERROR: 256 exceeds byte range (0-255)
x: word = 65536        # ERROR: 65536 exceeds signed word range (-32768 to 32767)
x: word = -32769       # ERROR: -32769 below signed word minimum
```

#### **6b. Warnings**
```python
# Potentially confusing cases
x = 0xFF               # WARNING: Could be byte(255) or word(255)
x = 32768              # WARNING: Exceeds signed 16-bit, using bigint
```

### **7. Summary Decision Table**

| Value Range | Decimal | Hex | Binary | Result Type |
|-------------|---------|-----|--------|-------------|
| 0-127 | `42` | `0x2A` | `0b101010` | `imm.byte` |
| 128-255 | `200` | `0xC8` | `0b11001000` | `imm.byte` |
| 256-32767 | `1000` | `0x3E8` | `0b1111101000` | `imm.word` |
| -1 to -32768 | `-100` | N/A | N/A | `imm.word` |
| 32768-65535 | `40000` | `0x9C40` | N/A | `imm.word` |
| > 65535 | `100000` | `0x186A0` | N/A | `imm.bigint` |
| < -32768 | `-40000` | N/A | N/A | `imm.bigint` |
| Multi-byte hex | N/A | `0x123456` | N/A | `imm.blob` |
| Strings | `"text"` | N/A | N/A | `imm.blob` |
| Arrays | `[1,2,3]` | N/A | N/A | `imm.blob` |

# ...existing code...

# OCM Bytecode Type Promotion Patterns

Based on the OCM instruction set and type conversion instructions, here are the possible promotion patterns:

## **1. Automatic Promotions (Compiler-Generated)**

### **1a. Arithmetic Promotions**
```python
# Same-type operations (no promotion needed)
byte + byte        → ADD (0x11)           # Use smallint arithmetic
word + word        → ADD (0x11)           # Use smallint arithmetic
bigint + bigint    → ADD.BIGINT (0x87)    # Use bigint arithmetic

# Mixed-type promotions (smaller → larger)
byte + word        → CVTNUM.S → ADD (0x11)        # Promote byte to word
byte + bigint      → CVTNUM.S → ADD.BIGINT (0x87) # Promote byte to bigint
word + bigint      → CVTNUM.S → ADD.BIGINT (0x87) # Promote word to bigint
```

### **1b. Comparison Promotions**
```python
# Mixed comparisons
byte < bigint      → CVTNUM.S → CMP.LT.BIGINT (0x8E)
word > bigint      → CVTNUM.S → CMP.GT.BIGINT (0x8D)
```

## **2. Explicit Conversion Instructions**

### **2a. Number Conversions**
```assembly
# Blob to Number (signed)
CVTNUM.S (0x50)    # blob → signed bigint
# Example: [0xFF, 0xFF] → -1

# Blob to Number (unsigned)
CVTNUM.U (0x51)    # blob → unsigned bigint
# Example: [0xFF, 0xFF] → 65535

# Number to Blob
CVTBLOB (0x52)     # number → blob (big-endian)
# Example: 65535 → [0xFF, 0xFF]

# Signed/Unsigned Reinterpretation
NUMUNSIGNED (0x53) # reinterpret bits as unsigned
# Example: -1 (smallint) → 65535 (bigint)

# Bigint to Smallint (truncation)
TRUNC16 (0x54)     # bigint → smallint (low 16 bits)
# Example: 65537 → 1
```

## **3. Promotion Examples**

### **3a. Mixed Arithmetic Example**
```python
# HLL: result = 100 + 0x123456789ABCDEF
# Generated bytecode:
imm.byte 100           # Push 100 as byte
CVTNUM.S              # Convert to signed bigint
imm.bigint 0x123456789ABCDEF  # Push large number
ADD.BIGINT            # Use bigint addition (0x87)
```

### **3b. Blob Arithmetic Example**
```python
# HLL: key_value = blob_data + 1000
# Generated bytecode:
imm.blob [0x12, 0x34]  # Push blob
CVTNUM.U              # Convert to unsigned bigint (0x1234)
imm.word 1000         # Push 1000
CVTNUM.S              # Convert to bigint
ADD.BIGINT            # Add as bigints
CVTBLOB               # Convert result back to blob
```

### **3c. DWORD Arithmetic Example**
```python
# HLL: hash = (value1 * value2) & 0xFFFFFFFF
# Generated bytecode:
imm.word 12345        # Push first value
imm.word 54321        # Push second value
MUL.DWORD (0x24)      # 32-bit unsigned multiply
imm.bigint 0xFFFFFFFF # Push mask
AND.DWORD (0x29)      # 32-bit bitwise AND
```

## **4. Promotion Hierarchy**

```
byte (8-bit unsigned)
  ↓ CVTNUM.S
word (16-bit signed)
  ↓ CVTNUM.S
bigint (arbitrary precision)
  ↓ CVTBLOB
blob (binary data)
  ↓ CVTNUM.S/CVTNUM.U
bigint (back to numeric)
```

## **5. Special Cases**

### **5a. DWORD Context (Unsigned 32-bit)**
```assembly
# Forces unsigned 32-bit interpretation
smallint → treat as unsigned 16-bit → extend to 32-bit
bigint → take low 32 bits → unsigned interpretation
```

### **5b. Cryptographic Context**
```assembly
# Modular arithmetic requires bigints
imm.word 12345        # Small value
CVTNUM.S             # Promote to bigint
imm.bigint modulus   # Large modulus
ADD.MOD (0x95)       # Modular addition
```

## **6. Compiler Decision Rules**

1. **Preserve precision:** Always promote to larger type
2. **Use efficient instructions:** Keep smallints when possible
3. **Handle signedness:** Use CVTNUM.S for signed, CVTNUM.U for unsigned
4. **Explicit conversions:** Use type annotations to force specific paths
5. **Context-aware:** Array indices stay smallint, crypto operations use bigint

The key insight is that **OCM requires explicit conversions** unlike high-level languages that do automatic promotion, giving precise control over numeric interpretation and performance.

### Type System

## Nominal vs Structural

-- OCM is NOMINAL - types are distinct event with same representation

type Byte = UInt8
type Word = Int16
type BigInt = Ref
type Blob = Ref
