require('@nomiclabs/hardhat-waffle');
const { expect } = require('chai');

const CONTRACT_NAME = 'SmyToken';
const SYMBOL = 'SMY';
const CONTRACT_NAME2 = 'Factory';
const CONTRACT_NAME3 = 'Exchange';

const toWei = (value) => ethers.utils.parseEther(value.toString());

describe('Factory contract', () => {
  let owner, SmyToken, smyToken, Factory, factory, Exchange, exchange;
  beforeEach(async () => {
    [owner] = await ethers.getSigners();

    SmyToken = await ethers.getContractFactory(CONTRACT_NAME);
    smyToken = await SmyToken.deploy(CONTRACT_NAME, SYMBOL, toWei(1000000));
    await smyToken.deployed();

    Factory = await ethers.getContractFactory(CONTRACT_NAME2);
    factory = await Factory.deploy();
    await factory.deployed();
  });

  it('is deployed', async () => {
    expect(await factory.deployed()).to.equal(factory);
  });

  describe('createExchange', () => {
    it('deploys an exchange', async () => {
      const exchangeAddress = await factory.callStatic.createExchange(smyToken.address);
      await factory.createExchange(smyToken.address);

      expect(await factory.tokenToExchange(smyToken.address)).to.equal(exchangeAddress);

      Exchange = await ethers.getContractFactory(CONTRACT_NAME3);
      exchange = await Exchange.attach(exchangeAddress);
      expect(await exchange.name()).to.equal('Syeswap');
      expect(await exchange.symbol()).to.equal('SYE');
      expect(await exchange.factoryAddress()).to.equal(factory.address);
    });

    it("doesn't allow zero address", async () => {
      await expect(factory.createExchange('0x0000000000000000000000000000000000000000')).to.be.revertedWith(
        'invalid token address'
      );
    });

    it('fails when exchange exists', async () => {
      await factory.createExchange(smyToken.address);

      await expect(factory.createExchange(smyToken.address)).to.be.revertedWith('exchange already exists');
    });
  });

  describe('getExchange', () => {
    it('returns exchange address by token address', async () => {
      const exchangeAddress = await factory.callStatic.createExchange(smyToken.address);
      await factory.createExchange(smyToken.address);

      expect(await factory.getExchange(smyToken.address)).to.equal(exchangeAddress);
    });
  });
});
