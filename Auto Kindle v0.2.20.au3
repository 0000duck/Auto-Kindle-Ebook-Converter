DirRemove("Temp", 1)
DirCreate("Temp")
$message = "Select an ebook file PDF HTML or LIT to convert."
$clitProgram = "app\clit.exe -d"
$mobigenProgram = "app\mobigen.exe "
$pdftohtmlProgram = "app\pdftohtml.exe -i "
$fileIn = FileOpenDialog($message, @MyDocumentsDir & "\", "ebook (*.pdf;*.html;*.htm;*.lit)", 1 + 2 )
$fileInDir = @WorkingDir
If @error Then
MsgBox(4096,"Error","No File Chosen - Exitting without conversion.")
exit
EndIf
$fileIn = StringReplace($fileIn, "|", @CRLF)
$fileExt = StringRight($fileIn, 4)
$fileExt = StringReplace($fileExt , ".", "")
$fileName = StringTrimRight($fileIn, StringLen($fileExt)+1)
$fileName2 = StringReplace($fileIn, $fileInDir, "")
$fileName2 = StringTrimRight($fileName2, StringLen($fileExt)+1)
;MsgBox(0,$fileIn,$fileName)
$fileExt = StringLower($fileExt)
;MsgBox(0,$fileExt,$fileIn)
$fileOut = FileSelectFolder ( "Select The Destination (Kindle) Folder", "",1)
If @error Then
MsgBox(4096,"Error","No folder chosen - Exitting without conversion")
exit
EndIf
$tempFolder = "Temp"
Select
	Case $fileExt == "html" OR $fileExt == "htm"
		ProgressOn("","Converting Ebook", "", -1, -1,1)
		ProgressSet( 10, "Converting From HTML to Mobi", "Converting Ebook")
		RunWait(@ComSpec & " /c " & $mobigenProgram &""""&$fileIn&"""", @ScriptDir, @SW_HIDE)
		ProgressSet( 50, "Moving Files", "Converting Ebook")
		Sleep(1000)
		FileMoveTest($fileName, $fileOut)
		;FileMove($fileName&".mobi", $fileOut, 1)
		ProgressSet( 100, "Complete", "Converting Ebook")
		Sleep(2000)
		ProgressOff()
	Case $fileExt == "lit"
		;MsgBox(0,"LIT Files", "Warning some lit files will change their names to the title from inside the file.  If this happens it will generate an html file in the same directory as the source file. Just run the converter again on this html file to complete the process",10)
		ProgressOn("","Converting Ebook", "", -1, -1,1)
		ProgressSet( 10, "Converting From .lit to HTML", "Converting Ebook")
		$runThis = $clitProgram & " " & chr(34) & $fileIn & chr(34) & " " & chr(34) & @ScriptDir &"\Temp" & chr(34)
		RunWait(@ComSpec & " /c " & $runThis, @ScriptDir, @SW_HIDE)
		ProgressSet( 30, "Converting from HTML to Mobi", "Converting Ebook")
		;MobiIt(@ScriptDir &"\Temp"&$fileName2&".htm", @ScriptDir &"\Temp"&$fileName2)
		$htmlFile = @ScriptDir &"\Temp"&$fileName2&".htm"
		$htmlFileName = @ScriptDir &"\Temp"&$fileName2
		RunWait(@ComSpec & " /c " & $mobigenProgram &""""&$htmlFile&"""", @ScriptDir, @SW_HIDE)
		ProgressSet( 70, "Moving Files", "Converting Ebook")
		FileMoveTest($htmlFileName, $fileOut)
		Sleep(1000)
		ProgressSet( 100, "Complete", "Converting Ebook")
		Sleep(2000)
		ProgressOff()
	Case $fileExt == "pdf"
		ProgressOn("","Converting Ebook", "", -1, -1,1)
		ProgressSet( 10, "Converting From PDF to HTML Pictures Removed", "Converting Ebook")
		RunWait(@ComSpec & " /c " & $pdftohtmlProgram &""""&$fileIn&"""", @ScriptDir, @SW_HIDE)
		$htmlFile = $fileName&"s.html"
		ProgressSet( 30, "Converting From HTML to Mobi", "Converting Ebook")
		RunWait(@ComSpec & " /c " & $mobigenProgram &""""&$htmlFile&"""", @ScriptDir, @SW_HIDE)
		ProgressSet( 70, "Moving Mobi File To Target", "Converting Ebook")
		Sleep(1000)
		FileMoveTest($fileName&"s", $fileOut)
		ProgressSet( 90, "Moving Intermediate Files to Temp", "Converting Ebook")
		Sleep(500)
		FileMove($fileName&"_ind.html", $tempFolder)
		FileMove($fileName&"s.html", $tempFolder)
		FileMove($filename&".html", $tempFolder)
		ProgressSet( 100, "Complete", "Converting Ebook")
		Sleep(2000)
		ProgressOff()
EndSelect


Func FileMoveTest($outPutFile, $fileOut)
; Check if file opened for reading OK
$fileCheck = FileOpen($outPutFile&".mobi", 0)
If $fileCheck = -1 Then
	ProgressOff()
    MsgBox(0, "Output File not Created", "Document may have Copy Protection and Cannot be Processed")
	;MsgBox(0, $fileCheck, $fileCheck)
Else
	FileClose($fileCheck)
	$filemoveCheck = FileMove($outPutFile&".mobi", $fileOut, 1)
	if $filemoveCheck = 0 Then
		ProgressOff()
		;MsgBox(0, "Error", $filemoveCheck)
		MsgBox(0, "Output File Cannot be Moved", "Output Filename may be Incorrect. Before Trying Again Look Here "&$outPutFile)
		;MsgBox(0, $outPutFile&".mobi", $fileOut, 0)
	Else
		FileMove($outPutFile&".mobi", $fileOut, 1)
		;MsgBox(0, $outPutFile&".mobi", $fileOut, 0)
	EndIf
EndIf	
FileClose($fileCheck)
EndFunc

;Func MobiIt($htmlFile, $htmlFileName)
	;msgbox(0,"",$htmlFile)
     ;RunWait(@ComSpec & " /c " & $mobigenProgram &""""&$htmlFile&"""", @ScriptDir, @SW_HIDE)
	; FileMoveTest($htmlFileName, $fileOut)
	; FileMove($htmlFileName&".mobi", $fileOut, 1)
;EndFunc
