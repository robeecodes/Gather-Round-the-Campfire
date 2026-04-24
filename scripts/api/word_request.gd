extends HTTPRequest

var fallback_words = {
	"noun": ["cat", "dog", "house", "tree", "book"],
	"adverb": ["quickly", "slowly", "happily", "carefully", "suddenly"],
	"weather": ["sunny", "rainy", "cloudy", "snowy", "windy"],
	"names": [
		"James", "Sofia", "Amara", "Oliver", "Priya","Ethan","Zara","Lucas","Yuki","Aisha",
		"Benjamin","Kai","Isabella","Marco","Leila","Henry","Theo","Freya","Dmitri","Maya",
		"Ren", "Matthew", "Kaori", "Morgan"
	],
	"adjective": ["sad", "happy", "green", "exciting", "cool"],
	"ing_word": ["running", "sleeping", "lying", "gaming", "swimming"],
	"drink": ["rum", "cola", "whisky", "water", "lemonade"],
	"past_verb": ["ran", "swam", "jumped", "fell", "punched"],
	"confirmation": ["yes", "yep", "indeed", "agreed", "sure"],
	"exclamation": ["YIKES", "AAAAAHHHHH", "EEEK"]}

var type = "noun"

var err := OK
var return_word: String

func get_word(p_type: String):
	type = p_type
	var idx = 0
	if type == "name":
		idx = randi() % fallback_words.names.size()
		return fallback_words.names[idx]
	elif type == "number":
		return str(randi_range(1, 100))
	if type == "drink":
		idx = randi() % fallback_words.drink.size()
		return_word = fallback_words.drink[idx]
	elif type == "noun":
		idx = randi() % fallback_words.noun.size()
		return_word = fallback_words.noun[idx]
	elif type == "adverb":
		idx = randi() % fallback_words.adverb.size()
		return_word = fallback_words.adverb[idx]
	elif type == "adjective":
		idx = randi() % fallback_words.adjective.size()
		return_word = fallback_words.adjective[idx]
	elif type == "verb ending in 'ing'":
		idx = randi() % fallback_words.ing_word.size()
		return_word = fallback_words.ing_word[idx]
	elif type == "weather":
		idx = randi() % fallback_words.weather.size()
		return_word = fallback_words.weather[idx]
	elif type == "past tense verb":
		idx = randi() % fallback_words.past_verb.size()
		return_word = fallback_words.past_verb[idx]
	elif type == "confirmation":
		idx = randi() % fallback_words.confirmation.size()
		return_word = fallback_words.confirmation[idx]
	elif type == "exclamation":
		idx = randi() % fallback_words.exclamation.size()
		return_word = fallback_words.exclamation[idx]
		
	return return_word
