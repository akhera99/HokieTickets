<h1 class="contract">creategame</h1>
---

spec-version: 0.1.0  
title: Create Game  
summary: This action will create a game to be played on the specified day, as well as create the specified number of tickets for the game, all owned by hokipoki. Of those tickets, some will be set aside for the ticket lottery and will not be purchaseable. The number set aside for the lottery is equal to the `tickets_for_lotto` parameter. Tickets set aside for the lottery have a face value of 0.00 HTK, the rest of the tickets have a face value of `price`/100. This action must be invoked with the active permission of hokipoki.  
icon:  
  
<h1 class="contract">buy</h1>  
---  

spec-version: 0.1.0  
title: Buy  
summary: This action takes a user and a ticket id. It must be invoked with the active permission of the passed user. If the ticket ID exists, is owned by hokipoki, is not reserved for the ticket lottery, and the user has enough available HTK to purchase the ticket, and the user has allowed the `hokipoki` smart contract to execute inline actions on `eosio.token` with the user's active permission, then the face value of the ticket is transfered to hokipoki, and the owner of the ticket is set to the calling user.  
icon:  
  
<h1 class="contract">sell</h1>  
---  

spec-version: 0.1.0  
title: Sell  
summary: This action takes a user and a ticket id. It must be invoked with the active permission of the passed user. If the ticket ID exists, is owned by the calling user, and the user has allowed the `hokipoki` smart contract to execute inline actions on `eosio.token` with the user's active permission, then the face value of the ticket is transfered from hokipoki to the active user, and the owner of the ticket is set to `hokipoki`.  
icon:  
  
<h1 class="contract">enterlottery</h1>  
---  

spec-version: 0.1.0  
title: Enter Lottery  
summary: This action takes a user and a game id. It must be invoked with the active permission of the passed user. If the game ID exists, the lottery is still open for that game, and the user has not already entered into the ticket lottery for that game, then the user is entered into the ticket lottery. The four passed random values should be randomly generated.   
icon:  
  
<h1 class="contract">leavelottery</h1>  
---  

spec-version: 0.1.0  
title: Leave Lottery  
summary: This action takes a user and a game id. It must be invoked with the active permission of the passed user. If the game ID exists, and the user has entered into the ticket lottery for that game, then the user is removed from the ticket lottery.  
icon:  
  
<h1 class="contract">executelotto</h1>  
---  

spec-version: 0.1.0  
title: Execute Lottery  
summary: This action takes a game id. It must be invoked with the active permission of `hokipoki`. If the game ID exists, and the lottery is still open for that game, each ticket for that game that is reserved for the lottery is assigned to a random student who has entered the lottery for that game, such that no two tickets are assigned to the same student. The face value for these tickets stays at 0. If there are more tickets than students, then for each remaining ticket, the owner stays as `hokipoki`, but their face value is updated to the price that was specified when the game was created. All tickets for the game are no longer reserved for the lottery.  
icon:  
  
<h1 class="contract">openlottery</h1>  
---  

spec-version: 0.1.0  
title: Open Lottery  
summary: This action takes a game id. It must be invoked with the active permission of `hokipoki`. If the game ID exists, and the lottery is not yet open for that game, it marks the lottery as being open, allowing students to enter themselves into the lottery.  
icon:  
  
<h1 class="contract">adduser</h1>  
---  

spec-version: 0.1.0  
title: Add User  
summary: This action takes a name, and adds it to the list of users who use HokieTickets. This list is used by the administrator on the website to view students balances and tickets. Must be run with the active permsision of `hokipoki`  
icon:  
  
<h1 class="contract">rewarduser</h1>  
---  

spec-version: 0.1.0  
title: Reward User  
summary: This action takes a ticket id, and it marks the ticket has having been used to attend a game, and transfers the game's reward amount to the owner of the ticket. Must be run with `hokipoki`'s active permission  
icon:  
  
<h1 class="contract">creatauction</h1>  
---  

spec-version: 0.1.0  
title: Create Auction  
summary: This action takes a ticket id, a starting bid amount, and an end date in the form YYYYMMDDHHmm. The ticket must exist, the starting bid amount must be greater than or equal to the face value of the ticket, and the end date must be after the current time but before 11:59 PM on the night before the game. There must not be an open auction on the ticket already, the ticket must not have already been used to attend a game, and the action requires the active permissions of the ticket owner. The action creates an auction with the current owner set as the highest bidder and the highest bid set as the opening bid.  
icon:  
  
<h1 class="contract">bid</h1>  
---  

spec-version: 0.1.0  
title: Bid  
summary: This action takes an auction id, a user, and a bid amount. The action requires the active permission of the passed user. The auction must exist, the auction end date must still be in the future, and the passed bid amount must be at least 1.00 HTK greater than the current highest bid. The user must not be the creator of the auction. If the auction has had at least one bid on it, the former top bidder is refunded their bid, and the passed user has their bid amount transferred to `hokipoki`. If they don't have enough money to make the bid, the action fails with an error. The top bidder and highest bid on the auction are updated to be the passed user and bid amount. Finally, the end date of the auction is extended by 1 minute, to a maximum end date of 11:59 on the night before the game.  
icon:  
  
<h1 class="contract">execauction1</h1>  
---  

spec-version: 0.1.0  
title: Execute Auction (Recipient)  
summary: This action takes an auction id, and checks that the auction exists, and that the end date has passed. If so, it transfers ownership of the ticket being auctioned to the highest bidder, and gives the top bid's value from `hokipoki` to the former owner. Then, it deletes the auction. Requires the active permission of the top bidder. If nobody bid on the auction before the end date, the auction is just deleted.  
icon:  
  
<h1 class="contract">execauction2</h1>  
---  

spec-version: 0.1.0  
title: Execute Auction (Owner)  
summary: This action takes an auction id, and checks that the auction exists, and that the end date has passed. If so, it transfers ownership of the ticket being auctioned to the highest bidder, and gives the top bid's value from `hokipoki` to the former owner. Then, it deletes the auction. Requires the active permission of the creator of the auction. If nobody bid on the auction before the end date, the auction is just deleted.  
icon:  
  
<h1 class="contract">aucexecall</h1>  
---  

spec-version: 0.1.0  
title: Execute All Auctions  
summary: This action takes a game id, and checks that it is currently the day of the game. If so, it finds all auctions for that game and executes them. We know that the auctions must already be over, because you cannot have an auction end date that is on or after the day of the game, and bidding will not extend the end date of an auction past 11:59 of the night before the game. Executing an auction simply transfers the ticket to the highest bidder, and the highest bid to the previous owner. If nobody bid on the ticket, the auction is deleted. Auctions could have finished and been executed before this action is called, this is simply a cleanup action to transfer tickets to students who won an auction but forgot to claim their ticket. Students do not have to wait for this action to be called to execute their auction, but they do have to wait for the end date of the auction. This action requries the active permission of `hokipoki`  
icon:  
  
<h1 class="contract">cancelauctn</h1>  
---  

spec-version: 0.1.0  
title: Cancel Auction  
summary: This action takes an auction ID, and requires the active permission of the creator of that auction. If nobody has bid on the auction yet, it deletes the auction. If someone has already bid on the auction, it fails with an error.  
icon:  
  
  
<h1 class="contract">reset</h1>  
---  

spec-version: 0.1.0  
title: Reset  
summary: This action must be invoked with the active permission of `hokipoki`. All games, tickets, lottery entries and auctions are deleted.  
icon:  
  
  
