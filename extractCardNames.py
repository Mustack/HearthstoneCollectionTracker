import json

input = open("AllSets.enUS.json", encoding="utf8")
output = open("allCards.txt", "w")

allSets = json.load(input)

byCost = [[],[],[],[],[],[],[],[]]

for set in allSets:
    for card in allSets[set]:
        if "cost" not in card or "name" not in card:
            continue

        if "collectible" not in card or not card["collectible"]:
            continue

        cardString = ""

        cardString += card["name"]

        if "text" in card:
            cardString += "$"
            cardString += card["text"].replace('\n', '').replace('$', '').replace('#', '').replace('<b>', '').replace('</b>', '').replace('<i>', '').replace('</i>', '')

        cardString += "\n"

        cost = 7 if card["cost"] > 7 else card["cost"]

        byCost[cost].append(cardString)

for cost in range(0, 8):
    print(cost)
    for card in byCost[cost]:
        output.write(str(cost))
        output.write("$")
        output.write(card)
