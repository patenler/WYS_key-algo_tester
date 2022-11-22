extends TextEdit


# Declare member variables here. Examples:
var ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

func mult(a, b): return a*b
func conc(a, b): return int(str(a)+str(abs(b)))
func mod(a, b): return int(fposmod(a, b))
func add(a, b): return a+b
func sub(a, b): return a-b

var functions = {"*": "mult", "|": "conc", "%": "mod", "+": "add", "-": "sub"}

func parse_key(key: String):
	if key == "":
		return [[0], 0]
	var result_key = []
	key = key.replace(" ", "")
	if "," in key:
		result_key = Array(key.split(","))
		for i in range(result_key.size()):
			if result_key[i].is_valid_integer():
				result_key[i] = int(result_key[i])
			else:
				return [[], 1]
		return [result_key, 0]
	elif key.is_valid_integer():
		return [[int(key)], 0]
	else:
		for c in key:
			if c in ALPHA:
				result_key.append(ord(c) - 64)
			else:
				return [[], 2]
		return [result_key, 0]

func parse_key_modifier(key_modifier : String):
	key_modifier = key_modifier.replace(" ", "")
	# allowed chars 
	# ints : 0123456789
	# symbols : ()*|%-+
	# key access : x[i]
	# '|' is concatenation and '%' is the modulo operator
	# symbol priorities are supposed to be from highest to lowest in the listed order :
	# () * | % -+
	var word_list = []
	var word = ""
	for c in key_modifier:
		if c in "()*|%-+" + "x[i]":
			if word != "":
				word_list.append(word)
			
			# getting the last word in the word list to check for - :
			# we keep - for neative integers only if - is after a symbol in '(*|%-+['
			var s = word_list.size()
			var last_word = ""
			if s != 0:
				last_word = word_list[s-1]
			var l = last_word.length()
			
			if c != "-":
				word_list.append(c)
				word = ""
			elif c == "-" and s != 0 and not (last_word[l-1] in "(*|%-+["):
				word_list.append(c)
				word = ""
			else:
				word = c
		elif c in "0123456789":
			word += c
		else:
			return [[], 1]
	if word != "":
		word_list.append(word)
	return [word_list, 0]

func equals(a, string):
	return (typeof(a) == TYPE_STRING and a == string)

func in_string(a, string):
	return (typeof(a) == TYPE_STRING and a in string)

func is_negative_number(a):
	return (typeof(a) == TYPE_ARRAY and a.size() > 0 and typeof(a[0]) == TYPE_INT and a[0] <= 0)

func compile_key_modifier(modifier_word_list : Array):
	"""
	E < (E)
	E < E*E
	E < E|E
	E < E%E
	E < E-E
	E <  -E
	E < E+E
	E < x[E]
	E < x
	E < i
	E < n
	
	symbols reduces only if there isn't a symbol with a higher priority after
	"""
	var priorities = {"*" : 3, "|": 2, "%": 1, "-": 0, "+": 0}
	var priority_symbols = "*|%-+"
	var result = []
	
	while modifier_word_list != []:
		var word = modifier_word_list[0]
		modifier_word_list.remove(0)
		if word.is_valid_integer():
			result.append([int(word)])
		elif word == "i":
			result.append(["i"])
		elif word == "x" and (modifier_word_list.size() == 0 or modifier_word_list[0] != "[" ):
			result.append(["x", ["i"]])
		else:
			result.append(word)
		
		var reduced = true
		while reduced:
			reduced = false
			var s = result.size()
			var new_block = []
			var n = 0
			if s >= 2 and equals(result[s-2], "-") and typeof(result[s-1]) == TYPE_ARRAY:
				reduced = true
				n = 2
				new_block = ["*", [-1], result[s-1]]
			if s >= 3 and equals(result[s-3],"(") and typeof(result[s-2]) == TYPE_ARRAY and equals(result[s-1], ")"):
				reduced = true
				n = 3
				new_block = result[s-2]
			elif s >= 3 and typeof(result[s-3]) == TYPE_ARRAY and in_string(result[s-2], priority_symbols) and typeof(result[s-1]) == TYPE_ARRAY:
				if (modifier_word_list.size() == 0 or 
				not (in_string(modifier_word_list[0], priority_symbols)) 
				or priorities[modifier_word_list[0]] <= priorities[result[s-2]] ):
					reduced = true
					n = 3
					new_block = [result[s-2], result[s-3], result[s-1]]
			elif s >= 4 and equals(result[s-4], "x") and equals(result[s-3], "[") and typeof(result[s-2]) == TYPE_ARRAY and equals(result[s-1], "]"):
				reduced = true
				n = 4
				new_block = ["x", result[s-2]]
				
			if reduced:
				for i in range(1, n+1):
					result.remove(s-i)
				result.append(new_block)
	return result

func value(key_modifier, key, i):
	var action = key_modifier[0]
	if typeof(action) == TYPE_INT:
		return action
	elif action == "i":
		return i
	elif action == "x":
		var value = value(key_modifier[1], key, i)
		value = int(fposmod(value, key.size()))
		return key[value]
	else:
		var val1 = value(key_modifier[1], key, i)
		var val2 = value(key_modifier[2], key, i)
		return call(functions[action], val1, val2)

func apply(key_modifier, key):
	var new_key = []
	for i in range(key.size()):
		new_key.append(value(key_modifier, key, i))
	return new_key

func decryption_algo(key, data : String):
	var key_length = key.size()
	var key_index = 0
	var data_index = 0
	var result = ""
	while data != "":
		
		data_index += key[key_index]
		data_index = int(fposmod(data_index, data.length()))
		
		result += data[data_index]
		data.erase(data_index, 1)
		
		key_index += 1
		key_index %= key_length
	return result

func encryption_algo(key, data : String):
	var key_length = key.size()
	var key_index = 0
	var result_index = 0
	var result_length = data.length()
	var result = []
	for _i in range(data.length()):
		result.append("-1")
	
	for c in data:
		var jump = key[key_index]
		var jump_direction = 1 if jump >=0 else -1
		while jump * jump_direction > 0 or result[result_index] != "-1":
			if result[result_index] == "-1":
				jump -= jump_direction
			result_index += jump_direction
			result_index = int(fposmod(result_index, result_length))
		
		result[result_index] = c
		
		key_index += 1
		key_index %= key_length
	
	var final_result = ""
	for c in result:
		final_result += c
	return final_result

func _on_DataTextEdit_crypting(decrypt, key_modifier_string, key_string, data):
	# parsing the key
	var key_parser_result = parse_key(key_string)
	var error = key_parser_result[1]
	if error != 0:
		if error == 1:
			text = "ERROR: only integers are supported in the format:\n a, b, c"
		elif error == 2:
			text = "ERROR: non uppurcase letter character in the key"
		else:
			text = "ERROR: unkown error while parsing the key"
		return
	var key = key_parser_result[0]
	
	# parsing the key modifier
	var modifier_word_list = []
	if key_modifier_string != "":
		var key_modifier_parser_result = parse_key_modifier(key_modifier_string)
		error = key_modifier_parser_result[1]
		if error != 0:
			if error == 1:
				text = "ERROR: unsupported character in the key modifier"
			else:
				text = "ERROR: unkown error while parsing the key modifier"
			return
		modifier_word_list = key_modifier_parser_result[0]
	
	print(modifier_word_list)
	# 'compiling' the key modifier
	var key_modifier = compile_key_modifier(modifier_word_list)
	print(key_modifier)
	if key_modifier.size() > 1:
		text = "ERROR: key modifier not valid"
		return
	
	# applying key modifier to key
	if key_modifier.size() > 0:
		key = apply(key_modifier[0], key)
	print(key)
	
	if decrypt:
		var result = decryption_algo(key, data)
		text = result
	else:
		var result = encryption_algo(key, data)
		text = result
	
