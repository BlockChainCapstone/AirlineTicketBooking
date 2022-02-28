pragma solidity 0.8.6;


contract Booking {
    /**
        Booking status
    */
    enum BookingStatus {Booked, RefundRequest, Refunded, CancelRequest, Cancelled};

    /**
    enum CancelOption {Before2Hours, Between2And24, Between24And96, Above96};

    string          _flightId;
    string          _startDate;
    address         _userAddress;
    address         _airlineAddress;
    uint8           _noOfTickets;
    uint256         _totalPrice;
    uint256         _refundAmount = 0 ;
    BookingStatus   _bookingStatus;

    modifier isAirliner() {
        require(_airlineAddress == msg.sender, "Only Airline is allowed to refund");
        _;
    }

    modifier isRefundable() {
        require(_bookingStatus == BookingStatus.RefundRequest || _bookingStatus == BookingStatus.CancelRequest, "Not in Refundable State ");
        _;
    }

    modifier validCancelOption() {
        require(cancelOption >= 1 && cancelOption <=3, "Not a valid cancel option, only accepted values are 1-3");
        _;
    }

    modifier isTraveller() {
        require(_userAddress == msg.sender, "Only Airline is allowed to refund");
        _;
    }

    constructor(string flightId, string startDate, address userAddress, address airlineAddress, uint8 noOfTickets, uint256 ticketPrice) payable  isTraveller {
      _flightId = flightId;
      _startDate = startDate;
      _userAddress = userAddress
      _airlineAddress=airlineAddress;
      _noOfTickets=noOfTickets;
      _totalPrice=ticketPrice * noOfTickets;
      _airlineAddress.transfer(totalPrice);
      _bookingStatus=BookingStatus.Booked;validCancelOption
    }

    function requestRefund(string flightState) public isTraveller {
      // 50% as refund amount
      if (flightState="Delayed"){
        _refundAmount = _totalPrice / 2;
      }else{
        _refundAmount = _totalPrice;
      }

      _bookingStatus=BookingStatus.RefundRequest;
    }

    function requestCancel(uint cancelOption) public isTraveller validCancelOption(cancelOption){
      if ( cancelOption == 1 ){
        //20% as refund Amount
        _refundAmount = _totalPrice / 5;
      }else if ( cancelOption == 2 ){
        //50% as refund Amount
        _refundAmount = _totalPrice / 2;
      } else if ( cancelOption == 3 ){
        //90% as refund Amount
        _refundAmount = _totalPrice - _totalPrice / 10
      }
      _bookingStatus=BookingStatus.CancelRequest;
    }

    function refund() payable pulblic isAirliner isRefundable {
      _userAddress.transfer(_refundAmount);
      if (_bookingStatus == BookingStatus.RefundRequest ){
        _bookingStatus=BookingStatus.Refunded;
      }else {
        _bookingStatus=BookingStatus.Cancelled;
      }
    }
}
