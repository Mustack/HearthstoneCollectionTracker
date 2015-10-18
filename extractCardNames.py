import json

input = open("AllSets.enUS.json")
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

for cost in range(0, 7):
    for card in byCost[cost]:
        # searchTerm = card.replace('\n', '')
        #
        # for other in byCost[cost]:
        #     if card == other:
        #         continue
        #
        #     if str.find(other.encode("utf-8"), searchTerm.encode("utf-8")) > 0:
        #         print "=========="
        #         print card
        #         print other
        #         print "=========="

        output.write(str(cost))
        output.write('$')
        output.write(card.encode("utf-8"))
