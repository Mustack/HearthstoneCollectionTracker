$inputFile = FileOpen("allCards.txt")
$outputFile = FileOpen("ownedCards.txt")
$currentManaCost = -1

; Rather than have a static coord for all mana cost filters,
; we have the first one and increment by X amount for each one after that.
Dim $initialManaCoord[2] = [405,990]
Dim $manaCostIncrement = 45

Dim $firstCard[2] = [335,205] ; Coord of first card
Dim $firstCardMult[2] = [440,505] ; Coord of first card's "X2"
Dim $secondCardIncrement = 245 ; How much to add to the X axis from the first card to read the second card

; Baseline colours for each coord used to determine if a card is present on screen
Dim $baselineFirstCard
Dim $baselineFirstCardMult
Dim $baselineSecondCard
Dim $baselineSecondCardMult

; Checks that the currently selected mana cost filter is appropriate
Func checkManaCostFilter($manaCost)
   If $manaCost <> $currentManaCost Then
	  MouseClick("left", $initialManaCoord[0] + $manaCostIncrement * $manaCost, $initialManaCoord[1])
	  $currentManaCost = $manaCost
	  Sleep(200) ; Otherwise it goes back to searching before it clicks some times
   EndIf
EndFunc

; Enter the card name and description in the search box and hit enter
Func searchForCard($card)
   ; Search term is card name + card description
   $searchTerm = $card[2]

   ; Check that card description exists before adding to search term
   If $card[0] == 3 Then
	  $searchTerm = $searchTerm & " " & $card[3]
   EndIf

   ; Do the search
   MouseClick("left", 935,990)
   ClipPut($searchTerm)
   Sleep(10)
   Send("^v")
   Send("{ENTER}")
EndFunc

Func readCollection()
   While 1
	  local $card = FileReadLine($inputFile)
	  If @error = -1 Then ExitLoop

	  ; $card is an array of card data [manaCost, Name, Description]
	  $card = StringSplit($card, "$")

	  checkManaCostFilter($card[1])

	  searchForCard($card)

	  Sleep(100)

	  ; TODO: Check if the card exists

   Wend

   FileClose($inputFile)
EndFunc

Func terminate()
   Exit
EndFunc

HotKeySet("{PAUSE}", "readCollection")
HotKeySet("{ESC}", "terminate")

While 1
   Sleep(1000)
WEnd