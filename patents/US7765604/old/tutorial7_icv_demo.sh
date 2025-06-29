#!/bin/bash
# tutorial7_icv_demo.sh - Integrity Check Values

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
print_perf() { echo -e "${WHITE}$1${NC}"; }

print_header "=== Tutorial 7: ICV (Integrity Check Values) ==="

# 1. Generate ICV key (distributed via EKB in real system)
print_step "1. Generating ICV key..."
openssl rand -hex 32 > icv_key.txt
ICV_KEY=$(cat icv_key.txt)
print_key "ICV Key: $ICV_KEY"

# 2. Create license data
print_step "\n2. Creating license data..."
LICENSE_DATA="LIC123456|CONTENT789|user@example.com|DEVICE001|2024-12-31|max_plays:100"
print_info "License data: $LICENSE_DATA"

# 3. Calculate ICV: Hash(ICV_Key, License_Data)
print_step "\n3. Calculating ICV..."
ICV=$(echo -n "${ICV_KEY}${LICENSE_DATA}" | openssl dgst -sha256 | cut -d' ' -f2)
print_key "ICV: $ICV"

# 4. Store license with ICV
print_step "\n4. Storing license with ICV..."
echo "$LICENSE_DATA" > license_with_icv.txt
echo "$ICV" > license_icv.txt
print_success "License and ICV stored separately"

print_info "Files created:"
print_info "  license_with_icv.txt: $(wc -c < license_with_icv.txt) bytes"
print_info "  license_icv.txt: $(wc -c < license_icv.txt) bytes"

# 5. Verify license integrity
echo -e "\n5. Verifying license integrity..."
STORED_LICENSE=$(cat license_with_icv.txt)
STORED_ICV=$(cat license_icv.txt)

# Recalculate ICV
CALCULATED_ICV=$(echo -n "${ICV_KEY}${STORED_LICENSE}" | openssl dgst -sha256 | cut -d' ' -f2)

echo "Stored ICV:     $STORED_ICV"
echo "Calculated ICV: $CALCULATED_ICV"

if [ "$STORED_ICV" = "$CALCULATED_ICV" ]; then
    echo "✓ License integrity verified - no tampering detected"
else
    echo "✗ License integrity check failed - tampering detected"
fi

# 6. Demonstrate tampering detection
echo -e "\n6. Demonstrating tampering detection..."
echo "LIC123456|CONTENT789|user@example.com|DEVICE001|2024-12-31|max_plays:999" > tampered_license.txt
TAMPERED_LICENSE=$(cat tampered_license.txt)
TAMPERED_ICV=$(echo -n "${ICV_KEY}${TAMPERED_LICENSE}" | openssl dgst -sha256 | cut -d' ' -f2)

echo "Original license: $STORED_LICENSE"
echo "Tampered license: $TAMPERED_LICENSE"
echo ""
echo "Original ICV: $STORED_ICV"
echo "Tampered ICV: $TAMPERED_ICV"

if [ "$STORED_ICV" = "$TAMPERED_ICV" ]; then
    echo "✗ SECURITY BREACH: ICV check passed for tampered license"
else
    echo "✓ TAMPERING DETECTED: ICV mismatch indicates license modification"
fi

# 7. ICV vs Digital Signature comparison
echo -e "\n7. ICV vs Digital Signature comparison..."

# Create a digital signature for comparison
openssl genrsa -out temp_private.pem 1024 2>/dev/null
openssl dgst -sha256 -sign temp_private.pem -out license_digital_sig.bin license_with_icv.txt

echo "ICV approach:"
echo "  - Symmetric key operation (fast)"
echo "  - Requires shared secret (ICV key)"
echo "  - Detects tampering but not authorship"
echo "  - ICV size: 64 characters (32 bytes)"

echo -e "\nDigital signature approach:"
echo "  - Asymmetric key operation (slower)"
echo "  - Uses public/private key pair"
echo "  - Provides authentication + integrity"
echo "  - Signature size: $(wc -c < license_digital_sig.bin) bytes"

# 8. Performance simulation
echo -e "\n8. Performance comparison simulation..."

# Time ICV calculation
start_time=$(date +%s%N)
for i in {1..100}; do
    echo -n "${ICV_KEY}${LICENSE_DATA}" | openssl dgst -sha256 >/dev/null
done
end_time=$(date +%s%N)
icv_time=$(( (end_time - start_time) / 1000000 ))

# Time digital signature verification
start_time=$(date +%s%N)
for i in {1..100}; do
    openssl dgst -sha256 -verify <(openssl rsa -in temp_private.pem -pubout 2>/dev/null) -signature license_digital_sig.bin license_with_icv.txt >/dev/null 2>&1
done
end_time=$(date +%s%N)
sig_time=$(( (end_time - start_time) / 1000000 ))

echo "Performance test (100 operations):"
echo "  ICV calculation: ${icv_time}ms"
echo "  Signature verification: ${sig_time}ms"
echo "  ICV is ~$((sig_time / icv_time))x faster"

# 9. Use cases
echo -e "\n9. When to use ICV vs Digital Signatures:"
echo "Use ICV when:"
echo "  • High-frequency integrity checks needed"
echo "  • Trusted environment (ICV key is secure)"
echo "  • Only tampering detection required"
echo "  • Performance is critical"

echo -e "\nUse Digital Signatures when:"
echo "  • Need to verify authorship"
echo "  • Untrusted environment"
echo "  • Non-repudiation required"
echo "  • Security is more important than performance"

# Cleanup temporary files
rm -f temp_private.pem license_digital_sig.bin

echo -e "\n=== ICV TUTORIAL COMPLETE ==="
echo "ICV provides efficient tampering detection for licenses"
echo "when combined with secure key distribution (EKB)."
