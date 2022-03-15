// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import "./Booking.sol";
import "./Flight.sol";
import "./String.sol";


contract AirlineTicketManagement {


  address airline1 = 0xf4E8b86db8fa52f6323C7fAa6F94d89900142948;
  address airline2 = 0x8f032B7C2997CB6AfFFe2578314bB4852AC5e462;

  mapping (address => mapping(string => mapping(string => Booking))) bookings;
  mapping (string => mapping(string => Flight )) flights;
  mapping (string => FlightRecord ) flightRecords;
  mapping (address => Booking[] ) dues;
  mapping (address => uint256  ) wallet;



  // modifier for airline account check
  modifier isAirliner() {
      require(airline1 == msg.sender || airline2 == msg.sender, "Only Airliner is allowed to perform function");
      _;
  }

  // modifier for traveller account check, if account is not airline account list then its traveller account
  modifier isTraveller() {
      require(airline1 != msg.sender && airline2 != msg.sender, "Only traveller is allowed to perform fucntion");
      _;
  }

  // modifier for flight id validation
  modifier validFlight(string memory flightId){
    require(flightRecords[flightId].airlineAddress != address(0x0),"Not a valid Flight Id");
    _;
  }

// modifier for flight booking validation
  modifier hasBookings(string memory flightId,string memory startDate){
    require(bookings[msg.sender][flightId][startDate].isValid(),"No bookings for the flight and date");
    _;
  }

  // modifier for validating flight booking status open
  modifier isBookingOpen(string memory flightId,string memory startDate){
    require(flights[flightId][startDate].isValid(),"Flight should be in valid state");
    require(String.compare(flights[flightId][startDate].getStatus(), "BookingOpen"), "Flight is not in BookingOpen State");
    _;
  }

  // modifier for validating flight status landed
  modifier isLanded(string memory flightId,string memory startDate){
    require(!String.compare(flights[flightId][startDate].getStatus(), "Landed"), "Flighthas already landed and not eligible for cencel now");
    _;
  }

  // modifier for balance check in traveller account 
  modifier checkBalance(uint8 numberOfTickets, string memory flightId){
    require(wallet[msg.sender] >= numberOfTickets * flightRecords[flightId].ticketPrice, "Traveller is not having enough balance");
    _;
  }

  // modifier for validating booking status for refund
  modifier refundable(string memory flightId,string memory startDate){
    require(String.compare(flights[flightId][startDate].getStatus(), "Cancelled") || String.compare(flights[flightId][startDate].getStatus(), "Delayed"), "Flight is not in Cancelled or Delayed State");
    _;
  }


  // Constructor to initialise flight records with flight details 
  constructor() {
    flightRecords["A11"] = FlightRecord("A11",airline1,20,"Bengaluru","Pune",180,20);
    flightRecords["A12"] = FlightRecord("A12",airline1,25,"Mumbai","Bengaluru",240,10);
    flightRecords["A13"] = FlightRecord("A13",airline1,20,"Bengaluru","Bhopal",720,30);
    flightRecords["A21"] = FlightRecord("A21",airline2,40,"Bengaluru","Pune",300,20);
    flightRecords["A22"] = FlightRecord("A22",airline2,40,"Kolkatta","Jaipur",180,10);
  }

  // method to load amount into user wallet in ether
  function loadToWallet() payable external {
     wallet[msg.sender] += msg.value/1000000000000000000;
  }

  // method to take amount back from user wallet account in ether currency
  function withdrawFromWallet() public {
    payable(msg.sender).transfer(wallet[msg.sender]*1000000000000000000);
    wallet[msg.sender]=0;
  }


  // method to update flight status and this is only usable by airline accounts
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

  //check balance in user wallet
  function getWalletBalance() public view returns (uint256){
    return wallet[msg.sender];
  }


// get flight rerords
  function getFlightRecords(string memory flightId) public view returns(FlightRecord memory){
    return flightRecords[flightId];
  }

// get flight status
  function getFlightStatus(string memory flightId, string memory startDate) public view returns(string memory){
    return flights[flightId][startDate].getStatus();
  }

// clear dues used by airline - this method will be triggered by airline to clear dues to travellers if any
  function clearDues() public isAirliner {
    Booking [] storage dueBookings = dues[msg.sender];
    for (uint i = 0; i < dueBookings.length; i++) {
        Booking booking = dueBookings[i];
        wallet[booking._userAddress()] += booking._refundAmount();
        wallet[msg.sender] -= booking._refundAmount();
        booking.refund(msg.sender);
        flights[booking.getFlightId()][booking.getStartDate()].releaseSeats(booking.getTicketCount());
    }
    delete dues[msg.sender];
  }

// check seat availability in flight with flight id and date as params
  function checkAvailability(string memory flightId, string memory startDate) public view validFlight(flightId) isBookingOpen(flightId,startDate) returns (uint256)  {
    return flights[flightId][startDate].getAvailableSeats();
  }

//booking status for user
  function checkBookingStatus(string memory flightId, string memory startDate) public view isTraveller  validFlight(flightId) hasBookings(flightId, startDate){
    bookings[msg.sender][flightId][startDate].getBookingStatus();
  }

// claim method for traveller accounts to make claim to refund in case of flight delay or cancel
  function claimRefund(string memory flightId, string memory startDate) public isTraveller hasBookings(flightId, startDate) refundable(flightId, startDate){
    bookings[msg.sender][flightId][startDate].requestRefund(flights[flightId][startDate].getStatus(), msg.sender);
    dues[flightRecords[flightId].airlineAddress].push(bookings[msg.sender][flightId][startDate]);
  }

// cancel booking with flightId, date and option {Before2Hours, Between2And24, Between24And96, Above96}
  function cancel(string memory flightId, string memory startDate, uint8 cancelOption) public isTraveller validFlight(flightId)  hasBookings(flightId, startDate) isLanded (flightId, startDate){
    bookings[msg.sender][flightId][startDate].requestCancel(cancelOption, msg.sender);
    dues[flightRecords[flightId].airlineAddress].push(bookings[msg.sender][flightId][startDate]);
  }

// booking done by traveller
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
