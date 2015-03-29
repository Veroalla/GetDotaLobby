forceCScriptExecution

dim dotapath
dotapath = readfromRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 570\InstallLocation", "")

if dotapath = "" then
	wscript.echo "Failed to find the dota directory.  If you're sure dota is installed, follow the manual installation."
  GoSleep(3)
	wscript.quit(1)
end if

'dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
dim xHttp: Set xHttp = createobject("MSXML2.ServerXMLHTTP.6.0")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", "http://getdotastats.com/d2mods/api/lobby_version.txt", False
'xHttp.Open "GET", "https://github.com/GetDotaStats/GetDotaLobby/raw/master/version.txt", False
xHttp.Send

dim latestVer, currentVer
latestVer = CDbl(xHttp.responseText)
currentVer = 0.00

dim verFile
Set objFSO = CreateObject("Scripting.FileSystemObject")
If (objFSO.FileExists("version.txt")) Then
  Set verFile = objFSO.OpenTextFile("version.txt",1)
  currentVer = CDbl(verFile.ReadAll())
  verFile.Close
  Set verFile = Nothing
End If

Wscript.echo "Latest Version: " & latestVer & " -- Current Version: " & currentVer

If (currentVer >= latestVer) Then
  Wscript.echo "Your Lobby Explorer is up to date.  No update will be performed"
  GoSleep(2)
  Wscript.quit(0)
End If

Wscript.echo "Your Lobby Explorer is not up to date.  Downloading new version.  Please wait."
Set xHttp = createobject("MSXML2.ServerXMLHTTP.6.0")
Set bStrm = createobject("Adodb.Stream")
'xHttp.Open "GET", "https://github.com/GetDotaStats/GetDotaLobby/raw/lobbybrowser/play_weekend_tourney.zip", False
xHttp.Open "GET", "https://github.com/GetDotaStats/GetDotaLobby/raw/master/play_weekend_tourney.zip", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    .savetofile "lx.zip", 2 '//overwrite
end with

Wscript.echo "Download complete.  Finding your steam directory paths."

Wscript.echo "INSTALLING LOBBY EXPLORER"
if objFSO.FolderExists(dotapath) then
  Wscript.echo "Installing in path: " & dotapath & "\dota\resource\flash3"
  
  Dim objShell
  Set objShell = WScript.CreateObject ("WScript.shell")
  objShell.run "cmd /c mkdir """ & dotapath & "\dota\resource\flash3""", 7, true
  'objShell.run "xcopy resource """ & dotapath & "\dota\resource""" & " /Y /E ", 7, true
  Set objShell = Nothing
  
  UnzipFiles objFSO.GetAbsolutePathName(dotapath & "\dota\resource\flash3"), objFSO.GetAbsolutePathName("./lx.zip")
end if 

' Write out the version.txt since the update suceeded
Set verFile = objFSO.OpenTextFile("version.txt",2,true)
verFile.WriteLine(latestVer)
verFile.Close
Set verFile = Nothing

GoSleep(2)

wscript.quit(0)


Function GoSleep(seconds) 

wsv = WScript.Version 

if wsv >= "5.1" then 
WScript.Sleep(seconds * 1000) 
else 

startTime = Time() ' gets the current time 
endTime = TimeValue(startTime) + TimeValue(elapsed) ' calculates when time is up 

While endTime > Time() 

DoEvents 
Wend 
end if 
End Function 

Sub forceCScriptExecution
    Dim Arg, Str
    If Not LCase( Right( WScript.FullName, 12 ) ) = "\cscript.exe" Then
        For Each Arg In WScript.Arguments
            If InStr( Arg, " " ) Then Arg = """" & Arg & """"
            Str = Str & " " & Arg
        Next
        CreateObject( "WScript.Shell" ).Run _
            "cscript //nologo """ & _
            WScript.ScriptFullName & _
            """ " & Str
        WScript.Quit
    End If
End Sub

function readFromRegistry (strRegistryKey, strDefault )
    Dim WSHShell, value

    On Error Resume Next
    Set WSHShell = CreateObject("WScript.Shell")
    value = WSHShell.RegRead( strRegistryKey )

    if err.number <> 0 then
        readFromRegistry= strDefault
    else
        readFromRegistry=value
    end if

    set WSHShell = nothing
end function

    '========================
    'Sub: UnzipFiles
    'Language: vbscript
    'Usage: UnzipFiles("C:\dir", "extract.zip")
    'Definition: UnzipFiles([Directory where zip is located & where files will be extracted], [zip file name])
    '========================
    Sub UnzipFiles(folder, file)
        Dim sa, filesInzip, zfile, fso, i : i = 1
        Set sa = CreateObject("Shell.Application")
        Set fso = CreateObject("Scripting.FileSystemObject")
        'WScript.echo folder
        'WScript.echo file
        Set filesInzip=sa.NameSpace(file).Items()
        For Each zfile In filesInzip
            If Not fso.FileExists(folder & zfile) Then
                sa.NameSpace(folder).CopyHere zfile, 20
                i = i + 1
            End If
            If i = 99 Then
            zCleanup file, i
            i = 1
            End If
        Next
        If i > 1 Then 
            zCleanup file, i
        End If
        'fso.DeleteFile(folder&file)
    End Sub

    '========================
    'Sub: zCleanup
    'Language: vbscript
    'Usage: zCleanup("filename.zip", 4)
    'Definition: zCleanup([Filename of Zip previously extracted], [Number of files within zip container])
    '========================
    Sub zCleanUp(file, count)   
        'Clean up
        Dim i, fso
        Set fso = CreateObject("Scripting.FileSystemObject")
        For i = 1 To count
           If fso.FolderExists(fso.GetSpecialFolder(2) & "\Temporary Directory " & i & " for " & file) = True Then
           text = fso.DeleteFolder(fso.GetSpecialFolder(2) & "\Temporary Directory " & i & " for " & file, True)
           Else
              Exit For
           End If
        Next
    End Sub