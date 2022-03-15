// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

// flight record struct
struct FlightRecord {
    string      flightId;
    address     airlineAddress;
    uint8       maxSeats;
    string      src;
    string      dest;
    uint256     startTime;
    uint        ticketPrice;
}


contract Flight {


  string[6] statusMap = ['BookingOpen', 'BookingClosed', 'Delayed', 'Departed','Landed','Cancelled'];
  /*
  0. Scheduled Flight is open for ticket booking - BookingOpen
  1. Booking are completed or booking is closed by airline - BookingClosed
  2. Flight is not on time - Delayed 
  6. Flight has taken off and in air - Departed
  4. Flight has completed- Landed
  5. Flight can’t not be completed due to any reason hence cancelled by airline - Cancelled
  */

  uint8       _availableSeats; // available seats in flight
  FlightRecord   _info;
  uint8  _status;
  bool   _exists;

  // modifier for invker address as airline can do certain operations
  modifier isAirliner(address invokerAddress) {
      require(_info.airlineAddress == invokerAddress, "Only  Airline is allowed to modify Status");
      _;
  }
  // modifier for flight status
  modifier validStatus(uint8 status) {
      require(status >= 0 && status<=5, "Status code are valid from 0-5");
      _;
  }

  // initialise flight record
  constructor(FlightRecord memory flightInfo)  {
    _info = flightInfo;
    _availableSeats= flightInfo.maxSeats;
    _status = 0;
    _exists = true;
  }

  function isValid() public view returns (bool) {
    return _exists;
  }

  function getAvailableSeats() public view returns (uint8) {
    return _availableSeats;
  }

  function setStatus(address invokerAddress, uint8 status) public isAirliner(invokerAddress) validStatus(status){
    _status = status;
  }

  function getStatus() public view returns(string memory){
    return statusMap[_status];
  }

  //blocking seat at the time of booking
  function blockSeats(uint8 numSeats) public {
    require(_availableSeats >= numSeats, "Not Enough Seats Available");
    _availableSeats = _availableSeats - numSeats;
  }

  // release seat if cancellation triggered 
  function releaseSeats(uint8 numSeats) public{
    require(_availableSeats + numSeats <= _info.maxSeats, "Release more seats than capacity");
    _availableSeats = _availableSeats + numSeats;
  }
}
