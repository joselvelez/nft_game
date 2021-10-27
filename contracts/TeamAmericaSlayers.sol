// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

// NFT contract to inherit from
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides
import "@openzeppelin/contracts/utils/Counters.sol";

// https://docs.openzeppelin.com/contracts/4.x/api/utils#Strings
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Helper to to encode in Base64
import "./libraries/Base64.sol";

// Inherit from ERC721 standard NFT contract
contract TeamAmericaSlayers is ERC721 {

    // struct to store character attributes
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHP;
        uint attackDamage;
        uint powerFactor;
        uint daysOff;
        uint lunchHour;
    }

    // Struct to store the boss attributes
    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;

    // NFT token unique identifiers
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/fa64a1ced0b70ab89073d5d0b6e01b0778f7e7d6/contracts/utils/Counters.sol#L32
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // array to store default attributes for our characters
    CharacterAttributes[] defaultCharacters;

    // Store a mapping of each NFT to it's unique attributes struct
    mapping(uint => CharacterAttributes) public nftCharacterAttributes;

    // Store a mapping of each NFT to its current holder
    mapping(uint => address) public nftHolders;

    constructor(
        // Character data passed into the contract constructor during initialization
        string[] memory characterNames,
        string[] memory chacterImageURIs,
        uint[] memory characterHP,
        uint[] memory characterAttackDmg,

        // Boss data passed into the constructor
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
    ) 
    
    // Parent contract constructor that passes in the collection name and token symbol
    ERC721("Team America Slayers", "TAS")

    {
        console.log("The is the Team America Slayers Game!");
        
        // Initialize the boss character
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log("Boss %s initialized with %s HP. You better run!", bigBoss.name, bigBoss.hp);

        // Iterate through the characters array and save their attributes to the
        // contract.
        for (uint i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: chacterImageURIs[i],
                hp: characterHP[i],
                maxHP: characterHP[i],
                attackDamage: characterAttackDmg[i],
                // these values below will be set randomly during mint
                powerFactor: 0,
                daysOff: 0,
                lunchHour: 0
            }));

            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Initialized %s w/ %s HP", c.name, c.hp);
        }

        // Set initial tokenId to 1, since default initial is zero
        _tokenIds.increment();
    }

    // Allow users to mint a new NFT character based on one of the selected
    // default characters available
    function mintNewCharacterNFT(uint _characterIndex) external {

        // Get the current token ID and assign it to the new mint
        uint newTokenId = _tokenIds.current();

        // assign new NFT to caller's wallet address
        _safeMint(msg.sender, newTokenId);

        // Map the new NFT to its character attributes
        nftCharacterAttributes[newTokenId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHP: defaultCharacters[_characterIndex].maxHP,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            powerFactor: defaultCharacters[_characterIndex].powerFactor,
            daysOff: defaultCharacters[_characterIndex].daysOff,
            lunchHour: defaultCharacters[_characterIndex].lunchHour
        });

        console.log("Minted NFT w/ TokenId %s using %s character.", newTokenId, defaultCharacters[_characterIndex].name);

        // Save new NFT owner to mapping
        nftHolders[newTokenId] = msg.sender;

        // Increment the tokenId for next mint
        _tokenIds.increment();
    }

    // Function to dynamically set the NFT's attributes when called
    function tokenURI(uint _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftCharacterAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHP);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);
        string memory strPowerFactor = Strings.toString(charAttributes.powerFactor);
        string memory strDaysOff = Strings.toString(charAttributes.daysOff);
        string memory strLunchHour = Strings.toString(charAttributes.lunchHour);

        // Pack our NFT character's attributes into a json formatted string
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',charAttributes.name,' -- NFT #: ',Strings.toString(_tokenId),'",',
                        '"description":"Join Team America and save the world! Battle the fierce boss and get nothing for it, maybe a thumbs up...",',
                        '"image":"',charAttributes.imageURI,'",',
                        '"attributes":[{"trait_type":"Health Points", "value":',strHp,',"max_value":',strMaxHp,'},',
                        '{"trait_type":"Attack Damage","value":',strAttackDamage,'},{"trait_type": "Power Factor","value":',strPowerFactor,'},',
                        '{"trait_type":"Days Off","value":',strDaysOff,'},{"trait_type":"Lunch Hour","value":',strLunchHour,'}]}'
                    )
                )
            )
        );

        string memory payload = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return payload;
    }

    // Attack boss function
    function attackBoss(uint _tokenId) public {
        require(nftHolders[_tokenId] == msg.sender, "Only the owner of this NFT can use it.");

    }
}