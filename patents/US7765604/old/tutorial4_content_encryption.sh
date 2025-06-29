#!/bin/bash
# tutorial4_content_encryption.sh - Multi-layer content encryption

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
print_info() { echo -e "${BLUE}$1${NC}"; }
print_key() { echo -e "${MAGENTA}$1${NC}"; }
print_content() { echo -e "${WHITE}$1${NC}"; }

print_header "=== Tutorial 4: Multi-layer Content Encryption ==="

# 1. Create sample content
print_step "1. Creating sample content..."
cat > original_content.txt << EOF
This is a secret movie file that needs DRM protection.
It contains valuable intellectual property.
Each block will be encrypted with different keys for security.
Block 1 content here.
Block 2 content here.
Block 3 content here.
EOF

print_info "Original content:"
print_content "$(cat original_content.txt)"

# 2. Generate content key
print_step "\n2. Generating content key..."
openssl rand -hex 32 > content_key.txt
CONTENT_KEY=$(cat content_key.txt)
print_key "Content key: $CONTENT_KEY"

# 3. Get root key (from EKB in real system)
print_step "\n3. Using root key for key encryption..."
if [ ! -f "root_key.txt" ]; then
    openssl rand -hex 32 > root_key_demo.txt
    ROOT_KEY=$(cat root_key_demo.txt)
else
    ROOT_KEY=$(cat root_key.txt)
fi
print_key "Root key: $ROOT_KEY"

# Encrypt content key with root key
echo "$CONTENT_KEY" | openssl enc -aes-256-cbc -a -salt -pass pass:"$ROOT_KEY" > encrypted_content_key.txt
print_success "Content key encrypted with root key"

# 4. Split content into blocks
print_step "\n4. Splitting content into blocks..."
split -l 2 original_content.txt block_
BLOCKS=(block_*)

print_info "Content split into ${#BLOCKS[@]} blocks:"
for i in "${!BLOCKS[@]}"; do
    print_info "Block $((i+1)): $(head -1 "${BLOCKS[i]}")"
done

# 5. Encrypt each block with derived keys
print_step "\n5. Encrypting blocks with derived keys..."
for i in "${!BLOCKS[@]}"; do
    BLOCK="${BLOCKS[i]}"
    
    # Generate random seed for this block
    SEED=$(openssl rand -hex 16)
    print_info "Block $((i+1)) seed: $SEED"
    
    # Derive block key: K'c = Hash(Kc, Seed)
    DERIVED_KEY=$(echo -n "${CONTENT_KEY}${SEED}" | openssl dgst -sha256 | cut -d' ' -f2)
    print_key "Block $((i+1)) derived key: $DERIVED_KEY"
    
    # Encrypt block with derived key
    openssl enc -aes-256-cbc -a -salt -pass pass:"$DERIVED_KEY" -in "$BLOCK" -out "${BLOCK}_encrypted"
    
    # Store seed with encrypted block (in real system, this goes in block header)
    echo "$SEED" > "${BLOCK}_seed"
    
    print_success "Block $((i+1)) encrypted"
done

print_header "\n6. Multi-layer encryption complete!"
print_success "Encryption layers:"
print_success "- Layer 1: Content key encrypted with root key"
print_success "- Layer 2: Each block encrypted with unique derived key"
print_success "- Random seeds ensure different keys per block"

# 7. Show file structure
print_step "\n7. Encrypted file structure:"
print_info "Files created:"
ls -la *encrypted* *seed* encrypted_content_key.txt | sed 's/^/  /'

print_header "\nSecurity benefits:"
print_success "- Content key separation from content"
print_success "- Each block has unique encryption key"
print_success "- Compromise of one block doesn't affect others"
print_success "- Root key controls access to all content"
