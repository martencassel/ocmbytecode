#!/bin/bash
# tutorial6_license_validation.sh - Digital signatures for licenses

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
print_license() { echo -e "${MAGENTA}$1${NC}"; }

print_header "=== Tutorial 6: License Validation ==="

# 1. Generate license server key pair
print_step "1. Generating License Server key pair..."
openssl genrsa -out license_server_private.pem 2048 2>/dev/null
openssl rsa -in license_server_private.pem -pubout -out license_server_public.pem 2>/dev/null
print_success "License server keys generated"

# 2. Create a license (JSON-like format)
print_step "\n2. Creating license..."
cat > license.json << EOF
{
  "license_id": "LIC123456",
  "content_id": "CONTENT789",
  "user_id": "user@example.com",
  "device_id": "DEVICE001",
  "valid_from": "2024-01-01",
  "valid_until": "2024-12-31",
  "usage_rules": {
    "max_plays": 100,
    "can_copy": false,
    "can_share": false
  }
}
EOF

print_info "License created:"
print_license "$(cat license.json)"

# 3. Sign the license
print_step "\n3. Signing license with server private key..."
openssl dgst -sha256 -sign license_server_private.pem -out license_signature.bin license.json
print_success "License signed, signature saved to license_signature.bin"

# Show signature in hex format
print_info "Signature (first 32 bytes): $(hexdump -C license_signature.bin | head -2)"

# 4. Device verifies license signature
print_step "\n4. Device verifying license signature..."
if openssl dgst -sha256 -verify license_server_public.pem -signature license_signature.bin license.json >/dev/null 2>&1; then
    print_success "License signature VALID - license is authentic"
    print_info "  Device can trust this license came from authorized server"
else
    print_error "License signature INVALID - license may be forged"
fi

# 5. Demonstrate tampering detection
print_step "\n5. Demonstrating tampering detection..."
cp license.json tampered_license.json
sed -i 's/"max_plays": 100/"max_plays": 999/' tampered_license.json

print_info "Original license snippet: $(grep 'max_plays' license.json)"
print_warning "Tampered license snippet: $(grep 'max_plays' tampered_license.json)"

print_info "\nVerifying tampered license with original signature:"
if openssl dgst -sha256 -verify license_server_public.pem -signature license_signature.bin tampered_license.json >/dev/null 2>&1; then
    print_error "SECURITY BREACH: Tampered license passed verification!"
else
    print_success "SECURITY WORKING: Tampered license rejected"
    print_info "  Signature verification failed as expected"
fi

# 6. Create license with different device ID
print_step "\n6. Testing device binding..."
cp license.json wrong_device_license.json
sed -i 's/"device_id": "DEVICE001"/"device_id": "DEVICE999"/' wrong_device_license.json

print_info "Checking license for wrong device:"
print_info "Original device: $(grep 'device_id' license.json)"
print_warning "Wrong device: $(grep 'device_id' wrong_device_license.json)"

if openssl dgst -sha256 -verify license_server_public.pem -signature license_signature.bin wrong_device_license.json >/dev/null 2>&1; then
    print_error "SECURITY ISSUE: License accepted for wrong device"
else
    print_success "DEVICE BINDING WORKING: License rejected for wrong device"
fi

# 7. Demonstrate license validation workflow
print_step "\n7. Complete license validation workflow:"
print_info "---"

# Function to validate license
validate_license() {
    local license_file="$1"
    local signature_file="license_signature.bin"
    local public_key="license_server_public.pem"
    
    print_info "Validating: $license_file"
    
    # Check signature
    if openssl dgst -sha256 -verify "$public_key" -signature "$signature_file" "$license_file" >/dev/null 2>&1; then
        print_success "  Cryptographic signature valid"
        
        # Check expiration (simplified)
        if grep -q "2024-12-31" "$license_file"; then
            print_success "  License not expired"
            print_success "  → LICENSE ACCEPTED: Device can play content"
            return 0
        else
            print_error "  License expired"
            print_error "  → LICENSE REJECTED: Cannot play content"
            return 1
        fi
    else
        print_error "  Cryptographic signature invalid"
        print_error "  → LICENSE REJECTED: Possible forgery"
        return 1
    fi
}

# Test with valid license
validate_license "license.json"
echo ""

# Test with tampered license
validate_license "tampered_license.json"

print_header "\n=== LICENSE VALIDATION SUMMARY ==="
print_success "Digital signatures provide:"
print_success "• Authentication: Verify license came from trusted server"
print_success "• Integrity: Detect any tampering with license terms"
print_success "• Non-repudiation: Server cannot deny issuing valid license"
print_success "• Device binding: License tied to specific device ID"
echo ""
print_info "This prevents:"
print_info "• License forgery"
print_info "• Unauthorized license modification"
print_info "• License sharing between devices"
print_info "• Man-in-the-middle attacks on license delivery"
