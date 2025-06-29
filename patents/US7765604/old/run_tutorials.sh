#!/bin/bash
# run_tutorials.sh - Run all DRM crypto tutorials

echo "DRM Cryptographic Concepts - Interactive Tutorial Suite"
echo "======================================================="
echo ""
echo "This tutorial demonstrates the cryptographic concepts from US Patent 7765604"
echo "using practical OpenSSL and bash examples."
echo ""

# Check if OpenSSL is available
if ! command -v openssl &> /dev/null; then
    echo "Error: OpenSSL is required but not installed."
    echo "Please install OpenSSL and try again."
    exit 1
fi

echo "OpenSSL version: $(openssl version)"
echo ""

# Create working directory
mkdir -p drm_demo
cd drm_demo

echo "Working directory: $(pwd)"
echo ""

# Function to run tutorial with pause
run_tutorial() {
    local script=$1
    local description=$2
    
    echo "=========================================="
    echo "Running: $description"
    echo "=========================================="
    
    if [ -f "../$script" ]; then
        bash "../$script"
        echo ""
        echo "Press Enter to continue to next tutorial..."
        read
    else
        echo "Error: Script $script not found"
    fi
}

# Run tutorials in sequence
run_tutorial "tutorial1_hierarchical_keys.sh" "Tutorial 1: Hierarchical Key Management"
run_tutorial "tutorial2_ekb_simulation.sh" "Tutorial 2: EKB (Encrypted Key Block) Simulation"
run_tutorial "tutorial3_device_revocation.sh" "Tutorial 3: Device Revocation"
run_tutorial "tutorial4_content_encryption.sh" "Tutorial 4: Multi-layer Content Encryption"
run_tutorial "tutorial5_content_decryption.sh" "Tutorial 5: Content Decryption Process"
run_tutorial "tutorial6_license_validation.sh" "Tutorial 6: License Validation with Digital Signatures"
run_tutorial "tutorial7_icv_demo.sh" "Tutorial 7: ICV (Integrity Check Values)"
run_tutorial "tutorial8_complete_workflow.sh" "Tutorial 8: Complete DRM Workflow"

echo ""
echo "=========================================="
echo "All tutorials completed!"
echo "=========================================="
echo ""
echo "Summary of concepts demonstrated:"
echo "1. Hierarchical key trees for efficient device management"
echo "2. EKB (Encrypted Key Blocks) for secure key distribution"
echo "3. Device revocation through key tree updates"
echo "4. Multi-layer content encryption with unique block keys"
echo "5. Client-side decryption process"
echo "6. Digital signatures for license authentication"
echo "7. ICV for efficient license integrity checking"
echo "8. Complete end-to-end DRM workflow"
echo ""
echo "These tutorials demonstrate the core cryptographic principles"
echo "behind the DRM system described in US Patent 7765604."
echo "Tutorial suite completed!"
echo "Files created during tutorials:"
ls -la

echo ""
echo "To clean up generated files, run:"
echo "bash ../cleanup.sh"
