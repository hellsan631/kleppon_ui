Function WriteOutputString([string]$string)
{
    echo $string
}

Function Process
{
 param( [String]$atlasname, [String]$prefix, [String]$path )

    $files  =get-childitem -Path $path

    $count = $files.Count

    $files | ForEach-Object {
        $count--
   
        $name =  $_.BaseName
        $name = (Get-Culture).TextInfo.ToTitleCase($name.ToLower())
        $name = $name.Replace('_','')
        $name = $name.Replace('-','')
        if ($count -eq 0){
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
        WriteOutputString( "  ""Type"" : ""Atlas"",")
        WriteOutputString( "  ""Blend"" : ""InverseAlpha"",")
        WriteOutputString( "  ""AtlasRef"" : ""$atlasname"",")
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

    WriteOutputString( "{")
    WriteOutputString( " ""AtlasDef"" : {")
    WriteOutputString( "  ""Name"" : """+$Atlasname+"""," )

    WriteOutputString( "   ""MaxWidth"" : 2048,")
    WriteOutputString( "   ""MaxHeight"" : 2048,")
    WriteOutputString( "   ""Cached"" : ""precached"",")
    WriteOutputString( "   ""Textures"" : [")

    $count = $files.Count
    $files | ForEach-Object {
        $count--
    
        $name =  $_.BaseName
        $name = (Get-Culture).TextInfo.ToTitleCase($name.ToLower())
        $name = $name.Replace('_','')
        $name = $name.Replace('-','')  
        $Textureref = $prefix +$name
        $filename = $_.FullName.Replace('\','/')
        $filename = $filename.Substring($filename.IndexOf("textures/"))
        WriteOutputString( "     {")
        WriteOutputString( "       ""RefName"" : ""$Textureref"",")
        WriteOutputString( "       ""FileName"" : ""$filename""")
        if ($count -eq 0)
        {
            WriteOutputString( "     }")
        }
        else
        {
            WriteOutputString( "     },")
        }
    }
    WriteOutputString( "   ]")
    WriteOutputString( " }")
    WriteOutputString( "}")

#    echo $files;
}


if ($args.Length -ne 3)
{
    Write-Host -ForegroundColor Red "Usage: texturetoatlas <Atlas Name> <TextureName Prefixe> <File Path>"
}
else
{

    Process -atlasname $args[0] -prefix $args[1] -path $args[2]
}