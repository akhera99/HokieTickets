#!/usr/bin/env python2
# coding=utf-8
import sqlite3, os, base64, cookies, pickle
import libgoblin

def connect():
	return sqlite3.connect("/dev/shm/goblin.db")

db = connect()
cur = db.cursor()
cur.execute("create table if not exists sessions (user text, cookie text, session blob);")
cur.close()
db.commit()
del db

#########################################################
## Restart mako-server every time you change this file ##
#########################################################

# Holds a session, which is an object that you can set or get values on like a dictionary, and those values are
# persisted as long as the user is signed in. In our case, we stored the session in the same place
# as the cookie we use to track who the user is logged in as. This means everything stored in the
# session is lost when the user logs out, or when they log on in another location. 
# session would be most useful for storing application state, such as previous inputs in
# a multi-page flow, before a transaction is actually comitted to the blockchain.
# In practice, Session was never used. All application data is stored on the blockchain.
class Session:
	def __init__(self, b, c, u):
		self._db = connect()
		self._backing_dict = b
		self._cookie = c
		self._user = u
		self._cur = self._db.cursor()
	# passively find the item from our stored data
	def __getitem__(self, k):
		return self._backing_dict[k]
	# put the item in our stored data, and write that update out to disk
	def __setitem__(self, k, v):
		self._backing_dict[k] = v
		self._cur.execute("update sessions set session = ? where user = ? and cookie = ?", [pickle.dumps(self._backing_dict), self._user, self._cookie])
		self._db.commit()
	# for debugging
	def __str__(self):
		return str(self._backing_dict)
	def __repr__(self):
		return repr(self._backing_dict)

# Attempts to log the user in using the form-submitted username and password
# Returns their username, session pair if successful (session is actually unused),
# or False, error_message on error.
# The user must exist on the blockchain (checked by libgoblin.get_user_info), and
# they must pass the permissions check - they must have allowed `hokipoki` to execute
# actions on their behalf. The submitted password must be "pass". In the future, this will
# integrate with VT's single sign on system, and so storing a user's password will never be
# necessary. 
# A new auth cookie is generated, and inserted or replaced into the session database.
# If the user was logged on somewhere else, this logs them out. The new session cookie
# is sent back in a Set-Cookie header in the response, by way of the `environ` object from
# `mako-server
# 
# `d` is a dictionary containing all submitted form data, so for example, loading a page with
# `?user=phil&pass=hunter2&lunch=%E3%81%8D%E3%81%99%E3%81%AD%E3%81%86%E3%81%A9%E3%82%93`
# (or sending a POST request with the body set to the that, without the leading question mark)
# results in `d` coming back from `mako-server` as
# {
#		"user": "phil",
#		"pass": "hunter2",
#		"lunch": "きすねうどん"
# }
def try_login(d, environ):
	if "user" not in d or "pass" not in d:
		return False, False
	try:
		libgoblin.get_user_info(d["user"])
	except Exception, e:
		return False, "User does not exist"
	if d["pass"] != "pass":
		return False, "Invalid password"
	if not libgoblin.check_permissions_grant(d["user"]):
		return False, "Permissions grant check failed - the hokipoki account does not have permission to perform eosio.token actions on your behalf."
	db = connect()
	cur = db.cursor()
	# If they had an old session, blow it away
	cur.execute("delete from sessions where user = ?", [d["user"]])
	# Make a new session cookie and store it with an empty session
	cookie = base64.b64encode(os.urandom(35)).decode("ascii")
	cur.execute("insert into sessions (user, cookie, session) values (?, ?, ?)", [d["user"], cookie, pickle.dumps({})])
	# Send back the Set-Cookie header with the new cookie
	environ["headers"] = [("Set-Cookie", cookies.Cookie("auth", cookie).render_response())]
	db.commit()
	cur.close()
	return d["user"], Session({}, cookie, d["user"])

# Attempts to find the username and (unused) session of the currently logged in user, based on
# their auth cookie. `c` is a dictionary of all sent cookies that comes from mako-server.
# If no auth cookie was sent, or no session exists with that auth cookie, False, False is returned.
# Otherwise, username, (unused) session is returned
def get_user(c):
	if "auth" not in c:
		return False, False
	db = connect()
	cur = db.cursor()
	cur.execute("select user, session from sessions where cookie = ?", [c["auth"]])
	r = cur.fetchone()
	cur.close()
	if not r:
		return False, False
	return r[0], Session(pickle.loads(r[1]), c["auth"], r[0])

# Deletes the session and auth cookie for the auth cookie in c.
# Essentially, logs the user out. 
def destroy_session(c):
	if "auth" not in c:
		return False
	db = connect()
	cur = db.cursor()
	cur.execute("delete from sessions where cookie = ?", [c["auth"]])
	if cur.rowcount == 0:
		cur.close()
		return False
	db.commit()
	cur.close()
	return True

