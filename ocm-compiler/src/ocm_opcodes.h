#ifndef OCM_OPCODES_H
#define OCM_OPCODES_H

// OCM Bytecode Opcodes for Arithmetic Operations
#define OPCODE_ADD        0x11  // Add smallints
#define OPCODE_SUB        0x12  // Subtract smallints
#define OPCODE_MUL        0x13  // Multiply smallints
#define OPCODE_DIV        0x14  // Divide smallints
#define OPCODE_MODDIV     0x15  // Divide and modulus
#define OPCODE_DIVMOD     0x16  // Modulus only
#define OPCODE_NEG        0x1A  // Bitwise NOT
#define OPCODE_CMP_GT     0x1E  // Compare greater than
#define OPCODE_CMP_LT     0x1F  // Compare less than

// OCM Bytecode Opcodes for Stack Manipulation
#define OPCODE_DUP        0x05  // Duplicate top of stack
#define OPCODE_POP        0x07  // Remove top of stack
#define OPCODE_PUSH       0x37  // Push smallint 0-8

#endif // OCM_OPCODES_H