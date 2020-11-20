pragma solidity 0.5.0 ; 

contract Auction{
    address thirdParty ; //第三方公正單位
    address payable public  beneficiary; //受益人
    uint public auctionEnded; //拍賣時間
    address public highestBidder; //出價最高者
    uint public highestBid; //最高出價
    bool ended; //拍賣狀態

    mapping (address => uint) public pendingReturn; //投標者，所投入的金錢

    //用來設定此次拍賣的受益人及拍賣時間期限
    constructor(address payable _beneficiary , uint _auctionEnded) public {
        thirdParty = msg.sender ;
        beneficiary = _beneficiary;
        auctionEnded =  now + _auctionEnded * 1 minutes ;
    }
    
    
    modifier limiteTime(){
        require(now < auctionEnded , "auction Ended!!!");
        _;
    }
    
    modifier onlyOwner(){
        require(thirdParty == msg.sender , "you are not thirdParty");
        _;
    }
    
    
    //競標
    function bid() public limiteTime payable {
       require(beneficiary!= msg.sender  , "beneficiary  can't join");
       require(thirdParty != msg.sender  , "thirdParty can't join");
       require(highestBid < msg.value , "need to pay more money");

        //先退回原本的押金，再重新轉帳新的押金
        if(pendingReturn[msg.sender]!=0){
            
             msg.sender.transfer(pendingReturn[msg.sender]);
        }
        // 等於右上方的value輸入框(可省略)
         address(this).transfer(msg.value); 
        
         highestBidder = msg.sender ; 
         highestBid = msg.value;
         pendingReturn[highestBidder] = highestBid ;
        
    }
    
    //領回競標金額
    function withdraw() public  returns(bool){
        require(now > auctionEnded ,"auction not ended !!!");
        require(highestBidder != msg.sender , "highestBidder cant withdraw money");
        require(ended ==true , "thirdParty not declare auctionEnd ");
        
        
        msg.sender.transfer(pendingReturn[msg.sender]);
        pendingReturn[msg.sender] = 0 ;
        return true ; 
        
    }
    
    //結束拍賣
    function auctionEnd() public onlyOwner {
        require(now > auctionEnded ,"auction not ended !!!");
        require(!ended, "auctionEnd has already been called.");
        ended = true ;
        beneficiary.transfer(highestBid);
    }
    
    
    function contract_balance() public view returns(uint){
        
        return address(this).balance;
    }
    
    function getAddressBId( address _addr) public view returns(uint){
       return pendingReturn[_addr];
    }
    
    
    
    function() external payable{}
    
    
}

