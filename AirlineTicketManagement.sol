// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

//import "AirlineBaseData.sol";

contract AirlineTicketManagement {
    
    // temp added here 

       /**
    number of seats in flight
    */
    uint256 numberOfSeats = 20;

    uint256 numberOfFlights = 2;
    
    /**
        1. Flight is scheduled from src to destination - Scheduled
        2. Scheduled Flight is open for ticket booking - BookingOpen
        3. Booking are completed or booking is closed by airline - BookingClosed
        4. Flight can’t not be completed due to any reason hence cancelled by airline - Cancelled
        5. Flight is not on time - Delayed 
        6. Flight has taken off and in air - Flying
    */
    enum FlightStatus {Scheduled, BookingOpen, BookingClosed, Delayed, Departed, Landed, Cancelled}


    /**
    Airline user details in struct
    */
    struct AirlineUser {
      address       user;
      string        userName;
    }


    /**
        booking status
    */
    enum BookingStatus {Refunded, Booked, Cancelled}
    /**
        booking details
    */
    struct BookingDetails{
        address         userAddress;
        address         airlineAddress;
        uint8           noOfTickets;
        uint256         totalPerTicket;
        BookingStatus   bookingStatus;
    }

    //key for bookingMap will be userAddess + flightId + StartDate
    mapping(string => BookingDetails) bookingMap;
    //Key -> flightId
    mapping(string => Flight) flightStatusMap;

    /**
        flight details
    */
    struct Flight{
      string        flightId;
      string        airlineName;
      uint256       availableSeats; 
      string        src;
      string        dest;
      uint256       departureTime;
      uint256       reachingTime;
      FlightStatus  status;
    }

    /**
    traveller details 
    */
    struct Traveller{
      address   traveller;
      string      name;
    }

    //temp to remove

    /*Variables*/
    mapping (address => AirlineUser) airlineUsers;
    mapping (address => Traveller) travellerUsers;
    Flight []       public flights;

    FlightStatus    flightStatus;


    constructor() {

        // airline users
        airlineUsers[msg.sender] = AirlineUser(msg.sender, 'AirlineUser1');
        airlineUsers[msg.sender] = AirlineUser(msg.sender, 'AirlineUser2');

        //traveller users
        travellerUsers[msg.sender] = Traveller(msg.sender, 'Bharat');
        travellerUsers[msg.sender] = Traveller(msg.sender, 'Shyam');
        travellerUsers[msg.sender] = Traveller(msg.sender, 'Mohan');
        travellerUsers[msg.sender] = Traveller(msg.sender, 'Abhi');
        travellerUsers[msg.sender] = Traveller(msg.sender, 'Akash');
    }

    //only airline users will be allowed
    modifier isAirlineUser() {
        require(msg.sender == airlineUsers[msg.sender].user, "Caller is not airline user");
        _;
    }

    //only traveller users will be allower
    modifier isTravellerUser() {
        require(msg.sender == travellerUsers[msg.sender].traveller, "Caller is not traveller");
        _;
    }
}