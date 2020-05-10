#!/usr/bin/env python2
import json, subprocess, collections, random, re, datetime, time, struct, qrcode, io, base64
cleos = ["cleos", "--no-auto-keosd", "-u", "http://127.0.0.1:8888", "--wallet-url", "unix:///home/ubuntu/eosio-wallet/keosd.sock"]
KEY = "EOS7J1tYpCHkCCvi5DwYXkJMRKRzK9XAUVvMC7PnrcucNXS6ZuMC1"
KEYWORDS = {"from", "except", "if", "else", "elif", "return"}


#########################################################
## Restart mako-server every time you change this file ##
#########################################################

# EosioError encodes an error returned from cleos. It simply holds
# a string called "output" containing the error message
class EosioError(Exception):
    # TODO - more post-processing, parse out exact error message, etc...
    def __init__(self, output):
	self.output = output
    def __str__(self):
	return "EosioError(output={})".format(self.output)

# Symbolizes names on an object returned from json decoding the output of cleos
# So for example, given a dict x returned from cleos containing {"a": "b"},
# if _try_symbolize_names is called on x, it returns a new object, which
# still allows x["a"] for accesses, but also allows x.a for accesses, making
# the code look prettier.
# It is recursive, so given a list of dictionaries or various arbitrarily nested data structures,
# it will still transform every dict it can find, and leave other values untouched
def _try_symbolize_names(l):
	# list? Just try and recurse on everything in it
	if isinstance(l, list): return [_try_symbolize_names(i) for i in l]
	# Not a list or a dict? Just return it and move on
	if not isinstance(l, dict): return l
	# Ok, now we have a dict.
	# Recurse on all the values, modifying the keys to not be KEYWORDS by adding an underscore if necessary
	l = {k if k not in KEYWORDS else k + "_": _try_symbolize_names(v) for k, v in l.items()} # recurse
	# Make a new class with the keys of the dict as its fields
	cls = collections.namedtuple("t", l.keys())
	# cls.__getitem__ is NOT a bound method of cls, it's a class method.
	old_getitem = cls.__getitem__
	# x.a accesses x[0] internally, so make sure that x[0] doesn't break, but also allow x["a"] to access
	# our original dict
	cls.__getitem__ = lambda self, k: l[k] if isinstance(k, str) else old_getitem(self, k)
	# construct this magical class and hope for the best
	return cls(**l)

# Attempts to do the opposite of _try_symbolize_names, because calling json.dumps on a namedtuple
# treats it like an actual tuple, not a dict.
def _try_desymbolize_names(l):
	if isinstance(l, list): return [_try_desymbolize_names(i) for i in l]
	if isinstance(l, dict): return {k: _try_desymbolize_names(v) for k, v in l.items()}
	if not (isinstance(l, tuple) and not type(l) == tuple): return l
	return l.__dict__


# Attempts to safely execute a cleos command, and record and decode the output, or record and throw the error
# message in an EosioError if the command failed
def _exec(l, json_decode = True):
	if not isinstance(l, list): raise TypeError("Invalid object passed to libgoblin._exec(): {}".format(str))
	proc = subprocess.Popen(cleos + l, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	stdout, stderr = proc.communicate()
	stdout = stdout.decode("utf-8")
	stderr = stderr.decode("utf-8")
	# Check for success
	if proc.returncode != 0:
		raise EosioError(stderr)
	# try to decode if they wanted us to
	if json_decode:
		try:
			return _try_symbolize_names(json.loads(stdout))
		except Exception as e:
			print(stdout)
			raise e
	return stdout

# Attempts to run and return a cleos command, extracting the error message from the cleos error output if possible
def wrap_exec(with_result, *args, **kwargs):
    try:
	if with_result:
	    return with_result(_exec(*args, **kwargs))
	else:
	    return _exec(*args, **kwargs)
    except EosioError as e:
	try:
	    # Try and pull out the actual error message, like "That ticket is reserved for the lottery", from the output
	    # (if possible)
	    return json.dumps({"error": re.sub(u'\u001b\[.*?[@-~]', '', e.output.split("message: ")[1].replace("pending console output:", "").replace("\n",""))})
	except:
	    return json.dumps({"error": e.output})

# Gets info about the current eosio installation, such as the version number and the last block number
# Used to be used on index.pyhtml
def get_info():
	return _exec(["get", "info"])

# Gets a user's account from the blockchain
def get_user_info(user):
	return _exec(["get", "account", "-j", user])

# Checks to see if the passed user has allowed hokipoki to execute actions on their behalf
def check_permissions_grant(user):
	ui = get_user_info(user)
	ps = [x for x in ui.permissions if x.perm_name == "active"]
	if len(ps) != 1: return False
	return any(f.permission.actor == "hokipoki" and f.permission.permission == "eosio.code" for f in ps[0].required_auth.accounts)


# Gets the hokietoken balance of a particular user into a float
def get_balance(user):
	bal = _exec(["get", "currency", "balance", "eosio.token", user, "HTK"], False)
	bal = bal.strip()
	# if they have never had any HTK it prints an empty string
	if len(bal) == 0:
		return 0
	# bal looks like "1000000000.00 HTK"
	return float(bal.split()[0])

# Gets statistics about the HTK currency, such as the current amount of HTK in circulation (including the hokipoki account)
def get_currency_stats():
	return _exec(["get", "currency", "stats", "eosio.token", "HTK"]).HTK

# Given an amount of hokietokens, either as a string (like "1,234.56 HTK") or a number (like 1234.56)
# returns a human-readable string, such as "1,234.56 HTK"
def format_htk(c):
	return "{:,.2f} HTK".format(float(str(c).replace(",", "").split()[0]))

# Repeats the given command until there are no more rows remaining. So for example, 
# `cleos get table hokipoki hokipoki tickets` may only return the first 10 tickets, with "more"
# set to true in the output, indicating that there are more rows
# This function runs the command until it has all the rows
def repeat_exec(*args, **kwargs):
    rows = []
    r = _exec(*args, **kwargs)
    rows += r.rows
    while r.more:
	r = _exec(*args, **kwargs)
	rows += r.rows
    return rows

# Gets all entries in the passed table
def get_raw_table(table):
	return repeat_exec(["get", "table", "-l", "9999", "hokipoki", "hokipoki", table])

# Lists the tables declared by the hokipoki abi. Used to be used in a debug page
# for viewing raw tables, since removed
def get_declared_tables():
	return [t.name for t in _exec(["get", "abi", "hokipoki"]).tables]

# Creates a new keypair, then a new user with their active permission key set to that keypair
# (but their owner key set to KEY), and the required code grant for `hokipoki` to be able to run
# actions on their behalf. Finally, it runs the `adduser` action on `hokipoki` to add the new
# user to the list of users in the table. Returns the user's generated private and public keys,
# so that the administrator creating the account can give them to the user
def create_account(user):
	keymat = list(map(lambda x: x.split(),_exec(["create", "key", "--to-console"], False).split("\n")))
	priv = keymat[0][2]
	pub = keymat[1][2]
	import_key(priv)
	_exec(["create", "account", "eosio", user, KEY], False)
	_exec(["set", "account", "permission", user, "active",
		'{"threshold":1, "keys":[{"key":"'+pub+'", "weight":1}], "accounts": [{"permission":{"actor":"hokipoki","permission":"eosio.code"},"weight":1}]}',
		"owner", "-p", user + "@owner"], False)
	_exec(["push", "action", "hokipoki", "adduser", json.dumps([user]), "-p", "hokipoki@active"], False)
	return pub, priv

# Used by debug_format to determine if it should recurse onto this object, or just print its string representation
def _debug_is_complex(t):
	return (isinstance(t, tuple) and type(t) != tuple) or isinstance(t, list) or "\n" in str(t)

# For debugging only. Put the output of debug_format() in a <pre> tag, or on the console
# Attempts to print out the complex data structures used by eosio after they have been put through
# _try_symbolize_names
# For example, print(debug_format(get_user_info("nilesr").permissions)) prints
# - perm_name: active
#   required_auth:
#       threshold: 1
#       keys:
#             - key: EOS7KVoEcPrZtjFdNvCkAfehruSSCVcQQktgJ5aP35vGoLtqtWUk5
#               weight: 1
#       accounts:
#             - weight: 1
#               permission:
#                   actor: hokipoki
#                   permission: eosio.code
#       waits:
#
#   parent: owner
# - perm_name: owner
#   required_auth:
#       threshold: 1
#       keys:
#             - key: EOS7J1tYpCHkCCvi5DwYXkJMRKRzK9XAUVvMC7PnrcucNXS6ZuMC1
#               weight: 1
#       accounts:
#
#       waits:
#
#   parent: 

def debug_format(t, depth=0, dash=False):
	pad = "    " * depth
	firstpad = pad[:-2] + "- " if dash else pad
	if isinstance(t, tuple) and type(t) != tuple:
		l = [k + ":" + ("\n" + debug_format(v, depth+1, False) if _debug_is_complex(v) else " " + str(v)) for k, v in t.__dict__.items()]
		return "\n".join([(firstpad if i == 0 else pad) + x for i, x in enumerate(l)])
	if isinstance(t, list):
		return "\n".join([debug_format(x, depth+1, True) for x in t])
	return firstpad + str(t)


# USER ACTIONS
# Given a user and a game id, pulls the first non-lottery ticket for that game owned by `hokipoki` and
# buys it on behalf of the user on the blockchain.
def buy(user, game_id):
    ticket_id = -1
    filtered = filter(lambda a:a["for_lottery"]==0 and a["owner"]=="hokipoki",get_tickets_for_game(game_id))
    if len(filtered) > 0:
	ticket_id= filtered[0]["id"]
    #TODO: Error if ticket is not available
    def with_result(r):
	return json.dumps({"balance":get_balance(user)})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "buy", json.dumps([user, ticket_id]), "-p", user + "@active", "-j"])

# Sells the given ticket id back to the university, assuming it is owned by `user`
def sell(user, ticket_id):
    def with_result(r):
	return json.dumps({"balance":get_balance(user)})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "sell", json.dumps([user, ticket_id]), "-p", user + "@active", "-j"])

def enter_lottery(user, game_id):
    r1 = random.randint(0, 2 ** 64 - 1)
    r2 = random.randint(0, 2 ** 64 - 1)
    r3 = random.randint(0, 2 ** 64 - 1)
    r4 = random.randint(0, 2 ** 64 - 1)
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "enterlottery", json.dumps([user, game_id, r1, r2, r3, r4]), "-p", user + "@active", "-j"])

def leave_lottery(user, game_id):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "leavelottery", json.dumps([user, game_id]), "-p", user + "@active", "-j"])

def create_auction(user, ticket_id, initial_bid, end_date):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "creatauction", json.dumps([ticket_id, initial_bid, end_date]), "-p", user + "@active", "-j"])

def bid(ticket_id, user, bid):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "bid", json.dumps([ticket_id, user, bid]), "-p", user + "@active", "-j"])

def execute_auction_winner(ticket_id, user):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "execauction1", json.dumps([ticket_id]), "-p", user + "@active", "-j"])

def execute_auction_owner(ticket_id, user):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "execauction2", json.dumps([ticket_id]), "-p", user + "@active", "-j"])

def cancel_auction(ticket_id, user):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "cancelauctn", json.dumps([ticket_id]), "-p", user + "@active", "-j"])


# ADMIN ACTIONS
def execute_lottery(game_id):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "executelotto", json.dumps([game_id]), "-p", "hokipoki@active", "-j"])

def open_lottery(game_id):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "openlottery", json.dumps([game_id]), "-p", "hokipoki@active", "-j"])

def create_game(day, num_tickets, tickets_for_lotto, price, name, location, lottery_opens, lottery_closes, reward, game_type):
	return wrap_exec(False, ["push", "action", "hokipoki", "creategame", json.dumps([day, num_tickets, tickets_for_lotto, price, name, location, lottery_opens, lottery_closes, reward, game_type]), "-p", "hokipoki@active", "-j"])

def execute_all_auctions(game_id):
    def with_result(r):
	return json.dumps({"success":"Success!"})
    return wrap_exec(with_result, ["push", "action", "hokipoki", "aucexecall", json.dumps([game_id]), "-p", "hokipoki@active", "-j"])

def reset():
	return wrap_exec(False, ["push", "action", "hokipoki", "reset", json.dumps([]), "-p", "hokipoki@active", "-j"])


# Transfers the given amount of money from `hokipoki` to the passed user, with the memo set to the passed message
def transfer(user, amount, message):
    amount_str = str(amount)
    if "." not in amount_str:
	amount_str = amount_str + ".00 HTK"
    elif len(amount_str.split(".")[1]) != 2:
	amount_str = amount_str + "0 HTK"
    else:
	amount_str = amount_str + " HTK"
    def with_result(r):
	return json.dumps({"balance":get_balance(user)})
    return wrap_exec(with_result, ["push", "action", "eosio.token", "transfer", json.dumps(["hokipoki", user, amount_str, message]), "-p", "hokipoki@active", "-j"])

#REQUESTS RECIEVED FROM RACHEL

#returns all tickets that a user owns
def user_tickets(user):
	return filter(lambda a:a["owner"]==user,get_raw_table("tickets"))

#gives you everything, but you can easily index the list for what you want
def filtered_date_games(date):
	filtered = filter(lambda a:a["date"]>=date,get_raw_table("games"))
	return sorted(filtered,key=lambda a:a["date"])

# Returns None if no game exists
# Returns game json object if game with id==game_id exists
def get_game(game_id):
	try:
		return repeat_exec(["get", "table", "hokipoki", "hokipoki", "games", "-l", "9999", "-L", str(game_id), "-U", str(game_id)])[0]
	except:
		return None

def get_ticket(ticket_id):
	try:
		return repeat_exec(["get", "table", "hokipoki", "hokipoki", "tickets", "-l", "9999", "-L", str(ticket_id), "-U", str(ticket_id)])[0]
	except:
		return None

def get_auction(ticket_id):
	try:
		return repeat_exec(["get", "table", "hokipoki", "hokipoki", "auctions", "-l", "9999", "-L", str(ticket_id), "-U", str(ticket_id)])[0]
	except:
		return None

# Gets all tickets for the passed game id
def get_tickets_for_game(game_id):
	try:
		return repeat_exec(["get", "table", "hokipoki", "hokipoki", "tickets", "--index", "2", "--key-type", "i64", "-l", "9999", "-L", str(game_id), "-U", str(game_id)])
	except:
		return None

# Returns true if there is a ticket available to be bought for game with id == game_id or false if not
def is_ticket_available(game_id):
	today = int(datetime.datetime.now().strftime("%Y%m%d%H%M"))
	game_time = get_game(game_id).date
	return len(filter(lambda a:a["for_lottery"]==0 and a["owner"]=="hokipoki" and game_time >= today ,get_tickets_for_game(game_id))) >0

# Returns true if the lottery is open for game with id == game_id or false if not
def is_lottery_available(game_id):
    return get_game(game_id).lottery_open == 1

# Returns true if user owns a ticket for game with id == game_id or false if not
def user_has_ticket(user,game_id):
    stuff = filter(lambda a:a["owner"] == user,get_tickets_for_game(game_id))
    return stuff[0] if len(stuff) > 0 else False

def get_lottery_entries_by_user(user):
    return repeat_exec(["get", "table", "hokipoki", "hokipoki", "lottoentries", "--index", "2", "--key-type", "i64", "-l", "9999", "-L", user, "-U", user])
def get_lottery_entries_by_game(game_id):
    return repeat_exec(["get", "table", "hokipoki", "hokipoki", "lottoentries", "--index", "3", "--key-type", "i64", "-l", "9999", "-L", str(game_id), "-U", str(game_id)])

# Returns true if user is in lottery for game with id == game_id or false if not
def user_in_lottery(user,game_id):
    return len(filter(lambda a:a["game_id"]==game_id,get_lottery_entries_by_user(user)))>0


# Gets the transaction history for the given user, WITH DUPLICATES REMOVED
# It groups all transactions in the same block into sub-lists, so this returns a list of lists of transactions, in order
# only returns the last 100 transactions to make the page load faster
def get_history(user):
    results = _exec(["get", "actions", user, "-j", "-1", "-100"]).actions
    l = []
    last = None
    lastact = None
    for r in results:
	if r.action_trace.trx_id == last:
	    if r.action_trace.receipt.act_digest == lastact:
		continue
	    l[-1].append(r)
	else:
	    l.append([r])
	    last = r.action_trace.trx_id
	lastact = r.action_trace.receipt.act_digest
    return l

# Returns the number of tickets reserved for the lottery
def get_num_of_lottery(game_id):
    	return len(filter(lambda a:a["for_lottery"],get_tickets_for_game(game_id)))

#Returns a list of users in the lottery for the given game_id
def lottery_entries_by_game(game_id):
    return [b.user for b in get_lottery_entries_by_game(game_id)]
    
#Returns the past tickets from a given user
def get_past_tickets(user):
	today = datetime.datetime.now().strftime("%Y%m%d%H%M")
	games = get_raw_table("games")
	dates = {game.id: game.date for game in games}
	return filter(lambda a:a.owner == user and (today > dates.get(a.game_id, today) or a.attended == True), get_raw_table("tickets")) # TODO put a "by owner" index on the tickets table, so we don't have to do a full table scan here


# Wrapper for transfer from eosio.token, transfers HTK from one user to another
# (the "transfer" function in this file is specifically for giving students money from hokipoki)
def transfer_from(from_user, to_user, amount, message):
    amount_str = str(amount)
    if "." not in amount_str:
	amount_str = amount_str + ".00 HTK"
    elif len(amount_str.split(".")[1]) != 2:
	amount_str = amount_str + "0 HTK"
    else:
	amount_str = amount_str + " HTK"
    def with_result(r):
	return json.dumps({"balance": get_balance(to_user)})
    return wrap_exec(with_result, ["push", "action", "eosio.token", "transfer", json.dumps([from_user,to_user, amount_str, message]), "-p", from_user+"@active", "-j"])


# Penalizes users for not attending games
def penalize_users(game_id):
    penalty_amount = "5"
    tickets = filter(lambda a:a["game_id"] == game_id,get_raw_table("tickets"))
    r = []
    for ticket in tickets:
        if not ticket["attended"] and not ticket["owner"]=="hokipoki":
            user = ticket["owner"]
            user_balance = get_balance(user)
            if (user_balance - float(penalty_amount)) < 0:
                penalty_amount = str(user_balance)
            transfer_from(user,"hokipoki",penalty_amount,"Penalty for not attending game")
            r.append(user)
    return r

# wrapper for the blockchain action
def reward_user(ticket_id):
    owner = get_ticket(ticket_id).owner
    def with_result(r):
	return {"success": "Success!", "user": owner}
    return wrap_exec(with_result, ["push", "action", "hokipoki", "rewarduser", json.dumps([ticket_id]), "-p", "hokipoki@active", "-p", owner + "@active", "-j"])

# Returns all tickets for the give user for games that have not yet happened, and for which the ticket
# has not been used yet
def active_tickets(user):
	r = []
	now = int(datetime.datetime.now().strftime("%Y%m%d%H%M"))
	return filter(lambda a: a["owner"] == user and not a.attended and int(get_game(a.game_id).date) >= now, get_raw_table("tickets"))

# Gets a human readable string for the passed game type
def get_game_type(game_type):
	games = {
		0: "Football",
		1: "Men's Basketball",
		2: "Women's Basketball",
		3: "Men's Soccer",
		4: "Women's Soccer", 
		5: "Baseball",
		6: "Cross Country",
		7: "Men's Golf",
		8: "Women's Golf",
		9: "Lacrosse",
		10: "Softball",
		11: "Swim and Dive",
		12: "Men's Tennis",
		13: "Women's Tennis",
		14: "Track and Field",
		15: "Volleyball",
		16: "Wrestling"
	} 
	return games.get(game_type, "Invalid Game ID")


# Given a big boy in format YYYYMMDDhhmm it returns a formatted date like "Tuesday, April 14, 2020"
def format_date(date):
    d = str(date)[:8]
    return time.strftime("%A, %B %-d, %Y", time.strptime(d, "%Y%m%d"))

# Given a big boy in format YYYYMMDDhhmm it returns a formatted datetime like "11:30 AM on Tuesday, April 14, 2020"
def format_datetime(dt):
    d = str(dt)
    return time.strftime("%-l:%M %P on %A, %B %-d, %Y", time.strptime(d, "%Y%m%d%H%M%S"))


# AUCTION HELPERS
# checks if there is currently an active auction on the given ticket
def auction_for_ticket_id(ticket_id):
	return get_auction(ticket_id) != None

def get_ticket_by_id(ticket_id):
	return get_ticket(ticket_id)

def get_auction_by_ticket_id(ticket_id):
	auction = get_auction(ticket_id)
	if not auction:
		return( json.dumps({"error": "No auction exists"}) )
	dt_string = datetime.datetime.now().strftime("%Y%m%d%H%M")
	if int(auction[0]) < int(dt_string):
		return( json.dumps({"error": "Auction ended"}) )
	else:
		return( auction )

# Determines if the passed auction has ended already
def auction_ended(ticket_id):
	auction = get_auction(ticket_id)
	dt_string = datetime.datetime.now().strftime("%Y%m%d%H%M")
	return int(auction[0]) < int(dt_string)


# No indexes for these two, have to do a full table scan :(
def get_auctions_by_name(user):
	auctions = filter(lambda a:a["auction_owner"] == user, get_raw_table("auctions"))
	return auctions

def get_auctions_by_game(game_id):
	auctions = filter(lambda a:a["game_id"] == game_id, get_raw_table("auctions"))
	return to_json({"Success": list(auctions)})

def get_auctions_user_bid(user):
	auctions = filter(lambda a:a["top_bidder"] == user, get_raw_table("auctions"))
	return auctions
	# return json.dumps({"Success": auctions})

def get_auction_groups():
    now = int(time.strftime("%Y%m%d%H%M", time.localtime()))
    games = get_raw_table("games")
    games = list(filter(lambda g: int(g.date) > now, games))
    games.sort(key=lambda g: g.date)
    auctions = get_raw_table("auctions")
    return [[g, list(filter(lambda a: a.game_id == g.id and a.end_date > now, auctions))] for g in games]

# Encoding key used for making the qr codes harder to read by nosy students
# Every QR code encodes an ascii base64 string, which decodes to a series of bytes
# The first byte is removed, and the rest of the bytes are xor'd with it
# The remaining bytes are xor'd with secret, and you get
# HOKIPOKI........nilesr, where ......... is an 8-byte representation of a uint64_t ticket id, 
# and nilesr is the owner of the ticket.
def get_qr_code_key_byte(s, i):
    secret = [
	0x6b, 0x34, 0x4c, 0xbf, 0xa8, 0x4c, 0x52, 0x42, 0x6b, 0x0b, 0xbf, 0x44,
	0xf7, 0x14, 0xb7, 0x96, 0xaa, 0xef, 0x3d, 0x44, 0x81, 0x2a, 0x01, 0xea,
	0x7c, 0xa9, 0x6c, 0x0c, 0xa3, 0x67, 0x92, 0x0b, 0x83, 0x4f, 0x87, 0xa7,
	0xd5, 0xa5, 0xdf, 0x41, 0xb5, 0x2f, 0xdf, 0xe4, 0x84, 0xb3, 0x88, 0x5e,
	0xbf, 0x0e, 0xac, 0x10, 0x26, 0xa4, 0x81, 0x8b, 0x63, 0x05, 0xc3, 0xe2,
	0x63, 0xd9, 0xce, 0xe8
    ]
    return secret[i % len(secret)] ^ s

# Given a ticket id, gets its owner and then constructs the base64 stream that needs to go into the qr code itself
def get_qr_code_data(ticket_id):
    data = b"HOKIPOKI" + struct.pack(">Q", ticket_id) + get_ticket(ticket_id).owner.encode()
    s = random.randint(0, 255)
    data = b"".join([chr(s)] + [chr(ord(c) ^ get_qr_code_key_byte(s, i)) for i, c in enumerate(data)])
    return base64.b64encode(data)

# Gets the raw bytes of a PNG image for the QR code
# Sent directly back to the mobile app to be displayed, or encoded in a uri for display in the browser
def get_qr_code(ticket_id):
    data = get_qr_code_data(ticket_id)
    i = io.BytesIO();
    #qrcode.make(data).get_image().save(i, format="PNG")
    qr = qrcode.QRCode(error_correction=random.choice([qrcode.constants.ERROR_CORRECT_H, qrcode.constants.ERROR_CORRECT_M, qrcode.constants.ERROR_CORRECT_L]))
    qr.add_data(data)
    qr.make()
    qr.make_image().save(i, format="PNG")
    i.seek(0)
    return i.read()

# Gets the data uri representation of the PNG file for a qr code - used on the web interface
def get_qr_code_data_uri(ticket_id):
    return "data:image/png;base64," + base64.b64encode(get_qr_code(ticket_id))

# Given the base64 stream of data from a qr code, attempt to scan it.
# If the ticket is no longer owned by the person who generated the QR code, an error is returned
# If the ticket has already been scanned, returns an error indicating what's wrong
# Otherwise, calls down to the blockchain to run the rewarduser action to mark their ticket has being scanned and give them their hokietokens
def scan_qr_code(data):
    data = base64.b64decode(data)
    data = b"".join([chr(ord(c) ^ get_qr_code_key_byte(ord(data[0]), i)) for i, c in enumerate(data[1:])])
    if data[:len("HOKIPOKI")].decode() != "HOKIPOKI":
	return {"error": "The magic number is invalid"}
    ticket_id = struct.unpack(">Q", data[len("HOKIPOKI"):len("HOKIPOKI")+8])[0]
    owner = data[len("HOKIPOKI")+8:]
    t = get_ticket(ticket_id)
    if not t:
	return {"error": "That ticket does not exist"}
    if t.owner != owner:
	return {"error": "That ticket no longer belongs to the user who generated the QR code"}
    if t.attended == 1:
	return {"error": "That ticket has already been scanned!"}
    return reward_user(ticket_id)

# If we don't _try_desymbolize_names before passing a symbolized object into json.dumps, it dumps it as an unlabeled array rather than a json object
def to_json(data):
    return json.dumps(_try_desymbolize_names(data))

# used for printing things that might be multiple
# like `len(tickets) + " ticket" + s(len(tickets))` will print
# "1 ticket" or "3 tickets"
def s(thing):
    return "" if len(thing) == 1 else "s"

# Returns the public key needed for the active permission of the passed user
# Displayed in the footer of every student page
def get_active_public_keys(user):
	ui = get_user_info(user)
	ps = [x for x in ui.permissions if x.perm_name == "active"]
	if len(ps) != 1: return False
	return [o.key for o in ps[0].required_auth.keys]

# Runs cleos wallet import on the passed private key
def import_key(priv):
    proc = subprocess.Popen(cleos + ["wallet", "import"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate(input=priv.encode())
    if proc.returncode != 0:
	raise EosioError(out.decode() + "\n" + err.decode())

# Attempts to guess the right logo to use for the game based on the name of the game
def get_logo(game_name):
    if "duke" in game_name.lower():
        return "/static/images/logo-duke.png"
    elif "spring game" in game_name.lower():
        return "/static/images/logo-vt.png"
    elif "ranchers" in game_name.lower():
        return "/static/images/logo-ranchers.png"
    elif "block.one" in game_name.lower():
        return "/static/images/logo-blockone.png"
    elif "block.two" in game_name.lower():
        return "/static/images/logo-blocktwo.png"
    elif "radford" in game_name.lower():
        return "/static/images/logo-radford.png"
    elif "zoom" in game_name.lower():
        return "/static/images/logo-zoom.png"
    elif "vs. virginia" in game_name.lower():
        return "/static/images/logo-uva.png"
    elif "liberty" in game_name.lower():
        return "/static/images/logo-liberty.png"
    elif "north carolina" in game_name.lower():
        return "/static/images/logo-nc.png"
    else:
        return "/static/images/logo-empty.png"

