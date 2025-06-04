# OCM Compiler

## Overview

The OCM Compiler is a simple compiler designed to process arithmetic expressions and generate bytecode for the OCM Bytecode Machine. It consists of a lexer, parser, and code generator, allowing users to input arithmetic expressions and receive corresponding OCM bytecode.

## Project Structure

```
ocm-compiler
├── src
│   ├── main.c          # Entry point of the compiler
│   ├── lexer.c         # Lexer implementation
│   ├── lexer.h         # Lexer header file
│   ├── parser.c        # Parser implementation
│   ├── parser.h        # Parser header file
│   ├── codegen.c       # Code generation implementation
│   ├── codegen.h       # Code generation header file
│   └── ocm_opcodes.h   # OCM bytecode opcodes definitions
├── Makefile             # Build instructions
└── README.md            # Project documentation
```

## Features

- **Lexer**: Tokenizes input arithmetic expressions into manageable tokens.
- **Parser**: Constructs an abstract syntax tree (AST) from the tokens provided by the lexer.
- **Code Generation**: Translates the AST into OCM bytecode instructions.

## Building the Project

To build the OCM Compiler, navigate to the project directory and run the following command:

```
make
```

This will compile the source files and create an executable named `ocm-compiler`.

## Usage

After building the project, you can run the compiler with an arithmetic expression as input. The compiler will process the expression and output the corresponding OCM bytecode.

## Contributing

Contributions to the OCM Compiler are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.


This code applies several foundational concepts from the "Dragon Book" (Aho, Lam, Sethi, Ullman, *Compilers: Principles, Techniques, and Tools*):

---

### 1. **Abstract Syntax Tree (AST) Construction**
- The code defines an `ASTNode` structure to represent the parsed program as a tree, a key concept in syntax analysis (Chapter 4: Syntax Analysis).
- Nodes represent either numbers (leaf nodes) or binary operations (internal nodes).

### 2. **Recursive Descent Parsing**
- The parser is implemented as a set of mutually recursive functions (`parse_expression`, `parse_term`, `parse_primary`), directly reflecting the grammar of arithmetic expressions.
- This is a classic *top-down parsing* technique (Section 4.4: Recursive-Descent Parsing).

### 3. **Operator Precedence and Associativity**
- The parser separates parsing of terms (`*`, `/`) and expressions (`+`, `-`), enforcing correct precedence and left-associativity (Section 4.2: Context-Free Grammars, and Section 4.4.2: Predictive Parsing).

### 4. **Lexical Analysis Interface**
- The parser interacts with a lexer (`lexer_next_token`, `lexer_peek_token`), separating lexical and syntactic analysis (Chapter 3: Lexical Analysis).

### 5. **Memory Management for Trees**
- The code allocates and frees AST nodes, reflecting the need for dynamic memory management in tree-based representations (Section 7.5: Storage Management).

---

**Summary:**
This code demonstrates recursive-descent parsing, AST construction, operator precedence handling, and separation of lexical and syntactic analysis—all core topics in the Dragon Book.
