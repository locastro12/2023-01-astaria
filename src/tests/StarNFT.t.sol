pragma solidity ^0.8.13;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {Strings} from "openzeppelin/utils/Strings.sol";
import {StarNFT} from "../StarNFT.sol";
import {MockERC721} from "solmate/test/utils/mocks/MockERC721.sol";
import {Strings2} from "./utils/Strings2.sol";

contract Dummy721 is MockERC721 {
    constructor() MockERC721("TEST NFT", "TEST") {
        _mint(msg.sender, 1);
        _mint(msg.sender, 2);
    }
}

contract StarNFTTest is DSTestPlus {
    using {Strings2.toHexString} for bytes;
    StarNFT wrapper;
    Dummy721 testNFT;
    bytes32 public whiteListRoot;
    bytes32[] public nftProof;


    function setUp() public {

        testNFT = new Dummy721();
        _createWhitelist(address(testNFT));
        wrapper = new StarNFT(whiteListRoot);
        testNFT.setApprovalForAll(address(wrapper), true);
    }

    function _createWhitelist(
        address newNFT
    ) internal {

        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "scripts/whitelistGenerator.js";
        inputs[2] = abi.encodePacked(newNFT).toHexString();

        bytes memory res = hevm.ffi(inputs);
        (bytes32 root, bytes32[] memory proof) = abi.decode(res, (bytes32, bytes32[]));
        whiteListRoot = root;
        nftProof = proof;
    }

    function testNFTDeposit() public {
        wrapper.depositERC721(address(this), address(testNFT), uint(1), nftProof);
        wrapper.depositERC721(address(this), address(testNFT), uint(2), nftProof);
    }
}