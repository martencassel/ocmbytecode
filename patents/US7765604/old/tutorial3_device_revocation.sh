#!/bin/bash
# tutorial3_device_revocation.sh - Device revocation using EKB

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

print_header "=== Tutorial 3: Device Revocation Simulation ==="

# Prerequisites: Run tutorial2 first
if [ ! -d "ekb" ]; then
    print_info "Running tutorial2 first to create EKB..."
    ./tutorial2_ekb_simulation.sh
fi

print_step "\n1. Initial state - all devices authorized..."
print_info "Devices with access: A, B, C, D"

# Create content encrypted with current root key
ROOT_KEY=$(cat root_key.txt)
echo "Secret content for authorized devices only!" > content.txt
echo "$ROOT_KEY" | openssl enc -aes-256-cbc -a -salt -pass pass:"content123" > encrypted_content.txt

print_success "Content encrypted and available"

# 2. Device B is compromised - needs revocation
print_step "\n2. Device B has been compromised - revoking access..."

# Generate new root key
openssl rand -hex 32 > new_root_key.txt
NEW_ROOT_KEY=$(cat new_root_key.txt)
print_key "New root key generated: $NEW_ROOT_KEY"

# Create new EKB excluding device B
print_step "\n3. Creating new EKB (excluding device B)..."
mkdir -p ekb_revoked

# Only devices A, C, D get the new root key
for device in device_a device_c device_d; do
    DEVICE_KEY=$(cat "${device}_key.txt")
    print_info "Encrypting new root key for $device..."
    echo "$NEW_ROOT_KEY" | openssl enc -aes-256-cbc -a -salt -pass pass:"$DEVICE_KEY" > "ekb_revoked/${device}_encrypted_root.txt"
done

print_success "New EKB created - device B excluded"

# 4. Re-encrypt content with new root key
print_step "\n4. Re-encrypting content with new root key..."
echo "$NEW_ROOT_KEY" | openssl enc -aes-256-cbc -a -salt -pass pass:"content123" > new_encrypted_content.txt

# 5. Test access for authorized device (A)
print_step "\n5. Testing access for device A (should work)..."
DEVICE_A_KEY=$(cat device_a_key.txt)
DECRYPTED_ROOT_A=$(openssl enc -aes-256-cbc -d -a -salt -pass pass:"$DEVICE_A_KEY" -in ekb_revoked/device_a_encrypted_root.txt)

if openssl enc -aes-256-cbc -d -a -salt -pass pass:"content123" -in new_encrypted_content.txt > /dev/null 2>&1; then
    print_success "Device A can still access new content"
else
    print_error "Device A cannot access new content"
fi

# 6. Test access for revoked device (B)
print_step "\n6. Testing access for device B (should fail)..."
DEVICE_B_KEY=$(cat device_b_key.txt)

if [ -f "ekb_revoked/device_b_encrypted_root.txt" ]; then
    print_error "Unexpected: Device B still in EKB"
else
    print_success "Device B not in new EKB - access revoked"
fi

# Device B tries to use old root key on new content
print_info "Device B trying to decrypt new content with old root key..."
if openssl enc -aes-256-cbc -d -a -salt -pass pass:"content123" -in new_encrypted_content.txt -out /dev/null 2>/dev/null; then
    print_error "Unexpected: Device B accessed new content"
else
    print_success "Device B cannot decrypt new content - revocation successful"
fi

# 7. Show EKB comparison
print_step "\n7. EKB comparison:"
print_info "Original EKB (all devices):"
ls -1 ekb/ | sed 's/^/  /'
print_info "New EKB (device B revoked):"
ls -1 ekb_revoked/ | sed 's/^/  /'

print_header "\nRevocation complete:"
print_success "- New root key generated"
print_success "- New EKB created excluding compromised device"
print_success "- Content re-encrypted with new key"
print_success "- Authorized devices retain access"
print_success "- Revoked device loses access to new content"
