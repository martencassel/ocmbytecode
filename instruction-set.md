Based on the OCM bytecode instruction set, here's a categorized breakdown:

## **1. Stack Manipulation & Constants**
### **1a. Basic Stack Operations (0x00-0x0F)**
- **Basic Stack Ops:** NOP, DUP, DUPNONZERO, POP, DESTROY, EXCH
- **Stack Indexing:** INDEX, FETCHSTACK, ROLLIN variants
- **Immediate Values:** Immediate byte/word/bigint/blob
- **Dictionary Ops:** SETUDICT, SETDICT, GETDICT

### **1b. Constants & Literals (0x37-0x43, 0x4E-0x4F)**
- **Small Constants:** PUSH 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -2, -3
- **Stack Tests:** ISPOS, ISNEG, ISZERO
- **Increment/Decrement:** INC.W, DEC.W
- **Advanced Indexing:** INDEX.1-4, ROLLIN.3-5

## **2. Arithmetic & Logic**
### **2a. Smallint Operations (0x10-0x1F)**
- **Arithmetic:** ADD, SUB, MUL, DIV, MODDIV, DIVMOD
- **Bitwise:** XOR, AND, OR, NEG, SHL, SHR, SAR
- **Comparison:** CMP.GT, CMP.LT, CMP.EQ, ISZEROW

### **2b. DWORD Operations (0x20-0x2F)**
- **Arithmetic:** ADD.DWORD, SUB.DWORD, MUL.DWORD, DIV.DWORD, etc.
- **Bitwise:** XOR.DWORD, AND.DWORD, OR.DWORD, NOT.DWORD, shifts
- **Comparison:** CMP.LT.DWORD, CMP.GT.DWORD, CMP.EQ.DWORD

### **2c. Big Integer Operations (0x87-0x8F)**
- **Arithmetic:** Add, subtract, multiply, divide big integers
- **Comparison:** Greater, less, equal for big integers

## **3. Control Flow (0x30-0x36)**
- **Execution:** EXEC, IFELSE, WHILE
- **Stack Context:** TOALT, FROMALT, PEEKALT

## **4. Type System & Conversion (0x50-0x5F)**
- **Type Conversion:** CVTNUM.S, CVTNUM.U, CVTBLOB, NUMUNSIGNED, TRUNC16
- **Array Operations:** ARRAY.ASTORE, ALOAD.LENGTH, LENGTH.ARR, AINSERT, ACUT, GET, SET, ARRAY
- **Serialization:** ASN1ENCODE, ASN1ARRAY, ASN1DECODE

## **5. System & Utility (0x60-0x6F)**
- **Data Handling:** ENCLOSE, DISCLOSE, COUNTBITS, TYPE
- **Threading:** THREADS, TIMESLICE, KILLTHREADS, TO/FROM/PEEKMAIN
- **Time:** GETTIMEOFDAY, MKTIME, LOCALTIME
- **Crypto:** Immediate crypted values

## **6. Random Number Generation (0x70-0x7F)**
- **RNG Operations:** RNG.SKIPGET, RNG.AUTOSKIP, RNG.SEED
- **Stream Decryption:** DECRYPTSEED, DECRYPTTABLE

## **7. Module System (0x75-0x7D)**
- **Native Modules:** LOADNATMOD, UNLOADNATMOD, CALLNATMOD, CALLBLOBMOD
- **Module Management:** MODNAME, MODHND, MODCREATE
- **Bytecode Modules:** BCMODCREATE, BCMODCALL

## **8. Advanced Mathematics**
### **8a. Modular Arithmetic (0x90-0x9F)**
- **Modular Ops:** Add, subtract, multiply, negate, reciprocal (mod m)
- **Power Operations:** Power, product of powers
- **Fuzzing:** Initialize context, fuzz/unfuzz numbers

### **8b. Fuzzed Arithmetic (0xA0-0xAF)**
- **Fuzzed Operations:** Add, subtract, multiply fuzzed numbers
- **Power Contexts:** Initialize and use power contexts

### **8c. Elliptic Curve Cryptography (0xAA-0xC1)**
- **Mod-P Curves:** Create context, add points, scalar multiplication
- **GF Curves:** Galois field elliptic curve operations
- **GFES Curves:** Efficient squaring elliptic curve operations

## **9. Compatibility/Extended Operations (0xC2-0xE0)**
- **String/Blob Ops:** blob.part, concat, compare, index, xor
- **Floating Point:** Add, subtract, multiply, divide floats
- **Cryptography:** DES operations, SHA1 hashing
- **Utility:** PRNG bytes, various helper functions

## **10. Special/Debug (0x80-0x86, 0xFB)**
- **Debug/Hook:** Unknown hook functions
- **Reference Management:** Pop without unref
- **Advanced Calls:** Dictionary procedure calls, RDTSC

---

## **Instruction Set Design Principles**

This categorization reveals several design patterns in the OCM bytecode:

### **Progressive Complexity**
- **Basic types:** Smallint → DWORD → BigInt
- **Simple operations** evolve into **modular arithmetic** and **elliptic curves**
- **Stack manipulation** provides foundation for all higher-level operations

### **Orthogonal Instruction Families**
- Each arithmetic family (smallint, dword, bigint) has parallel operations
- Type conversion bridges between families
- Specialized contexts (fuzzing, power, elliptic curve) extend capabilities

### **Stack-Centric Design**
- All operations consume from and produce to the stack
- Alternate stack provides call/return context
- No register allocation - pure stack machine

### **Cryptographic Focus**
- Extensive support for modular arithmetic
- Multiple elliptic curve implementations
- Stream encryption/decryption capabilities
- Fuzzing for side-channel attack resistance

---

This categorization groups related instructions together, making it easier to:
- Implement instruction families together
- Understand the VM's capabilities
- Design a high-level language that maps to these categories
- Build a compiler that targets specific instruction groups


---

# HLL Source
small  = 0x12
word   = 0x1234
large  = 12345678901230292931236789
mlarge = -12345678901230292931236789
blob   = 0x123456789

# Compiler Type Inference Rules

# Automatic type selection based on value range
42          → smallint (fits in 16-bit signed)
65536       → bigint (exceeds 16-bit)
-32768      → smallint (minimum 16-bit signed)
-32769      → bigint (below 16-bit minimum)

# Hex literals with implicit sizing
0x42        → byte (if fits in 8-bit unsigned)
0x1234      → word (if fits in 16-bit)
0x12345     → bigint (exceeds 16-bit)

# Blob literals (hex sequences)
0x123456789 → blob [0x12,0x34,0x56,0x78,0x9]
