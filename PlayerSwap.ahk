#SingleInstance Force
; Created by Tomshi - https://www.twitch.tv/tomshi
; v1.0.0

; This script was created for https://www.twitch.tv/Dangers
; It allows tracking of bits and subs in a given stream (using local text files created by streamlabels or anything that pulls from the twitch api) so the player with the higher total $ count plays the game allowing swapping back and forth for funny gameplay and content as the total $ changes back and forth

/* 
Copyright (C) 2022 - Tomshi

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

;first we define where the streamlabels folder is
if DirExist(A_Desktop "\Streaming\StreamLabels\")
    files := A_Desktop "\Streaming\StreamLabels\"
else
    {
        MsgBox("A StreamLabels Folder is required at`n[" A_Desktop "\Streaming\StreamLabels\]")
        return
    }

;here we will define some values for use later
getvalue() {
    global
    cheerRead := FileRead(files "session_cheer_amount.txt") ;reads the text file
    cheerStart := cheerRead/100 ;divides by 100 as 1 bit is 1c
    cheerstartround := Round(cheerStart, 2) ;rounds to 2dp so the number doesn't overflow
    subsRead := FileRead(files "session_subscriber_score.txt") ;reads the text file - gets the subpoint value. Using subpoints means that resubs will not count as they do not increment the subpoints
    subsStart := subsRead * 2.5 ;multiplies by 2.5 as 1 sub is worth $2.5 (well.. not really but close enough) and 1 sub gives 1 subpoint. This means technically T3 emotes give the wrong $ amount, but it's better than them only counting as $2.5.
    subsstartround := Round(subsStart, 2) ;rounds to 2dp so the number doesn't overflow
}
getvalue() ;running the above function

;next we will define our gui
MyGui := Gui("AlwaysOnTop", "Show Info")
MyGui.SetFont("S15") ;Sets the size of the font
MyGui.SetFont("W500") ;Sets the weight of the font (thickness)
MyGui.Opt("+MinSize430x150 +MaxSize430x150")

;creating the groupboxes
dangersTitle := MyGui.Add("GroupBox", "w170 h100 Y0", "Dangers")
azureTitle := MyGui.Add("GroupBox", "w170 h100 X200 Y0", "Azure")

;defining the text to show total amounts
dangersAmount := MyGui.Add("Text", "X30 Y40 W155 vDangers", "$ " cheerstartround)
dangersAmount.SetFont("cPurple")
azureAmount := MyGui.Add("Text", "X210 Y40 W155 vAzure", "$ " subsstartround)
azureAmount.SetFont("cblue")

;defining the text detailing who is currently playing
playing := MyGui.Add("Text", "X18 Y110 W50", "Playing: ")
player := MyGui.Add("Text", "X90 Y110 W150 W100", "...")

;next we do some math to show how much $ is required to swap players
math() {
    global
    swapmath := cheerstartround - subsstartround ;subtracts one value by the other
    untilswap := Abs(swapmath) ;takes the absolute value so even if the number is negative, it'll show positive
    swapround := Round(untilswap, 2) ;rounds to 2dp so the number doesn't overflow
}
math() ;running the above function
swap := MyGui.Add("Text", "X200 Y110 W200", "$ " swapround " until swap")

;define what to do when the gui is closed
MyGui.OnEvent("Close", closegui)

MyGui.Show()

closegui(*) {
    MyGui.Destroy() ;I don't think this line is necessary but why not
    DetectHiddenWindows(true)
    SetTitleMatchMode 2
    if WinExist("PlayerSwap.ahk - AutoHotkey")
		WinClose()
    if WinExist("PlayerSwap.exe")
		WinClose()
}

;defining how frequently the script checks the local files for updates, the below value details it in seconds
fire_frequency := 2.5
global fire := fire_frequency * 1000
SetTimer(update, -fire) ;this timer is what allows us to repeatedly update the gui

update()
{
    ;running that above function
    getvalue()
    ;doing math again then updating the text
    math()
    swap.Text := "$ " swapround " until swap"

    ;updating player amounts
    dangersAmount.Text := "$ " cheerstartround
    azureAmount.Text := "$ " subsstartround

    ;some logic to determine who should be playing as well as changing the colour
    if cheerstartround > subsstartround
        {
            player.Text := "Dangers"
            player.SetFont("cPurple")
            player.Opt("W80")
        }
    if cheerstartround = subsstartround
        {
            player.Text := "uh.. Both??"
            player.SetFont("cblack")
            player.Opt("W150")
        }
    if cheerstartround < subsstartround
        {
            player.Text := "Azure"
            player.SetFont("cblue")
            player.Opt("W80")
        }
    ;resets the timer so it'll update again in the previously defined time
    SetTimer(, -fire)
}