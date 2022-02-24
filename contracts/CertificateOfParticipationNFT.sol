// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract CertificateOfParticipationNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(address => uint) public mintedItem;

    constructor() ERC721("Certificate Of Participation for TECHTALK EP:01", "TCOP") {
    }

    function generateTokenURL(string memory participentName) internal pure returns (string memory){
        string memory imageURL = 'ipfs://QmQMqz8RV4FsKD9B6BQyaPQwoE8Dpvkm9jJzAi2vtosCAR';
        string memory empty = '';
        string memory json = '';

        if (keccak256(bytes(participentName)) == keccak256(bytes(empty))) {
            json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Smart Contracts: TECHTALK EP:01", "description": "This NFT certifies that the original holder joined the Smart Contracts webinar session conducted by OrangeHRM", "image_data": "', imageURL, '"}'))));
        } else {
            require(checkForInvalidCharacters(participentName), "Contains invalid characters");
            // Not supporting special characters. Adding special characters may corrupt your NFTs meta data
            json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Smart Contracts: TECHTALK EP:01", "description": "This NFT certifies that ', participentName ,' joined the Smart Contracts webinar session conducted by OrangeHRM", "image_data": "', imageURL, '"}'))));
        }
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function checkForInvalidCharacters(string memory text) public pure returns (bool) {

        string memory invalidCharacter1 = '{';
        string memory invalidCharacter2 = '}';
        string memory invalidCharacter3 = ',';
        string memory invalidCharacter4 = ':';
        string memory invalidCharacter5 = '"';
        string memory invalidCharacter6 = "'";

        for (uint i = 0; i < bytes(text).length; i++) {
            if (
                keccak256(abi.encodePacked(bytes(text)[i])) == keccak256(abi.encodePacked(invalidCharacter1)) || 
                keccak256(abi.encodePacked(bytes(text)[i])) == keccak256(abi.encodePacked(invalidCharacter2)) || 
                keccak256(abi.encodePacked(bytes(text)[i])) == keccak256(abi.encodePacked(invalidCharacter3)) || 
                keccak256(abi.encodePacked(bytes(text)[i])) == keccak256(abi.encodePacked(invalidCharacter4)) || 
                keccak256(abi.encodePacked(bytes(text)[i])) == keccak256(abi.encodePacked(invalidCharacter5)) || 
                keccak256(abi.encodePacked(bytes(text)[i])) == keccak256(abi.encodePacked(invalidCharacter6)) 
            ) {
                return false;    
            }
        }
        return true;    
    }

    function getCertificate(string memory participentName) public {
        // prevent minting after 1646915400 unix time
        require(block.timestamp < 1646915400, 'Time to mint the NFT is over');
        // prevent minting more than one nft per address
        require(mintedItem[msg.sender] == 0, 'Cannot mint more than one NFT per address');

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, generateTokenURL(participentName));
        
        // record the address that minted the item
        mintedItem[msg.sender] = newItemId;
    }

    function getCertificateAnonymously() public {
        getCertificate('');
    }
}