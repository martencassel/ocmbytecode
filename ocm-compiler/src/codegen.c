#include <stdio.h>
#include <stdlib.h>
#include "codegen.h"
#include "ocm_opcodes.h"

// Function to generate OCM bytecode for a given AST node
void generate_code(ASTNode *node, FILE *output) {
    if (node == NULL) {
        return;
    }

    switch (node->type) {
        case NODE_NUMBER:
            // Push the number onto the stack
            fprintf(output, "0x01 %d\n", node->value); // Immediate Byte
            break;

        case NODE_ADD:
            generate_code(node->left, output);
            generate_code(node->right, output);
            // Generate bytecode for addition
            fprintf(output, "0x11\n"); // ADD
            break;

        case NODE_SUBTRACT:
            generate_code(node->left, output);
            generate_code(node->right, output);
            // Generate bytecode for subtraction
            fprintf(output, "0x12\n"); // SUB
            break;

        case NODE_MULTIPLY:
            generate_code(node->left, output);
            generate_code(node->right, output);
            // Generate bytecode for multiplication
            fprintf(output, "0x13\n"); // MUL
            break;

        case NODE_DIVIDE:
            generate_code(node->left, output);
            generate_code(node->right, output);
            // Generate bytecode for division
            fprintf(output, "0x14\n"); // DIV
            break;

        default:
            fprintf(stderr, "Error: Unknown AST node type\n");
            exit(EXIT_FAILURE);
    }
}

// Function to initialize code generation
void init_codegen(const char *output_file) {
    FILE *output = fopen(output_file, "w");
    if (!output) {
        perror("Failed to open output file");
        exit(EXIT_FAILURE);
    }
    // Additional initialization can be done here
    fclose(output);
}