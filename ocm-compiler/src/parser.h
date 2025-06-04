#ifndef PARSER_H
#define PARSER_H

#include "lexer.h"

// Abstract Syntax Tree (AST) node types
typedef enum {
    AST_NODE_NUMBER,
    AST_NODE_BINARY_OP,
} ASTNodeType;

// Structure for AST nodes
typedef struct ASTNode {
    ASTNodeType type;
    union {
        int value; // For number nodes
        struct {
            struct ASTNode* left;
            struct ASTNode* right;
            TokenType op; // Operator for binary operations
        } binary_op; // For binary operation nodes
    };
} ASTNode;

// Function to create a new number node
ASTNode* create_number_node(int value);

// Function to create a new binary operation node
ASTNode* create_binary_op_node(ASTNode* left, TokenType op, ASTNode* right);

// Function to free the AST
void free_ast(ASTNode* node);

// Function to parse an expression and return the AST
ASTNode* parse_expression(Lexer* lexer);

// Function to initialize the parser
void init_parser(Lexer* lexer);

#endif // PARSER_H