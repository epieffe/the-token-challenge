# Token Hacker Challenge
The *Token Hacker Challenge* smart contract.

- [Etherscan](https://etherscan.io/address/0x3de4789307e9bf098b6b5d704d2c476e6ad307bf)
- [OpenSea](https://opensea.io/assets/ethereum/0x3DE4789307e9BF098b6b5d704d2C476e6ad307bF/1)
- Twitter: [@ferrariep](https://twitter.com/ferrariep)

## Description
The *Token Hacker Challenge* consists of retrieving an [ERC-721](https://eips.ethereum.org/EIPS/eip-721) key token from an hacked wallet on [Ethereum](https://ethereum.org/). The hacked wallet private key is publicly available to anyone. The Token Hacker Challenge NFT is locked in its own contract and will be given to the challenge winner along with an ETH prize. The first one that withdraws the key token from the hacked wallet wins the challenge. The key token must be transfered to the Token Hacker Challenge contract using `safeTransferFrom` to unlock the Token Hacker Challenge NFT and all the Ethers in the Token Hacker Challenge contract. Beware that if you transfer assets to the hacked wallet you will probabily lose them.

#### Hacked wallet public key
[0x36eec75d68eb9440cfe61e3a00d63c6b6ea1f703](https://etherscan.io/address/0x36eec75d68eb9440cfe61e3a00d63c6b6ea1f703)

#### Hacked wallet private key
9b9a7b2159a98fc67eb0f63c56a92e1891e608716e8c04011710271a233e9863

#### Key token address
[0xcf8f4ac2f895c7241e90d8968c574aa0c805ca75](https://etherscan.io/address/0xcf8f4ac2f895c7241e90d8968c574aa0c805ca75)

#### Key token id
56

## Testing and Development
Clone this repo and `cd` into the directory to get started.

### Docker development environment
You can use [Docker](https://www.docker.com/) to test and interact with smart contracts in a local development environment without the burden of installing anything else.

```bash
# build development Docker image based on current source code
docker build -t thc .

# run tests with 'brownie test'
docker run thc test

# run interactive 'brownie console'
docker run -it thc console
```

### Dependencies
If you don't like *Docker*, you can install development dependencies manually.

* [python3](https://www.python.org/downloads/release/python-368/) - tested with version 3.10
* [brownie](https://github.com/iamdefinitelyahuman/brownie) - tested with version 1.19.3
* [ganache-cli](https://github.com/trufflesuite/ganache-cli) - tested with version 6.12.2

We describe how to install development dependencies on Ubuntu 20.04, the same steps might apply to other operating systems.

We use [pipx](https://github.com/pypa/pipx) to install *Brownie* into a virtual environment and make it available directly from the commandline. You can also install *Brownie* via *pip*, in this case it is recommended to use a [virtual environment](https://docs.python.org/3/tutorial/venv.html). For more information about installing *Brownie* read the official [documentation](https://eth-brownie.readthedocs.io/en/stable/install.html#installing-brownie).

We use [node.js](https://nodejs.org/en/) and [npm](https://www.npmjs.com/) to install *ganache-cli* globally. We recommend installing the latest LTS versions of *node* and *npm* from [nvm](https://github.com/nvm-sh/nvm#installing-and-updating) as we find versions in Ubuntu and Debian repositories to have [this](https://askubuntu.com/questions/1161494/npm-version-is-not-compatible-with-node-js-version) problem frequently.

```bash
sudo apt install curl gcc python3 python3-dev python3-venv pipx
pipx ensurepath

#install nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile

# install node and npm using nvm
nvm install --lts=Hydrogen

# install ganache-cli
npm install ganache-cli@6.12.2 --global

# install brownie
pipx install eth-brownie==1.19.3
```

### Running tests
Test scripts are stored in the `tests/` directory of this project.

Use `brownie test` to run the complete test suite.

```bash
brownie test
```
