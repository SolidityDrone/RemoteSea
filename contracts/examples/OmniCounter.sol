// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../lzApp/NonblockingLzApp.sol";

/// @title A LayerZero example sending a cross chain message from a source chain to a destination chain to increment a counter
contract OmniCounter is NonblockingLzApp {
    uint16 public dstChainId;
    address public og;  
    event Receipt(address indexed _origin, address indexed _collection, uint indexed _tokenId);
    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {
        if (_lzEndpoint == 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8) dstChainId = 10153;
        if (_lzEndpoint == 0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1) dstChainId = 10109;
    }
    function _nonblockingLzReceive(
        uint16,
        bytes memory payload,
        uint64,
        bytes memory
    ) internal override {
        (address origin,,) = decode(payload);
        og = origin;
    }
    
    function estimateFee(
        uint16 _dstChainId,
        bool _useZro,
        bytes calldata _payload,
        bytes calldata _adapterParams
    ) public view returns (uint nativeFee, uint zroFee) {
        return lzEndpoint.estimateFees(_dstChainId, address(this), _payload, _useZro, _adapterParams);
    }

    function sendDst(address _origin, address _localCollection, uint256 _tokenId) public payable {
        bytes memory payload = encode(_origin, _localCollection, _tokenId);
        _lzSend(dstChainId, payload, payable(msg.sender), address(this), bytes(""), msg.value);
    }
 
    function setTrustedRemoteAddress(address _otherContract) public onlyOwner {
        trustedRemoteLookup[dstChainId] = abi.encodePacked(_otherContract, address(this));   
    }

    function encode(address _origin, address _localCollection, uint256 _tokenId) public pure returns (bytes memory){
        return abi.encodePacked(_origin, _localCollection, _tokenId);
    }

    function decode(bytes memory data) public pure  returns (address, address, uint256) {
    (address _origin, address _localCollection, uint256 _tokenId) = abi.decode(data, (address, address, uint256));
    return (_origin, _localCollection, _tokenId);
}
    receive() external payable { }
}
