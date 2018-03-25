pragma solidity ^0.4.21;

/**
Usage: "Blockchain Workshop", "03-23-2018", 50, 20
*/

interface TicketBoothInterface {
    function buyTicket() external payable;
    function showTicketsRemaining() constant external returns(uint64);
    function updateNumTickets (uint64 numTickets) external;
    function updateTicketCost (uint32 eventCost) external;
    function requestRefund () external;
    function sellTicket (address recipient, uint32 cost) external payable;
}

contract TicketBooth is TicketBoothInterface {
    address public _ticketMaster;

    struct User {
        bool hasPaid;
        uint32 ticketPrice;
    }

    string public _eventName;
    string public _eventDate;
    uint32 public _eventCost;

    uint64 private _numTickets;
    mapping(address => User) private _attendees;
    
    modifier stillTicketsLeft() {
        require(_numTickets > 0);
        _;
    }

    modifier isTicketmaster () {
        require(msg.sender == _ticketMaster);
        _;
    }

    modifier inAttendance () {
        require(_attendees[msg.sender].hasPaid);
        _;
    }

    modifier notInAttendance () {
        require(!_attendees[msg.sender].hasPaid);
        _;
    }

    function TicketBooth (string eventName, string eventDate, uint32 eventCost, uint64 numTickets) public {
        _ticketMaster = msg.sender;
        _eventName = eventName;
        _eventDate = eventDate;
        _eventCost = eventCost;
        _numTickets = numTickets;
    }

    function buyTicket () external payable stillTicketsLeft notInAttendance {
        require(msg.value >= _eventCost);
        _numTickets--;
        _attendees[msg.sender] = User(true, _eventCost);
        msg.sender.transfer(msg.value - _eventCost);
    }

    function showTicketsRemaining () constant external returns(uint64) {
        return _numTickets;
    }

    function updateNumTickets (uint64 numTickets) external isTicketmaster {
        _numTickets = numTickets;
    }
  
    function updateTicketCost (uint32 eventCost) external isTicketmaster {
        _eventCost = eventCost;
    }

    function requestRefund () external inAttendance {
        msg.sender.transfer(_attendees[msg.sender].ticketPrice);
        delete _attendees[msg.sender];
        _numTickets++;
    }

    function sellTicket (address recipient, uint32 cost) external payable inAttendance {
        delete _attendees[msg.sender];
        require(recipient.send(cost));
        _attendees[recipient] = User(true, cost);
    }
}
