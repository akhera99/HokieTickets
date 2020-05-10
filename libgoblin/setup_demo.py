## Use this file to set up the server with games, tickets, and other states as needed for demonstration

import libgoblin as lg
def dwf(ff):
	def wf(*args, **kwargs):
		r = lg.__dict__[ff](*args, **kwargs)
		if type(r) == dict and "error" in r:
			raise lg.EosioError(r["error"])
		if type(r) == str:
			try:
				r = json.loads(r)
				if "error" in r:
					raise lg.EosioError(r["error"])
			except lg.EosioError as e:
				print("Error in {}({}, {})".format(ff, args, kwargs))
				print(e)
				print(e.output)
				raise e
			except:
				pass
		return r
	if not ff in globals():
		globals()[ff] = wf
for f in dir(lg):
	dwf(f)

import json, time


reset();

for ux in get_raw_table("users"):
	b = get_balance(ux.user)
	diff = 2000 - b
	if diff > 0:
		transfer(ux.user, diff, "Reset for demo")

create_game("202004051500", 50, 25, 0, "VT vs. Clemson", "The Pool", "202003221200", "202003232359", 1500, 11) # 0
create_game("202005011200", 50, 25, 0, "VT vs. Liberty", "Lane Stadium", "202003241530", "202003312359", 1500, 12) # 1
create_game("202005181500", 50, 25, 6000, "VT Spring Game", "Lane Stadium", "202004101200", "202004172359", 500, 0) # 2
create_game("202005221400", 50, 25, 2000, "VT vs. Radford", "Baseball Field", "202004141200", "202004212359", 1000, 5) # 3
create_game("202005282000", 50, 25, 6000, "VT vs. Duke", "Cassell Colliseum", "202004201200", "202004272359", 500, 1) # 4
create_game("202005141600", 50, 25, 2000, "VT vs. Virginia", "Lane Stadium", "202004220800", "202005101600", 1000, 5) # 5
create_game("202005141600", 50, 25, 0, "VT vs. Block.One", "Lane Stadium", "202004220800", "202004241600", 1500, 7) # 6
create_game("202005141600", 50, 25, 0, "VT vs. Block.Two", "Lane Stadium", "202004220800", "202004241600", 1500, 7) # 7
create_game("202005081500", 50, 25, 0, "VT vs. UNC", "Lane Stadium", "202003221200", "202003232359", 1500, 0) # 8


buy("nilesr", 0)
buy("ankita", 0)
buy("rachelk4", 0)

buy("rachelk4", 1)
buy("ankita", 1)
buy("nathanmk", 1)

buy("sameer", 2)
buy("cameron", 2)

open_lottery(3)
enter_lottery("ankita", 3)
enter_lottery("nathanmk", 3)
enter_lottery("nilesr", 3)
enter_lottery("cameron", 3)
enter_lottery("sameer", 3)
execute_lottery(3)

open_lottery(4)
enter_lottery("nilesr", 4)
enter_lottery("rachelk4", 4)
execute_lottery(4)
buy("nathanmk", 4)

open_lottery(5)
enter_lottery("nilesr", 5)
enter_lottery("sameer", 5)
buy("cameron", 5)
buy("rachelk4", 5)

buy("nilesr", 6)
buy("rachelk4", 6)

buy("ankita", 7)
buy("rachelk4", 7)
buy("nathanmk", 7)

buy("rachelk4", 8)

tid = filter(lambda t: t.game_id == 7, user_tickets("ankita"))[0].id
create_auction("ankita", tid, 6500, 202005120000)
bid(tid, "cameron", 6700)

tid = filter(lambda t: t.game_id == 3, user_tickets("nathanmk"))[0].id
create_auction("nathanmk", tid, 6550, 202005151645)
bid(tid, "nilesr", 6950)

tid = filter(lambda t: t.game_id == 3, user_tickets("ankita"))[0].id
create_auction("ankita", tid, 7000, 202005131200)
bid(tid, "cameron", 7200)
bid(tid, "rachelk4", 7600)

tid = filter(lambda t: t.game_id == 5, user_tickets("rachelk4"))[0].id
create_auction("rachelk4", tid, 7000, 202005130930)
bid(tid, "sameer", 7250)


tid = filter(lambda t: t.game_id == 8, user_tickets("rachelk4"))[0].id
reward_user(tid)

print("Script finished.")
print("\t{} games".format(len(get_raw_table("games"))))
print("\t{} tickets".format(len(get_raw_table("tickets"))))
print("\t\t{} purchased by users".format(len(filter(lambda x: x.owner != "hokipoki" and x.face_value > 0, get_raw_table("tickets")))))
print("\t\t{} given through lottery".format(len(filter(lambda x: x.owner != "hokipoki" and x.face_value == 0, get_raw_table("tickets")))))
print("\t\t{} available for purchase".format(len(filter(lambda x: x.owner == "hokipoki" and x.face_value > 0, get_raw_table("tickets")))))
print("\t\t{} available in lottery".format(len(filter(lambda x: x.owner == "hokipoki" and x.for_lottery == 1, get_raw_table("tickets")))))
print("\t{} lottery entries".format(len(get_raw_table("lottoentries"))))
print("\t{} auctions".format(len(get_raw_table("auctions"))))

