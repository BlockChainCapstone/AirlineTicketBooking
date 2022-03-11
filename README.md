# Airline Management
## Scenario

    • Book a  ticket with airline
        ◦ Make flight status as BookingOpen
        ◦ Make a booking
        ◦ Eth should be given to airline account
    • Cancel ticket before 2 to 24 hours
        ◦ Cancel booked ticket with airline with option 1
        ◦ Eth should be given back to customer based on implemented %
        ◦ Airline Clears dues 
    • Cancel ticket before 24 to 96 hours
        ◦ Cancel booked ticket with airline with option 2
        ◦ Eth should be given back to customer based on implemented %
        ◦ Airline Clears dues 
    • Delay flight
        ◦ Make flight status as BookingOpen
        ◦ Make a booking
        ◦ Eth should be given to airline account
        ◦ Make flight status as delayed 
        ◦ Customer claim refunds from airline
        ◦ Airline to Clear dues
    • Flight Cancel
        ◦ Make flight status as BookingOpen
        ◦ Make a booking
        ◦ Eth should be given to airline account
        ◦ Make flight status as cancelled  
        ◦ Customer claim refunds from airline
        ◦ Airline to Clear dues
    • Cancel Ticket post flight completion
        ◦ Make flight status as BookingOpen
        ◦ Make a booking
        ◦ Eth should be given to airline account
        ◦ Make flight status as Completed  
        ◦ Customer attempt to cancel the flight 
        ◦ Error out with invalid Status 
    • Book Ticket with insufficient funds 
        ◦ Make flight status as BookingOpen
        ◦ Make a booking
        ◦ Error out - Insufficient balance in account
    • Cancel Ticket with ticket status BookingClosed
        ◦ Make flight status as BookingClosed
        ◦ Make a booking
        ◦ Error out - status is Booking closed
    • Ticket booking with Airline account
        ◦ Make flight status as BookingOpen
        ◦ Make a booking from airline account
        ◦ Error out - only traveller can book the ticket
    • Flight schedule with Traveller accounts
        ◦ Make flight status as BookingOpen from traveller account
        ◦ Error out - only airline can  Perform this operation
