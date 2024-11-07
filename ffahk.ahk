Directory := "C:\Users\YOURNAME\Documents\Final Fantasy XIV\SquareEnix\FINAL FANTASY XIV - A Realm Reborn\boot\ffxivboot.exe" ; Replace the directory with the directory on your PC here
Password := "" ; Insert your password here

/*
The above sets user variables.

Directory should be changed to the directory of the file named "ffxivboot.exe" in your PC, beginning with C:\. Note you must use BACKSLASHES '\' and NOT FORWARD SLASHES '/'

Password should be changed to the password you use to login. This script does NOT work with one time passwords and should NOT BE USED if you use a one time password to login.
Place both values, the directory starting from C:\ and your password, inside the double quotation marks below.
Directory should look something like this:
	Directory := "C:\Users\YOURNAME\Documents\Final Fantasy XIV\SquareEnix\FINAL FANTASY XIV - A Realm Reborn\boot\ffxivboot.exe"
*/




Esc::ExitApp

; 		Initial function setup

; Error message for clicking out of the game or launcher window.
; arg0 - OPTIONAL - errorCode: The error code to throw before exiting script.
offWindow(errorCode:=0) {
	; If the game window is inactive for some reason, entire script fails. However, it should never be inactive when this function is called.
	if !WinActive("FINAL FANTASY XIV") {
		if errorCode = 0 {
			MsgBox("FFXIV's game window was detected but the game window was not selected. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again.")
		}
		else {
			MsgBox(errorCode)
		}
		ExitApp
	}
}

; Function to search inside a provided location for a provided color using a double check system to account for on screen animations that may cause false positives. Uses PixelSearch logic.
; arg0 - originX: The box's origin X coordinate
; arg1 - originY: The box's origin Y coordinate
; arg2 - range: The box's distance to search within, from the origin point
; arg3 - xDirection: The direction to search in for the X coordinates. An argument of 1 moves from left to right, -1 moves from right to left.
; arg4 - yDirection: The direction to search in for the Y coordinates. An argument of 1 moves from top to bottom, -1 moves from bottom to top.
; arg5 - colour: The color to search for
; arg6 - timeToSearch: The time to search before error is thrown. Given in whole seconds (not milliseconds)
; arg7 - interval: The interval between each pixel check in the box (smaller is more processing power). Given in milliseconds.
searchBox(originX, originY, range, xDirection, yDirection, colour, timeToSearch, interval) {
	failSafe := 0
	pixelIsDetected := false
	; Declare global to remind function it's global
	global searchBoxTop
	global searchBoxRight
	global searchBoxBottom
	global searchBoxLeft

	; Variables Ppxx and Ppyy
	Ppxx := 0
	Ppyy := 0
	while !pixelIsDetected {
		failSafe++
		Sleep(interval)
		WinActivate "FINAL FANTASY XIV"
		x1 := (originX-(range*xDirection))
		y1 := (originY-(range*yDirection))
		x2 := (originX+(range*xDirection))
		y2 := (originY+(range*yDirection))
		;MsgBox("X1 and Y1: " . x1 . ", " . y1 . ". X2 and Y2: " . x2 . ", " . y2 . ".")
		if PixelSearch(&Ppxx, &Ppyy, x1, y1, x2, y2, colour, 0) {
			; Initially the color is found. Re-do the search 25 milliseconds later to ensure the same pixel is there, meaning it's a button and not varying particle effects.
			temp_x_ := Ppxx
			temp_y_ := Ppyy
			Sleep(20)
			WinActivate "FINAL FANTASY XIV"
			if PixelSearch(&Ppxx, &Ppyy, (temp_x_-1), (temp_y_-1), (temp_x_+1), (temp_y_+1), colour, 0) {
				offWindow("Error code: " . xDirection . yDirection)
				pixelIsDetected := true
				; Set the initial box parameters. As this is the first while loop to execute, I do not have to verify I'm overwriting previous data.
				if (Ppxx < searchBoxLeft) {
					searchBoxLeft := Ppxx
				}
				if (Ppxx > searchBoxRight) {
					searchBoxRight := Ppxx
				}
				if (Ppyy < searchBoxTop) {
					searchBoxTop := Ppyy
				}
				if (Ppyy > searchBoxBottom) {
					searchBoxBottom := Ppyy
				}
			}
			else if failSafe > ((1000/interval) * timeToSearch) {
				MsgBox "Error code: " . xDirection . yDirection . "-a. Character confirmation menu was initially detected but could not be found after. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
				ExitApp
			}
		}
		else if (failSafe > ((1000/interval) * timeToSearch)) {
			MsgBox "Error code: " . xDirection . yDirection . "-b. Character confirmation menu not detected. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
			ExitApp
		}
	}
}


; Set universal values
launcherLoginButtonColor := 0x43a047
launcherStartButtonColor := 0x4caf50
gameStartButtonColor := 0xE5C689
gameCharacterNameColor := 0x81E4CE
;gameConfirmMenuBorderColor := 0x
gameConfirmButtonColor := 0xf1f1f1

; Open the launcher
Run Directory

; Set variables. failSafe and secondsToHang ensure the script doesn't run forever if FFXIV fails to launch or it's not detected.
; timeBetweenEachCheck is the number of milliseconds to wait before attempting to detect the window again.
windowExists := false
timeBetweenEachCheck := 200
secondsToHang := 10
failSafe := 0
; Keep checking to make sure the window exists. If it doesn't, then wait a portion of a second before checking again.
while !windowExists {
	failSafe++
	Sleep(timeBetweenEachCheck)
	if WinExist("FFXIVLauncher") {
		windowExists := true
	}
	else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
		MsgBox "FFXIV's Launcher did not launch, or it was not detected due to a different naming convention. Please exit the launcher and start the script again."
		ExitApp
	}
}

; Set variables. Reset safety variables after the while statement above is done executing to reuse them.
timeBetweenEachCheck := 200
secondsToHang := 10
failSafe := 0
pixelIsDetected := false
; Window size setting variable
dimensionSet := false
; Start the search
if windowExists {
	; If the window exists, ensure it's the active window before checking for a pixel inside of it
	WinActivate "FFXIVLauncher"
	; Get the launcher's width and height values. This is done only once.
	if !dimensionSet {
		WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, "FFXIVLauncher")
		if (OutX = 0) and (OutY = 0) and (OutWidth > 0) and (OutHeight > 0) {
			dimensionSet := true
		}
	}
	while !pixelIsDetected {
		failSafe++
		Sleep(timeBetweenEachCheck)
		; If the correctly colored pixel is detected here, then type the password in, and click login.
		if PixelSearch(&Px, &Py, 0, 0, OutWidth, OutHeight, launcherLoginButtonColor, 0) {
			if !WinActive("FFXIVLauncher") {
				WinActivate "FFFXIVLauncher"
				Sleep(50)
			}
			pixelIsDetected := true
			Click(OutWidth * 0.64922, OutHeight * 0.4694)
			SendText Password
			Sleep(25)
			SendEvent('{Enter}')
		}
		else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
			MsgBox "FFXIV's Launcher was detected but the login field was not before a time out. Ensure that you do not click off the launcher while this script is running. Please exit the launcher and start the script again."
			ExitApp
		}
	}
}

; Now that the script has detected the play button, typed the password and hit enter, wait again until the second
; play button appears, and then hit enter on that.
; Note that 'timeBetweenEachCheck' is set significantly shorter here since the second "Play" screen often loads quickly
timeBetweenEachCheck := 20
secondsToHang := 10
failSafe := 0
pixelIsDetected := false
while (!pixelIsDetected) {
	WinActivate "FFXIVLauncher"
	failSafe++
	Sleep(timeBetweenEachCheck)
	if PixelSearch(&Px, &Py, 0, 0, OutWidth, OutHeight, launcherStartButtonColor, 0) {
		if !WinActive("FFXIVLauncher") {
			WinActivate "FFFXIVLauncher"
			Sleep(50)
		}
		pixelIsDetected := true
		SendEvent('{Enter}')
	}
	else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
		MsgBox "FFXIV's Launcher failed at the 'Play' button screen. Ensure that you do not click off the launcher while this script is running. Please exit the launcher and start the script again."
		ExitApp
	}
}

; Now the the script has launched the official game, detect the game window, then wait until the start button is detected before clicking on it.
; There is a slight delay before the click to allow for title screen animations to finish.
timeBetweenEachCheck := 200
secondsToHang := 15
failSafe := 0
windowExists := false
pixelIsDetected := false
dimensionSet := false
; Keep checking to make sure the window exists. If it doesn't, then wait a portion of a second before checking again.
while !windowExists {
	failSafe++
	Sleep(timeBetweenEachCheck)
	if WinExist("FINAL FANTASY XIV") {
		windowExists := true
	}
	else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
		MsgBox "FINAL FANTASY XIV did not launch, or it was not detected due to a different naming convention. Please exit both the launcher and the game, and start the script again."
		ExitApp
	}
}

; Start the search for the game window's 'Start' button
timeBetweenEachCheck := 20
secondsToHang := 5
failSafe := 0
; Check to make sure the game window itself exists first
if windowExists {
	; If the window exists, ensure it's the active window before checking for a pixel inside of it
	WinActivate "FINAL FANTASY XIV"
	; Get the game's width and height values. This is done only once. A delay is added to maximize the game window first.
	while !dimensionSet {
		failSafe++
		Sleep(timeBetweenEachCheck)
		WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, "FINAL FANTASY XIV")
		if (OutWidth > 0) and (OutHeight > 0) {
			WinActivate "FINAL FANTASY XIV"
			WinGetClass
			WinMaximize
			Sleep(1000)
			Click(100, 100)
			Sleep(100)
			Send "#{Up}"
			Sleep(100)
			Click(100, 100)
			Sleep(100)
			Send "#{Up}"
			WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, "FINAL FANTASY XIV")
			dimensionSet := true
		}
		else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
			MsgBox "FINAL FANTASY XIV launched, but the game window's size could not be detected. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
			ExitApp
		}
	}

	; Now that the game window is maximized, search for the game's 'Start' button. 
	; I double check to make sure the same pixel is the identical color a moment later, because there are particle effects and animations that play on game start that flash by and are identical sometimes to the start
	; button's size.
	timeBetweenEachCheck := 200
	secondsToHang := 30
	failSafe := 0
	temp_x_ := 0
	temp_y_ := 0
	while !pixelIsDetected {
		failSafe++
		Sleep(timeBetweenEachCheck)
		; If the correctly colored pixel is detected in the lower half of the game window, then click on the Start button.
		; PixelSearch operates by moving left to right, then top to bottom, so because the 'Start' button is always at the top, the first pixel with the specified color will be chosen,
		; which will always be the 'Start' button.
		WinActivate "FINAL FANTASY XIV"
		if PixelSearch(&Px, &Py, (OutWidth*(1/3)), (OutHeight/2), (OutWidth*(2/3)), OutHeight, gameStartButtonColor, 3) {
			; Initially the color is found. Re-do the search 20 milliseconds later to ensure the same pixel is there, meaning it's a button and not varying particle effects.
			temp_x_ := Px
			temp_y_ := Py
			Sleep(20)
			WinActivate "FINAL FANTASY XIV"
			if PixelSearch(&Px, &Py, (temp_x_-1), (temp_y_ - 1), (temp_x_ + 1), (temp_y_ + 1), gameStartButtonColor, 0) {
				offWindow()
				; Set pixel to detected, to exit the while loop, then double click on the game 'Start' button. The first click is to let the game know you're in the window in case you weren't before.
				; The second click is to actually select the 'Start' button, in case it wasn't already selected.
				pixelIsDetected := true
				Click(Px, Py)
				Sleep(50)
				Click(Px, Py)
			}
			else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
				MsgBox "FFXIV's game window was detected but the game's 'Start' button was not before a time out. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
				ExitApp
			}
		}
		else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
			MsgBox "FFXIV's game window was detected but the game's 'Start' button was not before a time out. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
			ExitApp
		}
	}
}

timeBetweenEachCheck := 50
secondsToHang := 15
failSafe := 0
pixelIsDetected := false
; Now, just character selecting left.
; First, reset variables.
; Finally, look for the two last buttons needed to login.
if windowExists {
	WinActivate "FINAL FANTASY XIV"
	; Detection for game character name to click on
	while !pixelIsDetected {
		failSafe++
		Sleep(timeBetweenEachCheck)
		; This searches the furthest right 3rd of the game and top 4th of the game for the game character name color.
		; A double search like above is needed, because of the aforementioned particle effects.
		if PixelSearch(&Px, &Py, (OutWidth*(2/3)), 0, OutWidth, (OutHeight*(1/4)), gameCharacterNameColor, 3) {
			; Initially the color is found. Re-do the search 20 milliseconds later to ensure the same pixel is there, meaning it's a button and not varying particle effects.
			temp_x_ := Px
			temp_y_ := Py
			Sleep(40)
			WinActivate "FINAL FANTASY XIV"
			if PixelSearch(&Px, &Py, (temp_x_-1), (temp_y_-1), (temp_x_+1), (temp_y_+1), gameCharacterNameColor, 3) {
				offWindow()
				; Set pixel to detected, to exit the while loop, then double click on the game 'Start' button. The first click is to let the game know you're in the window in case you weren't before.
				; The second click is to actually select the 'Start' button, in case it wasn't already selected.
				pixelIsDetected := true
				Sleep(100)
				Click(Px, Py)
				Sleep(100)
				Click(Px, Py)
			}
			else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
				MsgBox "Character name initially detected but could not be found after. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
				ExitApp
			}
		}
		else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
			MsgBox "Character name not detected. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
			ExitApp
		}
	}
	
	; Now that the name is detected, search again for the confirmation menu in the center of the screen. This is the final button to press.
	; I first need to find the menu, which is done by searching the entire screen for the white text in the menu.
	; I then confirm it's there via a double check like above.
	; Once the menu is found, I set a small search box, and then search through it 4 times, once in each direction (left to right and top to bottom, then left to right but bottom to top, etc.)
	; I store the furthest locations of each pixel found, which gives me a narrow box to search through.
	; Lastly, I split box into quadrants, and because the 'OK' button will be in the bottom left quadrant, I can guarantee the white text found in that quadrant is the 'OK' button.

	; Reset standard variables
	timeBetweenEachCheck := 25
	secondsToHang := 5
	failSafe := 0
	pixelIsDetected := false

	; Delay a moment to allow the search window to appear
	Sleep(50)

	; Create variables needed for this specific check
	; Because searchBoxVarianceSize is used to shift the search left and right, the actual search area will be double whatever is here. E.g. it's set to (OutWidth/8), so the total search area will be 1/4 the size of OutWidth.
	searchBoxVarianceSize := (OutWidth/8)
	searchBoxOriginX := 0
	searchBoxOriginY := 0

	global searchBoxTop := 0
	global searchBoxRight := 0
	global searchBoxBottom := 0
	global searchBoxLeft := 0

	; Search just for the initial white pixel to create the search box
	while !pixelIsDetected {
		failSafe++
		Sleep(timeBetweenEachCheck)
		; This searches the entire screen for the confirmation menu, as the menu can move around and is not guaranteed to be in any 1 location.
		if PixelSearch(&Px, &Py, (OutWidth*(1/4)), (OutHeight*(1/5)), (OutWidth*(4/5)), (OutHeight*(4/5)), gameConfirmButtonColor, 0) {
			; Initially the color is found. Re-do the search 25 milliseconds later to ensure the same pixel is there, meaning it's a button and not varying particle effects.
			temp_x_ := Px
			temp_y_ := Py
			if (temp_x_ >= (OutWidth - 1)) {
				temp_x_ := (OutWidth - 1)
			}
			if (temp_y_ >= (OutHeight - 1)) {
				temp_y_ := (OutHeight - 1)
			}
			Sleep(20)
			WinActivate "FINAL FANTASY XIV"
			if PixelSearch(&Px, &Py, (temp_x_-1), (temp_y_-1), (temp_x_+1), (temp_y_+1), gameConfirmButtonColor, 0) {
				offWindow()
				; Set pixel to detected, to exit the while loop, then double click on the game 'Start' button. The first click is to let the game know you're in the window in case you weren't before.
				; The second click is to actually select the 'Start' button, in case it wasn't already selected.
				pixelIsDetected := true
				searchBoxOriginX := Px
				searchBoxOriginY := Py
			}
			else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
				MsgBox "Character confirmation menu was initially detected but could not be found after. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
				ExitApp
			}
		}
		else if (failSafe > ((1000/timeBetweenEachCheck) * secondsToHang)) {
			MsgBox "Character confirmation menu not detected. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
			ExitApp
		}
	}

	; Now that the search box has been created, used it to search again for more white pixels, except this time updating the specific search location area (searchBoxTop, searchBoxRight, etc.)
	if (searchBoxOriginX > 0) and (searchBoxOriginY > 0) {
		; LR,TB: Search executed Left to Right - Top to Bottom
		timeBetweenEachCheck := 25
		secondsToHang := 5
		failSafe := 0
		pixelIsDetected := false
		Sleep(1500)
		while !pixelIsDetected {
			failSafe++
			Sleep(timeBetweenEachCheck)
			if PixelSearch(&Px, &Py, (searchBoxOriginX-searchBoxVarianceSize), (searchBoxOriginY-searchBoxVarianceSize), (searchBoxOriginX+searchBoxVarianceSize), (searchBoxOriginY+searchBoxVarianceSize), gameConfirmButtonColor, 0) {
				; Initially the color is found. Re-do the search 25 milliseconds later to ensure the same pixel is there, meaning it's a button and not varying particle effects.
				temp_x_ := Px
				temp_y_ := Py
				Sleep(20)
				WinActivate "FINAL FANTASY XIV"
				if PixelSearch(&Px, &Py, (temp_x_-1), (temp_y_-1), (temp_x_+1), (temp_y_+1), gameConfirmButtonColor, 0) {
					offWindow("Error Code: 11")
					pixelIsDetected := true
					; Set the initial box parameters. As this is the first while loop to execute, I do not have to verify I'm overwriting previous data.
					searchBoxLeft := Px
					searchBoxRight := Px
					searchBoxTop := Py
					searchBoxBottom := Py
					Click(Px, Py)
				}
				else if failSafe > ((1000/timeBetweenEachCheck) * secondsToHang) {
					MsgBox "Error code 11-a. Character confirmation menu was initially detected but could not be found after. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
					ExitApp
				}
			}
			else if (failSafe > ((1000/timeBetweenEachCheck) * secondsToHang)) {
				MsgBox "Error code 11-b. Character confirmation menu not detected. Ensure that you do not click off the game while this script is running. Please exit the game and start the script again."
				ExitApp
			}
		}
		
		; LR, BT: Search executed Left to Right - Bottom to Top - Error Code 1-1
		timeBetweenEachCheck := 25
		secondsToHang := 2
		failSafe := 0
		pixelIsDetected := false
		searchBox(searchBoxOriginX, searchBoxOriginY, searchBoxVarianceSize, 1, (-1), gameConfirmButtonColor, secondsToHang, timeBetweenEachCheck)

		; RL, TB: Search executed Right to Left - Top to Bottom - Error Code -11
		timeBetweenEachCheck := 25
		secondsToHang := 2
		failSafe := 0
		pixelIsDetected := false
		searchBox(searchBoxOriginX, searchBoxOriginY, searchBoxVarianceSize, (-1), 1, gameConfirmButtonColor, secondsToHang, timeBetweenEachCheck)

		; RL, BT: Search executed Right to Left - Bottom to Top - Error Code -1-1
		timeBetweenEachCheck := 25
		secondsToHang := 2
		failSafe := 0
		pixelIsDetected := false
		searchBox(searchBoxOriginX, searchBoxOriginY, searchBoxVarianceSize, (-1), (-1), gameConfirmButtonColor, secondsToHang, timeBetweenEachCheck)
	}


	; Finally, split the new search box into quadrants, and search, then click, on the pixel found in the bottom left quadrant, where the 'OK' button is at.
	timeBetweenEachCheck := 20
	secondsToHang := 2
	failSafe := 0
	pixelIsDetected := false
	; This is the top of the quadrant to search in, minus half of the difference between the bottom and top of the box (the height of the search box / 2).
	topOfQuadrant := (searchBoxBottom-((searchBoxBottom-searchBoxTop)/2))
	; This is the right side of the quadrant to search in, minus the half of the difference between the right and left sides of the box (the width of the search box / 2).
	rightOfQuadrant := (searchBoxRight-((searchBoxRight-searchBoxLeft)/2))
	while (!pixelIsDetected) {
		failSafe++
		Sleep(timeBetweenEachCheck)
		WinActivate "FINAL FANTASY XIV"
		if PixelSearch(&Px, &Py, searchBoxLeft, searchBoxBottom, rightOfQuadrant, topOfQuadrant, gameConfirmButtonColor, 0) {
			pixelIsDetected := true
			Click(Px, Py)
			Sleep(50)
			Click(Px, Py)
		}
	}
}

/*
Sleep, 8000
Send, {Enter}
Sleep, 5000
Send, {Enter}
Sleep, 18000
Send, {LWin down}{Up}
Sleep, 50
Send, {LWin up}
Sleep, 100
Click, 1286 1093
Sleep, 9000
Click, 2206 168
Sleep, 800
Click, 1224 726
*/

ExitApp