#ifndef LEXER_H
#define LEXER_H

typedef enum {
    TOKEN_NUMBER,
    TOKEN_PLUS,
    TOKEN_MINUS,
    TOKEN_MULTIPLY,
    TOKEN_DIVIDE,
    TOKEN_EOF,
    TOKEN_INVALID
} TokenType;

typedef struct {
    TokenType type;
    union {
        int value; // For TOKEN_NUMBER
    } data;
} Token;

void lexer_init(const char *source);
Token lexer_next_token();
void lexer_free();

#endif // LEXER_H