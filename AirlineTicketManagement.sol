// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import "./Booking.sol";
import "./Flight.sol";
import "./String.sol";


contract AirlineTicketManagement {


  address airline1;
  address airline2;

  mapping (address => mapping(string => mapping(string => Booking))) bookings;
  mapping (string => mapping(string => Flight )) flights;
  mapping (string => FlightRecord ) flightRecords;
  mapping (address => Booking[] ) dues;



  modifier isAirliner() {
      require(airline1 == msg.sender || airline2 == msg.sender, "Only Aireliner is allowed to perform function");
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

  modifier refundable(string memory flightId,string memory startDate){
    require(String.compare(flights[flightId][startDate].getStatus(), "Cancelled") || String.compare(flights[flightId][startDate].getStatus(), "Delayed"), "Flight is not in Cancelled or Delayed State");
    _;
  }

  constructor() {
    flightRecords["A1-P001"] = FlightRecord("A1-P001",airline1,20,"Bengaluru","Pune",180,20);
    flightRecords["A1-P002"] = FlightRecord("A1-P002",airline1,25,"Mumbai","Bengaluru",240,10);
    flightRecords["A1-P003"] = FlightRecord("A1-P003",airline1,20,"Bengaluru","Bhopal",720,30);
    flightRecords["A2-P001"] = FlightRecord("A2-P001",airline2,40,"Bengaluru","Pune",300,20);
    flightRecords["A2-P002"] = FlightRecord("A2-P002",airline2,40,"Kolkatta","Jaipur",180,10);
  }

  function updateFlightStatus(string memory flightId, string memory startDate, uint8 status) public validFlight(flightId) isAirliner {
    if ( ! flights[flightId][startDate].isValid() ){
      flights[flightId][startDate]= new Flight(flightRecords[flightId]);
    }
    flights[flightId][startDate].setStatus(status);
  }

  function clearDues() public isAirliner {
    Booking [] storage dueBookings = dues[msg.sender];

    for (uint i = 0; i < dueBookings.length; i++) {
        Booking booking = dueBookings[i];
        booking.refund();
        flights[booking.getFlightId()][booking.getStartDate()].releaseSeats(booking.getTicketCount());

    }
  }

  function checkAvailability(string memory flightId, string memory startDate) public validFlight(flightId) isBookingOpen(flightId,startDate) returns (uint)  {
    return flights[flightId][startDate].getAvailableSeats();
  }

  function checkBookingStatus(string memory flightId, string memory startDate) public isTraveller hasBookings(flightId, startDate){
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

  function book(string memory flightId, string memory startDate, uint8 numOfTickets) public isTraveller validFlight(flightId) isBookingOpen(flightId,startDate){
    bookings[msg.sender][flightId][startDate] = new Booking(flightId,startDate,msg.sender,payable(flightRecords[flightId].airlineAddress),numOfTickets,flightRecords[flightId].ticketPrice);
    flights[flightId][startDate].blockSeats(numOfTickets);
  }

}
