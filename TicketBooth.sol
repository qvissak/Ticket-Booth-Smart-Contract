pragma solidity ^0.4.18;

interface TicketBoothInterface {
    function buyTicket(string name, string email) external payable;
    function showTicketsRemaining() external returns(uint256);
    function updateNumTickets (uint256 numTickets) external;
    function updateTicketCost (uint256 eventCost) external;
    function requestRefund () external;
}

contract TicketBooth is TicketBoothInterface {
    address public _ticketMaster;

    struct User {
        string name;
        string email;
        bool paid;
        uint256 ticketPrice;
    }

    string public _eventName;
    string public _eventDate;
    uint256 public _eventCost;

    uint256 private _numTickets;
    mapping(address => User) private _attendees;

    modifier stillTicketsLeft() {
        require(_numTickets > 0);
        _;
    }

    modifier isTicketmaster () {
        require(msg.sender == _ticketMaster);
        _;
    }

    modifier notAttendee () {
        require(!_attendees[msg.sender].paid);
        _;
    }

    function TicketBooth(string eventName, string eventDate, uint256 eventCost, uint256 numTickets) public {
        _ticketMaster = msg.sender;
        _eventName = eventName;
        _eventDate = eventDate;
        _eventCost = eventCost;
        _numTickets = numTickets;
    }

    function decrementTicket() private { _numTickets--; }
    function incrementTicket() private { _numTickets++; }

    function buyTicket (string name, string email) external payable stillTicketsLeft notAttendee {
        decrementTicket();
        _attendees[msg.sender] = User(name, email, true, _eventCost);
        msg.sender.transfer(msg.value - _eventCost);
    }

    function showTicketsRemaining () external returns(uint256) {
        return _numTickets;
    }

    function updateNumTickets (uint256 numTickets) external isTicketmaster {
        _numTickets = numTickets;
    }
  
    function updateTicketCost (uint256 eventCost) external isTicketmaster {
        _eventCost = eventCost;
    }

    function requestRefund () external {
        require(_attendees[msg.sender].paid);
        _attendees[msg.sender].paid = false;
        msg.sender.transfer(_attendees[msg.sender].ticketPrice);
        incrementTicket();
    }
}
