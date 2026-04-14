// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Chainlink VRF v2.5
import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract MooveCityNFT is ERC721, VRFConsumerBaseV2Plus {
    using Strings for uint256;

    struct NFTData {
        string city;
        string rarity;
        bool hasPrize;
        uint256 randomNumber;
        uint256 mintedAt;
    }

    uint256 private s_tokenCounter;
    uint256 private s_pendingRequests;
    uint256 public mintPrice;
    uint256 public immutable maxSupply;
    string private s_baseTokenURI;

    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    mapping(uint256 => NFTData) private s_nftDetails;
    mapping(uint256 => address) private s_requestIdToSender;
    mapping(uint256 => bool) private s_requestPending;

    event NFTRequested(uint256 indexed requestId, address indexed requester);
    event NFTMinted(
        uint256 indexed tokenId,
        address indexed owner,
        string city,
        string rarity,
        bool hasPrize
    );
    event MintPriceUpdated(uint256 newPrice);
    event BaseURIUpdated(string newBaseURI);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    constructor(
        uint256 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint256 _mintPrice,
        uint256 _maxSupply,
        string memory _baseTokenURI
    )
        ERC721("Moove City NFT", "MOOVE")
        VRFConsumerBaseV2Plus(_vrfCoordinator)
    {
        require(_vrfCoordinator != address(0), "Invalid coordinator");
        require(_maxSupply > 0, "Max supply must be > 0");

        i_subscriptionId = _subscriptionId;
        i_keyHash = _keyHash;
        i_callbackGasLimit = _callbackGasLimit;
        mintPrice = _mintPrice;
        maxSupply = _maxSupply;
        s_baseTokenURI = _baseTokenURI;
    }

    function requestMint() external payable returns (uint256 requestId) {
        require(msg.value >= mintPrice, "Not enough ETH sent");
        require(s_tokenCounter + s_pendingRequests < maxSupply, "Max supply reached");

        s_pendingRequests++;

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
                )
            })
        );

        s_requestIdToSender[requestId] = msg.sender;
        s_requestPending[requestId] = true;

        emit NFTRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        require(s_requestPending[requestId], "Request not found");

        address nftOwner = s_requestIdToSender[requestId];
        uint256 tokenId = s_tokenCounter;
        uint256 randomNumber = randomWords[0];

        string memory city = _pickCity(randomNumber);
        string memory rarity = _pickRarity(randomNumber);
        bool hasPrize = _pickPrize(randomNumber);

        s_nftDetails[tokenId] = NFTData({
            city: city,
            rarity: rarity,
            hasPrize: hasPrize,
            randomNumber: randomNumber,
            mintedAt: block.timestamp
        });

        _safeMint(nftOwner, tokenId);

        s_tokenCounter++;
        s_pendingRequests--;

        delete s_requestIdToSender[requestId];
        delete s_requestPending[requestId];

        emit NFTMinted(tokenId, nftOwner, city, rarity, hasPrize);
    }

    function _pickCity(uint256 randomNumber) internal pure returns (string memory) {
        uint256 cityIndex = randomNumber % 4;

        if (cityIndex == 0) return "Rome";
        if (cityIndex == 1) return "Milan";
        if (cityIndex == 2) return "Paris";
        return "Madrid";
    }

    function _pickRarity(uint256 randomNumber) internal pure returns (string memory) {
        uint256 rarityValue = randomNumber % 100;

        if (rarityValue < 60) return "Common";
        if (rarityValue < 85) return "Rare";
        if (rarityValue < 95) return "Epic";
        return "Legendary";
    }

    function _pickPrize(uint256 randomNumber) internal pure returns (bool) {
        return (randomNumber % 10 == 0);
    }

    function getNFTDetails(uint256 tokenId) external view returns (NFTData memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return s_nftDetails[tokenId];
    }

    function getCollectionInfo()
        external
        view
        returns (
            string memory collectionName,
            string memory collectionSymbol,
            uint256 currentSupply,
            uint256 collectionMaxSupply,
            uint256 currentMintPrice,
            uint256 pendingRequests
        )
    {
        return (
            name(),
            symbol(),
            s_tokenCounter,
            maxSupply,
            mintPrice,
            s_pendingRequests
        );
    }

    function getCurrentSupply() external view returns (uint256) {
        return s_tokenCounter;
    }

    function getPendingRequests() external view returns (uint256) {
        return s_pendingRequests;
    }

    function getSubscriptionId() external view onlyOwner returns (uint256) {
        return i_subscriptionId;
    }

    function setMintPrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
        emit MintPriceUpdated(_newPrice);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        s_baseTokenURI = _newBaseURI;
        emit BaseURIUpdated(_newBaseURI);
    }

    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds available");

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");

        emit FundsWithdrawn(msg.sender, amount);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        string memory base = _baseURI();
        return bytes(base).length > 0
            ? string(abi.encodePacked(base, tokenId.toString(), ".json"))
            : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return s_baseTokenURI;
    }
}