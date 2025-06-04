#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexer.h"

#define MAX_TOKEN_LENGTH 64

typedef enum {
    TOKEN_NUMBER,
    TOKEN_PLUS,
    TOKEN_MINUS,
    TOKEN_MULTIPLY,
    TOKEN_DIVIDE,
    TOKEN_EOF,
    TOKEN_INVALID
} TokenType;

struct Token {
    TokenType type;
    char value[MAX_TOKEN_LENGTH];
};

static const char *input;
static size_t position;

void lexer_init(const char *src) {
    input = src;
    position = 0;
}

static char current_char() {
    return input[position];
}

static void advance() {
    position++;
}

static void skip_whitespace() {
    while (current_char() == ' ' || current_char() == '\t' || current_char() == '\n') {
        advance();
    }
}

static struct Token create_token(TokenType type, const char *value) {
    struct Token token;
    token.type = type;
    strncpy(token.value, value, MAX_TOKEN_LENGTH);
    token.value[MAX_TOKEN_LENGTH - 1] = '\0'; // Ensure null-termination
    return token;
}

struct Token lexer_next_token() {
    while (current_char() != '\0') {
        if (current_char() == ' ' || current_char() == '\t' || current_char() == '\n') {
            skip_whitespace();
            continue;
        }

        if (current_char() >= '0' && current_char() <= '9') {
            char number[MAX_TOKEN_LENGTH];
            size_t length = 0;

            while (current_char() >= '0' && current_char() <= '9') {
                if (length < MAX_TOKEN_LENGTH - 1) {
                    number[length++] = current_char();
                }
                advance();
            }
            number[length] = '\0';
            return create_token(TOKEN_NUMBER, number);
        }

        if (current_char() == '+') {
            advance();
            return create_token(TOKEN_PLUS, "+");
        }

        if (current_char() == '-') {
            advance();
            return create_token(TOKEN_MINUS, "-");
        }

        if (current_char() == '*') {
            advance();
            return create_token(TOKEN_MULTIPLY, "*");
        }

        if (current_char() == '/') {
            advance();
            return create_token(TOKEN_DIVIDE, "/");
        }

        return create_token(TOKEN_INVALID, "Invalid character");
    }

    return create_token(TOKEN_EOF, "");
}