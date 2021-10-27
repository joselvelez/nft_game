const characters = require('./characters.js');

const characterNames = [];
const characterImages = [];
const characterHP = [];
const characterAttackDmg = [];

const fetchCharacters = () => {
    for (i = 0; i < characters.length; i++) {
        characterNames.push(characters[i].name);
    }
    
    for (i = 0; i < characters.length; i++) {
        characterImages.push(characters[i].imageURI);
    }
    
    for (i = 0; i < characters.length; i++) {
        characterHP.push(characters[i].hp);
    }
    
    for (i = 0; i < characters.length; i++) {
        characterAttackDmg.push(characters[i].attackDamage);
    }
};

const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('TeamAmericaSlayers');
    const gameContract = await gameContractFactory.deploy(
        // Character names array
        characterNames,
        // Character images array
        characterImages,
        // Character HP values
        characterHP,
        // Character Attack damage values
        characterAttackDmg,
        // Boss attributes
        "Kim Jong-il",
        "https://static.wikia.nocookie.net/teamamerica/images/c/c5/Kim-jong-il.png/revision/latest/scale-to-width-down/616?cb=20141102004837",
        10000,
        50
    );
    
    await gameContract.deployed();
    console.log("Team America Slayers Game contract deployed to ", gameContract.address)

    // Mint a few test NFTs
    let txn;
    txn = await gameContract.mintNewCharacterNFT(2);
    await txn.wait();

    // Get the value of the new NFT
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI: ", returnedTokenUri);
}

const runMain = async () => {
    fetchCharacters();
    try {
        await main();
        process.exit(0);
    } catch (e) {
        console.log(e);
        process.exit(1);
    }
};

runMain();