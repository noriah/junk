-------IMPORTANT-------
You must edit the lua/umaul/mysql.lua file and write the correct 
sql.queryUserData and sql.handleSqlData functions.

=========
I'd be more than happy to help you out with this. Just email me at ----------
or steam message me: --------------- 
and I'll try to help. I can't do it right now because I have no idea
what you have for table structures, or how rank is determined.
=========


The code that you see in these functions is my test code.
I used it with a table structure I thought might be like yours.

mysql> select * from forum;
+----+---------+-----------+
| id | forumid | forumname |
+----+---------+-----------+
|  1 |       1 | noriahbot |
+----+---------+-----------+
1 row in set (0.00 sec)

mysql> select * from maul;
+----+--------------------+--------------+---------+------------+
| id | steamid            | pin          | forumid | permission |
+----+--------------------+--------------+---------+------------+
|  1 | STEAM_0:0:33454113 | abcdefghijkl |       1 |          4 |
+----+--------------------+--------------+---------+------------+
1 rows in set (0.00 sec)

mysql>


///////////////ABOUT///////////////
UMaul is an eGO MAUL-ULib connector to fill in the gap where SourceMod can't.

Normally, you would edit your users.txt file or add each individual user in game.
This is tiring and can lead to a large text file. With this tool, no files are
written, no adding of users is required. If you still want to use specific permissions
from the users file, this tool will include them.


///////////////REQUIREMENTS///////////////
mysqloo -- http://facepunch.com/showthread.php?t=1357773

ULib/ULX -- http://ulyssesmod.net/downloads.php


///////////////INSTALLATION///////////////
Place the ego-umaul folder in the garrysmod/addons folder.


Copy the config.txt file located in garrysmod/addons/ego-umaul/data/config.txt to 
garrysmod/data/umaul/config.txt and edit it.

If you don't do this, UMaul will automatically copy the file for you and tell you
about it in the server log.


Once this addon is installed and working to your liking,
You might want to delete all non-special users from the 
garrysmod/data/ulib/users.txt file

non-special users are any users that don't have anything in the
"allow" or "deny" sections of their entry. It will look like this:

"allow"
{
}
"deny"
{
}

Make a backup of the file first.
Just delete their entry, and you will be good to go.
Even if you don't do this, UMaul will ignore the group set here unless you change the code.
