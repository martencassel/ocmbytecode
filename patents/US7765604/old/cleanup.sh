#!/bin/bash
# cleanup.sh - Clean up tutorial files

echo "Cleaning up tutorial files..."
rm -f *.txt *.pem *.json *.bin
rm -rf ekb ekb_revoked block_* decrypted_*
echo "Cleanup complete"
