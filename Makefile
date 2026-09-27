SRC_DIR := src
BUILD_DIR := build
ASM_SRC := $(SRC_DIR)/main.s
OBJ := $(BUILD_DIR)/main.o
BIN := $(BUILD_DIR)/main

.PHONY: all clean

all: $(BIN)

$(BUILD_DIR):
    mkdir -p $(BUILD_DIR)

$(OBJ): $(ASM_SRC) | $(BUILD_DIR)
    as -g $< -o $@

$(BIN): $(OBJ)
    ld $(OBJ) -o $(BIN)

clean:
    rm -rf $(BUILD_DIR)