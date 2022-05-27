require('@nomiclabs/hardhat-waffle');
require('hardhat-deploy');
require('hardhat-deploy-ethers');
require('solidity-coverage');
require('@nomiclabs/hardhat-vyper');
require('@nomiclabs/hardhat-etherscan');
require('dotenv').config();

const ethers = require('ethers');
// Prevents the "Duplicate definition of Transfer" logs when running tests/scripts
ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.ERROR);
const mainnetAccounts = [process.env.MAINNET_PRIVATE_KEY];

task('contracts', 'Prints the contract addresses for a network').setAction(async () => {
    // eslint-disable-next-line no-undef
    const contracts = await deployments.all();
    for (const contract in contracts) {
        console.log(contract, contracts[contract].address);
    }
});

module.exports = {
    defaultNetwork: 'hardhat',
    networks: {
        hardhat: {
            chainId: 31337,
            mining: {
                auto: true,
                interval: 1000
            },
        },
        mainnet: {
            url: process.env.MAINNET_RPC_URL,
            accounts: mainnetAccounts,
            chainId: 1
        },
        localhost: {
            chainId: 31337,
            timeout: 200000000
        }
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY
    },
    namedAccounts: {
        COMP: {
            1: '0xc00e94Cb662C3520282E6f5717214004A7f26888',
            31337: '0xc00e94Cb662C3520282E6f5717214004A7f26888'
        },
        CRV: {
            1: '0xD533a949740bb3306d119CC777fa900bA034cd52',
            31337: '0xD533a949740bb3306d119CC777fa900bA034cd52'
        },
        CVX: {
            1: '0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B',
            31337: '0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B'
        },
        converter: {
            1: '0xA5c16eb6eBD72BC72c70Fca3e4faCf389AD4aBE7',
            31337: '0xA5c16eb6eBD72BC72c70Fca3e4faCf389AD4aBE7'
        },
        convex3poolVault: {
            1: '0xF403C135812408BFbE8713b5A23a04b3D48AAE31',
            31337: '0xF403C135812408BFbE8713b5A23a04b3D48AAE31'
        },
        convexBoost: {
            1: '0xF403C135812408BFbE8713b5A23a04b3D48AAE31',
            31337: '0xF403C135812408BFbE8713b5A23a04b3D48AAE31'
        },
        DAI: {
            1: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
            31337: '0x6B175474E89094C44Da98b954EedeAC495271d0F'
        },
        DAIETH: {
            1: '0x773616E4d11A78F511299002da57A0a94577F1f4',
            31337: '0x773616E4d11A78F511299002da57A0a94577F1f4'
        },
        DF: {
            1: '0x431ad2ff6a9C365805eBaD47Ee021148d6f7DBe0',
            31337: '0x431ad2ff6a9C365805eBaD47Ee021148d6f7DBe0'
        },
        dDAI: {
            1: '0x02285AcaafEB533e03A7306C55EC031297df9224',
            31337: '0x02285AcaafEB533e03A7306C55EC031297df9224'
        },
        dRewardsDAI: {
            1: '0xD2fA07cD6Cd4A5A96aa86BacfA6E50bB3aaDBA8B',
            31337: '0xD2fA07cD6Cd4A5A96aa86BacfA6E50bB3aaDBA8B'
        },
        dRewardsUSDT: {
            1: '0x324EebDAa45829c6A8eE903aFBc7B61AF48538df',
            31337: '0x324EebDAa45829c6A8eE903aFBc7B61AF48538df'
        },
        dUSDT: {
            1: '0x868277d475E0e475E38EC5CdA2d9C83B5E1D9fc8',
            31337: '0x868277d475E0e475E38EC5CdA2d9C83B5E1D9fc8'
        },
        deployer: {
            1: process.env.DEPLOYER_ADDRESS,
            31337: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        },
        developFund: {
            default: 5,
            1: '0x5118Df9210e1b97a4de0df15FBbf438499d6b446',
            31337: '0x5118Df9210e1b97a4de0df15FBbf438499d6b446'
        },
        ETHUSD: {
            1: '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419',
            31337: '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419'
        },
        gauge: {
            1: '0xbFcF63294aD7105dEa65aA58F8AE5BE2D9d0952A',
            31337: '0xbFcF63294aD7105dEa65aA58F8AE5BE2D9d0952A'
        },
        IDLE: {
            1: '0x875773784Af8135eA0ef43b5a374AaD105c5D39e',
            31337: '0x875773784Af8135eA0ef43b5a374AaD105c5D39e'
        },
        idleDAI: {
            1: '0x3fE7940616e5Bc47b0775a0dccf6237893353bB4',
            31337: '0x3fE7940616e5Bc47b0775a0dccf6237893353bB4'
        },
        idleUSDT: {
            1: '0xF34842d05A1c888Ca02769A633DF37177415C2f8',
            31337: '0xF34842d05A1c888Ca02769A633DF37177415C2f8'
        },
        idleUSDC: {
            1: '0x5274891bEC421B39D23760c04A6755eCB444797C',
            31337: '0x5274891bEC421B39D23760c04A6755eCB444797C'
        },
        insurancePool: {
            default: 4
        },
        MIM: {
            1: '0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3',
            31337: '0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3'
        },
        MIMCRV: {
            1: '0x5a6A4D54456819380173272A5E8E9B9904BdF41B',
            31337: '0x5a6A4D54456819380173272A5E8E9B9904BdF41B'
        },
        LINKCRV: {
            1: '0xcee60cFa923170e4f8204AE08B4fA6A3F5656F3a',
            31337: '0xcee60cFa923170e4f8204AE08B4fA6A3F5656F3a'
        },
        ALETHCRV: {
            1: '0xC4C319E2D4d66CcA4464C0c2B32c9Bd23ebe784e',
            31337: '0xC4C319E2D4d66CcA4464C0c2B32c9Bd23ebe784e'
        },
        PBTCCRV: {
            1: '0xDE5331AC4B3630f94853Ff322B66407e0D6331E8',
            31337: '0xDE5331AC4B3630f94853Ff322B66407e0D6331E8'
        },
        minter: {
            1: '0xd061D61a4d941c39E5453435B6345Dc261C2fcE0',
            31337: '0xd061D61a4d941c39E5453435B6345Dc261C2fcE0'
        },
        multisig: {
            1: '0xC1d40e197563dF727a4d3134E8BD1DeF4B498C6f',
            42: '0x36D68d13dD18Fe8076833Ef99245Ef33B00A7259',
            31337: '0xC1d40e197563dF727a4d3134E8BD1DeF4B498C6f'
        },
        oldController: {
            1: '0x2ebE1461D2Fc6dabF079882CFc51e5013BbA49B6',
            31337: '0x2ebE1461D2Fc6dabF079882CFc51e5013BbA49B6'
        },
        oldStrategyCrv: {
            1: '0xED93BeCebaB166AbEeAC1C5FA3b5a0cAA0d34891',
            31337: '0xED93BeCebaB166AbEeAC1C5FA3b5a0cAA0d34891'
        },
        p3crv: {
            1: '0x1BB74b5DdC1f4fC91D6f9E7906cf68bc93538e33',
            31337: '0x1BB74b5DdC1f4fC91D6f9E7906cf68bc93538e33'
        },
        pchef: {
            1: '0xbD17B1ce622d73bD438b9E658acA5996dc394b0d',
            31337: '0xbD17B1ce622d73bD438b9E658acA5996dc394b0d'
        },
        PICKLE: {
            1: '0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5',
            31337: '0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5'
        },
        pjar: {
            1: '0x1BB74b5DdC1f4fC91D6f9E7906cf68bc93538e33',
            31337: '0x1BB74b5DdC1f4fC91D6f9E7906cf68bc93538e33'
        },
        stableSwap3Pool: {
            1: '0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7',
            42: '0xE2C2a45850375c0A8B92b853fcd0a110463ed5Ab',
            31337: '0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7'
        },
        stableSwapMIMPool: {
            1: '0x5a6A4D54456819380173272A5E8E9B9904BdF41B',
            31337: '0x5a6A4D54456819380173272A5E8E9B9904BdF41B'
        },
        stableSwapLINKPool: {
            1: '0xF178C0b5Bb7e7aBF4e12A4838C7b7c5bA2C623c0',
            31337: '0xF178C0b5Bb7e7aBF4e12A4838C7b7c5bA2C623c0'
        },
        stableSwapALETHPool: {
            1: '0xC4C319E2D4d66CcA4464C0c2B32c9Bd23ebe784e',
            31337: '0xC4C319E2D4d66CcA4464C0c2B32c9Bd23ebe784e'
        },
        stableSwapBTCPool: {
            1: '0x93054188d876f558f4a66B2EF1d97d16eDf0895B',
            31337: '0x93054188d876f558f4a66B2EF1d97d16eDf0895B'
        },
        stableSwapPBTCPool: {
            1: '0x7F55DDe206dbAD629C080068923b36fe9D6bDBeF',
            31337: '0x7F55DDe206dbAD629C080068923b36fe9D6bDBeF'
        },
        stakingPool: {
            default: 2,
            1: '0xeF31Cb88048416E301Fee1eA13e7664b887BA7e8',
            42: '0x36D68d13dD18Fe8076833Ef99245Ef33B00A7259',
            31337: '0xeF31Cb88048416E301Fee1eA13e7664b887BA7e8'
        },
        STBZ: {
            1: '0xb987d48ed8f2c468d52d6405624eadba5e76d723',
            31337: '0xb987d48ed8f2c468d52d6405624eadba5e76d723'
        },
        STBZOperator: {
            1: '0xEe9156C93ebB836513968F92B4A67721f3cEa08a',
            31337: '0xEe9156C93ebB836513968F92B4A67721f3cEa08a'
        },
        SYAX: {
            1: '0xeF31Cb88048416E301Fee1eA13e7664b887BA7e8',
            31337: '0xeF31Cb88048416E301Fee1eA13e7664b887BA7e8'
        },
        T3CRV: {
            1: '0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490',
            31337: '0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490'
        },
        teamFund: {
            default: 6,
            1: '0xEcD3aD054199ced282F0608C4f0cea4eb0B139bb',
            31337: '0xEcD3aD054199ced282F0608C4f0cea4eb0B139bb'
        },
        timelock: {
            1: '0x66C5c16d13a38461648c1D097f219762D374B412',
            42: '0x36D68d13dD18Fe8076833Ef99245Ef33B00A7259',
            31337: '0x66C5c16d13a38461648c1D097f219762D374B412'
        },
        treasury: {
            1: process.env.DEPLOYER_ADDRESS,
            31337: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        },
        unirouter: {
            1: '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D',
            31337: '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'
        },
        USDC: {
            1: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
            31337: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'
        },
        USDCETH: {
            1: '0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46',
            31337: '0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46'
        },
        USDT: {
            1: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
            31337: '0xdAC17F958D2ee523a2206206994597C13D831ec7'
        },
        USDTETH: {
            1: '0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46',
            31337: '0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46'
        },
        vault3crv: {
            1: '0xBFbEC72F2450eF9Ab742e4A27441Fa06Ca79eA6a',
            31337: '0xBFbEC72F2450eF9Ab742e4A27441Fa06Ca79eA6a'
        },
        WETH: {
            1: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
            31337: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
        },
        yvDAI: {
            1: '0x19D3364A399d251E894aC732651be8B0E4e85001',
            31337: '0x19D3364A399d251E894aC732651be8B0E4e85001'
        },
        yvUSDC: {
            1: '0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9',
            31337: '0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9'
        },
        zpaUSDC: {
            1: '0x4dEaD8338cF5cb31122859b2Aec2b60416D491f0',
            poolId: 5,
        },
        zpaUSDT: {
            1: '0x6B2e59b8EbE61B5ee0EF30021b7740C63F597654',
            poolId: 6
        },
        zpaDAI: {
            1: '0xfa8c04d342FBe24d871ea77807b1b93eC42A57ea',
            poolId: 8
        },
        zpasUSD: {
            1: '0x89Cc19cece29acbD41F931F3dD61A10C1627E4c4',
            poolId: 7
        },
        flamIncomeUSDT: {
            1: '0x54bE9254ADf8D5c8867a91E44f44c27f0c88e88A'
        },
        dYdXSoloMargin: {
            1: '0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e'
        },
        RENBTCCRV: {
            1: '0x49849C98ae39Fff122806C06791Fa73784FB3675',
            31337: '0x49849C98ae39Fff122806C06791Fa73784FB3675'
        },
        sushirouter: {
            1: '0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F',
            31337: '0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F'
        },
        ALETH: {
            1: '0x0100546F2cD4C9D97f798fFC9755E47865FF7Ee6',
            31337: '0x0100546F2cD4C9D97f798fFC9755E47865FF7Ee6'
        },
        CVXETHPOOL: {
            1: '0xb576491f1e6e5e62f1d8f26062ee822b40b0e0d4',
            31337: '0xb576491f1e6e5e62f1d8f26062ee822b40b0e0d4'
        },
        CVXETHCRV: {
            1: '0x3A283D9c08E8b55966afb64C515f5143cf907611',
            31337: '0x3A283D9c08E8b55966afb64C515f5143cf907611'
        },
        TRICRYPTO2StableSwap: {
            1: '0x3993d34e7e99Abf6B6f367309975d1360222D446',
            31337: '0x3993d34e7e99Abf6B6f367309975d1360222D446'
        },
        TRICRYPTO2: {
            1: '0xc4AD29ba4B3c580e6D59105FFf484999997675Ff',
            31337: '0xc4AD29ba4B3c580e6D59105FFf484999997675Ff'
        },
        FRAXCRV: {
            1: '0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B',
            31337: '0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B'
        },
        FRAXStableSwap: {
            1: '0xa79828df1850e8a3a3064576f380d90aecdd3359',
            31337: '0xa79828df1850e8a3a3064576f380d90aecdd3359'
        },
        FRAXPOOL: {
            1: '0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B',
            31337: '0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B'
        },
        CRVETHPOOL: {
            1: '0x8301AE4fc9c624d1D396cbDAa1ed877821D7C511',
            31337: '0x8301AE4fc9c624d1D396cbDAa1ed877821D7C511'
        },
        SPELL: {
            1: '0x090185f2135308BaD17527004364eBcC2D37e5F6',
            31337: '0x090185f2135308BaD17527004364eBcC2D37e5F6'
        },
        NUME: {
            1: '0x34769D3e122C93547836AdDD3eb298035D68F1C3',
            31337: '0x34769D3e122C93547836AdDD3eb298035D68F1C3'
        },
        NUMEETHLP: {
            1: '0xF06550C34946D251C2EACE59fF4336168dB7EbF2',
            31337: '0xF06550C34946D251C2EACE59fF4336168dB7EbF2'
        }
    },
    solidity: {
        compilers: [
            {
                version: "0.8.14",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    }
                }
            }
        ],
    },
    vyper: {
        version: '0.2.8'
    },
    paths: {
        sources: './contracts',
        tests: './test'
    },
    mocha: {
        timeout: 0
    }
};
