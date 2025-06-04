# ASN.1 Reference for OCM Bytecode Machine

This document explains how the OCM Bytecode Machine uses ASN.1 encoding for its data types and serialization.
For the original OCM Bytecode documentation, see:
[https://wiki.physik.fu-berlin.de/linux-minidisc/ocmbytecode](https://wiki.physik.fu-berlin.de/linux-minidisc/ocmbytecode)

---

## Overview

The OCM Bytecode Machine uses ASN.1 (Abstract Syntax Notation One) encoding for serialization of its core data types:
- **Smallint** and **Bigint** (integers)
- **Blob** (binary data)
- **Array** (heterogeneous sequences)

Serialization is always in binary (BER/DER-like) format, not textual ASN.1.

---

## ASN.1 Concepts Used

- **Length-prefixed encoding:** All values are serialized with an ASN.1-style length prefix.
- **Primitive types:** Smallint/Bigint as INTEGER, Blob as OCTET STRING.
- **SEQUENCE:** Arrays are encoded as ASN.1 SEQUENCEs (can contain mixed types).
- **Two's complement, little-endian:** Integers are encoded in two's complement, little-endian order after the ASN.1 length.

---

## OCM Data Types and ASN.1 Mapping

### Smallint / Bigint

- **ASN.1 Type:** `INTEGER`
- **Encoding:** `[ASN.1 length][two's complement little-endian bytes]`
- **Example:**
  - Value: `42` (smallint)
  - ASN.1: `02 01 2A` (Tag 0x02, Length 0x01, Value 0x2A)

### Blob

- **ASN.1 Type:** `OCTET STRING`
- **Encoding:** `[ASN.1 length][raw bytes]`
- **Example:**
  - Value: `0xDEADBEEF`
  - ASN.1: `04 04 DE AD BE EF` (Tag 0x04, Length 0x04, Value bytes)

### Array

- **ASN.1 Type:** `SEQUENCE`
- **Encoding:** `[ASN.1 length][encoded elements]`
- **Elements:** Each element is encoded as its ASN.1 type (INTEGER, OCTET STRING, SEQUENCE, etc.)
- **Example:**
  - Array: `[42, "foo"]`
  - ASN.1: `30 06 02 01 2A 04 03 66 6F 6F`
    - `30`: SEQUENCE, `06`: length, `02 01 2A`: INTEGER 42, `04 03 66 6F 6F`: OCTET STRING "foo"

---

## OCM Opcodes Using ASN.1

| Opcode      | Name         | Description                                 |
|-------------|--------------|---------------------------------------------|
| `0x5D`      | ASN1ENCODE   | Encode stack value as ASN.1 blob            |
| `0x5E`      | ASN1ARRAY    | Pack N stack values as ASN.1 SEQUENCE blob  |
| `0x5F`      | ASN1DECODE   | Decode ASN.1 blob to stack value            |

---

## ASN.1 Encoding Rules in OCM

- **Length:** Standard ASN.1 BER/DER length encoding (short or long form).
- **Tag:** Standard ASN.1 tags (INTEGER: 0x02, OCTET STRING: 0x04, SEQUENCE: 0x30).
- **Value:**
  - Integers: two's complement, little-endian (unusual for ASN.1, but as per OCM docs).
  - Blobs: raw bytes.
  - Arrays: sequence of encoded elements.

---

## Example: Encoding an Array

Suppose the stack contains:
- Smallint `1`
- Blob `"hi"` (ASCII)

OCM ASN.1 encoding as SEQUENCE:
```
30 07    // SEQUENCE, length 7
   02 01 01    // INTEGER, length 1, value 1
   04 02 68 69 // OCTET STRING, length 2, value "hi"
```

---

## Notes

- **Heterogeneous arrays:** OCM arrays can contain mixed types; ASN.1 SEQUENCE allows this.
- **Decoding:** ASN.1 decoding in OCM expects the above conventions (especially little-endian integers).
- **Compatibility:** OCM's ASN.1 is compatible with BER/DER, except for integer endianness.

---

## See Also

- [ASN.1 Encoding (Wikipedia)](https://en.wikipedia.org/wiki/X.690)
- [OCM Bytecode Machine Reference](https://wiki.physik.fu-berlin.de/linux-minidisc/ocmbytecode)
