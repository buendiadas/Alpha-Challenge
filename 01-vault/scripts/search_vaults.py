from web3 import Web3

rpc = 'https://thrilling-dawn-fog.quiknode.pro/d591282baebf5e63ea3aeafac74c72b284797a80/' # Replace with your own RPC endpoint, included for testing purposes
web3 = Web3(Web3.HTTPProvider(rpc))

# Replace with the ERC-4626 contract address and ABI
contract_address = '0x815C23eCA83261b6Ec689b60Cc4a58b54BC24D8D'
contract_abi = [
    # Minimal ABI needed to interact with the Deposit event
    {
        "anonymous": False,
        "inputs": [
            {"indexed": True, "name": "caller", "type": "address"},
            {"indexed": True, "name": "owner", "type": "address"},
            {"indexed": False, "name": "assets", "type": "uint256"},
            {"indexed": False, "name": "shares", "type": "uint256"}
        ],
        "name": "Deposit",
        "type": "event"
    }
]

contract = web3.eth.contract(address=contract_address, abi=contract_abi)


current_block = web3.eth.block_number
start_block = current_block - 1000    
end_block = current_block

print(f"Scanning blocks from {start_block} to {end_block} for potential attack events...")

events = contract.events.Deposit.get_logs(from_block=start_block, to_block=end_block)

def check_for_attack(events):
    for event in events:
        assets = event['args']['assets']
        shares = event['args']['shares']

        print(f"Assets: {assets}, Shares: {shares}")

        # Check if shares are 0 and assets > 0
        if shares == 0 and assets > 0:
            caller = event['args']['caller']
            owner = event['args']['owner']
            print(f"Potential attack detected! Caller: {caller}, Owner: {owner}, Assets lost: {assets} tokens")
        else:
            print("No attack detected")

if __name__ == "__main__":
    check_for_attack(events)
