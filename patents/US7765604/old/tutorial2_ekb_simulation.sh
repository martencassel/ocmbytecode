#!/bin/bash
# tutorial2_ekb_simulation.sh - EKB (Encrypted Key Block) simulation

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
print_info() { echo -e "${BLUE}$1${NC}"; }
print_key() { echo -e "${MAGENTA}$1${NC}"; }
print_tree() { echo -e "${CYAN}$1${NC}"; }

print_header "=== Tutorial 2: EKB (Encrypted Key Block) Simulation ==="

# Simulate key tree structure
print_step "1. Setting up key tree structure..."

# Root key and category keys
openssl rand -hex 32 > root_key.txt
openssl rand -hex 32 > category1_key.txt
openssl rand -hex 32 > category2_key.txt

# Device keys (leaves)
openssl rand -hex 32 > device_a_key.txt
openssl rand -hex 32 > device_b_key.txt
openssl rand -hex 32 > device_c_key.txt
openssl rand -hex 32 > device_d_key.txt

ROOT_KEY=$(cat root_key.txt)
print_key "Root key: $ROOT_KEY"

# Assign devices to categories
# Category 1: devices A, B
# Category 2: devices C, D
print_step "\n2. Key hierarchy:"
print_tree "Root"
print_tree "├── Category1 (devices A, B)"
print_tree "└── Category2 (devices C, D)"

# 3. Create EKB - encrypt root key for all authorized devices
print_step "\n3. Creating EKB (Encrypted Key Block)..."
mkdir -p ekb

# Each device can decrypt root key using its own key
for device in device_a device_b device_c device_d; do
    DEVICE_KEY=$(cat "${device}_key.txt")
    print_info "Encrypting root key for $device..."
    echo "$ROOT_KEY" | openssl enc -aes-256-cbc -a -salt -pass pass:"$DEVICE_KEY" > "ekb/${device}_encrypted_root.txt"
done

print_success "EKB created with encrypted root keys for all devices"

# 4. Device simulation - device A decrypts its portion of EKB
print_step "\n4. Device A accessing content using EKB..."
DEVICE_A_KEY=$(cat device_a_key.txt)

# Device A decrypts root key from EKB
DECRYPTED_ROOT=$(openssl enc -aes-256-cbc -d -a -salt -pass pass:"$DEVICE_A_KEY" -in ekb/device_a_encrypted_root.txt)

print_key "Device A decrypted root key: $DECRYPTED_ROOT"

if [ "$ROOT_KEY" = "$DECRYPTED_ROOT" ]; then
    print_success "Device A successfully obtained root key from EKB"
else
    print_error "Device A failed to decrypt root key"
fi

# 5. Show EKB structure
print_step "\n5. EKB structure:"
ls -la ekb/
print_info "Each device has its own encrypted copy of the root key"

print_success "\nEKB allows efficient key distribution - all devices get the same root key"
print_success "but encrypted with their individual keys."
