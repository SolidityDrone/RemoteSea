// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/proxy/Clones.sol";
import "./lzApp/NonblockingLzApp.sol";
import "./Clownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/token/ERC721/IERC721Receiver.sol";
   /*
    uint256 dstPolygonZKevm = 10158;
    uint256 dstCoreDao = 10109;
    uint256 dstGnosis = 10145;
    */
/// @title A LayerZero example sending a cross chain message from a source chain to a destination chain to increment a counter
contract MumbaiSea is NonblockingLzApp, IERC721Receiver{

    mapping(bytes => address) public s_serializedToSyntheticContract;
    mapping(address => mapping(uint256 => address)) public  s_tokenOwner; 
    address public _implementationClownable;
    uint16 public dstChainId;
    
    event Receipt(address indexed _origin, address indexed _collection, uint indexed _tokenId);
    
    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {
        _implementationClownable = address(new Clownable());
    }

    function serializeTokenContract(uint16 _originChain, address _originTokenAddress) public pure returns (bytes memory){
        bytes memory serial = abi.encode(_originChain, _originTokenAddress);
        return serial;
    }

    function _syntethizeNFT(address _originOwner, uint16 _originChain, address _originTokenAddress, uint256 _originTokenId, string memory name) public {
        bytes memory serializedTokenContract = serializeTokenContract(_originChain, _originTokenAddress);
        if (s_serializedToSyntheticContract[serializedTokenContract] == address(0)){
            address payable cloneAddress = payable(
            Clones.clone(_implementationClownable));
            Clownable(cloneAddress).init(name);
            Clownable(cloneAddress).sytntheticMint(_originTokenId);
            s_serializedToSyntheticContract[serializedTokenContract] = cloneAddress;
            s_tokenOwner[cloneAddress][_originTokenId] = _originOwner;
        } else {
            address syntheticContract = s_serializedToSyntheticContract[serializedTokenContract];
            s_tokenOwner[syntheticContract][_originTokenId] = _originOwner;
            Clownable(syntheticContract).sytntheticMint(_originTokenId);
        }
        
    }

    function _nonblockingLzReceive(
        uint16,
        bytes memory payload,
        uint64,
        bytes memory
    ) internal override {
        (address origin,,) = decode(payload);

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
        return abi.encode(_origin, _localCollection, _tokenId);
    }

    function decode(bytes memory data) public pure  returns (address, address, uint256) {
    (address _origin, address _localCollection, uint256 _tokenId) = abi.decode(data, (address, address, uint256));
    return (_origin, _localCollection, _tokenId);
}
    receive() external payable { }

     function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}
