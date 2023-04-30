from pytest import fixture
from brownie import FakeToken, accounts, reverts
from scripts import deploy

TOKEN_ID = 1

@fixture(scope="module", autouse=True)
def challenge():
    challenge = deploy.local()
    # Unlock the challenge token so we can make tests
    key = FakeToken.at(challenge.keyContract())
    key.safeTransferFrom(accounts[0], challenge, challenge.keyId(), {"from": accounts[0]})
    return challenge

@fixture(autouse=True)
def isolation(fn_isolation):
    pass

def test_transfer(challenge):
    assert challenge.ownerOf(TOKEN_ID) == accounts[0]
    assert challenge.balanceOf(accounts[0]) == 1
    challenge.transferFrom(accounts[0], accounts[1], TOKEN_ID, {"from": accounts[0]})
    assert challenge.ownerOf(TOKEN_ID) == accounts[1]
    assert challenge.balanceOf(accounts[1]) == 1
    assert challenge.balanceOf(accounts[0]) == 0

def test_safe_transfer(challenge):
    assert challenge.ownerOf(TOKEN_ID) == accounts[0]
    assert challenge.balanceOf(accounts[0]) == 1
    challenge.safeTransferFrom(accounts[0], accounts[1], TOKEN_ID, {"from": accounts[0]})
    assert challenge.ownerOf(TOKEN_ID) == accounts[1]
    assert challenge.balanceOf(accounts[1]) == 1
    assert challenge.balanceOf(accounts[0]) == 0

def test_approve(challenge):
    assert challenge.getApproved(TOKEN_ID) == "0x0000000000000000000000000000000000000000"
    with reverts("ERC721: caller is not token owner or approved"):
        challenge.safeTransferFrom(accounts[0], accounts[2], TOKEN_ID, {"from": accounts[1]})
    challenge.approve(accounts[1], TOKEN_ID, {"from": accounts[0]})
    assert challenge.getApproved(TOKEN_ID) == accounts[1]
    challenge.safeTransferFrom(accounts[0], accounts[2], TOKEN_ID, {"from": accounts[1]})
    assert challenge.getApproved(TOKEN_ID) == "0x0000000000000000000000000000000000000000"
    with reverts("ERC721: caller is not token owner or approved"):
        challenge.safeTransferFrom(accounts[2], accounts[0], TOKEN_ID, {"from": accounts[1]})

def test_approval_for_all(challenge):
    with reverts("ERC721: caller is not token owner or approved"):
        challenge.safeTransferFrom(accounts[0], accounts[2], TOKEN_ID, {"from": accounts[1]})
    challenge.setApprovalForAll(accounts[1], True, {"from": accounts[0]})
    assert challenge.isApprovedForAll(accounts[0], accounts[1]) == True
    challenge.safeTransferFrom(accounts[0], accounts[2], TOKEN_ID, {"from": accounts[1]})
    assert challenge.isApprovedForAll(accounts[0], accounts[1]) == True
    with reverts("ERC721: caller is not token owner or approved"):
        challenge.safeTransferFrom(accounts[2], accounts[0], TOKEN_ID, {"from": accounts[1]})
