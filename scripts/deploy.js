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
    const contractFactory = await hre.ethers.getContractFactory("TeamAmericaSlayers");
    const contract = await contractFactory.deploy(
        // Character names array
        characterNames,
        // Character images array
        characterImages,
        // Character HP values
        characterHP,
        // Character Attack damage values
        characterAttackDmg,
    );

    await contract.deployed();
    console.log("Team America Slayers Game contract deployed to ", contract.address);

    /*
        Mint a few test NFTs
    */
    let txn;
    let returnedTokenUri;

    txn = await contract.mintNewCharacterNFT(1);
    await txn.wait();
    // Get the value of the new NFT
    returnedTokenUri = await contract.tokenURI(1);
    console.log("Minting #1");

    txn = await contract.mintNewCharacterNFT(2);
    await txn.wait();
    // Get the value of the new NFT
    returnedTokenUri = await contract.tokenURI(2);
    console.log("Minting #2");

    txn = await contract.mintNewCharacterNFT(3);
    await txn.wait();
    // Get the value of the new NFT
    returnedTokenUri = await contract.tokenURI(3);
    console.log("Minting #3");

    txn = await contract.mintNewCharacterNFT(4);
    await txn.wait();
    // Get the value of the new NFT
    returnedTokenUri = await contract.tokenURI(4);
    console.log("Minting #4");

    txn = await contract.mintNewCharacterNFT(5);
    await txn.wait();
    // Get the value of the new NFT
    returnedTokenUri = await contract.tokenURI(5);
    console.log("Minting #5");

    txn = await contract.mintNewCharacterNFT(6);
    await txn.wait();
    // Get the value of the new NFT
    returnedTokenUri = await contract.tokenURI(6);
    console.log("Token URI: ", returnedTokenUri);
}

const runMain = async () => {
    fetchCharacters();

    try {
        await main();
        process.exit(1);
    } catch (e) {
        console.log(e);
        process.exit(0);
    }
}

runMain();