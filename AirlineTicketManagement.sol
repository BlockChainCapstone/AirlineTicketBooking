// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import "./Booking.sol";
import "./Flight.sol";
import "./String.sol";


contract AirlineTicketManagement {


  address airline1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
  address airline2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

  mapping (address => mapping(string => mapping(string => Booking))) bookings;
  mapping (string => mapping(string => Flight )) flights;
  mapping (string => FlightRecord ) flightRecords;
  mapping (address => Booking[] ) dues;
  mapping (address => uint256  ) wallet;



  modifier isAirliner() {
      require(airline1 == msg.sender || airline2 == msg.sender, "Only Airliner is allowed to perform function");
      _;
  }

  modifier isTraveller() {
      require(airline1 != msg.sender && airline2 != msg.sender, "Only traveller is allowed to perform fucntion");
      _;
  }

  modifier validFlight(string memory flightId){
    require(flightRecords[flightId].airlineAddress != address(0x0),"Not a valid Flight Id");
    _;
  }

  modifier hasBookings(string memory flightId,string memory startDate){
    require(bookings[msg.sender][flightId][startDate].isValid(),"No bookings for the flight and date");
    _;
  }

  modifier isBookingOpen(string memory flightId,string memory startDate){
    require(String.compare(flights[flightId][startDate].getStatus(), "BookingOpen"), "Flight is not in BookingOpen State");
    _;
  }

  modifier checkBalance(uint8 numberOfTickets, string memory flightId){
    require(wallet[msg.sender] > numberOfTickets * flightRecords[flightId].ticketPrice, "Traveller is not having enough balance");
    _;
  }

  modifier refundable(string memory flightId,string memory startDate){
    require(String.compare(flights[flightId][startDate].getStatus(), "Cancelled") || String.compare(flights[flightId][startDate].getStatus(), "Delayed"), "Flight is not in Cancelled or Delayed State");
    _;
  }


  constructor() {
    flightRecords["A11"] = FlightRecord("A11",airline1,20,"Bengaluru","Pune",180,20);
    flightRecords["A12"] = FlightRecord("A12",airline1,25,"Mumbai","Bengaluru",240,10);
    flightRecords["A13"] = FlightRecord("A13",airline1,20,"Bengaluru","Bhopal",720,30);
    flightRecords["A21"] = FlightRecord("A21",airline2,40,"Bengaluru","Pune",300,20);
    flightRecords["A22"] = FlightRecord("A22",airline2,40,"Kolkatta","Jaipur",180,10);
  }

  function loadToWallet() payable external {
     wallet[msg.sender] += msg.value/1000000000000000000;
  }

  function withdrawFromWallet() public {
    payable(msg.sender).transfer(wallet[msg.sender]*1000000000000000000);
    wallet[msg.sender]=0;
  }


  function updateFlightStatus(string memory flightId, string memory startDate, uint8 status) public validFlight(flightId) isAirliner {
    if ( status == 0 ){
        require(msg.sender == flightRecords[flightId].airlineAddress, "Not an airline address");
        flights[flightId][startDate] = new Flight(flightRecords[flightId]);
    }else{
        require(flights[flightId][startDate].isValid(),"Flight should be in valid state");
        Flight flight = flights[flightId][startDate];
        flight.setStatus(msg.sender, status);
    }
  }

  function getWalletBalance() public view returns (uint256){
    return wallet[msg.sender];
  }


  function getFlightRecords(string memory flightId) public view returns(FlightRecord memory){
    return flightRecords[flightId];
  }

  function getFlightStatus(string memory flightId, string memory startDate) public view returns(string memory){
    return flights[flightId][startDate].getStatus();
  }

  function clearDues() public isAirliner {
    Booking [] storage dueBookings = dues[msg.sender];
    for (uint i = 0; i < dueBookings.length; i++) {
        Booking booking = dueBookings[i];
        wallet[booking._userAddress()] += booking._refundAmount();
        wallet[msg.sender] -= booking._refundAmount();
        booking.refund();
        flights[booking.getFlightId()][booking.getStartDate()].releaseSeats(booking.getTicketCount());
    }
  }

  function checkAvailability(string memory flightId, string memory startDate) public view validFlight(flightId) isBookingOpen(flightId,startDate) returns (uint)  {
    return flights[flightId][startDate].getAvailableSeats();
  }

  function checkBookingStatus(string memory flightId, string memory startDate) public view isTraveller hasBookings(flightId, startDate){
    bookings[msg.sender][flightId][startDate].getBookingStatus();
  }

  function claimRefund(string memory flightId, string memory startDate) public isTraveller hasBookings(flightId, startDate) refundable(flightId, startDate){
    bookings[msg.sender][flightId][startDate].requestRefund(flights[flightId][startDate].getStatus());
    dues[flightRecords[flightId].airlineAddress].push(bookings[msg.sender][flightId][startDate]);
  }

  function cancel(string memory flightId, string memory startDate, uint8 cancelOption) public isTraveller validFlight(flightId)  hasBookings(flightId, startDate){
    bookings[msg.sender][flightId][startDate].requestCancel(cancelOption);
    dues[flightRecords[flightId].airlineAddress].push(bookings[msg.sender][flightId][startDate]);
  }

  function book(string memory flightId, string memory startDate, uint8 numOfTickets)  public isTraveller validFlight(flightId) isBookingOpen(flightId,startDate) checkBalance(numOfTickets, flightId){
    address airlineAddress = flightRecords[flightId].airlineAddress;
    Booking booking = new Booking(flightId,startDate,msg.sender,airlineAddress,numOfTickets,flightRecords[flightId].ticketPrice);
    wallet[airlineAddress] += booking.getTicketPrice();
    wallet[msg.sender] -= booking.getTicketPrice();
    bookings[msg.sender][flightId][startDate] = booking;
    flights[flightId][startDate].blockSeats(numOfTickets);
    booking.setStatus(BookingStatus.Booked);
  }
}
