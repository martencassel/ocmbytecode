
#!/bin/bash


# Inputs

echo -n "TestMessage1234" > message.bin


# Inputs
MESSAGE="message.bin"
KEY1="0123456789ABCDEF"
KEY2="FEDCBA9876543210"
KEY3="$KEY1$KEY2"

rm -f step1.bin last_block.bin mac.bin
# Step 1: DES-CBC encryption with zero IV (with padding)
openssl enc -des-cbc -K "$KEY1" -iv 0000000000000000 -in "$MESSAGE" -out step1.bin -provider legacy


# Step 2: Extract last 8 bytes
tail -c 8 step1.bin > last_block.bin

# Step 3: Encrypt last block with 3DES (K1-K2-K1)
openssl enc -des-ede -K "$KEY1$KEY2" -in last_block.bin -out mac.bin -provider legacy

#echo "Retail MAC (hex):"
xxd -p mac.bin

Error setting cipher DES-EDE
40D76B818B730000:error:0308010C:digital envelope routines:inner_evp_generic_fetch:unsupported:../crypto/evp/evp_fetch.c:349:Global default library context, Algorithm (DES-EDE : 72), Properties ()

