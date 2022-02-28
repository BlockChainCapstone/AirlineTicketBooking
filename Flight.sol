pragma solidity 0.8.6;


conract Flight {

  string[4] statusMap = ['BookingOpen', 'BookingClosed', 'Delayed', 'Departed','Landed','Cancelled'];

  struct FlightRecord {
    string      flightId;
    address     airlineAddress;
    uint8       maxSeats;
    string      src;
    string      dest;
    uint256     startTime;
    uint        ticketPrice;
  }

  uint8       _availableSeats;
  FlightRecord _info;
  uint8  _status;

  modifier isAirliner() {
      require(_info.airlineAddress == msg.sender, "Only  Airline is allowed to mdify");
      _;
  }
  modifier validStatus(uint8 status) {
      require(status >= 0 && status<=5, "Status code are valid from 0-5");
      _;
  }


  constructor(FlightRecord flightInfo)  {
    _info = flightInfo;
    _availableSeats= flightInfo.maxSeats;
    _status = 0;
  }

  function setStatus(uint8 status) public isAirliner validStatus(status){
    _status = status;
  }

  function getStatus public returns (string){
    return statusMap[_status];
  }

  function block(unint numSeats) public {
    require(_availableSeats >= numSeats, "Not Enough Seats Available");
    _availableSeats = _availableSeats - numSeats;
  }

  function release(unint numSeats) public{
    require(_availableSeats + numSeats <= _info.maxSeats, "Release more seats than capacity");
    _availableSeats = _availableSeats + numSeats;
  }

}
