Dim $inputFile = FileOpen("allCards.txt")
Dim $outputFile
Dim $currentManaCost = -1

; Rather than have a static coord for all mana cost filters,
; we have the first one and increment by X amount for each one after that.
Dim $initialManaCoord[2] = [405,990]
Dim $manaCostIncrement = 50

Dim $firstCard[2] = [335,205] ; Coord of first card
Dim $firstCardMult[2] = [405,530] ; Coord of first card's "X2"
Dim $searchBox[2] = [935,990]
Dim $secondCardIncrement = 245 ; How much to add to the X axis from the first card to read the second card

; Baseline colours for each coord used to determine if a card is present on screen
Dim $baselineFirstCard
Dim $baselineFirstCardMult
Dim $baselineSecondCard

Func startJsonFile()
   Local $fileName = "ownedCards.json"
   FileDelete($fileName)
   $outputFile = FileOpen($fileName, 1)
   FileWriteLine($outputFile, "{")
EndFunc

; Record a baseline of colours for each coord
Func recordBaselineColours()
   ; Search for giberish so we know no cards are present on screen
   searchForCard("not a card igbaugyasdvtfyuasdtvfia")

   Sleep(500)

   $baselineFirstCard = PixelGetColor($firstCard[0], $firstCard[1])
   $baselineFirstCardMult = PixelGetColor($firstCardMult[0], $firstCardMult[1])
   $baselineSecondCard = PixelGetColor($firstCard[0] + $secondCardIncrement, $firstCard[1])
EndFunc

; This baseline is tricky, we can't establish it until we make sure we have a card
; with an X2 multiplier that is not new.
Dim $baselineNewCard = -1
Func getBaselineNewCard()
   If $baselineNewCard > -1 Then
	  return $baselineNewCard
   EndIf

   ; We hover over the card to make sure it's not new
   MouseMove($firstCard[0], $firstCard[1])

   $baselineNewCard = PixelGetColor($firstCardMult[0], $firstCardMult[1])
   Return $baselineNewCard
EndFunc

; Checks that the currently selected mana cost filter is appropriate
Func checkManaCostFilter($manaCost)
   If $manaCost <> $currentManaCost Then
	  MouseClick("left", $initialManaCoord[0] + $manaCostIncrement * $manaCost, $initialManaCoord[1])
	  $currentManaCost = $manaCost
	  Sleep(200) ; Otherwise it goes back to searching before it clicks some times
   EndIf
EndFunc

; Takes a card array and returns the search term for it, which includes the card description if possible
Func getSearchTerm($card)
   ; Search term is card name + card description
   Local $searchTerm = $card[2]

   ; Check that card description exists before adding to search term
   If $card[0] == 3 Then
	  $searchTerm = $searchTerm & " " & $card[3]
   EndIf

   Return $searchTerm
EndFunc

; Enter the card name and description in the search box and hit enter
Func searchForCard($searchTerm)
   MouseClick("left", $searchBox[0], $searchBox[1]) ; Click on search box
   ClipPut($searchTerm) ; Put the search term on the clipboard
   Sleep(10)
   Send("^v") ; Paste
   Send("{ENTER}") ; Hit Enter
   Sleep(100)
EndFunc

; Checks if the card is new and hovers over it if it is
Func checkForNewCard()
   ; The colour on the multiplier should be different from what it normally is if the card is new
   Local $currentNewCard = PixelGetColor($firstCardMult[0], $firstCardMult[1])
   Local $_baselineNewCard = getBaselineNewCard()
   Local $isNew = $_baselineNewCard <> $currentNewCard

   If $isNew Then
	  MouseMove($firstCard[0], $firstCard[1])
	  MouseMove($searchBox[0], $searchBox[1])
   EndIf

   Return $isNew
EndFunc

Func readScreenForCards()
   Local $numberOfCards = 0

   ; Current colours to compare to baseline
   Local $currentFirstCard = PixelGetColor($firstCard[0], $firstCard[1])
   Local $currentFirstCardMult = PixelGetColor($firstCardMult[0], $firstCardMult[1])
   Local $currentSecondCard = PixelGetColor($firstCard[0] + $secondCardIncrement, $firstCard[1])

   If $baselineFirstCard <> $currentFirstCard Then
	  $numberOfCards = 1 ; At least one card is detected

	  If $baselineSecondCard <> $currentSecondCard Then
		 Return 2 ; No need to check if the card is new
	  EndIf

	  If $baselineFirstCardMult <> $currentFirstCardMult Then
		 ; This pixel could be a false positive if the card is new
		 Local $wasNew = checkForNewCard()

		 ; Rather than check of edge cases, just do the whole check over now that the card is not new anymore
		 If $wasNew Then
			Return readScreenForCards()
		 EndIf

		 $numberOfCards = 2
	  EndIf
   EndIf

   Return $numberOfCards
EndFunc

Dim $isFirstLine = True
Func logCard($cardName, $numberOfCopies)
   If $numberOfCopies < 1 Then
	  Return
   EndIf

   If Not $isFirstLine Then
	  FileWrite($outputFile, "," & @CRLF) ; start a new line
   EndIf

   FileWrite($outputFile, "  ") ;indent
   FileWrite($outputFile, '"' & $cardName & '": ' & $numberOfCopies)

   $isFirstLine = False
EndFunc

Func readCollection()
   recordBaselineColours()

   ; start the json file
   startJsonFile()

   While 1
	  local $card = FileReadLine($inputFile)
	  If @error = -1 Then ExitLoop

	  ; $card is an array of card data [manaCost, Name, Description]
	  $card = StringSplit($card, "$")

	  checkManaCostFilter($card[1])

	  Local $searchTerm = getSearchTerm($card)

	  searchForCard($searchTerm)

	  Local $numberOfCopies = readScreenForCards()

	  logCard($card[2], $numberOfCopies)
   Wend

   FileWrite($outputFile, @CRLF & "}")

   FileClose($inputFile)
   FileClose($outputFile)
EndFunc

Func terminate()
   FileClose($inputFile)
   FileClose($outputFile)
   Exit
EndFunc

HotKeySet("{PAUSE}", "readCollection")
HotKeySet("{ESC}", "terminate")

While 1
   Sleep(1000)
WEnd