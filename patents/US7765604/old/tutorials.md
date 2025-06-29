# DRM Cryptographic Concepts - Practical Tutorials

This tutorial demonstrates the core cryptographic concepts from the patent using OpenSSL and bash scripts. These examples illustrate the underlying principles without implementing the full DRM system.

## Prerequisites

```bash
# Check if OpenSSL is installed
openssl version

# Create a working directory
mkdir drm_crypto_tutorial
cd drm_crypto_tutorial
```

## Tutorial 1: Hierarchical Key Management

This demonstrates the tree-based key structure where each device has keys along a path from leaf to root.

```bash
#!/bin/bash
# tutorial1_hierarchical_keys.sh - Simulating hierarchical key structure

echo "=== Tutorial 1: Hierarchical Key Management ==="

# Simulate a 3-level hierarchy: Root -> Category -> Device
# In real system: KR -> K0 -> K00 -> Device keys

# 1. Generate Root Key (KR)
echo "1. Generating Root Key (KR)..."
openssl rand -hex 32 > root_key.txt
ROOT_KEY=$(cat root_key.txt)
echo "Root Key: $ROOT_KEY"

# 2. Generate Category Key (K0) 
echo -e "\n2. Generating Category Key (K0)..."
openssl rand -hex 32 > category_key.txt
CATEGORY_KEY=$(cat category_key.txt)
echo "Category Key: $CATEGORY_KEY"

# 3. Generate Device Keys (leaf keys)
echo -e "\n3. Generating Device Keys..."
for device in device1 device2 device3; do
    openssl rand -hex 32 > "${device}_key.txt"
    DEVICE_KEY=$(cat "${device}_key.txt")
    echo "Device $device Key: $DEVICE_KEY"
done

# 4. Simulate key path for device1 (device1 -> category -> root)
echo -e "\n4. Device1's key path (leaf to root):"
echo "Device1 Key: $(cat device1_key.txt)"
echo "Category Key: $(cat category_key.txt)" 
echo "Root Key: $(cat root_key.txt)"

echo -e "\nIn real system, device1 would store all these keys to access content."
```

## Tutorial 2: EKB (Enabling Key Block) Simulation

This shows how keys are encrypted and distributed to specific devices.

```bash
#!/bin/bash
# tutorial2_ekb_simulation.sh - Simulating EKB key distribution

echo "=== Tutorial 2: EKB Key Distribution ==="

# Setup: Create device keys and a new root key
echo "1. Setting up device keys..."
for i in {1..4}; do
    openssl rand -hex 32 > "device${i}_key.txt"
    echo "Device$i key: $(cat device${i}_key.txt)"
done

# Generate new root key to distribute
echo -e "\n2. Generating new Root Key to distribute..."
openssl rand -hex 32 > new_root_key.txt
NEW_ROOT_KEY=$(cat new_root_key.txt)
echo "New Root Key: $NEW_ROOT_KEY"

# Create EKB: Encrypt new root key with each device's key
echo -e "\n3. Creating EKB (Enabling Key Block)..."
mkdir -p ekb
for i in {1..4}; do
    DEVICE_KEY=$(cat "device${i}_key.txt")
    # Simulate encryption: Enc(DeviceKey, NewRootKey)
    echo "$NEW_ROOT_KEY" | openssl enc -aes-256-cbc -a -salt -pass pass:"$DEVICE_KEY" > "ekb/enc_for_device${i}.txt"
    echo "EKB entry for Device$i created"
done

# Simulate device1 decrypting its EKB entry
echo -e "\n4. Device1 decrypting EKB to get new root key..."
DEVICE1_KEY=$(cat device1_key.txt)
DECRYPTED_ROOT=$(openssl enc -aes-256-cbc -d -a -salt -pass pass:"$DEVICE1_KEY" -in ekb/enc_for_device1.txt)
echo "Device1 decrypted root key: $DECRYPTED_ROOT"

# Verify it matches
if [ "$DECRYPTED_ROOT" = "$NEW_ROOT_KEY" ]; then
    echo "✓ Success: Device1 successfully obtained new root key"
else
    echo "✗ Error: Decryption failed"
fi
```

## Tutorial 3: Device Revocation Simulation

This demonstrates how compromised devices are excluded from new key distributions.

```bash
#!/bin/bash
# tutorial3_device_revocation.sh - Simulating device revocation

echo "=== Tutorial 3: Device Revocation ==="

# Setup devices
echo "1. Initial setup - 4 devices in system..."
for i in {1..4}; do
    openssl rand -hex 32 > "device${i}_key.txt"
    echo "Device$i enrolled"
done

# Simulate device3 being compromised
echo -e "\n2. Device3 compromised! Revoking access..."
echo "Device3 is now REVOKED"

# Create new EKB excluding device3
echo -e "\n3. Creating new EKB (excluding revoked device3)..."
openssl rand -hex 32 > revoked_root_key.txt
NEW_ROOT=$(cat revoked_root_key.txt)

mkdir -p ekb_revoked
# Only create EKB entries for devices 1, 2, 4 (skip device3)
for i in 1 2 4; do
    DEVICE_KEY=$(cat "device${i}_key.txt")
    echo "$NEW_ROOT" | openssl enc -aes-256-cbc -a -salt -pass pass:"$DEVICE_KEY" > "ekb_revoked/enc_for_device${i}.txt"
    echo "EKB entry created for Device$i"
done

echo "No EKB entry created for Device3 (revoked)"

# Test: All non-revoked devices can decrypt
echo -e "\n4. Testing decryption by non-revoked devices..."
for i in 1 2 4; do
    DEVICE_KEY=$(cat "device${i}_key.txt")
    DECRYPTED=$(openssl enc -aes-256-cbc -d -a -salt -pass pass:"$DEVICE_KEY" -in "ekb_revoked/enc_for_device${i}.txt")
    if [ "$DECRYPTED" = "$NEW_ROOT" ]; then
        echo "✓ Device$i: Successfully decrypted new root key"
    else
        echo "✗ Device$i: Failed to decrypt"
    fi
done

echo -e "\n5. Device3 (revoked) cannot access new content:"
echo "Device3 has no EKB entry - cannot decrypt new root key"
```

## Tutorial 4: Multi-Layer Content Encryption

This simulates the content encryption scheme with block-level keys.

```bash
#!/bin/bash
# tutorial4_content_encryption.sh - Multi-layer content encryption

echo "=== Tutorial 4: Multi-Layer Content Encryption ==="

# Create sample content
echo "This is secret content that needs DRM protection!" > original_content.txt
echo "1. Original content: $(cat original_content.txt)"

# Layer 1: Generate content key (Kc)
echo -e "\n2. Layer 1 - Generating Content Key (Kc)..."
openssl rand -hex 32 > content_key.txt
CONTENT_KEY=$(cat content_key.txt)
echo "Content Key (Kc): $CONTENT_KEY"

# Layer 2: Encrypt content key with root key (from EKB)
echo -e "\n3. Layer 2 - Encrypting Content Key with Root Key..."
openssl rand -hex 32 > root_key_demo.txt
ROOT_KEY=$(cat root_key_demo.txt)
echo "Root Key (K): $ROOT_KEY"

# Encrypt: Enc(K, Kc)
echo "$CONTENT_KEY" | openssl enc -aes-256-cbc -a -salt -pass pass:"$ROOT_KEY" > encrypted_content_key.txt
echo "Encrypted Content Key saved to encrypted_content_key.txt"

# Layer 3: Block-level encryption with derived keys
echo -e "\n4. Layer 3 - Block-level encryption with derived keys..."

# Split content into blocks (simulate 8-byte blocks)
split -b 8 original_content.txt block_
BLOCKS=(block_*)

for i in "${!BLOCKS[@]}"; do
    BLOCK="${BLOCKS[$i]}"
    
    # Generate random seed for this block
    SEED=$(openssl rand -hex 16)
    echo "Block $((i+1)) seed: $SEED"
    
    # Derive block key: K'c = Hash(Kc, Seed)
    DERIVED_KEY=$(echo -n "${CONTENT_KEY}${SEED}" | openssl dgst -sha256 | cut -d' ' -f2)
    echo "Block $((i+1)) derived key: $DERIVED_KEY"
    
    # Encrypt block with derived key
    openssl enc -aes-256-cbc -a -salt -pass pass:"$DERIVED_KEY" -in "$BLOCK" -out "${BLOCK}_encrypted"
    
    # Store seed with encrypted block (in real system, this goes in block header)
    echo "$SEED" > "${BLOCK}_seed"
    
    echo "Block $((i+1)) encrypted"
done

echo -e "\n5. Content successfully encrypted with multi-layer scheme!"
echo "- Content key encrypted with root key"
echo "- Each block encrypted with unique derived key"
echo "- Random seeds ensure different keys per block"
```

## Tutorial 5: Content Decryption Process

This simulates the client-side decryption process.

```bash
#!/bin/bash
# tutorial5_content_decryption.sh - Simulating client decryption

echo "=== Tutorial 5: Content Decryption Process ==="

# Prerequisites: Run tutorial4 first to create encrypted content
if [ ! -f "encrypted_content_key.txt" ]; then
    echo "Error: Run tutorial4_content_encryption.sh first!"
    exit 1
fi

# Step 1: Device decrypts root key from EKB (simulated)
echo "1. Device decrypts root key from EKB..."
ROOT_KEY=$(cat root_key_demo.txt)
echo "Device obtained root key: $ROOT_KEY"

# Step 2: Decrypt content key using root key
echo -e "\n2. Decrypting content key using root key..."
DECRYPTED_CONTENT_KEY=$(openssl enc -aes-256-cbc -d -a -salt -pass pass:"$ROOT_KEY" -in encrypted_content_key.txt)
echo "Decrypted content key: $DECRYPTED_CONTENT_KEY"

# Step 3: Decrypt each content block
echo -e "\n3. Decrypting content blocks..."
ENCRYPTED_BLOCKS=(block_*_encrypted)

for ENCRYPTED_BLOCK in "${ENCRYPTED_BLOCKS[@]}"; do
    # Get block number
    BLOCK_NUM=$(echo "$ENCRYPTED_BLOCK" | sed 's/block_\([^_]*\)_encrypted/\1/')
    
    # Read seed for this block
    SEED=$(cat "block_${BLOCK_NUM}_seed")
    echo "Block $BLOCK_NUM seed: $SEED"
    
    # Derive block key: K'c = Hash(Kc, Seed)
    DERIVED_KEY=$(echo -n "${DECRYPTED_CONTENT_KEY}${SEED}" | openssl dgst -sha256 | cut -d' ' -f2)
    echo "Block $BLOCK_NUM derived key: $DERIVED_KEY"
    
    # Decrypt block
    openssl enc -aes-256-cbc -d -a -salt -pass pass:"$DERIVED_KEY" -in "$ENCRYPTED_BLOCK" -out "decrypted_${BLOCK_NUM}"
    echo "Block $BLOCK_NUM decrypted"
done

# Reassemble content
echo -e "\n4. Reassembling decrypted content..."
cat decrypted_* > final_decrypted_content.txt

echo "Original content: $(cat original_content.txt)"
echo "Decrypted content: $(cat final_decrypted_content.txt)"

# Verify
if cmp -s original_content.txt final_decrypted_content.txt; then
    echo "✓ Success: Content decrypted correctly!"
else
    echo "✗ Error: Decryption failed"
fi
```

## Tutorial 6: Digital Signatures and License Validation

This demonstrates license signing and verification.

```bash
#!/bin/bash
# tutorial6_license_validation.sh - Digital signatures for licenses

echo "=== Tutorial 6: License Validation ==="

# 1. Generate license server key pair
echo "1. Generating License Server key pair..."
openssl genrsa -out license_server_private.pem 2048
openssl rsa -in license_server_private.pem -pubout -out license_server_public.pem
echo "License server keys generated"

# 2. Create a license (JSON-like format)
echo -e "\n2. Creating license..."
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

echo "License created:"
cat license.json

# 3. Sign the license
echo -e "\n3. Signing license with server private key..."
openssl dgst -sha256 -sign license_server_private.pem -out license_signature.bin license.json
echo "License signed, signature saved to license_signature.bin"

# 4. Device verifies license signature
echo -e "\n4. Device verifying license signature..."
if openssl dgst -sha256 -verify license_server_public.pem -signature license_signature.bin license.json; then
    echo "✓ License signature valid - license is authentic"
else
    echo "✗ License signature invalid - license may be forged"
fi

# 5. Demonstrate tampering detection
echo -e "\n5. Demonstrating tampering detection..."
cp license.json tampered_license.json
sed -i 's/"max_plays": 100/"max_plays": 999/' tampered_license.json

echo "Tampered license:"
cat tampered_license.json

echo -e "\nVerifying tampered license:"
if openssl dgst -sha256 -verify license_server_public.pem -signature license_signature.bin tampered_license.json; then
    echo "✗ Unexpected: Tampered license passed verification"
else
    echo "✓ Expected: Tampered license rejected - signature verification failed"
fi
```

## Tutorial 7: ICV (Integrity Check Values)

This demonstrates tamper detection for licenses.

```bash
#!/bin/bash
# tutorial7_icv_demo.sh - Integrity Check Values

echo "=== Tutorial 7: ICV (Integrity Check Values) ==="

# 1. Generate ICV key (distributed via EKB in real system)
echo "1. Generating ICV key..."
openssl rand -hex 32 > icv_key.txt
ICV_KEY=$(cat icv_key.txt)
echo "ICV Key: $ICV_KEY"

# 2. Create license data
echo -e "\n2. Creating license data..."
LICENSE_DATA="LIC123456|CONTENT789|user@example.com|DEVICE001|2024-12-31|max_plays:100"
echo "License data: $LICENSE_DATA"

# 3. Calculate ICV: Hash(ICV_Key, License_Data)
echo -e "\n3. Calculating ICV..."
ICV=$(echo -n "${ICV_KEY}${LICENSE_DATA}" | openssl dgst -sha256 | cut -d' ' -f2)
echo "ICV: $ICV"

# 4. Store license with ICV
echo -e "\n4. Storing license with ICV..."
echo "$LICENSE_DATA" > license_with_icv.txt
echo "$ICV" > license_icv.txt
echo "License and ICV stored separately"

# 5. Verify license integrity
echo -e "\n5. Verifying license integrity..."
STORED_LICENSE=$(cat license_with_icv.txt)
STORED_ICV=$(cat license_icv.txt)

# Recalculate ICV
CALCULATED_ICV=$(echo -n "${ICV_KEY}${STORED_LICENSE}" | openssl dgst -sha256 | cut -d' ' -f2)

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

echo "Original ICV: $STORED_ICV"
echo "Tampered ICV: $TAMPERED_ICV"

if [ "$STORED_ICV" = "$TAMPERED_ICV" ]; then
    echo "✗ Unexpected: ICV check passed for tampered license"
else
    echo "✓ Expected: ICV mismatch detected tampering"
fi
```

## Tutorial 8: Complete DRM Workflow Simulation

This puts it all together in a complete workflow.

```bash
#!/bin/bash
# tutorial8_complete_workflow.sh - Complete DRM workflow

echo "=== Tutorial 8: Complete DRM Workflow ==="

# Phase 1: System Setup
echo "PHASE 1: SYSTEM SETUP"
echo "====================="

# Generate license server keys
openssl genrsa -out ls_private.pem 2048
openssl rsa -in ls_private.pem -pubout -out ls_public.pem

# Generate device key
openssl rand -hex 32 > device_key.txt
DEVICE_KEY=$(cat device_key.txt)
echo "Device enrolled with key: $DEVICE_KEY"

# Phase 2: Content Distribution
echo -e "\nPHASE 2: CONTENT DISTRIBUTION"
echo "=============================="

# Create content
echo "Secret movie content - DRM protected!" > movie.txt
echo "Content created: $(cat movie.txt)"

# Encrypt content
openssl rand -hex 32 > movie_content_key.txt
CONTENT_KEY=$(cat movie_content_key.txt)
openssl enc -aes-256-cbc -a -salt -pass pass:"$CONTENT_KEY" -in movie.txt -out movie_encrypted.txt
echo "Content encrypted with key: $CONTENT_KEY"

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
```

## Running the Tutorials

```bash
# Make all scripts executable
chmod +x tutorial*.sh

# Run tutorials in order
./tutorial1_hierarchical_keys.sh
./tutorial2_ekb_simulation.sh  
./tutorial3_device_revocation.sh
./tutorial4_content_encryption.sh
./tutorial5_content_decryption.sh
./tutorial6_license_validation.sh
./tutorial7_icv_demo.sh
./tutorial8_complete_workflow.sh

# Clean up
./cleanup.sh
```

## Cleanup Script

```bash
#!/bin/bash
# cleanup.sh - Clean up tutorial files

echo "Cleaning up tutorial files..."
rm -f *.txt *.pem *.json *.bin
rm -rf ekb ekb_revoked block_* decrypted_*
echo "Cleanup complete"
```

## Key Learning Points

1. **Hierarchical Keys**: Each device has keys along tree path for efficient revocation
2. **EKB Distribution**: Encrypted key blocks enable selective key updates
3. **Multi-layer Encryption**: Content → Block → Key encryption provides defense in depth
4. **Digital Signatures**: Licenses cryptographically signed for authenticity
5. **Integrity Checks**: ICVs detect tampering without full encryption
6. **Device Binding**: Keys tied to specific devices prevent sharing
7. **Separation of Concerns**: Content distribution separate from licensing

These tutorials demonstrate the core cryptographic principles behind modern DRM systems while being educational and hands-on.
