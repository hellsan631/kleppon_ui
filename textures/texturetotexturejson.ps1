Function WriteOutputString([string]$string)
{
    echo $string
}

Function Process
{
 param( [String]$prefix, [String]$path )

    $files  =get-childitem -Path $path

    $count = $files.Count
    $files | ForEach-Object {
        $count--
   
        $name =  $_.BaseName
        $name = (Get-Culture).TextInfo.ToTitleCase($name.ToLower())
        $name = $name.Replace('_','')
        $name = $name.Replace('-','')
        if ($count -eq 0)
        {
            WriteOutputString(" """+$prefix +$name+"""")
        }
        else
        {
            WriteOutputString(" """+$prefix +$name+""",")
        }
    }
 
    $count = $files.Count
    $files | ForEach-Object {
        $count--
   
        $name =  $_.BaseName
        $name = (Get-Culture).TextInfo.ToTitleCase($name.ToLower())
        $name = $name.Replace('_','')
        $name = $name.Replace('-','')
        $Textureref = $prefix +$name

        WriteOutputString( "{")
        WriteOutputString( " ""MaterialDef"" : {")
        WriteOutputString( "  ""Name"" : """+$Textureref+"""," )
        WriteOutputString( "  ""Type"" : ""Texture"",")
        WriteOutputString( "  ""Blend"" : ""None"",")
        WriteOutputString( "  ""TextureRef"" : ""$Textureref""")
        WriteOutputString( " }")
        if ($count -eq 0)
        {
            WriteOutputString( "}")
         }
         else
         {
            WriteOutputString( "},")
         }
    }

    $count = $files.Count
    WriteOutputString( """GlobalTextures"" : [")
    $files | ForEach-Object {
   
        $count--
        $name =  $_.BaseName
        $name = (Get-Culture).TextInfo.ToTitleCase($name.ToLower())
        $name = $name.Replace('_','')
        $name = $name.Replace('-','')
        $Textureref = $prefix +$name
        $filename = $_.FullName.Replace('\','/')
        $filename = $filename.Substring($filename.IndexOf("textures/"))
        WriteOutputString( "  {")
        WriteOutputString( "     ""TextureDef"" : {")
        WriteOutputString( "         ""Name"" : ""$Textureref"",")
        WriteOutputString( "         ""FileName"" : ""$filename"",")
        WriteOutputString( "         ""Cached"" : ""precached""")
        WriteOutputString( "       }")
        if ($count -eq 0)
        {
            WriteOutputString( "  }")
         }
         else
         {
            WriteOutputString( "  },")
         }
    }
    WriteOutputString( "]")


#    echo $files;
}


if ($args.Length -ne 2)
{
    Write-Host -ForegroundColor Red "Usage: texturetotexturejson <TextureName Prefix> <File Path>"
}
else
{

    Process -prefix $args[0] -path $args[1]
}