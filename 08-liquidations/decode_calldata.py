def master_key(inputAddress: bytes) -> bytes:
    # Ensure the input is exactly 32 bytes long
    if len(inputAddress) != 32:
        raise ValueError("Input address must be exactly 32 bytes long")

    # Perform the 12-byte (96-bit) left shift
    shifted_address = inputAddress[12:] + b'\x00' * 12

    # XOR the original address with the shifted address
    xor_result = bytes(a ^ b for a, b in zip(inputAddress, shifted_address))

    return xor_result


def dynamic_key(n: int, master_key: bytes) -> bytes:
    # Ensure the data is exactly 32 bytes long (same as the master key)
    if len(master_key) != 32:
        raise ValueError("Master key must be 32 bytes long.")

    # Convert master key and data to integers for easier addition
    master_key_int = int.from_bytes(master_key, byteorder='big')
    dynamic_key_int = master_key_int

    # Generate the dynamic key for the nth iteration
    for i in range(n):
        # Add the dynamic key and the master key
        dynamic_key_int = (dynamic_key_int + master_key_int) % (1 << 256)  # Modulo to ensure 256-bit size

    # Convert the dynamic key back to bytes
    dynamic_key_bytes = dynamic_key_int.to_bytes(32, byteorder='big')

    return dynamic_key_bytes


def xor_with_dynamic_key(index: int, master_key: bytes, payload: bytes) -> bytes:
    # Ensure the payload is exactly 32 bytes long
    if len(payload) != 32:
        raise ValueError("Payload must be exactly 32 bytes long.")
    
    # Calculate the dynamic key using the provided index
    dynamic_key_value = dynamic_key(index, master_key)

    print(f"Dynamic key for index {index}: {dynamic_key_value.hex()}")  
    
    # Perform XOR between the payload and the dynamic key
    xor_result = bytes(a ^ b for a, b in zip(payload, dynamic_key_value))
    
    return xor_result


def decode_payload(payload: bytes, master_key: bytes) -> bytes:
    # Start at position 0xe4 and process every 32-byte segment (starting from index 1)
    start_pos = 0xe4
    decoded_payload = bytearray(payload)  # Use bytearray for mutable byte sequence

    # Loop through the payload every 32 bytes, starting from position 0xe4
    for i in range(0, len(payload) - start_pos, 32):
        current_pos = start_pos + i
        if current_pos + 32 > len(payload):
            break

        # Extract the 32-byte word
        word = payload[current_pos:current_pos + 32]

        # Calculate the index (starting from 1)
        index = (i // 32) + 1

        # Decode the word using the xor_with_dynamic_key function
        decoded_word = xor_with_dynamic_key(index, master_key, word)

        # Replace the word in the decoded payload
        decoded_payload[current_pos:current_pos + 32] = decoded_word

    return bytes(decoded_payload)


def extract_addresses(payload: bytes):
    # Define the start positions
    positions = {
        "borrow token": 0xe8,
        "collateral token": 0x108,
        "victim address": 0x128
    }
    
    # Loop through each position and extract the last 20 bytes of the 32-byte word
    for label, start_pos in positions.items():
        # Extract the 32-byte word from the payload
        word = payload[start_pos:start_pos + 32]
        
        # Extract the last 20 bytes of the word
        address = word[-20:]
        
        # Print the label and the extracted address in hexadecimal format
        print(f"{label}: 0x{address.hex()}")


# Example usage
# inputAddress = bytes.fromhex('00000000000000000000000088886841CfCCBf54AdBbC0B6C9cBAceAbec42b8B')
# n = 2
# data =  master_key(inputAddress)
# result = dynamic_key(n, data)
# print(result.hex())

inputAddress = bytes.fromhex('00000000000000000000000088886841CfCCBf54AdBbC0B6C9cBAceAbec42b8B')
payload = bytes.fromhex('298e3e019f997ea95b77816c82878956bf2b7ad1161a3c0c875b477848ff2cbd')
result = xor_with_dynamic_key(1,  master_key(inputAddress), payload)
print(result.hex())




payload_hex = '3743cb3f6afae9510000000000000000000000000000000000000000000000000000003400000000000000000000000000000000000000000000000000000000000000000000000000000000000000009d9b321b6398150d984de5f5be1f9bba60efaabd00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000744298e3e019f997ea95b77816c82878956bf2b7ad1161a3c0c875b477848ff2cbd0d170e866f663dfe09334222c3cb4e021ec59386307bd0495f9ab73ea25128a63a06afd23f32fd52b6ef02d9050f12ade2f9d0be89af83eeb4158f55706a7246d4a0d7f5640555f664aac38f4652d759352ae85e64aac391f0fa6095b9d4d9b73336714a21338403ed997bba786963fb59cc82c1ed997bb74539f27f8766fabd444526335166c4af3fddbb0437259f4fe8c3ede23fddbb007b6e4594c8a2cf32bbbcbdf1819a055a9221fa4df5e1daa477bb59029221fa49b1a298aa09dea3a7333455af4e32b9fa1b99c6684b61ea06f94d3bdd1b99c66d18291440b4e587e3555413f21dff794ec955871e8ca5aeb26a55d0bcc9558723e1f4c12b73a9b36edddc7b53edcc38a3771147d4cde9735ddb5e659c771147daabc06e16326ddef96664e2b5bd98f7f824cd088b0f2d38094c66fa7c24cd0891758c1b00f1320a84eeed4a978d65b74cd288c9415070fcb4bd6f8f5bd288c9483f57c7ebaff6360f7775b3995d3276a1804489f791b4c1602e78243b804489ff092374d66eba619afffe1bdb2cff35f62e004aadd2f8860b9f80b91b2e004ab5d2ef21c12d7e8d258886841cfccbf54adbbc0b64143c4ab710894dfadbbc0b6c9cbaceabec42b8b0110eec5fcc98b49f8977cc1a55800f628191e2da8977cc2366867b96ab06e43b999754809c6573f437338cd096c3d40df29a77ba37338cda3052288169cb0fc6221fbc826c323348e4ef4d86d80798b963a30c99e4ef4d90fa1dd56c288f3b51aaa826243bfef29d92ab0e3d194b5d64d4aba17992ab0e47c3e98256e75366dc333089060bcbb1f24066cef35a8f221045b436594066cefe8db52f41a6179267bbb8f5a5db987146ee228fa99bd2e6bbb6bccb38ee228fb55780dc2c64dbbdf244415da9ab65309b9bde505fdd16ab6727c560189bde506c214c8917239fe97dccc9c74b7b31eff0499a11161e5a701298cdf4f8499a1122eb183601e264150855522f6d4afeaf44f755d1cc5f9e34be09d689d7f755d1d9b4e3e2eca1284093ddda962f1acb6e99a5119282a0e1f9697adf1eb7a51192907eaf8fd75fec6c1e395f7c98ea982dee52cd5338e225be14ebe7b39752cd5347487b3cc21eb097a9eeeb67f2ba64ed43008913ef236982c05cf04877008913fe1246e9acdd74c33460dc0b4c8a31ac97ae44d4a564ad476bcdf8dd56ae44d4b4dc1296979c38eebffffc37b0298c028f3973955ba5f10c173f0172365c00956ba5de43825afd1a4a88849ff829cb2b4109bc5611e734d0c2b00a071609bc56226fa9f06d19c145d5110d083abcc3a295b77816c82878956e21129bf5b77816d939759d57d88571609995707bc964a9ea6533d77e69bc5a19921b30d56533d79003414a4297499ceb221dd9bd9931693f12ef9834ab001ec50323c5b512ef9846cd0cf72d560dc876aaa6407f68fe2893c0ab58eaec43e370742c5a94c0ab58fd96d8a41814d1f4016c132b2938cae7e86e6719a12d87a81be534ef746e6719b460a45102d3961f8cbbb711430897a73d1c22da576ecb6cc7563d84541c22da6b2a6ffded925a4b174430256bd8646691c9de9b0db00f3172c7461933c9de9b21f43baad8511e76a2ccc7e200d8434c8512e95bc3f152f61e384eae13779a5bd8be0757c30fe2a22d55504a4877fde53b25561c7a3296bac9a95742f325561c8f87d304adcea6cdb8ddd8b289038bed8fd311dd3073da7f751a5fd7d2d311dd46519eb1988d6af94366611acc179763e480cd9de6b51e44208b686cb280cd9dfd1b6a5e834c2f24ceeee9830fe76423392e895e9cf66208cbfc7101922e895eb3e5360b6e0af350597771eb0fb730e28ddc451f5337a5cd776d799671dc451f6aaf01b858c9b77be4fffa535186fda1e28a00e00978e99222de822b518a00e02178cd6543887ba76f8882bbb386704ff426dadd4b789390a6faecacd8656d97e916492b1546e6e5287f12772846abefeecc77c8c18e77547a5ad26c99b1080d1b1b1ca2fc1c12d158d4bbb06bf663dfe09334222c3cb4e025319be9f093342245d6306c03c4c82a10221bf483c6309f3540efe2e27df8a4d0a2a47ed040efe2fc9ffc18ee838c559baaa45cba6f7f4f9bb4cd3d5f207ef33d39672631afb3c577d4f21272498bf66f6b7be32e19b8f8254580fba13b9874ae2997281f3b65043286e198fa3f08ac89572245313596dd334a23250541c3f2d2f5be3d6f4a232520fd5f1faebfd8d83c443d95bb05639c87f7dee5bb8307b77e66c6d24ef7dee5d7c72acc997e9d03c7ccc5fde3d5305bdca59aa671c44b7c29d7cf672ea59aa68e90f679843d612f52554e6663a4fd1b3153566728058f40d548d7fc0e535667455ac2266efc255addddd6cee574c9da86011227de46d30580b9e090ee011227fc248dd359bae98668665f36a401c2d1daaecde8948816ca2c2ae925cdaecde8b2ee59804479adb1f3eee79ee91463592f5c89a94ac95a8ed79bf1baad5c89a969b8252d2f3871dd7e77700729a07151840a456a010a9e53830cfa4f8d0a456a2081f0da19f7360909fff86f6c00000000000000000000000000000000000000000000000000000000'

print('\n\n' + '-------------------  DYNAMIC KEYS GENERATED -------------------' + '\n\n')

decode_payload = decode_payload(bytes.fromhex(payload_hex), master_key(inputAddress))

print( '\n\n' + '-------------------  DECODED PAYLOAD -------------------' + '\n\n')

print(decode_payload.hex())

print('\n\n' + '-------------------  EXTRACTED VALUES -------------------' + '\n\n')

extract_addresses(decode_payload)

print("\n\n" + '-------------------  END -------------------' + "\n\n")






