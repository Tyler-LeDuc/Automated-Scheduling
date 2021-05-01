function downloadFiles($project_ID, $lot_ID, $StartDate, $URL_Floorplan, $URL_Plotplan, $URL_Options, $URL_Hardscape, $URL_POs, $DC_Docs, $Complete_Start_Pkg){
    $wc = New-Object System.Net.WebClient
    $Subdivision_Name = GetSubdivision $project_ID
    $Parcel_Name = GetParcelName $project_ID
    $lotFolder = "$($Subdivision_Name) $($Parcel_Name) Lot $($Lot_Id)"

    # $output = New-Item -ItemType Directory -Force -Path "/Users/tylerleduc/Documents/Fulton-Bot/$($lotFolder)/"
    $SaveToPath = GetSaveToPath $project_ID
    $output = New-Item -ItemType Directory -Force -Path "$($SaveToPath)/$($LotFolder)"
    
    if ($SaveToPath -eq $false){
        return
    }
    
    LogWrite("Files saved:")
    # Lots - URL_Floorplan
    $url = "$($URL_Floorplan)"
    $path = "$($output)/$($fileName)"
    $fileName = "$($Subdivision_Name) $($Parcel_Name) Lot $($Lot_Id) Floorplan $($StartDate).pdf"
    try {
        $wc.DownloadFile($url, "$($output)/$($fileName)")
        DebugLogWrite("Download Success: $($path)")
        LogWrite("Floorplans")
    } catch{
        DebugLogWrite("DOWNLOAD FAILED: $($path)")
    }
    DebugLogWrite("TYPE: Floorplans")
    DebugLogWrite("URL: $($url)")
    DebugLogWrite("FileName: $($FileName)`n")

    #Lots - URL_Plotplan --------------------------------------------
    $url = "$($URL_Plotplan)"
    $fileName = $fileName -replace "Floorplan", "Plotplan"
    $path = "$($output)/$($fileName)"
    try {
        $wc.DownloadFile($url, "$($output)/$($fileName)")
        DebugLogWrite("Download Success: $($path)")
        LogWrite("Plotplan")
    } catch{
        DebugLogWrite("DOWNLOAD FAILED: $($path)")
    }
    DebugLogWrite("TYPE: Plotplan")
    DebugLogWrite("URL: $($url)")
    DebugLogWrite("FileName: $($FileName)`n")
    #  --------------------------------------------------------------

    #Lots - URL_Options ---------------------------------------------
    $url = "$($URL_Options)"
    $fileName = $fileName -replace "Plotplan", "Options"
    $path = "$($output)/$($fileName)"
    try {
        $wc.DownloadFile($url, "$($output)/$($fileName)")
        DebugLogWrite("Download Success: $($path)")
        LogWrite("Options")
    } catch{
        DebugLogWrite("DOWNLOAD FAILED: $($path)")
    }
    DebugLogWrite("TYPE: Options")
    DebugLogWrite("URL: $($url)")
    DebugLogWrite("FileName: $($FileName)`n")
    #  --------------------------------------------------------------  

    #Lots - URL_Hardscape --------------------------------------------
    $url = "$($URL_Hardscape)"
    $fileName = $fileName -replace "Options", "Hardscape"
    $path = "$($output)/$($fileName)"
    # DownloadFile $url, $path, "Hardscape"
    try {
        $wc.DownloadFile($url, "$($output)/$($fileName)")
        DebugLogWrite("Download Success: $($path)")
        LogWrite("Hardscape")
    } catch{
        DebugLogWrite("DOWNLOAD FAILED: $($path)")
    }
    DebugLogWrite("TYPE: Hardscape")
    DebugLogWrite("URL: $($url)")
    DebugLogWrite("FileName: $($FileName)`n")
    #  --------------------------------------------------------------

    # URL_POs --------------------------------------------------------------
    $url = "$URL_POs"
    $concat = ""
    $check = $false
    $test = $url.ToCharArray()
    foreach ($char in $test){
        $concat += $($char)
        if ($char -eq '|'){
            $check = $true
            $concat = $concat.TrimEnd('|')
            $concat += '&vend=ldsma'
            # "CONCAT: $($concat)`n"
            # Write-Host "send: $($concat)"

            $po_num = [Regex]::Matches($concat, "(ponum)(.*)(?<=&vend)")
            $po_num = $po_num -replace "(ponum=)", ""
            $po_num = $po_num -replace "(&vend)", ""

            $fileName = $filename -replace "(Hardscape)(?s)(.*$)", "PO_$($po_num).pdf"
            $fileName = $filename -replace "(PO_)(.*)", "PO_$($po_num).pdf"

            $path = "$($output)/$($fileName)"
            try {
                $wc.DownloadFile($concat, "$($output)/$($fileName)")
                DebugLogWrite("Download Success: $($output)/$($fileName)")
            } catch{
                DebugLogWrite("DOWNLOAD FAILED: $($output)/$($fileName)")
            } 
            DebugLogWrite("TYPE: Purchase Orders")
            DebugLogWrite("URL: $($concat)")
            DebugLogWrite("FileName: $($FileName)")


            $concat = $concat -replace "(ponum)(.*)", ""
            $concat = $concat -replace "(?<=.ashx)(.*)", "?ponum="
        }
    }

    # Downloads last file in URL_POs
    $concat = $concat.TrimEnd('|')
    $po_num = [Regex]::Matches($concat, "(ponum)(.*)(?<=&vend)")
    $po_num = $po_num -replace "(ponum=)", ""
    $po_num = $po_num -replace "(&vend)", ""

    $fileName = $filename -replace "(Hardscape)(?s)(.*$)", "PO_$($po_num).pdf"
    $fileName = $filename -replace "(PO_)(.*)", "PO_$($po_num).pdf"
    $fileName = $filename -replace "=ldsma", ""

    $path = "$($output)/$($fileName)"
    # DownloadFile $url, $path, "Purchase Orders"
    try {
        $wc.DownloadFile($concat, "$($output)/$($fileName)")
        DebugLogWrite("Download Success: $($path)")
        LogWrite("Purchase Orders")
    } catch{
        DebugLogWrite("DOWNLOAD FAILED: $($path)")
    }
    DebugLogWrite("TYPE: Purchase Orders")
    DebugLogWrite("URL: $($concat)")
    DebugLogWrite("FileName: $($FileName)`n")
    #  ----------------------------------------------------------------------

    # DCDOCS --------------------------------------------------------
    foreach ($node2 in $DC_Docs){
        $url = "$($node2.doc_link)"
        $fileName = $fileName -replace "(Hardscape)(?s)(.*$)", "$($node2.doc_name).pdf"
        $fileName = $fileName -replace "(PO_)(?s)(.*$)", "$($node2.doc_name).pdf"
        $fileName = $fileName -replace "(DC Docs)(?s)(.*$)", "$($node2.doc_name).pdf"
        try{
            $wc.DownloadFile($url, "$($output)/$($fileName)")
            DebugLogWrite("Download Success: $($path)")
        } catch{
            DebugLogWrite("DOWNLOAD FAILED: $($path)")
        }
    }
    DebugLogWrite("TYPE: DCDocs")
    DebugLogWrite("URL: $($url)")
    DebugLogWrite("FileName: $($FileName)`n")
    LogWrite("DCDocs")
    #  --------------------------------------------------------------

    # Lots - URL_Complete_Start_Pkg
    $url = "$URL_Complete_Start_Pkg"
    $fileName = $fileName -replace "(DC Docs)(.*)", "Complete_Start_Pkg $($StartDate).pdf"
    $fileName = $fileName -replace "(Hardscape)(?s)(.*$)", "Complete_Start_Pkg $($StartDate).pdf"
    $fileName = $fileName -replace "(PO_)(?s)(.*$)", "Complete_Start_Pkg $($StartDate).pdf"
    $fileName = $fileName -replace "(DC Docs)(?s)(.*$)", "Complete_Start_Pkg $($StartDate).pdf"
    $path = "$($output)/$($fileName)"
    # DownloadFile $url, $path, "Start Pkg"
    try {
        $wc.DownloadFile($url, "$($output)/$($fileName)")
        DebugLogWrite("Download Success: $($path)")
        LogWrite("Start Pkg")
    } catch{
        DebugLogWrite("DOWNLOAD FAILED: $($path)")
    } 
    DebugLogWrite("TYPE: Start Pkg")
    DebugLogWrite("URL: $($url)")
    DebugLogWrite("FileName: $($FileName)`n")
    LogWrite("`n")
}