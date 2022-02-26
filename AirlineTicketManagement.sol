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
        1. Seat is available but not open for booking - Initial
        2. Seat is available for booking - Free
        3. Seat is under booking  - Blocked
        4. Seat is allocated to customer - Booked 
    */
    enum SeatStatus {Initialise, Free, Blocked, Booked}

    /**
        events
    */
    enum FlightEvents{FlightInitialisation, BookingOpen, BookingClosed, Delayed, Flying, Cancelled}

    /**
    Airline user details in struct
    */
    struct AirlineUser {
      address     user;
      string        userName;
      string        userId;
    }

    /**
     flight seat details 
    */
    struct Seat {
        uint256         seatId;
        address     owner;
        address     passenger;
        uint      price;
      SeatStatus      status;
    }

    /**
        flight details
    */
    struct Flight{
      string        flightId;
      string        airlineName;
      uint256     seatCount; 
      string        src;
      string        dest;
      uint256     departureTime;
      uint256     reachingTime;
      FlightStatus  status;
      Seat        []seats;
    }

    /**
    traveller details 
    */
    struct Traveller{
      address   traveller;
      string      name;
      string      age;
      string      govtId;
    }

    //temp to remove

    /*Variables*/
    mapping (address => AirlineUser) airlineUsers;
    mapping (address => Traveller) travellerUsers;
    Flight []       public flights;
    uint256         flightCounter;

    FlightStatus    flightStatus;
    SeatStatus      seatStatus;
    FlightEvents    flightEvent;


    constructor(uint256 seatCount, uint256 flightCount) {

        // airline users
        
        airlineUsers[msg.sender] = AirlineUser(msg.sender, 'AirlineUser1', 'AU01');

        airlineUsers[msg.sender] = AirlineUser(msg.sender, 'AirlineUser2', 'AU02');

        //traveller users
        travellerUsers[msg.sender] = Traveller(msg.sender, '24', 'Bharat', 'UAID-01');
        travellerUsers[msg.sender] = Traveller(msg.sender, '25', 'Shyam', 'UAID-02');
        travellerUsers[msg.sender] = Traveller(msg.sender, '27', 'Mohan', 'UAID-03');
        travellerUsers[msg.sender] = Traveller(msg.sender, '34', 'Abhi', 'UAID-04');
        travellerUsers[msg.sender] = Traveller(msg.sender, '38', 'Akash', 'UAID-05');

        numberOfSeats =  seatCount;
        numberOfFlights = flightCount;
        flightCounter = 0;

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

    //method to add flight
    function addFlight(string memory flightId, string memory flightName, string memory src, string memory dest, uint256 depTime, 
                        uint256 landingTime, uint256 price) public isAirlineUser {

        
        Flight memory flight = Flight(flightId, flightName, numberOfSeats, src, dest, depTime, landingTime, FlightStatus.Scheduled, addSeats(price));
        flights.push(flight);
        flightCounter += 1;
    }

    // function to initialise seats 
    function addSeats(uint256 price) public view returns(Seat[] memory seatList){
        for (uint256 i = 1; i <= numberOfSeats; i ++){
            Seat memory seat = Seat(i, address(0), address(0), price, SeatStatus.Initialise);
            seatList[i-1] = seat;
        }
        return seatList;
    }
}