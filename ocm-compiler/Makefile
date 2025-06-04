CC=gcc
CFLAGS=-Wall -Wextra -g
SRC=src/main.c src/lexer.c src/parser.c src/codegen.c
OBJ=$(SRC:.c=.o)
BIN=ocm-compiler

all: $(BIN)

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ)

test: $(BIN)
	@echo "Running test: 1 + 2 * 3"
	./$(BIN) tests/arith1.ocmexpr > tests/arith1.bytecode
	@echo "Bytecode output:"
	@cat tests/arith1.bytecode
	@echo
	@echo "Running test: (4 - 1) * 5"
	./$(BIN) tests/arith2.ocmexpr > tests/arith2.bytecode
	@echo "Bytecode output:"
	@cat tests/arith2.bytecode
	@echo

clean:
	rm -f $(OBJ) $(BIN) tests/*.bytecode

.PHONY: all test clean
