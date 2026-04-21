extends HTTPRequest

var url = "https://api.datamuse.com/words?rel_jjb=weather"

var fallback_words = {
	## ADD REMAINING FALLBACKS
	"noun": ["cat", "dog", "house", "tree", "book"],
	"adverb": ["quickly", "slowly", "happily", "carefully", "suddenly"],
	"weather": ["sunny", "rainy", "cloudy", "snowy", "windy"],
	"names": [
		"James", "Sofia", "Amara", "Oliver", "Priya","Ethan","Zara","Lucas","Yuki","Aisha",
		"Benjamin","Kai","Isabella","Marco","Leila","Henry","Theo","Freya","Dmitri","Maya",
		"Ren", "Matthew", "Kaori", "Morgan"
	]
}

var type = "noun"

var err := OK
var return_word: String

signal word_ready

func _ready() -> void:
	request_completed.connect(_on_request_completed)
	get_word("noun")

func send_request():
	var headers = ["Content-Type: application/json"]
	err = await request(url, headers, HTTPClient.METHOD_GET)

func _on_request_completed(res, response_code, headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if err != OK or json.size() < 1:
		var idx: int = randi() % fallback_words.noun.size()
		return_word = fallback_words.noun[idx]
	else:
		var idx: int = randi() % json.size()
		return_word = json[idx].word
		
	word_ready.emit()

func get_word(p_type: String):
	type = p_type
	
	if type == "name":
		var idx: int = randi() % fallback_words.names.size()
		return fallback_words.names[idx]
	elif type == "number":
		return str(randi_range(1, 100))
	elif type == "drink":
		url = "https://api.datamuse.com/words?rel_trg=drink"
	elif type == "noun":
		url = "https://api.datamuse.com/words?sp=*&md=n"
	elif type == "adverb":
		url = "https://api.datamuse.com/words?ml=quickly&sp=*ly"
	elif type == "adjective":
		url = "https://api.datamuse.com/words?ml=awesome"
	elif type == "verb ending in 'ing'":
		url = "https://api.datamuse.com/words?sp=*ing&md=v"
	elif type == "weather":
		url = "https://api.datamuse.com/words?rel_jjb=weather"
	elif type == "past tense verb":
		url = "https://api.datamuse.com/words?ml=ran"
	elif type == "confirmation":
		url = "https://api.datamuse.com/words?ml=yes"
	elif type == "exclamation":
		url = "https://api.datamuse.com/words?ml=scream"
		
	send_request()
	
	await word_ready
		
	return return_word
