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
        // Boss attributes
        "Kim Jong-il",
        "https://static.wikia.nocookie.net/teamamerica/images/c/c5/Kim-jong-il.png",
        10000,
        50
    );

    await contract.deployed();
    console.log("Team America Slayers Game contract deployed to ", contract.address);
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