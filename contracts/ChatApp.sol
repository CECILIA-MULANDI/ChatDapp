// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract ChatApp{
    // user
    struct user{
        string name;
        friend[] friendList;
    }
    struct friend{
        address pubKey;
        string name;
    }
    struct message{
        address sender;
        uint256 timestamp;
        string message;
    }
    mapping (address=>user) userList;
    mapping(bytes32=>message[])allMessages;
    // check if user exists
    function checkUserExists(address pubKey) public view returns(bool){
        return bytes(userList[pubKey].name).length>0;
    }

    // create user
    function createAccount(string calldata name) external{
        require(checkUserExists(msg.sender)==false,"User already exists");
        require(bytes(name).length>0,"Username cannot be empty");
        userList[msg.sender].name=name;

    }
    // get user name
    function getUsername(address pubKey) external view returns(string memory){
        // check if they are registered
        require(checkUserExists(pubKey),"User is not registered");
        return userList[pubKey].name;
    }

    // add friends
    function addFriend(address friend_key,string calldata name) external {
        require(checkUserExists(msg.sender),"Create an account");
        require(checkUserExists(friend_key),"User is not registered");
        require(msg.sender!=friend_key,"User cannot add themselves as a friend");
        require(checkAlreadyFriends(msg.sender,friend_key)==false,"These users re already friends");
        _addFriend(msg.sender,friend_key,name);
        _addFriend(friend_key,msg.sender,userList[msg.sender].name);
    }

    // check already friends
    function checkAlreadyFriends(address pubkey1,address pubkey2) internal view returns(bool){
        if(userList[pubkey1].friendList.length>userList[pubkey2].friendList.length){
            address tmp=pubkey1;
            pubkey1=pubkey2;
            pubkey2=tmp;
        }
        for(uint256 i =0;i<userList[pubkey1].friendList.length;i++){
           if (userList[pubkey1].friendList[i].pubKey == pubkey2) {
    return true;
    }
        }
        return false;
    }
    function _addFriend(address me,address friend_key,string memory name) internal{
        friend memory newFriend=friend(friend_key,name);
        userList[me].friendList.push(newFriend);
    }
    // get my friends
    function getMyFriendList() external view returns(friend [] memory){
        return userList[msg.sender].friendList;
    }

    // get chat code
    function _getChatCode(address pubkey1,address pubkey2) internal pure returns(bytes32){
        if(pubkey1<pubkey2){
            return keccak256(abi.encodePacked(pubkey1,pubkey2));
        }else return keccak256(abi.encodePacked(pubkey2,pubkey1));

    }
    function sendMessage(address friend_key,string calldata _msg) external{
        require(checkUserExists(msg.sender),"create an account first");
        require(checkUserExists(friend_key),"User is not registered");
        require(checkAlreadyFriends(msg.sender, friend_key),"You are not friends");

        bytes32 chatCode=_getChatCode(msg.sender, friend_key);
        message memory newMsg=message(msg.sender,block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    // read message 
    function readMessage(address friend_key) external view returns(message[] memory){
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
    }


}