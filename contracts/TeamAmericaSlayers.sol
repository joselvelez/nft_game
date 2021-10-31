// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

// NFT contract to inherit from
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// https://docs.openzeppelin.com/contracts/4.x/api/utils#Strings
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Helper to to encode in Base64
import "./libraries/Base64.sol";

// Inherit from ERC721 standard NFT contract
contract TeamAmericaSlayers is ERC721 {
    
    using SafeMath for uint256;
    // Events
    event CharacterMinted(address minter, uint tokenId, uint characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);

    // struct to store character attributes
    struct Character {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
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
    Character[] defaultCharacters;

    // array of minted characters
    Character[] mintedCharacters;

    // array of minted character ids
    uint[] mintedCharacterIds;

    // Store a mapping of each NFT to it's unique attributes struct
    mapping(uint => Character) public nftCharacterAttributes;

    // Store a mapping of each NFT to its current owner
    mapping(uint => address) public assetToOwner;

    // Store mapping of how many characters an owner has
    mapping(address => uint) ownerAssetCount;

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
            defaultCharacters.push(Character({
                characterIndex: i,
                name: characterNames[i],
                imageURI: chacterImageURIs[i],
                hp: characterHP[i],
                maxHp: characterHP[i],
                attackDamage: characterAttackDmg[i]
            }));

            Character memory c = defaultCharacters[i];
            console.log("Initialized %s w/ %s HP", c.name, c.hp);
        }

        // Set initial tokenId to 1, since default initial is zero
        _tokenIds.increment();
    }

    // Allow users to mint a new NFT character based on one of the selected
    // default characters available
    function mintNewCharacterNFT(uint _characterIndex) external {
        require(checkIfDefaultMinted(_characterIndex) == false, "You have already minted this character.");

        // Get the current token ID and assign it to the new mint
        uint newTokenId = _tokenIds.current();

        // assign new NFT to caller's wallet address
        _safeMint(msg.sender, newTokenId);

        // Map the new NFT to its character attributes
        nftCharacterAttributes[newTokenId] = Character({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT w/ TokenId %s using %s character.", newTokenId, defaultCharacters[_characterIndex].name);

        // Save new NFT owner to mapping
        assetToOwner[newTokenId] = msg.sender;

        // Increment owner's asset count
        ownerAssetCount[msg.sender] = ownerAssetCount[msg.sender].add(1);

        // Add new NFT to mintedCharacters array
        mintedCharacters.push(nftCharacterAttributes[newTokenId]);

        // Add new NFT id to mintedCharacterIds array
        mintedCharacterIds.push(newTokenId);

        // Increment the tokenId for next mint
        _tokenIds.increment();

        emit CharacterMinted(msg.sender, newTokenId, _characterIndex);
    }

    // Function to dynamically set the NFT's attributes when called
    function tokenURI(uint _tokenId) public view override returns (string memory) {
        Character memory charAttributes = nftCharacterAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

        // Pack our NFT character's attributes into a json formatted string
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',charAttributes.name,' -- NFT #: ',Strings.toString(_tokenId),'",',
                        '"description":"Join Team America and save the world! Battle the fierce boss and get nothing for it, maybe a thumbs up...",',
                        '"image":"',charAttributes.imageURI,'",',
                        '"attributes":[{"trait_type":"Health Points", "value":',strHp,',"max_value":',strMaxHp,'},',
                        '{"trait_type":"Attack Damage","value":',strAttackDamage,'}]}'
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
        require(assetToOwner[_tokenId] == msg.sender, "Only the owner of this NFT can use it.");

        Character storage nftCharacterPlayed = nftCharacterAttributes[_tokenId];

        console.log("\nPlayer w/ character %s is about to attack with %s HP and %s AD. \nGrab some popcorn!",
            nftCharacterPlayed.name, nftCharacterPlayed.hp, nftCharacterPlayed.attackDamage);
        console.log("The Boss %s has %s HP and %s AD...", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

        require(nftCharacterPlayed.hp > 0, "Error: character has no HP. R.I.P.");
        require(bigBoss.hp > 0, "Error: Looks like the big boss is out for good. Hang your hat and hit the beach!");

        // allow player to attack the boss
        if (bigBoss.hp < nftCharacterPlayed.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - nftCharacterPlayed.attackDamage;
        }

        // allow boss to attack player
        if (nftCharacterPlayed.hp < bigBoss.attackDamage) {
            nftCharacterPlayed.hp = 0;
        } else {
            nftCharacterPlayed.hp = nftCharacterPlayed.hp - bigBoss.attackDamage;
        }

        if (nftCharacterPlayed.hp == 0) {
            console.log("OOF! %s just got REKT by %s. GGs.", nftCharacterPlayed.name, bigBoss.name);
        } else if (bigBoss.hp == 0) {
            console.log("NOICE!!! %s just defeated %s. The world is safe again... or is it?", nftCharacterPlayed.name, bigBoss.name);
        } else if (bigBoss.hp == 0 && nftCharacterPlayed.hp == 0) {
            console.log("Whoao... both of these fools just floored each other. Game over for %s and %s", bigBoss.name, nftCharacterPlayed.name);
        } else {
            console.log("Battle results are in... Boss HP is %s and %s HP is %s. \nThat was a nailbiter! Nah, not really...", 
                bigBoss.hp, nftCharacterPlayed.name, nftCharacterPlayed.hp);
        }

        emit AttackComplete(bigBoss.hp, nftCharacterPlayed.hp);
    }

    // Character Selection
    function getAllDefaultCharacters() public view returns (Character[] memory) {
        return defaultCharacters;
    }

    // Get the Boss Data
    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    // Get list of characters a wallet owns
    function getListOfOwnedCharacters(address _owner) external view returns (uint[] memory) {
        // setup a var to store the results of our search. Since we cannot have dynamic arrays
        // in memory, we will create a new fixed array of size length that corresponds to the
        // owner's number of owned characters.
        // Docs: https://docs.soliditylang.org/en/v0.8.9/types.html?highlight=array#allocating-memory-arrays
        uint[] memory _results = new uint[](ownerAssetCount[_owner]);
        uint counter = 0;
        for (uint i = 1; i <= mintedCharacters.length; i++) {
            if (assetToOwner[i] == _owner) {
                // Since we can't push into a dynamic array, instead we set the values for each
                // result, with the index based on the iterator.
                _results[counter] = i;
                counter ++;
            }
        }
        return _results;
    }

    // Get character by id
    function getCharacter(uint _id) public view returns (Character memory) {
        return nftCharacterAttributes[_id];
    }

    // Before minting, check if user has already minted the selected default character
    function checkIfDefaultMinted(uint _characterIndex) private view returns (bool) {
        bool result = false;

        if (mintedCharacterIds.length == 0) {
            return false;
        } else {
            for (uint i = 0; i < mintedCharacterIds.length; i++) {
                uint currentMintedCharacterId = mintedCharacterIds[i];
                Character memory currentMintedCharacter = nftCharacterAttributes[currentMintedCharacterId];
                uint currentCharacterIndex = currentMintedCharacter.characterIndex;
                address currentCharacterOwner = assetToOwner[currentMintedCharacterId];

                if (currentCharacterOwner == msg.sender && currentCharacterIndex == _characterIndex) {
                    result = true;
                    break;
                } else {
                    result = false;
                }
            }
            return result;
        }
    }
}