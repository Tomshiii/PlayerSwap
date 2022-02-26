#SingleInstance Force
#Requires AutoHotkey v2.0-beta.1
TraySetIcon(A_ScriptDir "\Assets\icon.ico")
; Created by Tomshi - https://www.twitch.tv/tomshi - https://github.com/Tomshiii
version := "v1.3.3"

;@Ahk2Exe-SetMainIcon "C:\Program Files\ahk\PlayerSwap\Assets\icon.ico"
;@Ahk2Exe-SetCompanyName Tomshi
;@Ahk2Exe-SetVersion 1.3.3
;@Ahk2Exe-SetDescription Player Swap
;@Ahk2Exe-SetName Player Swap
;@Ahk2Exe-SetCopyright 2022

; This script was originally created for https://www.twitch.tv/Dangers
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

;////////// USER DEFINE INFORMATION READ FROM INI FILE //////////
; first we define where the streamlabels folder is
userFolderIni := IniRead(A_ScriptDir "\User_Values.ini", "Info", "StreamLabelsFolder")

if DirExist(userFolderIni)
    {
        if FileExist(userFolderIni "\session_cheer_amount.txt")
            files := userFolderIni
        else
            {
                MsgBox("There doesn't seem to be any StreamLabels files in the defined directory, reopen Player Swap and select a correct directory")
                IniWrite("", A_ScriptDir "\User_Values.ini", "Info", "StreamLabelsFolder")
                return
            }
    }
else
    {
        SLPath := MsgBox("A StreamLabels folder was not detected, would you like to set it now?", "Set StreamLabels Folder", "4 32")
        if SLPath = "No"
            return
        else
            {
                dir:
                SLDir := DirSelect("::{20d04fe0-3aea-1069- a2d8-08002b30309d}", 1, "Select StreamLabels Folder")
                if SLDir = ""
                    return
                if FileExist(SLDir "\session_cheer_amount.txt")
                    {
                        IniWrite('"' SLDir '\"', A_ScriptDir "\User_Values.ini", "Info", "StreamLabelsFolder")
                        global files := IniRead(A_ScriptDir "\User_Values.ini", "Info", "StreamLabelsFolder")
                    }
                else
                    {
                        MsgBox("There doesn't seem to be any StreamLabels files in the selected directory, please try again")
                        goto dir
                    }
            }        
    }

; defining player names using the ini file
global playerBits := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerBits")
global playerSubs := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerSubs")

; defining player colours using the ini file
playerBitsColour := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerBitsColour")
playerSubsColour := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerSubsColour")

;////////// END USER INI INFORMATION //////////


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
MyGui := Gui("AlwaysOnTop", "Player Swap")
MyGui.SetFont("S15") ;Sets the size of the font
MyGui.SetFont("W500") ;Sets the weight of the font (thickness)
MyGui.Opt("+MinSize430x150 +MaxSize430x150")

;creating the groupboxes
player_bits_Title := MyGui.Add("GroupBox", "w170 h100 Y0", playerBits)
player_subs_Title := MyGui.Add("GroupBox", "w170 h100 X200 Y0", playerSubs)

;defining the text to show total amounts
player_bits_amount := MyGui.Add("Text", "X30 Y50 W155", "$ " cheerstartround)
player_bits_amount.SetFont(playerBitsColour)
player_subs_amount := MyGui.Add("Text", "X210 Y50 W155", "$ " subsstartround)
player_subs_amount.SetFont(playerSubsColour)

;defining settings button
settingsButton := MyGui.Add("Button", "X400 Y10 w25 h26", "⚙")
settingsButton.SetFont("S13")
settingsButton.OnEvent("Click", settings)

;defining images to help guide the player
bitsImage := MyGui.Add("Picture", "X160 Y5 w20 h-1", A_ScriptDir  "\Assets\bits.png")
subsImage := MyGui.Add("Picture", "X340 Y5 w20 h-1", A_ScriptDir  "\Assets\subs.png")

;defining the text detailing who is currently playing
playing := MyGui.Add("Text", "X18 Y110 W50", "Playing: ")
player := MyGui.Add("Text", "X90 Y110 W150 W100", "waiting...")

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
    DetectHiddenWindows(true)
    SetTitleMatchMode 2
    if WinExist("PlayerSwap.ahk - AutoHotkey")
		WinClose()
    if WinExist("PlayerSwap.exe")
		WinClose()
    MyGui.Destroy() ;I don't think this line is necessary but why not
}

settings(*) {
    settingswin := Gui("+owner" MyGui.Hwnd, "Player Swap")
    MyGui.Opt("+Disabled")
    settingswin.SetFont("S12")

    ;define settings title
    settings_title := settingswin.Add("Text",, "Settings")
    settings_title.SetFont("underline")

    ;define version text
    version_text := settingswin.Add("Text", "X215 Y12", "Release " version)
    version_text.SetFont("underline S11")
    version_text.OnEvent("Click", openVer)

    ;define bits/subs underline titles
    settings_bits := settingswin.Add("Text","X80 Y45", "Player - Bits")
    settings_bits.SetFont("S11 underline")
    settings_subs := settingswin.Add("Text", "X205 Y45", "Player - Subs")
    settings_subs.SetFont("S11 underline")

    ;define the name text
    settings_names := settingswin.Add("Text", "X15 Y85", "Names:")
    settings_names.SetFont("S12")
    ;define bit input field
    bits_edit := settingswin.Add("Edit", "r1 vbitsEdit w100 X80 Y80")
    bits_edit.SetFont("S10")
    bits_edit.Value := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerBits")
    bits_edit.OnEvent("Change", bitsIniWrite)
    ;define sub input field
    subs_edit := settingswin.Add("Edit", "r1 vsubsEdit w100 X205 Y80")
    subs_edit.SetFont("S10")
    subs_edit.Value := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerSubs")
    subs_edit.OnEvent("Change", subsIniWrite)
    
    ;define the colour text
    settings_Colour := settingswin.Add("Text", "X15 Y125", "Colour:")
    settings_Colour.SetFont("S12")
    ;define bit colour
    bits_colour := settingswin.Add("DropDownList", "vBitColorChoice w100 X80 Y125", ["Black","Red","Green","Blue", "Teal", "Aqua", "Yellow", "Purple", "Fuchsia"])
    bits_colour.SetFont("S10")
    bits_colour.OnEvent("Change", bitsColour)
    ;define bit colour
    subs_colour := settingswin.Add("DropDownList", "vSubsColorChoice w100 X205 Y125", ["Black","Red","Green","Blue", "Teal", "Aqua", "Yellow", "Purple", "Fuchsia"])
    subs_colour.SetFont("S10")
    subs_colour.OnEvent("Change", subsColour)

    ;define separator
    seperate := settingswin.Add("Text", "X7 Y155", "_________________________________")
    ;defining update frequency
    update_text := settingswin.Add("Text", "X40 Y203", "Update Frequency (s):")
    update_text.SetFont("S12")
    update_start := fire_frequency
    update_setting := settingswin.Add("Edit", "X205 Y200 w100")
    update_updown := settingswin.Add("UpDown",, fire_frequency)
    update_setting.SetFont("S10")
    update_updown.OnEvent("Change", updown)
    update_setting.OnEvent("Change", updown)

    ;defining final button
    okayButton := settingswin.Add("Button", "Default X260 Y240 w45 h30", "OK")
    okayButton.SetFont("S10")
    okayButton.OnEvent("Click", okayClick)

    settingswin.OnEvent("Close", closesettingsgui)
    settingswin.Show()

    bitsIniWrite(*) {
        IniWrite('"' bits_edit.Value '"', A_ScriptDir "\User_Values.ini", "Info", "playerBits")
        player_bits_Title.Text := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerBits")
        global playerBits := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerBits")
    }
    subsIniWrite(*) {
        IniWrite('"' subs_edit.Value '"', A_ScriptDir "\User_Values.ini", "Info", "playerSubs")
        player_subs_Title.Text := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerSubs")
        global playerSubs := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerSubs")
    }
    bitsColour(*) {
        IniWrite('"c' bits_colour.Text '"', A_ScriptDir "\User_Values.ini", "Info", "playerBitsColour")
        global playerBitsColour := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerBitsColour")
        player_bits_amount.SetFont(playerBitsColour)
    }
    subsColour(*) {
        IniWrite('"c' subs_colour.Text '"', A_ScriptDir "\User_Values.ini", "Info", "playerSubsColour")
        global playerSubsColour := IniRead(A_ScriptDir "\User_Values.ini", "Info", "playerSubsColour")
        player_subs_amount.SetFont(playerSubsColour)
    }
    okayClick(*) {
        MyGui.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        settingswin.Destroy()  ; Destroy the about box.
    }
    closesettingsgui(*) {
        MyGui.Opt("-Disabled")
    }
    updown(*) {
        IniWrite('"' update_updown.Value '"', A_ScriptDir "\User_Values.ini", "Info", "updateFrequency")
        global fire_frequency := IniRead(A_ScriptDir "\User_Values.ini", "Info", "updateFrequency")
        global fire := fire_frequency * 1000
    }
    openVer(*) {
        if not WinExist("Releases · Tomshiii/PlayerSwap")
            run("https://github.com/Tomshiii/PlayerSwap/releases")
    }
}

;defining how frequently the script checks the local files for updates, the below value details it in seconds
fire_frequency := IniRead(A_ScriptDir "\User_Values.ini", "Info", "updateFrequency")
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
    player_bits_amount.Text := "$ " cheerstartround
    player_subs_amount.Text := "$ " subsstartround

    ;some logic to determine who should be playing as well as changing the colour
    if cheerstartround > subsstartround
        {
            player.Text := playerBits
            player.SetFont(playerBitsColour)
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
            player.Text := playerSubs
            player.SetFont(playerSubsColour)
            player.Opt("W80")
        }
    ;resets the timer so it'll update again in the previously defined time
    SetTimer(, -fire)
}