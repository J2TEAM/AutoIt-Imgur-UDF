#NoTrayIcon
#include 'Imgur.au3'

Global $fp = FileOpenDialog('Open', @ScriptDir, 'Images (*.jpg;*.gif;*.png;*.bmp)', 1)

If Not @error Then
	Local $image_url = _imgur_upload($fp)

	If @error Then
		MsgBox(16 + 262144, 'Error', 'Upload image failed!')
	Else
		; Open with default browser
		ShellExecute($image_url)
	EndIf
EndIf