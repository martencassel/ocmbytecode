#!/bin/bash
# tutorial8_complete_workflow.sh - Complete DRM workflow

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
print_phase() { echo -e "${BOLD}${MAGENTA}$1${NC}"; }
print_step() { echo -e "${BOLD}${YELLOW}$1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}$1${NC}"; }
print_key() { echo -e "${MAGENTA}$1${NC}"; }

print_header "=== Tutorial 8: Complete DRM Workflow ==="

# Phase 1: System Setup
print_phase "PHASE 1: SYSTEM SETUP"
print_phase "====================="

# Generate license server keys
openssl genrsa -out ls_private.pem 2048 2>/dev/null
openssl rsa -in ls_private.pem -pubout -out ls_public.pem 2>/dev/null

# Generate device key
openssl rand -hex 32 > device_key.txt
DEVICE_KEY=$(cat device_key.txt)
print_key "Device enrolled with key: $DEVICE_KEY"

# Phase 2: Content Distribution
print_phase "\nPHASE 2: CONTENT DISTRIBUTION"
print_phase "=============================="

# Create content
echo "Secret movie content - DRM protected!" > movie.txt
print_info "Content created: $(cat movie.txt)"

# Encrypt content
openssl rand -hex 32 > movie_content_key.txt
CONTENT_KEY=$(cat movie_content_key.txt)
openssl enc -aes-256-cbc -a -salt -pass pass:"$CONTENT_KEY" -in movie.txt -out movie_encrypted.txt
print_key "Content encrypted with key: $CONTENT_KEY"

# Create content package with metadata
cat > content_package.json << EOF
{
  "content_id": "MOVIE123",
  "license_id": "LIC_MOVIE123",
  "license_server_url": "https://license.example.com",
  "content_key_encrypted": "$(echo "$CONTENT_KEY" | openssl enc -aes-256-cbc -a -salt -pass pass:"$DEVICE_KEY")",
  "content_file": "movie_encrypted.txt"
}
EOF

echo "Content package created (freely distributable)"

# Phase 3: License Purchase
echo -e "\nPHASE 3: LICENSE PURCHASE"
echo "========================="

# Create license
cat > movie_license.json << EOF
{
  "license_id": "LIC_MOVIE123",
  "content_id": "MOVIE123", 
  "device_id": "$DEVICE_KEY",
  "valid_until": "2024-12-31",
  "max_plays": 5,
  "purchased": true
}
EOF

# Sign license
openssl dgst -sha256 -sign ls_private.pem -out license_signature.bin movie_license.json
echo "License purchased and signed"

# Phase 4: Content Playback
echo -e "\nPHASE 4: CONTENT PLAYBACK"
echo "========================="

# Verify license signature
if openssl dgst -sha256 -verify ls_public.pem -signature license_signature.bin movie_license.json; then
    echo "✓ License signature valid"
    
    # Extract encrypted content key from package
    ENCRYPTED_CONTENT_KEY=$(grep -o '"content_key_encrypted": "[^"]*"' content_package.json | cut -d'"' -f4)
    
    # Decrypt content key using device key
    DECRYPTED_CONTENT_KEY=$(echo "$ENCRYPTED_CONTENT_KEY" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$DEVICE_KEY")
    
    # Decrypt content
    openssl enc -aes-256-cbc -d -a -salt -pass pass:"$DECRYPTED_CONTENT_KEY" -in movie_encrypted.txt -out movie_decrypted.txt
    
    echo "✓ Content successfully decrypted"
    echo "Decrypted content: $(cat movie_decrypted.txt)"
    
    # Update play count (in real system)
    echo "Play count updated (not implemented in demo)"
    
else
    echo "✗ License invalid - cannot play content"
fi

echo -e "\n=== DRM Workflow Complete ==="
echo "Content was distributed freely but could only be played with valid license"
