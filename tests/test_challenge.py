from pytest import fixture
from scripts import deploy
from brownie import FakeToken, accounts, reverts, convert

@fixture(scope="module", autouse=True)
def challenge():
    return deploy.local()

@fixture(autouse=True)
def isolation(fn_isolation):
    pass

def test_received_with_no_data(challenge):
    key = FakeToken.at(challenge.keyContract())
    assert challenge.balance() == 30000000000000000
    operator_balance = accounts[1].balance()
    # set key token approval
    key.setApprovalForAll(accounts[1], True)
    # transfer key token to challenge contract
    key.safeTransferFrom(accounts[0], challenge, challenge.keyId(), {"from": accounts[1]})
    # winner is the transfer operator
    assert challenge.ownerOf(1) == accounts[1]
    assert accounts[1].balance() == operator_balance + 30000000000000000

def test_received_with_data(challenge):
    key = FakeToken.at(challenge.keyContract())
    winner = accounts[2]
    assert challenge.balance() == 30000000000000000
    winner_balance = winner.balance()
    # transfer key token to challenge contract
    data = convert.to_bytes(winner.address, type_str="bytes")
    key.safeTransferFrom(accounts[0], challenge, challenge.keyId(), data, {"from": accounts[0]})
    # winner is read from `data`
    assert challenge.ownerOf(1) == winner
    assert winner.balance() == winner_balance + 30000000000000000

def test_receive_eth(challenge):
    key = FakeToken.at(challenge.keyContract())
    operator_balance = accounts[0].balance()
    # transfer additional funds to challenge contract
    accounts[1].transfer(challenge, "0.1 ether")
    # check that winner receives all the contract's balance
    key.safeTransferFrom(accounts[0], challenge, challenge.keyId(), {"from": accounts[0]})
    assert accounts[0].balance() == operator_balance + 130000000000000000
    # now challenge contract must stop accepting funds
    with reverts(): accounts[1].transfer(challenge, "0.1 ether")

def test_withdraw_key_token(challenge):
    key = FakeToken.at(challenge.keyContract())
    key.safeTransferFrom(accounts[0], challenge, challenge.keyId(), {"from": accounts[0]})
    assert key.ownerOf(challenge.keyId()) == challenge
    challenge.withdrawKeyToken(accounts[1])
    assert key.ownerOf(challenge.keyId()) == accounts[1]

def test_admin_permissions(challenge):
    with reverts("Ownable: caller is not the owner"): challenge.setRoyalty(accounts[0], 2000, {"from": accounts[1]})
    with reverts("Ownable: caller is not the owner"): challenge.withdrawKeyToken(accounts[0], {"from": accounts[1]})
    challenge.transferOwnership(accounts[1], {"from": accounts[0]})
    challenge.setRoyalty(accounts[0], 2000, {"from": accounts[1]})
    assert challenge.royaltyInfo(1, 100) == (accounts[0], 20)

def test_fail_if_invalid_token_received(challenge):
    token_id = 2
    key = FakeToken.at(challenge.keyContract())
    key.safeMint(accounts[0], token_id)
    with reverts("received invalid token"): key.safeTransferFrom(accounts[0], challenge, token_id, {"from": accounts[0]})

def test_supports_interface(challenge):
    assert not challenge.supportsInterface("0x0000dEaD")
    assert challenge.supportsInterface("0x80ac58cd") # ERC-721
    assert challenge.supportsInterface("0x5b5e139f") # ERC-721 Metadata
    assert challenge.supportsInterface("0x2a55205a") # ERC-721 Royalty

def test_royalty(challenge):
    assert challenge.royaltyInfo(1, 100) == (accounts[0], 10)
    challenge.setRoyalty(accounts[2], 2500)
    assert challenge.royaltyInfo(1, 100) == (accounts[2], 25)
