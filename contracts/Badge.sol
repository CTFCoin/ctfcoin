pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import "zeppelin-solidity/contracts/math/SafeMath.sol";

/** @title Badge */
contract Badge is ERC721Token {
    using SafeMath for uint256;
    using SafeMath for uint64;

    mapping (uint256 => bytes32) public tokenData;

    // Total number of tokens
    uint256 private numTokens = 0;

    // Total number of ctfs.
    uint64 private numCtfs = 0;

    // Total number of writeups
    uint64 private numWriteups = 0;

    struct Writeup {
        address team;
        string url;
        bytes23 data;
        bool approved;
    }

    struct CTF {
        bytes32 ctfName;
        string ctfUrl;
        address ctfOwner;
        uint256 ctfStartTime;
        uint256 ctfEndTime;
        uint256 rewardedTokens;
        uint256 numWriteups;
        mapping (uint256 => Writeup) writeups;
    }

    // mapping from ctf ID to a CTF struct
    mapping (uint64 => CTF) public ctf;

    // Modifiers

    /**
    * @dev Guarantees that the ctf is in progress
    * @param _ctfId uint64 ID of the ctf to validate that it is in progress
    */
    modifier requireCtfIsOn(uint64 _ctfId) {
        require(ctf[_ctfId].ctfStartTime <= block.timestamp);
        require(ctf[_ctfId].ctfEndTime > block.timestamp);
        _;
    }

    /**
    * @dev Guarantees that the ctf has not ended
    * @param _ctfId uint64 ID of the ctf to validate that it has not ended
    */
    modifier requireCtfNotOver(uint64 _ctfId) {
        require(ctf[_ctfId].ctfEndTime >= block.timestamp);
        _;
    }

    /**
    * @dev Guarantees that the ctf is complete
    * @param _ctfId uint64 ID of the ctf to validate that it is complete
    */
    modifier requireCtfIsOver(uint64 _ctfId) {
        require(ctf[_ctfId].ctfEndTime < block.timestamp);
        _;
    }

    /**
    * @dev Guarantees that msg.sender is the owner of the ctf.
    * @param _ctfId uint64 ID of the ctf to validate that ownership belongs to msg.sender
    */
    modifier requireOwnsCtf(uint64 _ctfId) {
        require(ctf[_ctfId].ctfOwner == msg.sender);
        _;
    }

    // Events

    event CtfRegistered(uint64 _ctfId);
    event WriteupEvent(uint64 _ctfId, uint256 _writeupId, string _url);

    // view functions

    /**
    * @dev Gets the data stored in the given token struct
    * @param _tokenId uint256 ID of the token to query the data of
    * @return bytes32 containing the data stored in the token specified
    */
    function getTokenData(uint256 _tokenId) public view returns (bytes32) {
        return tokenData[_tokenId];
    }

    // Writeup getters b/c you can't return a struct

    /**
    * @dev Gets the team stored in the given writeup struct
    * @param _ctfId uint64 ID of the ctf that contains the writeup to query
    * @param _writeupId uint256 ID of the writeup to query
    * @return address of the team stored in the writeup specified
    */
    function getWriteupTeam(uint64 _ctfId, uint256 _writeupId) public view returns (address team) {
        team = ctf[_ctfId].writeups[_writeupId].team;
    }

    /**
    * @dev Gets the url stored in the given writeup struct
    * @param _ctfId uint64 ID of the ctf that contains the writeup to query
    * @param _writeupId uint256 ID of the writeup to query
    * @return string the url stored in the writeup specified
    */
    function getWriteupUrl(uint64 _ctfId, uint256 _writeupId) public view returns (string url) {
        url = ctf[_ctfId].writeups[_writeupId].url;
    }

    /**
    * @dev Gets the data stored in the given writeup struct
    * @param _ctfId uint64 ID of the ctf that contains the writeup to query
    * @param _writeupId uint256 ID of the writeup to query
    * @return bytes32 the data stored in the writeup specified
    */
    function getWriteupData(uint64 _ctfId, uint256 _writeupId) public view returns (bytes23 data) {
        data = ctf[_ctfId].writeups[_writeupId].data;
    }

    /**
    * @dev Gets the approval value stored in the given writeup struct
    * @param _ctfId uint64 ID of the ctf that contains the writeup to query
    * @param _writeupId uint256 ID of the writeup to query
    * @return bool the approval value stored in the writeup specified
    */
    function getWriteupApproved(uint64 _ctfId, uint256 _writeupId) public view returns (bool approved) {
        approved = ctf[_ctfId].writeups[_writeupId].approved;
    }

    // internal functions that change state

    /**
    * @dev Internal function to create a unique token with the given data attached
    * @param _to address reciever of the created token
    * @param _data bytes32 data to be attached to the token
    * @return uint256 ID of the token created
    */
    function giveToken(address _to, bytes32 _data) private returns (uint256) {
        super._mint(_to, numTokens);

        tokenData[numTokens] = _data;

        numTokens++;
        return numTokens - 1;
    }

    // public functions that change state

    /**
    * @dev Registers a ctf
    * @param _name bytes32 name of the ctf, purely for convienence
    * @param _url string url of the ctf to be created
    * @param _startTime uint256 time of the ctf start in seconds since unix epoch
    * @param _endTime uint256 time of the ctf end in seconds since unix epoch
    * @return uint64 ID of the ctf registered
    */
    function registerCtf(bytes32 _name, string _url, uint256 _startTime, uint256 _endTime) public returns (uint64) {
        //require(_startTime > block.timestamp);
        require(_startTime > _endTime);

        ctf[numCtfs].ctfName = _name;
        ctf[numCtfs].ctfUrl = _url;
        ctf[numCtfs].ctfOwner = msg.sender;
        ctf[numCtfs].ctfStartTime = _startTime;
        ctf[numCtfs].ctfEndTime = _endTime;

        numCtfs++;
        CtfRegistered(numCtfs - 1);
        return numCtfs - 1;
    }

    /**
    * @dev Lets the ctf owner distribute reward tokens with custom data. The number of tokens is limited by the number of writeups approved
    * @param _ctfId uint64 ID of the ctf for which the reward token will be distributed
    * @param _target address address of the team to recieve the reward token
    * @param _data bytes23 data to be attached to the rewarded token
    * @return uint256 ID of the token created
    */
    function distributeRewards(uint64 _ctfId, address _target, bytes23 _data) public requireOwnsCtf(_ctfId) requireCtfIsOver(_ctfId) returns (uint256 tokenId) {
        require(ctf[_ctfId].rewardedTokens < ctf[_ctfId].numWriteups);

        bytes32[1] memory b;
        uint256 proofOfReward = 0x0000000000000000000000aa00000000;
        assembly {
            mstore(b, xor(xor(_ctfId, _data), proofOfReward))
        }

        ctf[_ctfId].rewardedTokens++;
        return giveToken(_target, b[0]);
    }

    /**
    * @dev Submit a writeup for a completed ctf
    * @param _ctfId uint64 ID of the completed ctf for which the writeup is foro
    * @param _url string url where the writeup is hosted
    * @param _data bytes23 data to be attached to the potential reward token
    * @return uint256 ID of the writeup created
    */
    function submitWriteup(uint64 _ctfId, string _url, bytes23 _data) public requireCtfIsOver(_ctfId) returns (uint256) {
        ctf[_ctfId].writeups[numWriteups].url = _url;
        ctf[_ctfId].writeups[numWriteups].approved = false;
        ctf[_ctfId].writeups[numWriteups].data = _data;
        ctf[_ctfId].writeups[numWriteups].team = msg.sender;

        numWriteups++;
        WriteupEvent(_ctfId, numWriteups - 1, _url);
        return numWriteups - 1;
    }

    /**
    * @dev Lets the ctf owner approve submitted writeups. A token is given to the address that submitted the writeup
    * @param _ctfId uint64 ID of the ctf for which the writeup belongs to
    * @param _writeupId uint256 ID of the writeup to be approved
    * @return uint256 ID of the token created
    */
    function approveWriteup(uint64 _ctfId, uint256 _writeupId) public requireOwnsCtf(_ctfId) returns (uint256) {
        require(ctf[_ctfId].writeups[_writeupId].approved == false);

        ctf[_ctfId].writeups[_writeupId].approved = true;
        ctf[_ctfId].numWriteups++;

        bytes23 data = ctf[_ctfId].writeups[_writeupId].data;
        uint256 proofOfWriteup = 0x0000000000000000000000bb00000000;

        bytes32[1] memory b;
        assembly {
            mstore(b, xor(xor(_writeupId, data), proofOfWriteup))
        }

        return giveToken(ctf[_ctfId].writeups[_writeupId].team,  b[0]);
    }

}
