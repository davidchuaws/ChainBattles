// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => Character) public tokenIdToCharacter;
    string[] private classes = ["Warrior", "Wizard", "Ranger", "Warlock", "Cleric"];
    string[] private classSvgs = [
        '<path fill="#000" d="M491.844 22.533l-83.42 14.865L196.572 249.25c3.262 4.815 5.37 10.72 5.37 16.932 0 5.863-1.71 11.35-4.643 15.996-5.065-1.606-10.448-2.477-16.027-2.477-15.724 0-29.904 6.89-39.69 17.796l-9.112-9.113 17.237-17.237c-4.515-5.772-8.907-11.645-13.19-17.6l-19.443 19.44-13.215-13.215 21.828-21.827c-4.403-6.59-8.67-13.278-12.792-20.068l-40.802 40.803 58.314 58.314c-1.613 5.075-2.49 10.47-2.49 16.063 0 7.666 1.65 14.96 4.592 21.564l-72.14 72.14-14.56-14.56L21.013 437l14.558 14.56-8.607 8.608 27.246 27.246 8.606-8.61 14.56 14.56 24.798-24.8-14.557-14.556 72.158-72.16c6.586 2.922 13.858 4.562 21.498 4.562 5.593 0 10.988-.877 16.063-2.49l58.363 58.363L296.5 401.48c-6.797-4.127-13.486-8.395-20.068-12.793l-21.83 21.83L241.39 397.3l19.442-19.44c-5.962-4.29-11.835-8.683-17.603-13.194l-17.238 17.238-9.16-9.16c10.905-9.785 17.795-23.965 17.795-39.69 0-5.346-.806-10.51-2.285-15.39 4.703-3.04 10.288-4.817 16.265-4.816 6.21 0 11.776 1.77 16.52 4.955L476.98 105.95l14.864-83.417zm-66.227 53.012l13.215 13.215-191.684 191.68-13.214-13.213L425.617 75.545zM181.273 298.39c19.257 0 34.665 15.41 34.665 34.665 0 19.256-15.408 34.666-34.665 34.666-19.256 0-34.666-15.41-34.666-34.665s15.41-34.666 34.666-34.666z"/>'
        '<path fill="#000" d="M416.125 42.406c-57.576.457-104.863 25.804-144.813 64.875-41.984 41.063-75 97.61-100 155.5.78 4.503 3.06 8.946 7.094 13.658 5.158 6.024 13.183 12.113 23.188 17.593 20.01 10.962 47.79 19.545 75.5 24.47 27.71 4.925 55.505 6.21 75.156 3.438 9.825-1.386 17.538-3.91 21.813-6.563 4.274-2.653 4.916-3.957 4.812-6.625l.72-.03c-3.408-42.828-6-88.797.092-131.94 2.82-19.972 7.668-39.434 15.22-57.624-31.573 31.44-62.918 65.425-86.844 94.72 35.418-70.2 86.2-121.398 141.125-168.97-11.376-1.71-22.42-2.584-33.063-2.5zM155.21 238.994c-2.033-.012-4.053-.012-6.054.006-2.453.022-4.87.065-7.28.125-23.138.575-44.227 2.91-61.876 7.188-23.532 5.703-40.466 14.888-48.78 26.03-8.317 11.144-10.08 24.667-.97 45.532 32.86 75.263 117.185 130.26 207.844 148.594 90.66 18.33 186.108.147 242.28-66.75 13.59-16.185 15.297-29.312 9.938-43.22-5.358-13.908-19.586-28.878-40.78-42.75-14.745-9.65-32.683-18.737-52.75-27.03 1.506 22.59 3.555 44.877 5.124 65.967v.219c.607 11.402-5.49 21.585-14.344 27.938-8.853 6.353-20.268 10.08-33.437 12.406-26.337 4.654-60.026 3.398-93.344-2.188-33.317-5.585-66.085-15.466-90.28-29.312-12.097-6.923-22.145-14.85-28.875-24.47-6.73-9.617-9.76-21.554-6.594-33.374l.095-.375.125-.374c7.637-21.206 16.308-42.79 26.094-64.094-2.053-.032-4.1-.056-6.133-.068zm6.634 46.662c-3.08 7.8-6.017 15.596-8.813 23.344-1.595 6.246-.4 11.407 3.907 17.563 4.374 6.25 12.28 12.923 22.844 18.968 21.128 12.09 52.4 21.78 84.095 27.095 31.694 5.314 64.016 6.28 87 2.22 11.492-2.032 20.53-5.42 25.78-9.19 5.25-3.766 6.864-6.726 6.595-11.78-.517-6.93-1.088-14.027-1.688-21.25-7.448 4.03-16.47 6.367-26.718 7.813-22.732 3.206-51.79 1.665-81.03-3.532-29.242-5.196-58.5-14.055-81.22-26.5-11.36-6.222-21.122-13.34-28.375-21.812-.825-.962-1.62-1.933-2.376-2.938z"/>',
        '<path fill="#000" d="M77.85 11.848l9.535 70.648-69.418-11.174 41.508 56.07-11.127 322.715c-11.712 13.235-20.716 28.85-25.823 47.914 74.198-55.834 152.88-71.602 223.606-101.383l-35.913-35.914c-53.122 25.232-105.774 42.49-142.547 71.347l9.674-280.54 8.06 10.888 2.2 4.47h71.304L358.723 394.03c15.618-13.627 29.605-28.41 42.66-44.645l-229.877-193.78V84.226l-11.86-9.165 273.594-10.66c-29.99 36.36-46.84 89.07-71.39 142.416l36.558 36.56c29.22-70.24 45.014-148.09 100.262-221.507-18.54 4.97-33.69 13.015-46.604 23.603l-.02-.506-315.437 12.29-58.76-45.41zm24.613 42.638l50.355 38.916v54.795H99.236l-.607-.146-38.357-50.988 49 7.89-6.81-50.466zm248.103 167.48c-8.162 13.275-17.044 25.835-26.586 37.727l30.727 25.903c11.16-8.75 22.568-17.176 34.06-25.432l-38.2-38.2zm100.006 89.74C414.826 368.52 375.184 412.43 315.88 447.67c59.143 20.683 118.488 37.302 178.8 43.98-8.706-60.66-23.977-120.562-44.108-179.94zm-184.08 5.774c-13.42 10.98-27.58 21.186-42.414 30.674l37.47 37.47c8.748-14.57 18.62-27.954 29.327-40.43l-24.383-27.714z"/>',
        '<path fill="#000" d="M187.406 22.22l-41.562 41.843 62.875 29.843-8 16.875-68.845-32.655L59.97 150.53l33.31 96.97 56.876-7.156 10.53-42.47 18.126 4.47-45.843 185.25 55.31-49.656 10-9 4.94 12.5 14.81 37.53 31.25-41.624 8.126-10.844 7.25 11.47 30.406 48.217 22.657-46.75 5.092-10.5 9.125 7.25 62.532 49.782-62.814-182.22 17.656-6.094 12.782 37.063 60.562-.94 26.47-101.874-72.72-62.344-70.125 38.844-9.06-16.375 64.03-35.468-29.75-25.53-144.094-8.813zm190.688 85.5l13.28 67.218-107.28-16.25 94-50.97zm-246.188.936L229.97 160l-116.25 13.47 18.186-64.814zm123.188 122.5l55.844 64.75-36.25 12.875-17.407-42.655-15.374 43.344-35.344-13.564 48.532-64.75zm74.344 126.938L304.53 409.47l-7.342 15.155-8.97-14.25-32.124-50.97-33.156 44.19-10.063 13.342-6.125-15.53-15.97-40.594-30.436 27.312 25.53 66.406 61.407 35.22 98.814-39.563 16.937-65.343-33.592-26.75z"/>',
        '<path fill="#000" d="M79.625 22.03c-16.694.274-31.01 5.33-41.22 15.658C5.743 70.735 27.53 145.313 87.22 204.313c39.992 39.53 91.568 45.025 125.03 56.593-38.19 35.214-80.874 67.594-130.438 99.28l61.594 60.876c33.267-53.395 68.052-99.412 106.406-140.593 66.466 44.55 113.05 126.476 157.594 206.967l85.5-86.5c-82.206-44.252-164.58-88.96-209.25-154.687 41.214-39.214 86.72-74.14 138.656-107.344L360.72 78.03c-30.47 48.903-61.926 91.685-96.845 130.564-11.704-33.438-18.262-84.475-58.28-124.032C164.556 44 116.35 21.43 79.624 22.032zm16.97 47.064c20.94.415 50.89 16.01 77.436 42.25 36.934 36.505 53.305 79.782 36.595 96.687-16.71 16.907-60.194 1.037-97.125-35.468C76.57 136.06 60.165 92.75 76.875 75.844c4.7-4.755 11.525-6.913 19.72-6.75z"/>'
    ];

    struct Character {
        uint256 level;
        uint256 strength;
        uint256 speed;
        uint256 life;
    }

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 tokenId) public view returns(string memory){
        uint256 class = random(5);
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 512 512">',
            '<style>.baseStat { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<style>.baseClass { fill: white; font-family: serif; font-size: 18px; font-weight: bold; }</style>',
            '<rect x="0" y="0" width="20%" height="20%" fill="black" />',
            getClassSvg(class),
            '<text x="8%" y="5%" class="baseClass" >',class,'</text>',
            '<text x="8%" y="10%" class="baseStat" >', "Levels: ",getLevels(tokenId),'</text>',
            '<text x="8%" y="15%" class="baseStat" >', "Strength: ",getStrength(tokenId),'</text>',
            '<text x="8%" y="20%" class="baseStat" >', "Speed: ",getSpeed(tokenId),'</text>',
            '<text x="8%" y="25%" class="baseStat" >', "Life: ",getLife(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getClassSvg(uint256 class) public view returns (string memory) {
        return classSvgs[class];
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        Character memory character = tokenIdToCharacter[tokenId];
        return character.level.toString();
    }

    function getStrength(uint256 tokenId) public view returns (string memory) {
        Character memory character = tokenIdToCharacter[tokenId];
        return character.strength.toString();
    }

    function getSpeed(uint256 tokenId) public view returns (string memory) {
        Character memory character = tokenIdToCharacter[tokenId];
        return character.speed.toString();
    }

    function getLife(uint256 tokenId) public view returns (string memory) {
        Character memory character = tokenIdToCharacter[tokenId];
        return character.life.toString();
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint() public {
        _tokenIds.increment(); // default starts at 0
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToCharacter[newItemId] = (Character(1, random(3), random(3), random(3))); // level 1 character with base stats.
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing Token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it!");
        Character memory character = tokenIdToCharacter[tokenId];
        levelUp(character);
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function levelUp(Character memory character) internal view{
        character.level += 1;
        character.life += random(10);
        character.speed += random(10);
        character.strength += random(10);
    }

    function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, msg.sender))) % number;
    }
}