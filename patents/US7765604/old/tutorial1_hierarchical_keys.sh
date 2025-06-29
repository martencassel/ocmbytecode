#!/bin/bash
# tutorial1_hierarchical_keys.sh - Simulating hierarchical key structure

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

print_header "=== Tutorial 1: Hierarchical Key Management ==="

print_header "=== Tutorial 1: Hierarchical Key Management ==="

print_info "Simulate a 3-level hierarchy: Root -> Category -> Device"
print_info "In real system: KR -> K0 -> K00 -> Device keys"

# 1. Generate Root Key (KR)
print_step "\n1. Generating Root Key (KR)..."
openssl rand -hex 32 > root_key.txt
ROOT_KEY=$(cat root_key.txt)
print_key "Root Key: $ROOT_KEY"

# 2. Generate Category Key (K0) 
print_step "\n2. Generating Category Key (K0)..."
openssl rand -hex 32 > category_key.txt
CATEGORY_KEY=$(cat category_key.txt)
print_key "Category Key: $CATEGORY_KEY"

# 3. Generate Device Keys (leaf keys)
print_step "\n3. Generating Device Keys..."
for device in device1 device2 device3; do
    openssl rand -hex 32 > "${device}_key.txt"
    DEVICE_KEY=$(cat "${device}_key.txt")
    print_key "Device $device Key: $DEVICE_KEY"
done

# 4. Simulate key path for device1 (device1 -> category -> root)
print_step "\n4. Device1's key path (leaf to root):"
print_key "Device1 Key: $(cat device1_key.txt)"
print_key "Category Key: $(cat category_key.txt)" 
print_key "Root Key: $(cat root_key.txt)"

print_success "\nIn real system, device1 would store all these keys to access content."
