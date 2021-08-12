const hre = require('hardhat');
const { deployed } = require('./deployed');
const { ethers } = require('hardhat');

const CONTRACT_NAME = 'SmyToken';
const SYMBOL = 'SMY';
const CONTRACT_NAME2 = 'Factory';
const CONTRACT_NAME3 = 'Exchange';

async function main() {
  let SmyToken, smyToken, Factory, factory, Exchange, exchange;

  SmyToken = await ethers.getContractFactory(CONTRACT_NAME);
  smyToken = await SmyToken.deploy(CONTRACT_NAME, SYMBOL, (10 ** 18).toString());
  await smyToken.deployed();

  Exchange = await hre.ethers.getContractFactory(CONTRACT_NAME3);
  const deployer = await Exchange.deploy(smyToken.address);
  await deployer.deployed();

  console.log('Exchange deployed to:', deployer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
