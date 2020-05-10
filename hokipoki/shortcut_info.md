## `create_game`
`create_game uint64_t day, uint64_t num_tickets, uint64_t tickets_for_lottery, uint64_t price, string name, string location, uint64_t lottery_opens, uint64_t lottery_closes, uint64_t reward, gametype game_type`

Creates a game

Preconditions:
- num_tickets >= tickets_for_lottery

Params:
- `day`: day that the game occurs in yyyymmddhhmm format
- `num_tickets`: number of tickets total for the game
- `tickets_for_lottery`: number of tickets reserved for the lottery 
- `price`: price of ticket in 100th of HTK (ex. 100.00 HTK = 10000)
- `name`: String, name of game
- `location`: String, location of game
- `lottery_opens`: Time listed in frontend for when the lottery will open, format is yyyymmddHHMM
- `lottery_closes`: Time listed in frontend for when the lottery will close, format is yyyymmddHHMM
- `reward`: Number of HTK you get for attending a game in 100th of a HTK (ex. 100.00 HTK = 10000)
- `game_type`: number specifying to game type, as follows

```
    0  FOOTBALL
    1  MENS_BASKETBALL
    2  WOMANS_BASKETBALL
    3  MENS_SOCCER
    4  WOMENS_SOCCER
    5  BASEBALL
    6  CROSS_COUNTRY
    7  MENS_GOLF
    8  WOMENS_GOLF
    9  LACROSSE
    10 SOFTBALL
    11 SWIMMING_AND_DIVING
    12 MENS_TENNIS
    13 WOMENS_TENNIS
    14 TRACK_AND_FIELD
    15 VOLLEYBALL
    16 WRESTLING
```

## `buy`
`buy name user, uint64_t ticket_id`

Buys a ticket for a given user.

Preconditions:
- user must not already own a ticket
- user must not be in the lottery
- user must have proper amount of HTK 

Params:
- `user`: name of the user in EOSIO naming format
- `ticket_id`: id of the ticket

sell name user, uint64_t ticket_id
sells a ticket back to hokipoki
Preconditions:
- user must own ticket with corresponding id

Params:
- `user`: name of the user in EOSIO naming format
- `ticket_id`: id of the ticket

## `enter_lottery`
`enter_lottery name user, uint64_t game_id`

enters user to lottery

Preconditions:
- user does not already own a ticket
- user is not already in the lottery
- lottery has not already been executed

Params:
- `user`: name of the user in EOSIO naming format
- `game_id`: id for the game

## `leave_lottery`
`leave_lottery name user, uint64_t game_id`

leaves user from the lottery

Preconditions:
- user is already in the lottery

Params:
- `user`: name of user in EOSIO naming format
- `game_id`: id for the game

## `execute_lottery`
`execute_lottery uint64_t game_id`

executes the lottery

Preconditions:
- the lottery has not been executed already

Params:
- `game_id`: id for the game

## `open_lottery`
`open_lottery uint64_t game_id`

opens the lottery (lotteries for games start as closed)

Preconditions:
- the lottery has not been opened already

Params:
- `game_id`: id for the game

## `create_auction`
`create_auction name user, uint64_t ticket_id, uint64_t initial_bid, uint64_t end_date`

creates an auction on a ticket

preconditions:
- the ticket exists
- user is the owner of the ticket
- there is not already an active auction on that ticket
- the starting bid is greater than or equal to the face value of the ticket, or the initial face value for the game if the ticket was from the llottery
- the end date is not in the past
- the end date is before midnight on the day of the game

Params:
- `user`: the user who owns the ticket
- `ticket_id`: the ticket to auction off
- `initial_bid`: the starting value of the auction, in 100ths of a hokietoken (i.e. 500 = 5.00 HTK) - note: no money is actually transferred in this action
- `end_date`: the datetime after which no more bids will be accepted, as YYYYMMDDhhmm

## `bid`
`bid uint64_t ticket_id, name user, uint64_t bid`

bids on an existing auction

the amount being bid is transferred to hokipoki, and the previous highest bid (if there was one) is transferred back from hokipoki to the previous highest bidder
preconditions:
- the ticket exists
- there is an active auction on the ticket
- the user is not the owner of the ticket
- the user is not the current top bidder on the ticket - NOT ENFORCED TODO
- the auction has not already ended
- the amount being bid is at least 1.00 HTK greater than the current highest bid

params:
- `ticket_id`: the id of the ticket to bid on
- `user`: the user placing the bid
- `bid`: the bid amount, in 100s of a hokietoken (i.e. 500 = 5.00 HTK)

## `execute_auction_winner`
`execute_auction_winner uint64_t ticket_id, name user`

Executes an auction if it's already ended, callable by the winner (highest bidder) of the auction

If there were any bids on the ticket, it transfers ownership of the ticket to the higest bidder, and transfers the amount of the highest bid from hokipoki to the previous owner, then deletes the auction

if there were no bids on the ticket, it deletes the auction

preconditions: 
- the ticket exists
- there is an auction on the ticket
- it is past the end date on the auction on the ticket
- user is the highest bidder of the auction

params:
- `ticket_id`: the id of the ticket
- `user`: the highest bidder on the auction

## `execute_auction_owner`
`execute_auction_owner uint64_t ticket_id, name user`

Executes an auction if it's already ended, callable by the owner (creator) of the auction

If there were any bids on the ticket, it transfers ownership of the ticket to the higest bidder, and transfers the amount of the highest bid from hokipoki to the previous owner, then deletes the auction

if there were no bids on the ticket, it deletes the auction

preconditions: 
- the ticket exists
- there is an auction on the ticket
- it is past the end date on the auction on the ticket
- user is the owner of the ticket/creator of the auction

params
- `ticket_id`: the id of the ticket
- `user`: the owner of the ticket and creator of the auction

## `execute_all_auctions`
`execute_all_auctions uint64_t game_id`

Finds all auctions in progress for a particular game, and executes them, if it is the day of the game

preconditions:
- the game exists
- it is on or after the day of the game

params:
- `game_id`: the id of the game to execute all outstanding auctions on

## `cancel_auction`
`cancel_auction name user, uint64_t ticket_id`

deletes an auction as long as nobody has bid on it yet

preconditions:
- the ticket exists
- there is an active auction on the ticket
- nobody has bid on the auction yet

params:
- `user`: the owner of the ticket/creator of the auction
- `ticket_id`: the id of the ticket to delete the auction from

## `reset`
`reset`

clears all tables

On action, all games, lottery entries, auctions, and tickets are removed

## `games`
`games`

view all active games

## `lottery_entries`
`lottery_entries`

view all active `lottery_entries` for all games

## `tickets`
`tickets`

view all active tickets

## `auctions`
`auctions`

view all auctions

## `balance`
`balance name user`

view HTK balance of user

Params:
- user: name of user in EOSIO naming format

## `transfer`
`transfer name user_from, name user_to, double amount, string memo`

transfers HTK between two users

Params:
- user_from: user giving HTK in EOSIO format
- user_to: user recieving HTK in EOSIO format
- amount: number of HTK to transfer. MUST have two decimal point precision
- memo: string containing a memo for a transfer
