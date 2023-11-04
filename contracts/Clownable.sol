// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/token/ERC721/IERC721.sol";
import "./ISeaport.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/token/ERC721/ERC721.sol";


contract Clownable is ERC721{
    
    address seaportOperator = 0x1E0049783F008A0085193E00003D00cd54003c71;
    uint256 counter;
    bool initialized;
    constructor()ERC721("","OPNSYN"){
        
    }

    function init(string memory name_) public {
        require(!initialized, "Already initialized");
        _name = name_;
        initialized = true;
    }
    
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        if (operator == seaportOperator){
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }  

    function sytntheticMint(uint256 synthTokenId) public {
        ++counter;
        _safeMint(msg.sender, synthTokenId);
    }
    
    function totalSupply() external view returns (uint){
        return counter;
    }
}