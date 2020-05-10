cleos() {
	echo
	tput bold
	tput setaf 46
	echo "                  " cleos $*
	tput sgr0
	echo
	/usr/bin/env cleos "$@"
}

create_game() {
	cleos push action hokipoki creategame "["$1", "$2", "$3", "$4", \""$5"\", \""$6"\", "$7", "$8", "$9","$10"]" -p hokipoki@active
}

buy() {
	cleos push action hokipoki buy "[\""$1"\", "$2"]" -p "$1"@active
}
sell() {
	cleos push action hokipoki sell "[\""$1"\", "$2"]" -p "$1"@active
}

enter_lottery() {
	r1=$(head -c 8 /dev/urandom | xxd -p)
	r2=$(head -c 8 /dev/urandom | xxd -p)
	r3=$(head -c 8 /dev/urandom | xxd -p)
	r4=$(head -c 8 /dev/urandom | xxd -p)
	cleos push action hokipoki enterlottery "[\""$1"\", "$2", 0x"$r1", 0x"$r2", 0x"$r3", 0x"$r4"]" -p "$1"@active
}

leave_lottery() {
	cleos push action hokipoki leavelottery "[\""$1"\", "$2"]" -p "$1"@active
}

execute_lottery() {
	cleos push action hokipoki executelotto "["$1"]" -p hokipoki@active
}

open_lottery() {
	cleos push action hokipoki openlottery "["$1"]" -p hokipoki@active
}

create_auction() {
	cleos push action hokipoki creatauction "["$2", "$3", "$4"]" -p "$1"@active
}

bid() {
	cleos push action hokipoki bid "["$1", \""$2"\", "$3"]" -p "$2"@active
}

execute_auction_winner() {
	cleos push action hokipoki execauction1 "["$2"]" -p "$1"@active
}

execute_auction_owner() {
	cleos push action hokipoki execauction2 "["$2"]" -p "$1"@active
}

execute_all_auctions() {
	cleos push action hokipoki aucexecall "["$1"]" -p hokipoki@active
}

cancel_auction() {
	cleos push action hokipoki cancelauctn "["$2"]" -p "$1"@active
}


reset() {
	cleos push action hokipoki reset '[]' -p hokipoki@active
}

games() {
	if test -z "$1"; then
		cleos get table -l 9999 hokipoki hokipoki games
	else
		cleos get table -l 9999 hokipoki hokipoki games -L $1 -U $1
	fi
}
lottery_entries() {
	cleos get table -l 9999 hokipoki hokipoki lottoentries
}
tickets() {
	if test -z "$1"; then
		cleos get table -l 9999 hokipoki hokipoki tickets
	else
		cleos get table -l 9999 hokipoki hokipoki tickets -L $1 -U $1
	fi

}
auctions() {
	if test -z "$1"; then
		cleos get table -l 9999 hokipoki hokipoki auctions
	else
		cleos get table -l 9999 hokipoki hokipoki auctions -L $1 -U $1
	fi
}

balance() {
	cleos get currency balance eosio.token $1 HTK
}

transfer() {
	htk=$3
	cleos push action eosio.token transfer "[\""$1"\", \""$2"\", \""$htk\ HTK"\", \""$4"\"]" -p "$1"@active
}
