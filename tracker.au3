Func readCollection()
   $inputFile = FileOpen("allCards.txt")
   $currentManaCost = -1

   Local $initialManaCoord[2] = [405,990]
   Local $firstCard[2] = [335,205]
   Local $firstCardMult[2] = [440,505]
   Local $secondCard[2] = [580,207]
   $manaCostIncrement = 45

   While 1
	  $card = FileReadLine($inputFile)
	  If @error = -1 Then ExitLoop

	  $card = StringSplit($card, "$")

	  ; Check the mana cost
	  If $card[1] <> $currentManaCost Then
		 MouseClick("left", $initialManaCoord[0] + $manaCostIncrement * $card[1], $initialManaCoord[1])
		 $currentManaCost = $card[1]
		 Sleep(200) ; Otherwise it goes back to searching before it clicks some times
	  EndIf

	  ; Search term is card name + card text
	  $searchTerm = $card[2]
	  If $card[0] == 3 Then
		 $searchTerm = $searchTerm & " " & $card[3]
	  EndIf

	  ; Do the search
	  MouseClick("left", 935,990)
	  ClipPut($searchTerm)
	  Sleep(10)
	  Send("^v")
	  Send("{ENTER}")
	  Sleep(100)

	  ;Check if the card exists

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