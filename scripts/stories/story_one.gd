extends Story

func _init() -> void:
	words = {
		character_a = "name",
		character_b = "name",
		weather = "weather",
		drink_1 = "drink",
		drink_2 = "drink",
		adjective = "adjective",
		noun_1 = "noun",
		past_verb_1 = "past tense verb",
		noun_2 = "noun",
		adverb_1 = "adverb",
		noun_3 = "noun",
		past_verb_2 = "past tense verb",
		number = "number",
		ing_verb_1 = "verb ending in 'ing'",
		exclamation = "exclamation",
		ing_verb_2 = "verb ending in 'ing'",
		past_verb_3 = "past tense verb",
		confirmation = "confirmation",
		adverb_2 = "adverb",
		noun_4 = "noun"
	}
	
	story = [
		"As it was a perfect, {weather} day, {Character A} and {Character B} decided it was time for another fishing trip.".format(
			{
				"weather": words.weather,
				"Character A": words.character_a,
				"Character B": words.character_b
			}
		),
		"With a bottle of {drink 1} and a 6-pack of {drink 2}, they made their way down to the lakeside, rods in hand and hopes high.".format(
			{
				"drink 1": words.drink_1,
				"drink 2": words.drink_2
			}
		),
		'\"{Adjective} for a {noun 1} dinner tonight?\" asked {Character A} as they {past-tense verb 1} out to the middle of the lake.'.format(
			{
				"Adjective": words.adjective,
				"noun 1": words.noun_1,
				"Character A": words.character_a,
				"past-tense verb 1": words.past_verb_1
			}
		),
		'\"Eh, I’m more of a {noun 2} fan,\" {Character B} replied, as they {adverb 1} hooked a {noun 3} for bait.'.format(
			{
				"noun 2": words.noun_2,
				"Character B": words.character_b,
				"adverb 1": words.adverb_1,
				"noun 3": words.noun_3
			}
		),
		"The two of them {past-tense verb 2} in their boat, helping themselves to a light drink as the day passed with not a fish in sight.".format(
			{
				"past-tense verb 2": words.past_verb_2
			}
		),
		"After {number} hours, {Character B} noticed {Character A} {‘ing’ verb 1} in their seat when, suddenly, their rod jerked violently.".format(
			{
				"number": words.number,
				"Character B": words.character_b,
				"Character A": words.character_a,
				"‘ing’ verb 1": words.ing_verb_1
			}
		),
		"\"{exclamation}!\" {Character A} shouted, {‘ing’ verb 2} to reel in their first catch of the day while {Character B} stared hard at the empty {drink 1} bottle.".format(
			{
				"exclamation": words.exclamation,
				"Character A": words.character_a,
				"Character B": words.character_b,
				"‘ing’ verb 2": words.ing_verb_2,
				"drink 1": words.drink_1
			}
		),
		"\"Wow, the whole thing?\" {Character B} asked as {Character A} {past-tense verb 3} with the pole.".format(
			{
				"Character B": words.character_b,
				"Character A": words.character_a,
				"past-tense verb 3": words.past_verb_3
			}
		),
		"\"{Confirmation},\" {Character A} replied as they finally pulled his prize into the boat, flopping {adverb 2} onto their back.".format(
			{
				"Confirmation": words.confirmation,
				"Character A": words.character_a,
				"adverb 2": words.adverb_2
			}
		),
		"It was a {noun 4}.".format(
			{
				"noun 4": words.noun_4
			}
		),
		"A small {noun 4}.".format(
			{
				"noun 4": words.noun_4
			}
		),
		"Perhaps it was time to pack it in."
	]
