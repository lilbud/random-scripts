# audio converter
# enter input folder path
# current options:
function Menu_Driver {
	Clear-Host
	Write-Host "# Audio Converter Program`n# Uses FFMPEG to convert audio files`n# Current Options: "
	Write-Host "`t[1] FLAC to MP3 (Options for Resolution)"
	Write-Host "`t[2] FLAC Downsample (24/96 to 16/48 or 16/44.1)"
	Write-Host "`t[3] FLAC to ALAC (Lossless to Apple Lossless)"
	Write-Host "`t[4] ALAC to FLAC (Apple Lossless to Lossless)"
	Write-Host "`t[0] Exit`n"
}

function MD5_FFP {
	param( 
		$saveName,
		$outputPath,
		$fileType
	)

	$name = "fingerprint"

	#ffp is only for FLAC files
	if ($fileType -eq "flac") {
		if (-not(Test-Path -Path $outputPath\$name.ffp -PathType Leaf)) {
			New-Item $outputPath\$name.ffp | Out-Null
		}
	}

	#MD5 is for all files
	if (-not(Test-Path -Path $outputPath\$name.md5 -PathType Leaf)) {
		New-Item $outputPath\$name.md5 | Out-Null
	}

	$temp = [System.IO.Path]::GetFileName($saveName)

	if ($fileType -eq "flac") {
		$ffp = ffmpeg -i $outputPath\$saveName -vn -f md5 - 2>NUL
    	Add-Content -Path $outputPath\$name.ffp -Value "$temp`:$ffp".Replace("MD5=", "")
	}
	
    $md5 = Get-FileHash $outputPath\$saveName -Algorithm MD5 | Select-Object Hash -ExpandProperty Hash
    Add-Content -Path $outputPath\$name.md5 -Value "$md5 *$temp"
}

function FLAC_to_MP3 {
	param( $inputPath )

	Clear-Host
	Write-Host "# FLAC --> MP3 320kbps or 192kbps`n# Converts Lossless Files to Lossy"

	Write-Host "`n# Enter the Resolution to Encode MP3 Files At:"
	Write-Host "# Options:`n`t[1] 320k (Highest Quality)`n`t[2] 192k (More Compressed)"

	$res = Read-Host "`n> Enter Option"
	$fileType = "mp3"

	switch ($res) {
		1 { $res = "320k" }
		2 { $res = "192k" }
	}

	if (Test-Path -Path $inputPath -PathType Container) {
		$outputPath = "$inputPath\MP3"
		[IO.Directory]::CreateDirectory($outputPath) | Out-Null

		foreach ($f in Get-ChildItem $inputPath\*.flac) {
			$saveName = [System.IO.Path]::GetFileNameWithoutExtension($f)
			$saveName += ".mp3"
			ffmpeg -i $f -hide_banner -c:v copy -b:a $res $outputPath\$saveName
			MD5_FFP $saveName $outputPath $fileType
		}
	} elseif (Test-Path -Path $inputPath -PathType Leaf) {
		$parentDir = [System.IO.Path]::GetDirectoryName($inputPath)
		$outputPath = "$parentDir\MP3"
		[IO.Directory]::CreateDirectory($outputPath) | Out-Null

		$saveName = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
		$saveName += ".mp3"
		ffmpeg -i $inputPath -hide_banner -c:v copy -b:a $res $outputPath\$saveName
		MD5_FFP $saveName $outputPath $fileType
	}
}
function FLAC24_to_FLAC16 {
	param( $inputPath )

	Clear-Host
	Write-Host "# FLAC 24/96 --> FLAC 16/48 or FLAC 16/44`n# Converts Hi-Res Files to Standard Res`nEnter the Rate to Downsample To:"
	Write-Host "# Options:`n`t[1] 48000hz (Good for Most People)`n`t[2] 44100hz (For CD Burning)"

	$sampleRate = Read-Host "`n> Enter Option"
	$fileType = "flac"

	switch ($sampleRate) {
		1 { $sampleRate = "48000" }
		2 { $sampleRate = "44100" }
	}

	Write-Host "`n# Enter the FLAC Compression Level (0-8)`n# Default: 5`n# If not sure, just leave blank and [ENTER]"
	$compress = Read-Host "`n> Enter Option"

	if ($compress -eq "") {
		$compress = 5
	}

	if (Test-Path -Path $inputPath -PathType Container) {
		$outputPath = "$inputPath\FLAC16"
		[IO.Directory]::CreateDirectory($outputPath) | Out-Null

		foreach ($f in Get-ChildItem $inputPath\*.flac) {
			$saveName = [System.IO.Path]::GetFileNameWithoutExtension($f)
			$saveName += ".flac"
			ffmpeg -i $f -hide_banner -c:a flac -dither_method triangular -c:v copy -sample_fmt s16 -ar $sampleRate -compression_level $compress $outputPath\$saveName
			MD5_FFP $saveName $outputPath $fileType
		}
	} elseif (Test-Path -Path $inputPath -PathType Leaf) {
		$parentDir = [System.IO.Path]::GetDirectoryName($inputPath)
		$outputPath = "$parentDir\FLAC16"
		[IO.Directory]::CreateDirectory($outputPath) | Out-Null

		$saveName = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
		$saveName += ".flac"
		ffmpeg -i $inputPath -hide_banner -c:a flac -dither_method triangular -c:v copy -sample_fmt s16 -ar $sampleRate -compression_level $compress $outputPath\$saveName
		MD5_FFP $saveName $outputPath $fileType
	}
}
function FLAC_to_ALAC {
	param( $inputPath )

	Clear-Host
	Write-Host "# FLAC --> ALAC (m4a)`n# Converts Lossless to Apple Lossless"
	$fileType = "m4a"

	if (Test-Path -Path $inputPath -PathType Container) {
		$outputPath = "$inputPath\ALAC"
		[IO.Directory]::CreateDirectory($outputPath) | Out-Null

		foreach ($f in Get-ChildItem $inputPath\*.flac) {
			$saveName = [System.IO.Path]::GetFileNameWithoutExtension($f)
			$saveName += ".m4a"
			ffmpeg -i $f -hide_banner -c:a alac -c:v copy $outputPath\$saveName
			MD5_FFP $saveName $outputPath $fileType
		}
	} elseif (Test-Path -Path $inputPath -PathType Leaf) {
		$parentDir = [System.IO.Path]::GetDirectoryName($inputPath)
		$outputPath = "$parentDir\ALAC"
		[IO.Directory]::CreateDirectory($outputPath) | Out-Null

		$saveName = [System.IO.Path]::GetFileNameWithoutExtension($f)
		$saveName += ".m4a"
		ffmpeg -i $f -hide_banner -c:a alac -c:v copy $outputPath\$saveName
		MD5_FFP $saveName $outputPath $fileType
	}
}
function ALAC_to_FLAC {
	param( $inputPath )

	Clear-Host
	Write-Host "# ALAC (m4a) --> FLAC`n# Converts Apple Lossless to Lossless"
	$fileType = "flac"

	if (Test-Path -Path $inputPath -PathType Container) {
		$outputPath = "$inputPath\FLAC"
		[IO.Directory]::CreateDirectory($outputPath) | Out-Null

		foreach ($f in Get-ChildItem $inputPath\*.m4a) {
			$saveName = [System.IO.Path]::GetFileNameWithoutExtension($f)
			$saveName += ".flac"
			ffmpeg -i $f -hide_banner -c:a flac -c:v copy $outputPath\$saveName
			MD5_FFP $saveName $outputPath $fileType
		}
	} elseif (Test-Path -Path $inputPath -PathType Leaf) {
		$parentDir = [System.IO.Path]::GetDirectoryName($inputPath)
		$outputPath = "$parentDir\FLAC"
		[IO.Directory]::CreateDirectory($outputPath) | Out-Null

		$saveName = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
		$saveName += ".flac"
		ffmpeg -i $inputPath -hide_banner -c:a flac -c:v copy $outputPath\$saveName
		MD5_FFP $saveName $outputPath $fileType
	}
}
function menu {
	Menu_Driver
	do {
		$menuAnswer = Read-Host "> Enter Option"
	} until ($menuAnswer -ne "")

	if ($menuAnswer -ne 0) {
		$inputPath = Read-Host "`n> Enter Path of Folder with Audio Files, or enter path of single file"

		switch ($menuAnswer) {
			1 { FLAC_to_MP3 $inputPath; break }
			2 { FLAC24_to_FLAC16 $inputPath; break }
			3 { FLAC_to_ALAC $inputPath; break }
			4 { ALAC_to_FLAC $inputPath; break }
			0 { Exit; break }
		}
	}
}
menu