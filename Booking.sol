// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import "./String.sol";

enum  BookingStatus {Booked, RefundRequest, Refunded, CancelRequest, Cancelled}

contract Booking {


    enum CancelOption {Before2Hours, Between2And24, Between24And96, Above96}

    string           _flightId;
    string          _startDate;
    address public      _userAddress;
    address     _airlineAddress;
    uint8           _noOfTickets;
    uint256         _totalPrice;
    uint256 public        _refundAmount = 0 ;
    BookingStatus public  _bookingStatus;


    modifier isAirliner(address invoker) {
        require(_airlineAddress == invoker, "Airline - Only Airline is allowed to refund");
        _;
    }

    modifier isRefundable() {
        require(_bookingStatus == BookingStatus.RefundRequest || _bookingStatus == BookingStatus.CancelRequest, "Not in Refundable State ");
        _;
    }

    modifier validCancelOption(uint8 cancelOption) {
        require(cancelOption >= 1 && cancelOption <=3, "Not a valid cancel option, only accepted values are 1-3");
        _;
    }

    modifier isTraveller(address invoker) {
        require(_userAddress == invoker, "Only Airline is allowed to refund");
        _;
    }

    constructor(string  memory flightId, string  memory startDate, address  userAddress, address  airlineAddress, uint8  noOfTickets, uint256   ticketPrice) {
      _flightId = flightId;
      _startDate = startDate;
      _userAddress =  userAddress;
      _airlineAddress = airlineAddress;
      _noOfTickets = noOfTickets;
      _totalPrice = ticketPrice * noOfTickets;

    }

    function setStatus(BookingStatus bookingStatus) external {
      _bookingStatus = bookingStatus;
    }

    function isValid() public view returns (bool) {
        return _userAddress!=address(0x0);
    }

    function getFlightId() public view returns (string memory) {
        return _flightId;
    }

    function getStartDate() public view returns (string memory) {
        return _startDate;
    }

    function getTicketPrice() public view returns (uint256){
        return _totalPrice;
    }

    function getTicketCount() public view returns (uint8){
        return _noOfTickets;
    }

    function getBookingStatus() public view returns (BookingStatus){
        return _bookingStatus;
    }

    function requestRefund(string memory flightState, address invoker) public isTraveller(invoker) {
      // 50% as refund amount
      if (String.compare(flightState, "Delayed")){
        _refundAmount = _totalPrice / 2;
      } else{
        _refundAmount = _totalPrice;
      }
      _bookingStatus=BookingStatus.RefundRequest;
    }

    function requestCancel(uint8 cancelOption, address invoker) public isTraveller(invoker) validCancelOption(cancelOption){
      if ( cancelOption == 1 ){
        //20% as refund Amount
        _refundAmount = _totalPrice / 5;
      }else if ( cancelOption == 2 ){
        //50% as refund Amount
        _refundAmount = _totalPrice / 2;
      } else if ( cancelOption == 3 ){
        //90% as refund Amount
        _refundAmount = _totalPrice - _totalPrice / 10;
      }
      _bookingStatus=BookingStatus.CancelRequest;
    }

    function refund(address invoker) payable public isAirliner(invoker) isRefundable {
    //  _userAddress.transfer(_refundAmount);
      if (_bookingStatus == BookingStatus.RefundRequest ){
        _bookingStatus=BookingStatus.Refunded;
      }else {
        _bookingStatus=BookingStatus.Cancelled;
      }
    }
}
