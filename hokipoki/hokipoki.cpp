#include <eosio/eosio.hpp>
#include <eosio/asset.hpp>
#include <eosio/transaction.hpp>
#include <eosio/crypto.hpp>
#include <eosio/time.hpp>
#include <eosio/system.hpp>
#include <stdio.h>

extern "C" {
#include "newlib/gmtime_r.c"
}

using eosio::contract, eosio::require_auth, eosio::check, eosio::name;

// This class is used to generate "random" numbers
// The numbers it generates MUST be deterministic, or different nodes on the blockchain
// will get different transactions when they execute an action - but for selecting students
// to win the ticket lottery, we want it to be as random as possible
//
// It seeds itself based on the current block number, which is mostly unpredictable
// because the administrator can click the "execute lottery" button at any time, and
// blocks are generated twice per second.
//
// Then, each student submitted 4 random numbers when they entered the lottery, and all
// those numbers are xor'd, added, multiplied, and so on to get a final seed
//
// Based on that seed, random numbers are generated based on a linear congruency generator
// set up with the same parameters as glibc's rand() function.
struct random {
    uint64_t state = 0x4017117fdf7c8ee9;
    int n = 0;
    random() {
        // seed with current block number
        auto mixedBlock = eosio::tapos_block_prefix() * eosio::tapos_block_num();
        eosio::checksum256 result = eosio::sha256((char*) &mixedBlock, sizeof(mixedBlock));
        static_assert(sizeof(result) / 8 >= 4, "pls");
        uint64_t* uptr = (uint64_t*) &result;
        update(uptr[0], uptr[1], uptr[2], uptr[3]);
    }
    // Tumble around these new values to get a new state
    void update(uint64_t r1, uint64_t r2, uint64_t r3, uint64_t r4) {
        check(n == 0, "already called get().");
        state ^= r1;
        while (r2 == 0 || r3 == 0) { r2++; r3++; }
        state ^= ((r2 % r3) * (r3 % r2) * r2 * r3);
        state ^= (r4 % 11) * r4 * r1;
    }
    // LCG based on glibc implementation
    uint32_t get() {
        n++;
        uint64_t s = state;
        for (int i = 0; i < n; i++) {
            s = (s * 1103515245 + 12345) % (1 << 31);
        }
        return s;
    }
};



class [[eosio::contract("hokipoki")]] hokipoki : public eosio::contract {
public:
    using contract::contract;

    // Returns the current time as a big integer of the format YYYYMMDDHHmm
    // Since both gmtime and std::chrono are not included in the eosio C++ toochain,
    // we use parts of a public library released under a free license called newlib.
    // Since `struct tm` and `gmtime_r` are already reserved (the compiler gmtime_r
    // exist but the linker doesn't), we took only the parts of newlib we needed
    // (three functions, gmtime_r, mktime, and a helper function), and renamed
    // the functions as necessary. The license for this code is in newlib/LICENSE
    uint64_t current_datetime() {
        // Get the current time as an epoch
        time_t now = eosio::current_block_time().to_time_point().elapsed.to_seconds();
        now -= 4 * 3600; // time zone offset
        struct hokipoki_tm cal;
        hokipoki_gmtime_r(&now, &cal);
        // Convert back to giant int
        return (((uint64_t) cal.tm_year + YEAR_BASE) * 100000000) + (((uint64_t) cal.tm_mon + 1) * 1000000) + ((uint64_t) (cal.tm_mday + 1) * 10000) + ((uint64_t) cal.tm_hour * 100) + (uint64_t) cal.tm_min;
    }
    // Given a datetime in the format YYYYMMDDHHmm, it adds one minute and returns a date in the same format
    // This is used for adding 1 minute to the closing times of auctions when someone bids on them
    // mktime and gmtime_r are both coming from newlib, since the eosio C++ toolchain claims to support them but doesn't
    // 
    // A first pass at adding one minute simply added 1, resulting in times like 11:60 PM :(
    uint64_t datetime_add_1min(uint64_t datetime) {
        struct hokipoki_tm t{};
        t.tm_year = (datetime / 100000000) - 1900;
        t.tm_mon = ((datetime / 1000000) % 100) - 1;
        t.tm_mday = ((datetime / 10000) % 100) - 1;
        t.tm_hour = (datetime / 100) % 100;
        t.tm_min = datetime % 100;
        time_t m = mktime(&t);
        m += 60;
        hokipoki_gmtime_r(&m, &t);
        return (((uint64_t) t.tm_year + 1900) * 100000000) + (((uint64_t) t.tm_mon + 1) * 1000000) + ((uint64_t) (t.tm_mday + 1) * 10000) + ((uint64_t) t.tm_hour * 100) + (uint64_t) t.tm_min;
    }

    // This action will create a game to be played on the specified day, as well as create the specified number of
    // tickets for the game, all owned by hokipoki. Of those tickets, some will be set aside for the ticket lottery
    // and will not be purchaseable. The number set aside for the lottery is equal to the `tickets_for_lotto` parameter.
    // Tickets set aside for the lottery have a face value of 0.00 HTK, the rest of the tickets have a face value of
    // `price`/100. This action must be invoked with the active permission of hokipoki.
    [[eosio::action]]
    void creategame(
            uint64_t day,
            uint64_t num_tickets,
            uint64_t tickets_for_lotto,
            uint64_t price,
            std::string name,
            std::string location,
            uint64_t lottery_opens,
            uint64_t lottery_closes,
            uint64_t reward,
            uint64_t game_type) {
        require_auth(get_self());
        games_index games(get_self(), get_first_receiver().value);
        // Get the next available ID
        uint64_t new_id = 0;
        if (games.cbegin() != games.cend()) {
            new_id = games.crbegin()->id + 1;
        }
        // Get the next available number. The first game on each day is number 1, then 2 and 3 and so on. But if games are on different days, the numbers don't have any relation
        uint64_t new_number = 0;
        auto dayindex = games.get_index<"bydate"_n>();
        auto dayiter = dayindex.lower_bound(day);
        while (dayiter != dayindex.end() && dayiter->date == day) {
            new_number = std::max(new_number, dayiter->number);
            dayiter++;
        }
        new_number += 1;

        // Put the game in the table
        games.emplace(get_self(), [new_id, day, new_number, price, name, location, lottery_opens, lottery_closes,reward,game_type](auto& row) {
            row.id = new_id;
            row.date = day;
            row.number = new_number;
            row.lottery_open = false; // lottery is closed until the admin executes openlottery on the game
            row.initial_face_value = price;
            row.name = name;
            row.location = location;
            row.lottery_opens = lottery_opens;
            row.lottery_closes = lottery_closes;
            row.reward = reward;
            row.game_type = game_type;
        });

        // Create a row in the tickets table for each ticket, each owned by hokipoki, and with the appropriate for_lotto and face_value
        tickets_index tickets(get_self(), get_first_receiver().value);
        uint64_t ticket_base_id = tickets.cbegin() == tickets.cend() ? 0 : tickets.crbegin()->id + 1;
        for (uint64_t i = 0; i < num_tickets; i++) {
            bool lotto = i < tickets_for_lotto;
            tickets.emplace(get_self(), [ticket_base_id, i, new_id, lotto, price,game_type](auto& row) {
                row.id = ticket_base_id + i;
                row.game_id = new_id;
                row.owner = "hokipoki"_n;
                row.face_value = lotto ? 0 : price;
                row.for_lottery = lotto;
                row.attended = false;
                row.game_type = game_type;
            });
        }
    }

    // This action takes a user and a ticket id. It must be invoked with the active permission of the passed user.
    // If the ticket ID exists, is owned by hokipoki, is not reserved for the ticket lottery, and the user has
    // enough available HTK to purchase the ticket, and the user has allowed the `hokipoki` smart contract to
    // execute inline actions on `eosio.token` with the user's active permission, then the face value of the
    // ticket is transfered to hokipoki, and the owner of the ticket is set to the calling user.
    [[eosio::action]]
    void buy(name user, uint64_t id) {
        // Lots of preliminary checks before we do anything
        require_auth(user);
        check(user != get_self(), "Only students may purchase tickets.");
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto tptr = tickets.find(id);

        check(tptr != tickets.end(), "Ticket does not exist.");
        check(tptr->owner == "hokipoki"_n, "Ticket is already owned.");
        check(!tptr->for_lottery, "Ticket is not available for sale - it is reserved for the lottery.");
        
        uint64_t game_id = tptr->game_id;
        // Users can't buy a ticket if they're already in the lottery for that game
        lottery_entries_index lottery_entries(get_self(), get_first_receiver().value);
        auto userindex = lottery_entries.get_index<"byuser"_n>();
        auto eptr = userindex.lower_bound(user.value);
        while (eptr != userindex.end() && eptr->user == user) {
            check(eptr->game_id != game_id, "You are already in the lottery for that game.");
            eptr++;
        }  

        // auto gameindex = tickets.get_index<"bygame"_n>();
        // auto tptr_2 = gameindex.lower_bound(game_id);
        // while(tptr_2 != gameindex.end() && tptr_2->game_id == game_id){
        //     check(tptr_2->owner != user, "You already own a ticket for that game.");
        //     tptr++;
        // }

        check(tptr->face_value <= std::numeric_limits<int64_t>::max(), "Face value would integer overflow if converted to an int64_t.");
        // If the value of the ticket is positive, transfer that amount of money from the student to hokipoki. 
        // If the user doesn't have enough balance, the transfer fails and the whole action fails with an "Overdrawn balance" error
        if (tptr->face_value != 0) {
            const eosio::asset ass{(int64_t) tptr->face_value, eosio::symbol{"HTK", 2}};
            eosio::action{
                eosio::permission_level{user, "active"_n},
                "eosio.token"_n,
                "transfer"_n,
                std::make_tuple(user, get_self(), ass, std::string{"Ticket Purchase"})
            }.send();
        }
        // Finally, update the owner of the ticket
        tickets.modify(tptr, user, [user](auto& row) {
            row.owner = user;
        });
    }

    // This action takes a user and a ticket id. It must be invoked with the active permission of the passed user.
    // If the ticket ID exists, is owned by the calling user, and the user has allowed the `hokipoki` smart contract
    // to execute inline actions on `eosio.token` with the user's active permission, then the face value of the ticket
    // is transfered from hokipoki to the active user, and the owner of the ticket is set to `hokipoki`.
    [[eosio::action]]
    void sell(name user, uint64_t id) {
        // Preliminary checks....
        require_auth(user);
        check(user != get_self(), "Only students may sell tickets.");
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto tptr = tickets.find(id);
        check(tptr != tickets.end(), "Ticket does not exist.");
        check(tptr->owner == user, "You don't own this ticket.");
        check(!tptr->attended, "This ticket can't be sold, it's already been used to attend the game!");
        check(tptr->face_value <= std::numeric_limits<int64_t>::max(), "Face value would integer overflow if converted to an int64_t");
        int new_face_value = tptr->face_value;
        // If the ticket was free (i.e. a lottery ticket), then don't give the user any money, but update the face value of the ticket
        // to be the initial face ticket vaue for the game. 
        // Otherwise, if the user paid for this ticket, transfer the face value of the ticket back to them.
        if (new_face_value == 0) {
            games_index games(get_self(), get_first_receiver().value);
            auto gptr = games.find(tptr->game_id);
            check(gptr != games.end(), "Ticket is for a game that does not exist.");
            new_face_value = gptr->initial_face_value;
        } else {
            const eosio::asset ass{(int64_t) tptr->face_value, eosio::symbol{"HTK", 2}};
            eosio::action{
                eosio::permission_level{get_self(), "active"_n},
                "eosio.token"_n,
                "transfer"_n,
                std::make_tuple(get_self(), user, ass, std::string{"Ticket Sold"})
            }.send();
        }
        // Finally, set the owner back to hokipoki and update the face value if necessary
        tickets.modify(tptr, user, [new_face_value](auto& row) {
            row.owner = "hokipoki"_n;
            row.face_value = new_face_value;
        });
    }

    // This action takes a user and a game id. It must be invoked with the active permission of the passed user.
    // If the game ID exists, the lottery is still open for that game, and the user has not already entered into the
    // ticket lottery for that game, then the user is entered into the ticket lottery. The four passed random values should be randomly generated. 
    [[eosio::action]]
    void enterlottery(name user, uint64_t game_id, uint64_t r1, uint64_t r2, uint64_t r3, uint64_t r4) {
        // Preliminary checks, make sure the lottery is open, the user is not already in the lottery, etc...
        require_auth(user);
        games_index games(get_self(), get_first_receiver().value);
        auto gptr = games.find(game_id);
        check(gptr != games.end(), "That game does not exist.");
        check(gptr->lottery_open, "The lottery for that game is not open.");
        
        lottery_entries_index lottery_entries(get_self(), get_first_receiver().value);
        auto userindex = lottery_entries.get_index<"byuser"_n>();
        auto eptr = userindex.lower_bound(user.value);
        while (eptr != userindex.end() && eptr->user == user) {
            check(eptr->game_id != game_id, "You are already in the lottery for that game.");
            eptr++;
        }

        // You cannot enter the lottery if you already have a ticket for that game
        tickets_index tickets{get_self(),get_first_receiver().value};
        auto gameindex = tickets.get_index<"bygame"_n>();
        auto tptr = gameindex.lower_bound(game_id);
        while(tptr != gameindex.end() && tptr->game_id == game_id){
            check(tptr->owner != user, "You already own a ticket for that game.");
            tptr++;
        }

        // Find the next available id and put the entry in the table
        uint64_t id = lottery_entries.cbegin() == lottery_entries.cend() ? 0 : lottery_entries.crbegin()->id + 1;
        lottery_entries.emplace(user, [id, user, game_id, r1, r2, r3, r4](auto& row) {
            row.id = id;
            row.user = user;
            row.game_id = game_id;
            row.random_1 = r1;
            row.random_2 = r2;
            row.random_3 = r3;
            row.random_4 = r4;
        });
    }

    // This action takes a user and a game id. It must be invoked with the active permission of the passed user.
    // If the game ID exists, and the user has entered into the ticket lottery for that game, then the user is
    // removed from the ticket lottery.
    [[eosio::action]]
    void leavelottery(name user, uint64_t game_id) {
        // Checks, make sure lottery is still open, etc...
        require_auth(user);
        games_index games(get_self(), get_first_receiver().value);
        auto gptr = games.find(game_id);
        check(gptr != games.end(), "That game does not exist.");
        check(gptr->lottery_open, "The lottery for that game has already ended.");
        lottery_entries_index lottery_entries(get_self(), get_first_receiver().value);
        // Loop through all of that user's lottery entries until we find the one for this game
        auto userindex = lottery_entries.get_index<"byuser"_n>();
        auto eptr = userindex.lower_bound(user.value);
        while (eptr != userindex.end() && eptr->user == user) {
            if (eptr->game_id == game_id) {
                userindex.erase(eptr);
                return;
            }
            eptr++;
        }
        // If we didn't find any entry for that game, bail
        check(false, "You are not in the lottery for that game.");
    }

    // This action takes a game id. It must be invoked with the active permission of `hokipoki`.
    // If the game ID exists, and the lottery is still open for that game, each ticket for that game
    // that is reserved for the lottery is assigned to a random student who has entered the lottery for
    // that game, such that no two tickets are assigned to the same student. The face value for these
    // tickets stays at 0. If there are more tickets than students, then for each remaining ticket,
    // the owner stays as `hokipoki`, but their face value is updated to the price that was specified
    // when the game was created. All tickets for the game are no longer reserved for the lottery.
    [[eosio::action]]
    void executelotto(uint64_t game_id) {
        require_auth(get_self());
        games_index games(get_self(), get_first_receiver().value);
        auto gptr = games.find(game_id);
        check(gptr != games.end(), "Game does not exist.");
        check(gptr->lottery_open, "Lottery is not open for that game.");
        random r{};
        uint64_t price = gptr->initial_face_value;

        // First, make a list of all of the students who entered the lottery, and remove all the entries for this game while we're at it
        std::vector<uint64_t> students{};
        lottery_entries_index lottery_entries(get_self(), get_first_receiver().value);
        auto entries_by_game = lottery_entries.get_index<"bygame"_n>();
        auto eptr = entries_by_game.lower_bound(game_id);
        while (eptr != entries_by_game.end() && eptr->game_id == game_id) {
            students.emplace_back(eptr->user.value);
            r.update(eptr->random_1, eptr->random_2, eptr->random_3, eptr->random_4);
            eptr = entries_by_game.erase(eptr);
        }

        // Now for each ticket, pick a random student, give the ticket to them, and remove them from the set
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto bygame = tickets.get_index<"bygame"_n>();
        for (auto tptr = bygame.lower_bound(game_id); tptr != bygame.end() && tptr->game_id == game_id; tptr++) {
            if (!tptr->for_lottery) continue;
            bygame.modify(tptr, get_self(), [](auto& row) {
                row.for_lottery = false;
            });
            if (students.size() > 0) {
                uint64_t idx = r.get() % students.size();
                auto owner = eosio::name{students.at(idx)};
                bygame.modify(tptr, get_self(), [owner](auto& row) {
                    row.owner = owner;
                });
                require_recipient(owner); // ensures that it appears in the action history for that user, so they will see that they got a ticket on their account page
                students.erase(students.begin() + idx);
            } else {
                bygame.modify(tptr, get_self(), [price](auto& row) {
                    row.face_value = price;
                });
            }
        }

        // Mark lottery as no longer open
        games.modify(gptr, get_self(), [](auto& row) {
            row.lottery_open = false;
        });
    }

    // This action takes a game id. It must be invoked with the active permission of `hokipoki`.
    // If the game ID exists, and the lottery is not yet open for that game, it marks the lottery as
    // being open, allowing students to enter themselves into the lottery.
    [[eosio::action]]
    void openlottery(uint64_t game_id) {
        require_auth(get_self());
        games_index games(get_self(), get_first_receiver().value);
        auto gptr = games.find(game_id);
        check(gptr != games.end(), "That game does not exist.");
        check(!gptr->lottery_open, "The lottery for that game is already open.");
        games.modify(gptr, get_self(), [](auto& row) {
            row.lottery_open = true;
        });
    }

    // This action takes a name, and adds it to the list of users who use HokieTickets. This list
    // is used by the administrator on the website to view students balances and tickets. Must
    // be run with the active permsision of `hokipoki`
    [[eosio::action]]
    void adduser(name user) {
        require_auth(get_self());
        users_index users(get_self(), get_first_receiver().value);
        users.emplace(get_self(), [user](auto& row) {
            row.user = user;
        });
    }

    // This action takes a ticket id, and it marks the ticket has having been used to attend a game,
    // and transfers the game's reward amount to the owner of the ticket. Must be run with `hokipoki`'s active permission
    [[eosio::action]]
    void rewarduser(uint64_t ticket_id) {
        require_auth(get_self());
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto tptr = tickets.find(ticket_id);
        check(tptr != tickets.end(), "Ticket does not exist");
        check(!tptr->attended, "Ticket is already used");
        tickets.modify(tptr, tptr->owner, [](auto& row) {
            row.attended = true;
        });
        require_recipient(tptr->owner); // Notifies the user in their transaction history that they were rewarded
        // Figure out how many HTK to reward the user with
        games_index games(get_self(), get_first_receiver().value);
        auto gptr = games.find(tptr->game_id);
        check(gptr != games.end(), "Game does not exist");
        const eosio::asset ass{(int64_t) gptr->reward, eosio::symbol{"HTK", 2}};
        // give them the money
        eosio::action{
            eosio::permission_level{get_self(), "active"_n},
            "eosio.token"_n,
            "transfer"_n,
            std::make_tuple(get_self(), tptr->owner, ass, std::string{"Reward"})
        }.send();
    }

    // This action takes a ticket id, a starting bid amount, and an end date in the form YYYYMMDDHHmm.
    // The ticket must exist, the starting bid amount must be greater than or equal to the face value
    // of the ticket, and the end date must be after the current time but before 11:59 PM on the night
    // before the game. There must not be an open auction on the ticket already, the ticket must not
    // have already been used to attend a game, and the action requires the active permissions of the
    // ticket owner. The action creates an auction with the current owner set as the highest bidder
    // and the highest bid set as the opening bid.
    [[eosio::action]]
    void creatauction(uint64_t ticket_id, uint64_t initial_bid, uint64_t end_date) {
        // Like a billion preliminary checks
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto tptr = tickets.find(ticket_id);
        check(tptr != tickets.end(), "Ticket does not exist");
        auto owner = tptr->owner;
        require_auth(owner);
        check(!tptr->attended, "This ticket can't be sold, it's already been used to attend the game!");
        auctions_index auctions(get_self(), get_first_receiver().value);
        auto game_id = tptr->game_id;
        auto aptr = auctions.find(ticket_id);
        check(aptr == auctions.end(), "There is already an auction in progress for that ticket");
        games_index games(get_self(), get_first_receiver().value);
        auto gptr = games.find(game_id);
        check(gptr != games.end(), "Game does not exist");
        check(initial_bid >= tptr->face_value, "Initial bid must be greater than or equal to the face value of the ticket!");
        check(initial_bid >= gptr->initial_face_value, "Initial bid must be greater than or equal to the face value of the ticket!");
        uint64_t now = current_datetime();
        check(now < end_date, "End date is in the past!");
        check((end_date/10000) < (gptr->date/10000), "End date is on or after the day of the game! Auctions must end before the day of the game.");
        // Place the auction in the table, with the top bidder set to the owner and the highest bid set to the initial bid
        auctions.emplace(get_self(), [ticket_id, game_id, initial_bid, end_date, owner](auto& row) {
            row.ticket_id = ticket_id;
            row.game_id = game_id;
            row.highest_bid = initial_bid;
            row.top_bidder = owner;
            row.auction_owner = owner;
            row.end_date = end_date;
        });
    }

    // This action takes an auction id, a user, and a bid amount. The action requires the active
    // permission of the passed user. The auction must exist, the auction end date must still be
    // in the future, and the passed bid amount must be at least 1.00 HTK greater than the current
    // highest bid. The user must not be the creator of the auction. If the auction has had at least
    // one bid on it, the former top bidder is refunded their bid, and the passed user has their bid
    // amount transferred to `hokipoki`. If they don't have enough money to make the bid, the action
    // fails with an error. The top bidder and highest bid on the auction are updated to be the passed
    // user and bid amount. Finally, the end date of the auction is extended by 1 minute, to a maximum
    // end date of 11:59 on the night before the game.
    [[eosio::action]]
    void bid(uint64_t ticket_id, name user, uint64_t bid) {
        // Checks
        require_auth(user);
        // TODO check that the user is not the current top bidder on the ticket. Doesn't do any harm though.
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto tptr = tickets.find(ticket_id);
        check(tptr != tickets.end(), "That ticket does not exist");
        check(tptr->owner != user, "You cannot bid in your own auction!");
        auctions_index auctions(get_self(), get_first_receiver().value);
        auto aptr = auctions.find(ticket_id);
        check(aptr != auctions.end(), "There is no ongoing auction for that ticket");
        check(aptr->end_date >= current_datetime(), "That auction has already ended");
        check(aptr->highest_bid + 100 <= bid, "You must bid at least 1.00 HTK greater than the previous highest bid");
        // If there was a previous bid on the auction, refund their money
        if (aptr->top_bidder != tptr->owner) {
            const eosio::asset ass{(int64_t) aptr->highest_bid, eosio::symbol{"HTK", 2}};
            eosio::action{
                eosio::permission_level{get_self(), "active"_n},
                "eosio.token"_n,
                "transfer"_n,
                std::make_tuple(get_self(), aptr->top_bidder, ass, std::string{"Outbid in an auction - bid money returned"})
            }.send();
        }
        // Transfer out the bid
        const eosio::asset ass{(int64_t) bid, eosio::symbol{"HTK", 2}};
        eosio::action{
            eosio::permission_level{user, "active"_n},
            "eosio.token"_n,
            "transfer"_n,
            std::make_tuple(user, get_self(), ass, std::string{"Bid on an auction"})
        }.send();
        // Set the top bidder, etc.. on the auction
        auctions.modify(aptr, get_self(), [user, bid](auto& row) {
            row.top_bidder = user;
            row.highest_bid = bid;
        });
        // Advance the end time by 1 minute if it wouldn't push it over to the next day
        games_index games(get_self(), get_first_receiver().value);
        auto gptr = games.find(aptr->game_id);
        check(gptr != games.end(), "Game does not exist");
        auto next_end_date = datetime_add_1min(aptr->end_date);
        if (gptr->date / 10000 > next_end_date / 10000) {
            auctions.modify(aptr, get_self(), [next_end_date](auto& row) {
                row.end_date = next_end_date;
            });
        }
    }

    // Finds an auction and its associated ticket by auction ID
    // Assuming it's being used to execute the auction, it checks that the auction's end date has passed
    auto find_auction_for_exec(uint64_t auction_id) {
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto tptr = tickets.find(auction_id);
        check(tptr != tickets.end(), "Ticket does not exist");
        auctions_index auctions(get_self(), get_first_receiver().value);
        auto aptr = auctions.find(auction_id);
        check(aptr != auctions.end(), "There is no auction in progress for that ticket.");
        check(aptr->end_date < current_datetime(), "The auction cannot be executed, it is still active!");
        return std::pair<decltype(aptr), decltype(tptr)>{aptr, tptr};
    }

    // This action takes an auction id, and checks that the auction exists, and that the end date has passed.
    // If so, it transfers ownership of the ticket being auctioned to the highest bidder, and gives the
    // top bid's value from `hokipoki` to the former owner. Then, it deletes the auction. Requires the
    // active permission of the top bidder. If nobody bid on the auction before the end date, the auction
    // is just deleted.
    [[eosio::action]]
    void execauction1(uint64_t ticket_id) {
        auto aptr = find_auction_for_exec(ticket_id).first;
        // BIDDER
        require_auth(aptr->top_bidder);
        exec_auction(ticket_id);
    }

    // This action takes an auction id, and checks that the auction exists, and that the end date has passed.
    // If so, it transfers ownership of the ticket being auctioned to the highest bidder, and gives the
    // top bid's value from `hokipoki` to the former owner. Then, it deletes the auction. Requires the
    // active permission of the creator of the auction. If nobody bid on the auction before the end date,
    // the auction is just deleted.
    [[eosio::action]]
    void execauction2(uint64_t ticket_id) {
        auto [aptr, tptr] = find_auction_for_exec(ticket_id);
        // OWNER
        require_auth(tptr->owner);
        exec_auction(ticket_id);
    }

    // Helper function for execauction1 and execauction2. Transfers the ticket ownership and highest bid to
    // the top bidder and previous owner, respectively. If nobody had bid on the ticket, just deletes it
    void exec_auction(uint64_t ticket_id) {
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto tptr = tickets.find(ticket_id);
        auctions_index auctions(get_self(), get_first_receiver().value);
        auto aptr = auctions.find(ticket_id);
        check(tptr != tickets.end() && aptr != auctions.end(), "Should have been already verified before calling this function");
        // If nobody bid on the auction, just delete it
        if (aptr->top_bidder == tptr->owner) {
            auctions.erase(aptr);
            return;
        }
        require_recipient(aptr->top_bidder); // not sure what I'm gonna do with this just yet
        // Transfer the money to the previous owner from `hokipoki`
        const eosio::asset ass{(int64_t) aptr->highest_bid, eosio::symbol{"HTK", 2}};
        eosio::action{
            eosio::permission_level{get_self(), "active"_n},
            "eosio.token"_n,
            "transfer"_n,
            std::make_tuple(get_self(), tptr->owner, ass, std::string{"Auction finished"})
        }.send();
        // Transfer ownership of the ticket
        auto new_owner = aptr->top_bidder;
        tickets.modify(tptr, get_self(), [new_owner](auto& row) {
            row.owner = new_owner;
        });
        auctions.erase(aptr);
    }


    // This action takes a game id, and checks that it is currently the day of the game.
    // If so, it finds all auctions for that game and executes them. We know that the auctions
    // must already be over, because you cannot have an auction end date that is on or after
    // the day of the game, and bidding will not extend the end date of an auction past 11:59
    // of the night before the game. Executing an auction simply transfers the ticket to the
    // highest bidder, and the highest bid to the previous owner. If nobody bid on the ticket,
    // the auction is deleted. Auctions could have finished and been executed before this action
    // is called, this is simply a cleanup action to transfer tickets to students who won an
    // auction but forgot to claim their ticket. Students do not have to wait for this action
    // to be called to execute their auction, but they do have to wait for the end date of the
    // auction. This action requries the active permission of `hokipoki`
    [[eosio::action]]
    void aucexecall(uint64_t game_id) {
        // Lots f checks
        require_auth(get_self());
        games_index games(get_self(), get_first_receiver().value);
        auto gptr = games.find(game_id);
        check(gptr != games.end(), "Game does not exist");
        check((current_datetime()/10000) >= (gptr->date/10000), "It is not yet the day of the game");
        tickets_index tickets(get_self(), get_first_receiver().value);
        // Just loop through every ticket for that game, and check if it has an auction on it
        auto bygame = tickets.get_index<"bygame"_n>();
        auctions_index auctions(get_self(), get_first_receiver().value);
        for (auto tptr = bygame.lower_bound(game_id); tptr != bygame.end() && tptr->game_id == game_id; tptr++) {
            auto aptr = auctions.find(tptr->id);
            if (aptr != auctions.end()) {
                exec_auction(tptr->id);
            }
        }
    }

    // This action takes an auction ID, and requires the active permission of the creator of that auction.
    // If nobody has bid on the auction yet, it deletes the auction. If someone has already bid on the
    // auction, it fails with an error.
    [[eosio::action]]
    void cancelauctn(uint64_t auction_id) {
        // this is about 99% sanity checks
        tickets_index tickets(get_self(), get_first_receiver().value);
        auto tptr = tickets.find(auction_id);
        check(tptr != tickets.end(), "That ticket does not exist");
        require_auth(tptr->owner);
        auctions_index auctions(get_self(), get_first_receiver().value);
        auto aptr = auctions.find(auction_id);
        check(aptr != auctions.end(), "There is no active auction on that ticket");
        check(aptr->top_bidder == tptr->owner, "The auction can't be cancelled, there are already active bids on it.");
        // finally erase the auction
        auctions.erase(aptr);
    }

    // Debug action to reset everything. This action must be invoked with the active permission of `hokipoki`.
    // All games, tickets, lottery entries and auctions are deleted.
    [[eosio::action]]
    void reset() {
        require_auth(get_self());
        lottery_entries_index lottery_entries(get_self(), get_first_receiver().value);
        for (auto iter = lottery_entries.begin(); iter != lottery_entries.end(); iter = lottery_entries.erase(iter));
        tickets_index tickets(get_self(), get_first_receiver().value);
        for (auto iter = tickets.begin(); iter != tickets.end(); iter = tickets.erase(iter));
        games_index games(get_self(), get_first_receiver().value);
        for (auto iter = games.begin(); iter != games.end(); iter = games.erase(iter));
        auctions_index auctions(get_self(), get_first_receiver().value);
        for (auto iter = auctions.begin(); iter != auctions.end(); iter = auctions.erase(iter));
    }
private:
    struct [[eosio::table]] game {
        uint64_t id;
        uint64_t date;
        uint64_t number;
        bool lottery_open;
        uint64_t initial_face_value;
        std::string name;
        std::string location;
        uint64_t lottery_opens;
        uint64_t lottery_closes;
        uint64_t reward;
        uint64_t game_type;
        uint64_t primary_key() const { return id; }
        uint64_t get_secondary_1() const { return date; }
    };

    struct [[eosio::table]] ticket {
        uint64_t id;
        uint64_t game_id;
        name owner;
        uint64_t face_value; // in HTK
        bool for_lottery;
        bool attended;
        uint64_t game_type;
        uint64_t primary_key() const { return id; }
        uint64_t get_secondary_1() const { return game_id; }
    };

    struct [[eosio::table]] lottery_entry {
        uint64_t id;
        name user;
        uint64_t game_id;
        uint64_t random_1;
        uint64_t random_2;
        uint64_t random_3;
        uint64_t random_4;
        uint64_t primary_key() const { return id; }
        uint64_t get_secondary_1() const { return user.value; }
        uint64_t get_secondary_2() const { return game_id; }
    };

    struct [[eosio::table]] user {
        name user;
        uint64_t primary_key() const { return user.value; }
    };

    struct [[eosio::table]] auction {
        uint64_t ticket_id;
        uint64_t game_id;
        name auction_owner; // should always be equal to the owner of the ticket
        uint64_t highest_bid;
        name top_bidder;
        uint64_t end_date;
        uint64_t primary_key() const { return ticket_id; }
        uint64_t get_secondary_1() const { return game_id; }
        uint64_t get_secondary_2() const { return top_bidder.value; }
    };

    typedef eosio::multi_index<
        "games"_n,
        game,
        eosio::indexed_by<"bydate"_n, eosio::const_mem_fun<game, uint64_t, &game::get_secondary_1>>
    > games_index;

    typedef eosio::multi_index<
        "tickets"_n,
        ticket,
        eosio::indexed_by<"bygame"_n, eosio::const_mem_fun<ticket, uint64_t, &ticket::get_secondary_1>>
    > tickets_index;

    typedef eosio::multi_index<
        "lottoentries"_n /* exactly 13 chars */,
        lottery_entry,
        eosio::indexed_by<"byuser"_n, eosio::const_mem_fun<lottery_entry, uint64_t, &lottery_entry::get_secondary_1>>,
        eosio::indexed_by<"bygame"_n, eosio::const_mem_fun<lottery_entry, uint64_t, &lottery_entry::get_secondary_2>>
    > lottery_entries_index;

    typedef eosio::multi_index<
        "users"_n,
        user
    > users_index;

    typedef eosio::multi_index<
        "auctions"_n,
        auction,
        eosio::indexed_by<"bygame"_n, eosio::const_mem_fun<auction, uint64_t, &auction::get_secondary_1>>,
        eosio::indexed_by<"bytop"_n, eosio::const_mem_fun<auction, uint64_t, &auction::get_secondary_2>>
    > auctions_index;
};
