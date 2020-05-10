function cleos
	echo
	tput bold
	tput setaf 46
	echo "                  " cleos $argv
	tput sgr0
	echo
	/usr/bin/env cleos $argv
end

function create_game 
	cleos push action hokipoki creategame "["$argv[1]", "$argv[2]", "$argv[3]", "$argv[4]", \""$argv[5]"\", \""$argv[6]"\", "$argv[7]", "$argv[8]","$argv[9]", "$argv[10]"]" -p hokipoki@active
end

function buy 
	cleos push action hokipoki buy "[\""$argv[1]"\", "$argv[2]"]" -p "$argv[1]"@active
end
function sell 
	cleos push action hokipoki sell "[\""$argv[1]"\", "$argv[2]"]" -p "$argv[1]"@active
end

function enter_lottery
	set r1 (head -c 8 /dev/urandom | xxd -p)
	set r2 (head -c 8 /dev/urandom | xxd -p)
	set r3 (head -c 8 /dev/urandom | xxd -p)
	set r4 (head -c 8 /dev/urandom | xxd -p)
	cleos push action hokipoki enterlottery "[\""$argv[1]"\", "$argv[2]", 0x"$r1", 0x"$r2", 0x"$r3", 0x"$r4"]" -p "$argv[1]"@active
end

function leave_lottery
	cleos push action hokipoki leavelottery "[\""$argv[1]"\", "$argv[2]"]" -p "$argv[1]"@active
end

function execute_lottery
	cleos push action hokipoki executelotto "["$argv[1]"]" -p hokipoki@active
end

function open_lottery
	cleos push action hokipoki openlottery "["$argv[1]"]" -p hokipoki@active
end

function create_auction
	cleos push action hokipoki creatauction "["$argv[2]", "$argv[3]", "$argv[4]"]" -p "$argv[1]"@active
end

function bid
	cleos push action hokipoki bid "["$argv[1]", \""$argv[2]"\", "$argv[3]"]" -p "$argv[2]"@active
end

function execute_auction_winner
	cleos push action hokipoki execauction1 "["$argv[2]"]" -p "$argv[1]"@active
end

function execute_auction_owner
	cleos push action hokipoki execauction2 "["$argv[2]"]" -p "$argv[1]"@active
end

function execute_all_auctions
	cleos push action hokipoki aucexecall "["$argv[1]"]" -p hokipoki@active
end

function cancel_auction
	echo cleos push action hokipoki cancelauctn "["$argv[2]"]" -p "$argv[1]"@active
	cleos push action hokipoki cancelauctn "["$argv[2]"]" -p "$argv[1]"@active
end


function reset
	cleos push action hokipoki reset '[]' -p hokipoki@active
end

function games
	if test -z "$argv[1]"
		cleos get table -l -1 hokipoki hokipoki games
	else
		cleos get table -l -1 hokipoki hokipoki games -L $argv[1] -U $argv[1]
	end
end
function lottery_entries
	cleos get table -l -1 hokipoki hokipoki lottoentries
end
function tickets
	if test -z "$argv[1]"
		cleos get table -l -1 hokipoki hokipoki tickets
	else
		cleos get table -l -1 hokipoki hokipoki tickets -L $argv[1] -U $argv[1]
	end
end
function auctions
	if test -z "$argv[1]"
		cleos get table -l -1 hokipoki hokipoki auctions
	else
		cleos get table -l -1 hokipoki hokipoki auctions -L $argv[1] -U $argv[1]
	end
end

function balance
	cleos get currency balance eosio.token $argv[1] HTK
end

function transfer
	set htk $argv[3]
	cleos push action eosio.token transfer "[\""$argv[1]"\", \""$argv[2]"\", \""$htk\ HTK"\", \""$argv[4]"\"]" -p "$argv[1]"@active
end
