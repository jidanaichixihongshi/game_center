cd ../etc
erl ^
	+K true ^
	-pa ../ebin edit ../deps/*/ebin ^
	-name game_center@127.0.0.1 ^
	-setcookie game_center ^
	-s game_center ^
	
	