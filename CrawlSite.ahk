#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Made by xcloudx01 2019-06-16
;Downloads all the images that a user posted on the Newgrounds forum. Can also be used to fetch all files that were linked on a page from a specified serverURL

;User vars
	SearchUrl := "https://www.newgrounds.com/bbs/search/author/USERNAMEGOESHERE" ;Where you want to look for files.
	ServerURLOfInterest := "https://bbsimg.ngfiles.com" ;What server does the file/image need to be on for us to want to download it?
	PageCount := 15 ;How many pages of comments does this user have? If not searching Newgrounds, then how many sub-pages does this page have that are numbered? You can just delete this line if only want to scan a single page.
	DownloadFolder := A_ScriptDir ;Where do you want to download the files to? A_ScriptDir is where this .ahk currently is. You can also use a path like: C:\MyDownloads (Do not include a slash at the end)
	TXTFileContainingURLs := "C:\testfile.txt"

;Main body
	;Looping page count
		If !(PageCount)
			SaveOnlyFilesFromGoalServer(SearchUrl, ServerURLOfInterest)

		Else {
			Loop,% PageCount
			{
				URL := SearchUrl . "/" . A_Index ""
				SaveOnlyFilesFromGoalServer(URL, ServerURLOfInterest)
			}
		}

	;Loop through .txt file - Uncomment this, and then comment out the above if you'd like to instead check through a .txt file that holds a list of URLs to check through.
	;	Loop, Read, %TXTFileContainingURLs%
	;	{
	;		SaveOnlyFilesFromGoalServer(A_LoopReadLine, ServerURLOfInterest)
	;	}




	Exitapp


;--------------------------------------------------------------
;Functions
;--------------------------------------------------------------

SaveOnlyFilesFromGoalServer(URL,FileURL)
{
	Tooltip Checking %URL%
	HtmlFile := A_Temp . "\TempFile.html"
	URLDownloadToFile,% URL,%HtmlFile%
	Fileread,FileContents,%HtmlFile%
	if Instr(FileContents,FileURL) ;Only want to download things that are from our server of interest.
		DownloadFiles(HtmlFile,URL)
	else
		filedelete,%A_Temp%\TempFile.html ;This HTML page contained nothing of interest, so remove it and try the next one.
}

DownloadFiles(InputHTML,URL)
{
	global ServerURLOfInterest
	global DownloadFolder
	FilesArray := []
	
	Loop, read, % InputHTML
	{
		If !(A_LoopReadLine) or !(Instr(A_LoopReadLine,ServerURLOfInterest)) ;Skip blank lines in the HTML file.
			continue
		FileURL := GetFileURLFromLine(A_LoopReadLine,"""") ;"""" = the last char of the url is a "
		If (FileURL)
		FilesArray.Push(FileURL)
		Loop % FilesArray.Length()
		{
			Tooltip % "Downloading file " . A_Index . " of " . FilesArray.Length() . " From Page: " . URL
			URLDownloadToFile,% FilesArray[A_Index],% DownloadFolder . "\" . GetFileName(FileURL)
		}
	}
}

GetFileURLFromLine(Line,URLEndsWith)
{
	global ServerURLOfInterest
	StartPos := Instr(Line,ServerURLOfInterest)
	FileURL := SubStr(Line,StartPos)
	EndPos := Instr(FileURL,URLEndsWith)
	FileURL := SubStr(FileURL,1,EndPos - 1)
	return % FileURL
}

GetFileName(FileURL)
{
	If (FileURL = "")
		return

	PathArray := StrSplit(FileURL,"/")
	PictureName := PathArray[PathArray.Length()]
	return % PictureName
}
