#include-once

#include 'include/Base64.au3' ; by Ward
#include 'include/JSON.au3' ; by Ward

; #INDEX# =======================================================================================================================
; Title .........: Imgur
; UDF Version....: 1.0.0
; AutoIt Version : 3.3.14.0
; Description ...: Upload images using Imgur API
; Author(s) .....: Juno_okyo
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $IMGUR_API_ENDPOINT = 'https://api.imgur.com/2/upload.json'
Global Const $IMGUR_API_KEY = '6528448c258cff474ca9701c5bab6927' ; YOUR API KEY
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _imgur_upload
; _imgur_remote_upload
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; _url_encode
; _simple_post_request
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Juno_okyo
; ===============================================================================================================================
Func _imgur_upload($sFile, $sType = 'base64')
	Local $fp, $sData, $sPostData, $sRequest

	If $sType = 'base64' Then
		If Not FileExists($sFile) Then
			SetError(1)
			Return False
		EndIf

		$fp = FileOpen($sFile, 16)
		$sData = FileRead($fp)
		FileClose($fp)

		$sData = _Base64Encode($sData)
	EndIf

	$sPostData = 'type=' & _url_encode($sType) & _
		'&key=' & _url_encode($IMGUR_API_KEY) & _
		'&image=' & _url_encode($sData)

	$sRequest = _simple_post_request($IMGUR_API_ENDPOINT, $sPostData)
	Local $json = Json_Decode($sRequest)

	Return Json_Get($json, '["upload"]["links"]["original"]')
EndFunc   ;==>upload

; #FUNCTION# ====================================================================================================================
; Author ........: Juno_okyo
; ===============================================================================================================================
Func _imgur_remote_upload($sURL)
	Return _imgur_upload($sURL, 'url')
EndFunc

#Region <INTERNAL_USE_ONLY>
Func _url_encode($vData)
    If IsBool($vData) Then Return $vData
	Local $aData = StringToASCIIArray($vData, Default, Default, 2)
	Local $sOut = '', $total = UBound($aData) - 1
	For $i = 0 To $total
		Switch $aData[$i]
			Case 45, 46, 48 To 57, 65 To 90, 95, 97 To 122, 126
				$sOut &= Chr($aData[$i])
			Case 32
				$sOut &= '+'
			Case Else
				$sOut &= '%' & Hex($aData[$i], 2)
		EndSwitch
	Next
	Return $sOut
EndFunc

Func _simple_post_request($url, $postData)
	If Not $url Or Not $postData Then Return False

	Local $oHTTP = ObjCreate('WinHttp.WinHttpRequest.5.1')
	$oHTTP.Option(6) = False
	$oHTTP.Open('post', $url, False)
	$oHTTP.SetRequestHeader('User-Agent', 'Mozilla/5.0 (Windows NT 6.1; rv:34.0) Gecko/20100101 Firefox/34.0')
	$oHTTP.SetRequestHeader('Referer', 'http://imgur.com/')
	$oHTTP.SetRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
	$oHTTP.SetRequestHeader('Content-Length', StringLen($postData))
	$oHTTP.Send($postData)
	$oHTTP.WaitForResponse
	Return $oHTTP.Responsetext
EndFunc
#EndRegion