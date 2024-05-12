# parameters:
# atlasname - name of the atlas to generate as it appears in "materials.json"
# qualityLevel - quality level: 1 - UHD, 2 - HD, 3 - SD, 0 or nothing - both UHD and HD

function ProcessAtlas
{
	param([Parameter(Mandatory=$true)][string]$atlasname, [ValidateRange(0,3)][int]$qualityLevel)
	$ToolPath = Resolve-Path -Path "..\Tools_Builds"
	$AtlasBuildTool = -join($ToolPath.Path,"\texassemble.exe")
	$TextureConversionTool = -join($ToolPath.Path,"\texconv.exe")
	$atlasOutputFolder = "textures/"

	Write-Host 'Atlas name is:'$atlasname
	Write-Host 'Tool path is:'$ToolPath.Path
	Write-Host 'Atlas tool path is:'$AtlasBuildTool
	Write-Host 'Texture conversion tool path is:'$TextureConversionTool
	Write-Host 'Quality level is:'$qualityLevel

	$materialDefs = Get-Content -Path "materials.json" -raw
	$materialJson = ConvertFrom-Json -InputObject $materialDefs
	$texturesInSelectedAtlas = @()
	$atlasWidth = 1024
	$atlasHeight = 1024
	#if($qualityLevel -eq ){
	#	$qualityLevel = 0
	#}

	$foundAtlas = $false;
	
	$materialJson.AtlasTextures | Foreach-Object {
		if ( $_.AtlasDef.Name -eq $atlasname )
		{
			$atlasWidth = $_.AtlasDef.MaxWidth;
			$atlasHeight = $_.AtlasDef.MaxHeight;
			$_.AtlasDef.Textures | Foreach-Object {
				$texturesInSelectedAtlas += $_.FileName
			}
			$foundAtlas = $true;
		}
	}
	if( -not $foundAtlas )
	{
		Write-Host "No such atlas: '$atlasname'. Please check supplied name against atlas name definitions in 'materials.json'"
		Exit
	}
	
	$uniqueTexturesInSelectedAtlas = $texturesInSelectedAtlas | Sort-Object | Get-Unique

	# temporary files
	$atlasTextureListFile = "textureList.txt"
	$atlasLayoutFile = "atlas.csv"
	$atlasTempFile = -join($atlasname,".bmp")

	Out-File -Encoding ASCII -FilePath $atlasTextureListFile -InputObject $uniqueTexturesInSelectedAtlas

	Write-Host "Attempting to layout textures into an atlas of size $atlasWidth x $atlasHeight named $atlasTempFile"
	$atlasSizeOpts = " -atlas-width " + $atlasWidth + " -atlas-height " + $atlasHeight
	$atlasLayoutCommand = -join($AtlasBuildTool, " atlas -flist ", $atlasTextureListFile, $atlasSizeOpts + " -o ", $atlasTempFile)
	Invoke-Expression $atlasLayoutCommand
	if($LASTEXITCODE -ne 0)
	{
		Write-Host 'Atlas layout failed'
		Write-Host 'The command attempted was:' $atlasLayoutCommand
	}
	else
	{
		$atlasHalfWidth = $atlasWidth / 2
		$atlasHalfHeight = $atlasHeight / 2
		$resizeOpt = "-w $atlasHalfWidth -h $atlasHalfHeight "

		if($qualityLevel -eq 0 -or $qualityLevel -eq 1)
		{
			# build UHD quality level
			$uhdAtlasOutputFolder = $atlasOutputFolder + 'atlas/UHD/'
			$uhdFormatOption = '-f BC7_UNORM -bcmax'
			$atlasBuildCommand = -join($TextureConversionTool, " -ft dds " + $uhdFormatOption + " -m 1 -y ", $atlasTempFile, " -o ", $uhdAtlasOutputFolder)
			Write-Host 'UHD atlas build command is:'$atlasBuildCommand
			Invoke-Expression $atlasBuildCommand
			$uhdAtlasSourcePathName = $uhdAtlasOutputFolder + $atlasname + '.dds'
		}

		if($qualityLevel -eq 0 -or $qualityLevel -eq 2)
		{
			# build HD quality level
			$hdAtlasOutputFolder = $atlasOutputFolder + 'atlas/HD/'
			$hdFormatOption = '-f BC3_UNORM'
			$atlasBuildCommand = -join($TextureConversionTool, " -ft dds " + $hdFormatOption + " -m 1 -y ", $atlasTempFile, " -o ", $hdAtlasOutputFolder)
			Write-Host 'HD atlas build command is:'$atlasBuildCommand
			Invoke-Expression $atlasBuildCommand
			$hdAtlasSourcePathName = $hdAtlasOutputFolder + $atlasname + '.dds'
		}

		# this quality level is used only for atlases which are too large for level 9 feature levels
		# it halves the resolution of the atlas texture to make them fit
		if($qualityLevel -eq 3)
		{
			# build SD quality level
			$sdAtlasOutputFolder = $atlasOutputFolder + 'atlas/SD/'
			$sdFormatOption = $resizeOpt + '-f BC3_UNORM'
			$atlasBuildCommand = -join($TextureConversionTool, " -ft dds " + $sdFormatOption + " -m 1 -y ", $atlasTempFile, " -o ", $sdAtlasOutputFolder)
			Write-Host 'SD atlas build command is:'$atlasBuildCommand
			Invoke-Expression $atlasBuildCommand
			$sdAtlasSourcePathName = $sdAtlasOutputFolder + $atlasname + '.dds'
		}

		$AtlasImageData = Import-Csv -Path $atlasLayoutFile

		# look up the original textures and add their atlas texture coordinates
		$materialJson.AtlasTextures | Foreach-Object {
			if ( $_.AtlasDef.Name -eq $atlasname )
			{
				if( $uhdAtlasSourcePathName )
				{
					Add-Member -Force -InputObject $_.AtlasDef -MemberType NoteProperty -Name "UHDSource" -Value $uhdAtlasSourcePathName
				}
				if( $hdAtlasSourcePathName )
				{
					Add-Member -Force -InputObject $_.AtlasDef -MemberType NoteProperty -Name "HDSource" -Value $hdAtlasSourcePathName
				}
				if( $sdAtlasSourcePathName )
				{
					Add-Member -Force -InputObject $_.AtlasDef -MemberType NoteProperty -Name "DefaultSource" -Value $sdAtlasSourcePathName
				}

				$_.AtlasDef.Textures | Foreach-Object {
					$atlasEntry = $_;
					$atlasEntryFilePath = $_.FileName;
					Write-Host "Processing atlas entry: $atlasEntryFilePath"
					$AtlasImageData | Foreach-Object {
						if($_.filepath -eq $atlasEntryFilePath)
						{
							Write-Host "Adding atlas entry for $atlasEntryFilePath"
							Add-Member -Force -InputObject $atlasEntry -MemberType NoteProperty -Name "imageTLX" -Value $_.imageTLX
							Add-Member -Force -InputObject $atlasEntry -MemberType NoteProperty -Name "imageTLY" -Value $_.imageTLY
							Add-Member -Force -InputObject $atlasEntry -MemberType NoteProperty -Name "imageBRX" -Value $_.imageBRX
							Add-Member -Force -InputObject $atlasEntry -MemberType NoteProperty -Name "imageBRY" -Value $_.imageBRY
							#$atlasEntry | Get-Member
						}
					}
				}
			}
		}

		$materialExportJson = ConvertTo-Json -Depth 16 -InputObject $materialJson
		Clear-Content -Path "materials.json"
		Add-Content -Encoding ASCII -Path "materials.json" -Value $materialExportJson
		
		# remove temporary files
		Remove-Item -Path $atlasLayoutFile
		Remove-Item -Path $atlasTextureListFile
		Remove-Item -Path $atlasTempFile
	}
}

if ($args.Length -lt 1 -or $args.Length -gt 2 -or ($args.Length -ne 1 -and $args[1] -isnot [int]))
{
    Write-Host "Usage: build_atlas <atlas_name>"
    Write-Host ' where: <atlasName> - one of the atlas names in "materials.json"'
    Write-Host '        <qualityLevel> - optional quality level setting (0 to 3)'
}
else
{
	if ($args[1] -is [int])
	{
		ProcessAtlas $args[0] $args[1]
	}
	else
	{
		ProcessAtlas $args[0]
	}
}
