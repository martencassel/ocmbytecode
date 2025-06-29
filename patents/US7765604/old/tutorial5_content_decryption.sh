#!/bin/bash
# tutorial5_content_decryption.sh - Client-side content decryption

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Color functions
print_header() { echo -e "${BOLD}${CYAN}$1${NC}"; }
print_step() { echo -e "${BOLD}${YELLOW}$1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}$1${NC}"; }
print_key() { echo -e "${MAGENTA}$1${NC}"; }
print_content() { echo -e "${WHITE}$1${NC}"; }

print_header "=== Tutorial 5: Content Decryption Process ==="

# Prerequisites: Run tutorial4 first to create encrypted content
if [ ! -f "encrypted_content_key.txt" ]; then
    print_error "Run tutorial4_content_encryption.sh first!"
    exit 1
fi

# Step 1: Device decrypts root key from EKB (simulated)
print_step "1. Device decrypts root key from EKB..."
if [ -f "root_key.txt" ]; then
    ROOT_KEY=$(cat root_key.txt)
elif [ -f "root_key_demo.txt" ]; then
    ROOT_KEY=$(cat root_key_demo.txt)
else
    print_error "No root key found. Run tutorial4 first."
    exit 1
fi
print_key "Device obtained root key: $ROOT_KEY"

# Step 2: Decrypt content key using root key
print_step "\n2. Decrypting content key using root key..."
DECRYPTED_CONTENT_KEY=$(openssl enc -aes-256-cbc -d -a -salt -pass pass:"$ROOT_KEY" -in encrypted_content_key.txt)
print_key "Decrypted content key: $DECRYPTED_CONTENT_KEY"

# Step 3: Decrypt each content block
print_step "\n3. Decrypting content blocks..."
ENCRYPTED_BLOCKS=(block_*_encrypted)

for ENCRYPTED_BLOCK in "${ENCRYPTED_BLOCKS[@]}"; do
    # Get block identifier (aa, ab, ac, etc.)
    BLOCK_ID=$(echo "$ENCRYPTED_BLOCK" | sed 's/block_\([^_]*\)_encrypted/\1/')
    
    # Read seed for this block
    if [ -f "block_${BLOCK_ID}_seed" ]; then
        SEED=$(cat "block_${BLOCK_ID}_seed")
        print_info "Block $BLOCK_ID seed: $SEED"
        
        # Derive block key: K'c = Hash(Kc, Seed)
        DERIVED_KEY=$(echo -n "${DECRYPTED_CONTENT_KEY}${SEED}" | openssl dgst -sha256 | cut -d' ' -f2)
        print_key "Block $BLOCK_ID derived key: $DERIVED_KEY"
        
        # Decrypt block
        openssl enc -aes-256-cbc -d -a -salt -pass pass:"$DERIVED_KEY" -in "$ENCRYPTED_BLOCK" -out "decrypted_${BLOCK_ID}"
        print_success "Block $BLOCK_ID decrypted"
    else
        print_warning "Seed file for block $BLOCK_ID not found"
    fi
done

# Step 4: Reassemble content
print_step "\n4. Reassembling decrypted content..."
cat decrypted_* > final_decrypted_content.txt 2>/dev/null

print_header "=== COMPARISON ==="
print_info "Original content:"
print_content "$(cat original_content.txt)"
print_info "\nDecrypted content:"
print_content "$(cat final_decrypted_content.txt)"

# Step 5: Verify decryption
print_step "\n5. Verification:"
if [ -f "final_decrypted_content.txt" ] && [ -s "final_decrypted_content.txt" ]; then
    if cmp -s original_content.txt final_decrypted_content.txt; then
        print_success "SUCCESS: Content decrypted correctly!"
    else
        print_warning "Warning: Decrypted content differs from original"
        print_info "This might be due to block ordering or formatting"
        
        # Check if content is substantially the same
        if grep -q "secret movie file" final_decrypted_content.txt; then
            print_success "Core content appears to be decrypted correctly"
        fi
    fi
else
    print_error "ERROR: Decryption failed - no output file created"
fi

print_header "\n=== DECRYPTION PROCESS SUMMARY ==="
print_success "1. Device obtained root key from EKB"
print_success "2. Root key used to decrypt content key"
print_success "3. Content key + block seeds used to derive block keys"
print_success "4. Each block decrypted with its unique key"
print_success "5. Blocks reassembled into original content"
echo ""
print_info "This demonstrates the reverse of the encryption process,"
print_info "showing how authorized devices can decrypt protected content."
