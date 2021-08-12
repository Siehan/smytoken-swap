const { expect } = require('chai');

const CONTRACT_NAME = 'SmyToken';
const SYMBOL = 'SMY';

describe('SmyToken contract', () => {
  let SmyToken, smyToken, owner;

  const INITIAL_SUPPLY = ethers.utils.parseEther('100000');
  //const ADDRESS_ZERO = ethers.constants.AddressZero;

  it('Deployment should assign the total supply of tokens to the owner', async function() {
    [owner] = await ethers.getSigners();

    SmyToken = await ethers.getContractFactory(CONTRACT_NAME);
    smyToken = await SmyToken.deploy(owner.address, SYMBOL, INITIAL_SUPPLY); // à la place de owner.address, peut-être CONTRACT_NAME
    await smyToken.deployed();
  });

  describe('Deployment', () => {
    it(`Should have name ${CONTRACT_NAME} & symbol ${SYMBOL} when created`, async () => {
      expect(await smyToken.name()).to.equal(CONTRACT_NAME);
      expect(await smyToken.symbol()).to.equal(SYMBOL);
    });

    it(`Should mint initialSupply: ${INITIAL_SUPPLY.toString()} to msg.sender when created`, async () => {
      expect(await smyToken.totalSupply()).to.equal(INITIAL_SUPPLY);
      expect(await smyToken.balanceOf(owner.address)).to.equal(INITIAL_SUPPLY);
    });
  });
});
