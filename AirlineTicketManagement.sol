// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import "./Booking.sol";
import "./Flight.sol";


contract AirlineTicketManagement {

  addres airline1;
  addres airline2;

  mapping (address => mapping(string => mapping(string => Booking))) bookings;
  mapping (string => mapping(string => Flight )) flights;
  mapping (string => FlightRecord ) flightRecords;
  mapping (address => Booking[] ) dues;


  modifier isAirliner() {
      require(airline1 == msg.sender || aireline2 == msg.sender, "Only Aireliner is allowed to perform function");
      _;
  }

  modifier isTraveller() {
      require(airline1 != msg.sender && aireline2 != msg.sender, "Only traveller is allowed to perform fucntion");
      _;
  }

  modifier validFlight(string flightId){
    require(flightRecords[flightId] != address(0x0),"Not a valid Flight Id");
    _;
  }

  modifier hasBookings(string flightId,string startDate){
    require(bookings[msg.sender][flightId][startDate] != address(0x0),"No bookings for the flight and date");
    _;
  }

  modifier isBookingOpen(string flightId,string startDate){
    require(flights[flightId][startDate].getStatus() == "BookingOpen", "Flight is not in BookingOpen State");
    _;
  }

  modifier refundable(string flightId,string startDate){
    require(flights[flightId][startDate].getStatus() == "Cancelled" || flights[flightId][startDate].getStatus() == "Delayed", "Flight is not in Cancelled or Delayed State");
    _;
  }

  constructor() {
    flightRecords["A1-P001"]=new FlightRecord("A1-P001",airline1,20,"Bengaluru","Pune",180,20);
    flightRecords["A1-P002"]=new FlightRecord("A1-P002",airline1,25,"Mumbai","Bengaluru",240,10);
    flightRecords["A1-P003"]=new FlightRecord("A1-P003",airline1,20,"Bengaluru","Bhopal",720,30);
    flightRecords["A2-P001"]=new FlightRecord("A2-P001",airline2,40,"Bengaluru","Pune",300,20);
    flightRecords["A2-P002"]=new FlightRecord("A2-P002",airline2,40,"Kolkatta","Jaipur",180,10);
  }

  function updateFlightStatus(string flightId, string startDate, uint status) public validFlight(flightId) isAirliner {
    if (flights[flightId][startDate] == address(0x0)){
      flights[flightId][startDate]= new Flight(flightRecords[flightId]);
    }
    flights[flightId][startDate].setStatus(status);
  }

  function clearDues() public isAirliner {
    Booking [] dueBookings = dues[msg.sender];
    while(dueBookings.length>0)
      Booking booking = dueBookings.pop();
      booking.refund();
      flights[booking._flightId][booking._startDate].release(booking._noOfTickets);
    }
  }

  function checkAvailability(string flightId, string startDate) public validFlight(flightId) isBookingOpen(flightId,startDate) return (uint)  {
    return flights[flightId][startDate]._availableSeats;
  }

  function checkBookingStatus(string flightId, string startDate) public isTraveller hasBookings(flightId, startDate){
    bookings[msg.sender][flightId][startDate]._bookingStatus;
  }

  function claimRefund(string flightId, string startDate) public isTraveller hasBookings(flightId, startDate) refundable(flightId, startDate){
    bookings[msg.sender][flightId][startDate].requestRefund(flights[flightId][startDate].getStatus());
    dues[flightRecords[flightId].airlineAddress].push(bookings[msg.sender][flightId][startDate]);
  }

  function cancel(string flightId, string startDate, uint cancelOption) public isTraveller validFlight(flightId)  hasBookings(flightId, startDate){
    bookings[msg.sender][flightId][startDate].requestCancel(cancelOption);
    dues[flightRecords[flightId].airlineAddress].push(bookings[msg.sender][flightId][startDate])
  }

  function book(string flightId, string startDate, uint numOfTickets) public isTraveller validFlight(flightId) isBookingOpen(flightId,startDate){
    bookings[msg.sender][flightId][startDate] = new Booking(flightId,startDate,msg.sender,flightRecords[flightId].airlineAddress,numOfTickets,flightRecords[flightId].ticketPrice);
    flights[flightId][startDate].block(numOfTickets)
  }

}
