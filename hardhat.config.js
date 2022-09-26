require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    goerli: {
      url: 'https://eth-goerli.g.alchemy.com/v2/cZNwSuFgH1Vlgqnt73U2rzdi9L41P7Qb',
      accounts: ['b8fc8d69052c1950c7db97c54544d536f63a02c5c31bd916f7d8639c9ea37f1a']
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.8.7",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }      
    ]
  },
};
