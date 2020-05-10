#!python
from __future__ import print_function
import json
from libgoblin import *
import datetime
import subprocess, collections, random, re

# try:
#     parsed = libgoblin.buy('ankita',3)
#     print(type(parsed))
#     print(json.dumps(parsed, indent=4, sort_keys=True))
# except Exception as e:
#     #print("TEST HAHAHAHAH GOTEEM")
#     print(e)


# try:
#     parsed = libgoblin.sell('ankita',3)
#     print(type(parsed))
#     print(json.dumps(parsed, indent=4, sort_keys=True))
# except Exception as e:
#     print(e)




# game_id = 1
# parsed = libgoblin.get_raw_table("tickets")
# filtered = filter(lambda a:a["game_id"]==game_id and a["for_lottery"]==0 and a["owner"]=="hokipoki",parsed)
# for item in filtered:
#     print(item)

# game_id = 3
# user = "bruh"

# a = libgoblin.buy(user,game_id)
# for item in a[0][1][0][3][0]:
#     print(item)

# table = libgoblin.get_raw_table("tickets")
# filtered = filter(lambda a:a["game_id"] == game_id and a["owner"] == user,table)
# ticket_id = filtered[0]["id"]

# a = libgoblin.sell(user,ticket_id)

# user='bruh'
# return filter(lambda a:a["owner"]==user,get_raw_table("tickets"))

# date = 20200305
# filtered = filter(lambda a:a["date"]>=date,get_raw_table("games"))
# b = sorted(filtered,key=lambda a:a["date"])
# for item in b:
#     print(item)

# game_id = 0
# filtered = filter(lambda a:a['id']==game_id,get_raw_table("games"))[0]
# print(filtered)

# game_id = 0
# today = datetime.datetime.now().strftime("%Y%m%d%H%M")
# game_time = filter(lambda a:a["id"]==game_id,get_raw_table("games"))[0]["date"]
# filtered = len(filter(lambda a:a["game_id"]==game_id and a["for_lottery"]==0 and a["owner"]=="hokipoki" and game_time >= today ,get_raw_table("tickets"))) >0
# print(filtered)

# def user_has_ticket(user,game_id):
#     return len(filter(lambda a:a["game_id"] == game_id and a["owner"] == user,get_raw_table("tickets")))>0
    
# print(user_has_ticket("bruh",0))
# buy("bruh",0)
# print(user_has_ticket("bruh",0))

# def user_in_lottery(user,game_id):
#     return len(filter(lambda a:a["user"]==user and a["game_id"]==game_id,get_raw_table("lottoentries")))>0
# print(user_in_lottery("bruh",0))
# print(user_in_lottery("bruh",1))

#print(transfer("ankita", 999996219.32, "testing"))

#print(json.dumps(parsed,indent=4,sort_keys=True))

# print(debug_format(get_history("nilesr")))
# print(get_history("nilesr"))

# game_id = 1
# num = len(filter(lambda a:a["game_id"] == game_id and a["for_lottery"],get_raw_table("tickets")))
# print(num)


# game_id = 1
# entries = filter(lambda a:a["game_id"] == game_id,get_raw_table("lottoentries"))
# b = [a["user"] for a in entries]
# print(b)

# user = "nathanmk"
# today = datetime.datetime.now().strftime("%Y%m%d%H%M")
# games = get_raw_table("games")
# tickets = filter(lambda a:a["owner"] == user and today > filter(lambda b:b["id"] == a["game_id"],games)[0]["date"],get_raw_table("tickets"))
# print(tickets)


# def penalize_users(game_id):
#     penalty_amount = "5.00"
#     tickets = filter(lambda a:a["game_id"] == game_id,get_raw_table("tickets"))
#     for ticket in tickets:
#         if not ticket["attended"] and not ticket["owner"]=="hokipoki":
#             user = ticket["owner"]
#             user_balance = get_balance(user)
#             if (user_balance - float(penalty_amount)) < 0:
#                 penalty_amount = str(user_balance)+"0"
#             print(penalty_amount)
#             _exec(["push", "action", "eosio.token", "transfer", json.dumps([user, "hokipoki", penalty_amount, "penalty for not attending event"]), "-p", "hokipoki@active", "-j"])
# print("nathanmk balance: " + str(get_balance("nathanmk")))
# penalize_users(0)
# print("nathanmk balance: " + str(get_balance("nathanmk")))

#active_tickets("nathanmk")

#auction_ended(57)

#print(get_auctions_by_game(6))

#print(scan_qr_code(get_qr_code_data(25)))

##import libgoblin
##for uo in get_raw_table("users"):
##	u = uo.user
##	keymat = libgoblin._exec(["create", "key", "--to-console"], False).split("\n")
##	keymat = [x.split() for x in keymat]
##	priv = keymat[0][2]
##	pub = keymat[1][2]
##	libgoblin.import_key(priv)
##	print(u, pub, priv)
##	libgoblin._exec(["set", "account", "permission", u, "active",
##		'{"threshold":1, "keys":[{"key":"'+pub+'", "weight":1}], "accounts": [{"permission":{"actor":"hokipoki","permission":"eosio.code"},"weight":1}]}',
##		"owner", "-p", u + "@owner"], False)


print(debug_format(get_history("nilesr")[0][0].action_trace.act))
