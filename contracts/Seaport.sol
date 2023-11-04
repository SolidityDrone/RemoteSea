// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/token/ERC721/IERC721.sol";
import "./ISeaport.sol";
import "./Clownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/proxy/Clones.sol";

contract MumbaiSea {
    
    address clownableImplementation;

    constructor(){
        
    }

    address seaportOperator = 0x1E0049783F008A0085193E00003D00cd54003c71;
    address seaport = 0x00000000000000ADc04C56Bf30aC9d3c0aAF14dC;
    
    function list(address collection, uint256 _tokenId) public {
        
        SeaportInterface.OrderType orderType = SeaportInterface.OrderType.FULL_OPEN;
        SeaportInterface.ItemType offerItemType = SeaportInterface.ItemType.ERC721;
        SeaportInterface.OfferItem[] memory offerItems = new SeaportInterface.OfferItem[](1);
        offerItems[0] = SeaportInterface.OfferItem({
            itemType: offerItemType,
            token: collection,
            identifierOrCriteria: _tokenId,
            startAmount: 1,
            endAmount: 1
        });
        SeaportInterface.ItemType considerationItemType = SeaportInterface.ItemType.NATIVE;
        SeaportInterface.ConsiderationItem[] memory considerationItems = new SeaportInterface.ConsiderationItem[](2);

        // 97.5% To ourselves
        considerationItems[0] = SeaportInterface.ConsiderationItem({
            itemType: considerationItemType,
            token: address(0),
            identifierOrCriteria: 0,
            startAmount: 29250000000000000, //certain
            endAmount: 29250000000000000, //certain
            recipient: payable(address(this))
        });

        // 2.5% to OpenSea
        considerationItems[1] = SeaportInterface.ConsiderationItem({
            itemType: considerationItemType,
            token: address(0),
            identifierOrCriteria: 0,
            startAmount: 750000000000000,
            endAmount: 750000000000000,
            recipient: payable(0x0000a26b00c1F0DF003000390027140000fAa719) // fixed
        });

        SeaportInterface.OrderParameters memory orderparams = SeaportInterface.OrderParameters({
            offerer: address(this),
            zone: address(0),
            offer: offerItems,
            consideration: considerationItems,
            orderType: orderType,
            startTime: block.timestamp,
            endTime: block.timestamp + 1 weeks,
            zoneHash: 0x0000000000000000000000000000000000000000000000000000000000000000,
            salt: block.timestamp,
            conduitKey: 0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000, // fixed
            totalOriginalConsiderationItems: 2
        });

        SeaportInterface.Order[] memory realorder = new SeaportInterface.Order[](1);
        realorder[0] = SeaportInterface.Order({
            parameters: orderparams,
            signature: "0x" // null signature ok if we are the nft owners
        });
        
        SeaportInterface(seaport).validate(realorder);
    }

    receive() external payable {}
    
  
}