from brownie import TokenChallenge, FakeToken, accounts

NAME = "Token Hacker Challenge"
SYMBOL = "THC"
TOKEN_URI = "ipfs://bafkreib7ezfrnygj3aglqh25vonl7wf74ovmvxi47vfdu44md7e7alp6py"

def local():
    key_id = 1
    key_contract = fake_token([key_id])
    thc = TokenChallenge.deploy(NAME, SYMBOL, TOKEN_URI, key_contract, key_id, {"from": accounts[0]})
    accounts[0].transfer(thc, "0.03 ether")
    return thc

def fake_token(ids = [1]):
    token = FakeToken.deploy({"from": accounts[0]})
    for id in ids:
        token.safeMint(accounts[0], id)
    return token
