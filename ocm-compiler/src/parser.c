#include <stdio.h>
#include <stdlib.h>
#include "parser.h"
#include "lexer.h"
#include "codegen.h"

typedef struct ASTNode {
    enum { NODE_NUMBER, NODE_BINARY_OP } type;
    union {
        int value; // For NODE_NUMBER
        struct {
            struct ASTNode *left;
            struct ASTNode *right;
            int op; // Operator
        } binary_op; // For NODE_BINARY_OP
    };
} ASTNode;

static ASTNode *create_number_node(int value) {
    ASTNode *node = malloc(sizeof(ASTNode));
    node->type = NODE_NUMBER;
    node->value = value;
    return node;
}

static ASTNode *create_binary_op_node(ASTNode *left, ASTNode *right, int op) {
    ASTNode *node = malloc(sizeof(ASTNode));
    node->type = NODE_BINARY_OP;
    node->binary_op.left = left;
    node->binary_op.right = right;
    node->binary_op.op = op;
    return node;
}

static ASTNode *parse_expression(Lexer *lexer);

static ASTNode *parse_primary(Lexer *lexer) {
    Token token = lexer_next_token(lexer);
    if (token.type == TOKEN_NUMBER) {
        return create_number_node(token.value);
    }
    // Handle other cases (like parentheses) here
    return NULL;
}

static ASTNode *parse_term(Lexer *lexer) {
    ASTNode *node = parse_primary(lexer);
    while (1) {
        Token token = lexer_peek_token(lexer);
        if (token.type == TOKEN_MUL || token.type == TOKEN_DIV) {
            lexer_next_token(lexer); // Consume the operator
            ASTNode *right = parse_primary(lexer);
            node = create_binary_op_node(node, right, token.type);
        } else {
            break;
        }
    }
    return node;
}

static ASTNode *parse_expression(Lexer *lexer) {
    ASTNode *node = parse_term(lexer);
    while (1) {
        Token token = lexer_peek_token(lexer);
        if (token.type == TOKEN_ADD || token.type == TOKEN_SUB) {
            lexer_next_token(lexer); // Consume the operator
            ASTNode *right = parse_term(lexer);
            node = create_binary_op_node(node, right, token.type);
        } else {
            break;
        }
    }
    return node;
}

ASTNode *parse(Lexer *lexer) {
    return parse_expression(lexer);
}

void free_ast(ASTNode *node) {
    if (node) {
        if (node->type == NODE_BINARY_OP) {
            free_ast(node->binary_op.left);
            free_ast(node->binary_op.right);
        }
        free(node);
    }
}