. ./ProjectData.ps1
. ./DownloadScript.ps1
$WSDLFile = "https://xml.fultonhomes.com/vendor.asmx?WSDL"

$GetStartsData = "
<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ven='http://xml.fultonhomes.com/Vendor'>
   <soapenv:Header/>
   <soapenv:Body>
      <ven:GetStartsData>
         <!--Optional:-->
         <ven:Logon>
            <!--Optional:-->
            <ven:Username></ven:Username>
            <!--Optional:-->
            <ven:Password></ven:Password>
         </ven:Logon>
      </ven:GetStartsData>
   </soapenv:Body>
</soapenv:Envelope>
"
$GetScheduleData = "
<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ven='http://xml.fultonhomes.com/Vendor'>
   <soapenv:Header/>
   <soapenv:Body>
      <ven:GetScheduleData>
         <!--Optional:-->
         <ven:Logon>
            <!--Optional:-->
            <ven:Username></ven:Username>
            <!--Optional:-->
            <ven:Password></ven:Password>
         </ven:Logon>
         <!--Optional:-->
         <ven:DateRange>
            <!--Optional:-->
            <ven:StartDate>$($(get-date).AddDays(-14).ToString('MM/dd/yyyy'))</ven:StartDate>
            <!--Optional:-->
            <ven:EndDate>$($(get-date).AddDays(42).ToString('MM/dd/yyyy'))</ven:EndDate>
         </ven:DateRange>
      </ven:GetScheduleData>
   </soapenv:Body>
</soapenv:Envelope>
"


Function LogWrite
{
    Param ([string]$logstring)

    $logstring | Out-File "log.txt" -Append
}

Function DebugLogWrite
{
    Param ([string]$logstring)

    $logstring | Out-File "DebugLog.txt" -Append  
}

# Uses log for sending email. Goes through each start from GetStartsData and confirms it. If it
# has not been confirmed yet, then it writes it to the log.
function Starts
{
    $noStarts = $true
    DebugLogWrite("STARTS called on $(get-date)")
    [xml]$xml=Invoke-WebRequest -Uri $WSDLFile -Method Post -ContentType "text/xml" -Body $GetStartsData
    DebugLogWrite("OUTERXML:`n$($xml.OuterXml)`n------------------------------------------------`n`n`n")
    foreach ($node in $xml.Envelope.Body.GetStartsDataResponse.GetStartsDataResult.JobStarts.ChildNodes){
        Clear-Content log.txt
        $Subdivision_Name = GetSubdivision "$($node.Project_ID)"
        $Community_Name = GetCommunity "$($node.Project_ID)"
        $date = get-date $node.Start_Date
        $StartDate = $date.ToString('MMddyyyy')

        $ConfirmJobStart = "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ven='http://xml.fultonhomes.com/Vendor'>
           <soapenv:Header/>
           <soapenv:Body>
              <ven:ConfirmJobStart>
                 <!--Optional:-->
                 <ven:Logon>
                    <!--Optional:-->
                    <ven:Username>ldsma</ven:Username>
                    <!--Optional:-->
                    <ven:Password>home</ven:Password>
                 </ven:Logon>
                 <!--Optional:-->
                 <ven:ConfirmData>
                    <!--Optional:-->
                    <ven:project_id>$($node.project_id)</ven:project_id>
                    <!--Optional:-->
                    <ven:lot_id>$($node.lot_id)</ven:lot_id>
                    <!--Optional:-->
                    <ven:start_date>$($node.start_date)</ven:start_date>
                    <!--Optional:-->
                    <ven:max_change_order>$($node.max_change_order)</ven:max_change_order>
                 </ven:ConfirmData>
              </ven:ConfirmJobStart>
           </soapenv:Body>
        </soapenv:Envelope>"
        if (($node.Checked -eq $false) -or ($node.Status -eq 'POs Changed') -or ($node.Status -eq 'Start Date Changed')){
            if ($node.Checked -eq $false){
                $subject = "---- Fulton sent a New Start for: $($Subdivision_Name) Lot $($node.lot_ID) at $($Community_Name)-----"
                LogWrite("---- Fulton sent a New Start for: $($Subdivision_Name) Lot $($node.lot_ID) at $($Community_Name)-----")    
            }
            elseif ($node.Status -eq 'POs Changed'){
                $subject = "---- Fulton sent a Change Order for: $($Subdivision_Name) Lot $($node.lot_ID) at $($Community_Name)-----"
                LogWrite("---- Fulton sent a Change Order for: $($Subdivision_Name) Lot $($node.lot_ID) at $($Community_Name)-----")
            }
            elseif ($node.Status -eq 'Start Date Changed'){
                $subject = "---- Fulton sent a Start Date Change for: $($Subdivision_Name) Lot $($node.lot_ID) at $($Community_Name)-----"
                LogWrite("---- Fulton sent a Start Date Change for: $($Subdivision_Name) Lot $($node.lot_ID) at $($Community_Name)-----")
            }
            try{
                [xml]$xml2=Invoke-WebRequest -Uri $WSDLFile -Method Post -ContentType "text/xml" -Body $GetScheduleData
                foreach ($activity in $xml2.Envelope.Body.GetScheduleDataResponse.GetScheduleDataResult.ScheduledActivities.ChildNodes){
                    if (($activity.project_id -eq "$($node.project_id)") -and ($activity.lot_id -eq "$($node.lot_id)")){
                        $activityDate = get-date $activity.current_start
                        $activityStartDate = $activityDate.ToString('MM/dd/yyyy')
                        LogWrite("`t$($activity.activity_name) is scheduled for $($activityStartDate)")
                    }
                }
                # Skips it if it is a new project_id and doesnt have a save to path
                if ((GetSaveToPath($node.Project_ID)) -eq $false){
                    Clear-Content log.txt
                    DebugLogWrite("`nSAVETOPATH DOES NOT EXIST: [PID] $($project_ID) [LID] $($lot_ID)`n")
                    $ErrorMessage = ""
                    $ErrorMessage += "The bot will not process ANY Fulton activity until the following data is known for the project(s) listed above`n"
                    $ErrorMessage += "Subdivision Name`nParcel Number`nSave To Path`n`n"
                    $ErrorMessage += "Please send an email to support@odd-bot.com with this data ASAP. Thank you.`n"
                    # "ERROR_MESSAGE: $($ErrorMessage)"
                    $subject = " URGENT: New Project(s) from Fulton"
                    LogWrite("$($ErrorMessage)")
                    python emailBot/EmailBot.py $subject
                }
                else{
                    downloadFiles $node.Project_ID $node.Lot_ID $StartDate $node.floorplan_link $node.plotplan_link $node.options_link $node.hardscape_link $node.pos_link $node.dc_docs.ChildNodes $node.complete_start_link
                    [xml]$confirmXML=Invoke-WebRequest -Uri $WSDLFile -Method Post -ContentType "text/xml" -Body $ConfirmJobStart
                    python emailBot/EmailBot.py $subject
                    $noStarts = $false
                    LogWrite("`n`n-------------------------------------------------------------------------------------------")
                    LogWrite("This project was confirmed on Fulton's website (Starts page).")
                    LogWrite("-------------------------------------------------------------------------------------------")

                    DebugLogWrite("$($confirmXML)")
                    DebugLogWrite("CONFIRM SUCCESS: $($ConfirmJobStart)")
                    DebugLogWrite("`t<CONFIRMED> $($node.project_Name) Project_ID:[$($node.Project_ID)] Lot_ID:[$($node.lot_ID)]`n")                
                    DebugLogWrite("downloadFiles `n$($node.Project_ID)`t$($node.Lot_ID)`t$($StartDate)`t$($node.floorplan_link)`t$($node.plotplan_link)`t$($node.options_link)`t$($node.hardscape_link)`t$($node.pos_link)`t$($node.dc_docs.ChildNodes)`t$($node.complete_start_link))")
                }
            }
            catch{
                DebugLogWrite("`nCONFIRM FAILED: $($ConfirmJobStart)")
            }
        }
    }
    if ($noStarts -eq $true){
        Clear-Content log.txt
        LogWrite("-------------------------------------------------------------------------------------------")
        LogWrite("No projects confirmed on Fulton's website (Starts page).")
        LogWrite("-------------------------------------------------------------------------------------------")
        $subject = "Bot - No Confirmed Starts"
        python emailBot/EmailBot.py $subject
    }
}

function Schedule()
{
    $noActivities = $true
    Clear-Content log.txt
    DebugLogWrite("SCHEDULE called on $(get-date)")
    $message = ""
    [xml]$xml=Invoke-WebRequest -Uri $WSDLFile -Method Post -ContentType "text/xml" -Body $GetScheduleData
    DebugLogWrite("$($xml.OuterXml)------------------------------------------------`n`n")
    foreach ($node in $xml.Envelope.Body.GetScheduleDataResponse.GetScheduleDataResult.ScheduledActivities.ChildNodes){
        "$($node.Project_ID)"
        "$($node.Lot_ID)"
        $alreadyExists = Select-String -pattern "<$($node.Project_ID), $($node.Lot_ID)>" -InputObject $message
        "LOT: $($alreadyExists)"
        $Subdivision_Name = GetSubdivision "$($node.Project_ID)"
        $Community_Name = GetCommunity "$($node.Project_ID)"
        $Parcel_Name = GetParcelName "$($node.Project_ID)"
        if ([string]::IsNullOrEmpty($alreadyExists)){
            if ($node.status -eq 'New'){
                LogWrite("---- Fulton sent a New Activity for: $Subdivision_Name Lot $($node.Lot_ID) at $Community_Name-----")
            }
            elseif ($node.status -eq 'Changed'){
                LogWrite("---- Fulton sent a Schedule Change for: $Subdivision_Name Lot $($node.Lot_ID) at $Community_Name-----")  
            }
            elseif ((GetSaveToPath($node.Project_ID)) -eq $false){
                "continued`n"
                continue
            }
            else{
                "continued`n"
                continue
            }
            foreach ($activity in $xml.Envelope.Body.GetScheduleDataResponse.GetScheduleDataResult.ScheduledActivities.ChildNodes){
                $ConfirmScheduledActivity = "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ven='http://xml.fultonhomes.com/Vendor'>
                   <soapenv:Header/>
                   <soapenv:Body>
                      <ven:ConfirmScheduledActivity>
                         <!--Optional:-->
                         <ven:Logon>
                            <!--Optional:-->
                            <ven:Username>ldsma</ven:Username>
                            <!--Optional:-->
                            <ven:Password>home</ven:Password>
                         </ven:Logon>
                         <!--Optional:-->
                         <ven:ConfirmData>
                            <!--Optional:-->
                            <ven:project_id>$($activity.project_id)</ven:project_id>
                            <!--Optional:-->
                            <ven:lot_id>$($activity.lot_id)</ven:lot_id>
                            <!--Optional:-->
                            <ven:activity_id>$($activity.Activity_ID)</ven:activity_id>
                            <!--Optional:-->
                            <ven:confirmed_start>$($activity.current_start)</ven:confirmed_start>
                            <!--Optional:-->
                            <ven:confirmed_complete>$($activity.current_complete)</ven:confirmed_complete>
                         </ven:ConfirmData>
                      </ven:ConfirmScheduledActivity>
                   </soapenv:Body>
                </soapenv:Envelope>"
                $pastSummary = "$Community_Name $Subdivision_Name  $Parcel_Name Lot $($activity.Lot_ID) $($activity.Activity_Name)"
                $formerSummary = "$Community_Name $Subdivision_Name  $Parcel_Name Lot $($activity.Lot_ID) $($activity.Activity_Name) "
                $calendarSummary = "$Community_Name $Subdivision_Name $Parcel_Name Lot $($activity.Lot_ID) $($activity.Activity_Name)"
                $date = get-date $activity.current_start
                $StartDate = $date.ToString('MM/dd/yyyy')
                if (($activity.project_id -eq "$($node.project_id)") -and ($activity.lot_id -eq "$($node.lot_id)")){
                    if (($activity.status -eq 'New') -or ($activity.status -eq 'Changed')){
                        $message += "<$($node.Project_ID), $($node.Lot_ID)> "
                        try{
                            python calendarBot/CalendarBot.py $StartDate, $calendarSummary, $pastSummary, $formerSummary
                            DebugLogWrite("python calendarBot/CalendarBot.py [$StartDate]`t [$calendarSummary]`t [$pastSummary]`t [$formerSummary]`n")
                            # [CONFIRM]
                            [xml]$confirmXML=Invoke-WebRequest -Uri $WSDLFile -Method Post -ContentType "text/xml" -Body $ConfirmScheduledActivity
                            $noActivities = $false
                        } catch{
                            DebugLogWrite("$($activity.project_ID) - $($activity.lot_id)")
                            DebugLogWrite("`n`t<CONFIRM_FAILED>: $($activity.activity_name) is scheduled for $($StartDate)`n")
                            return
                        }
                        if ($activity.status -eq 'New'){
                            LogWrite("`t$($activity.activity_name) is scheduled for $($StartDate)")
                            DebugLogWrite("New Activity: $($activity.activity_name) $($StartDate)")
                        }
                        elseif ($activity.status -eq 'Changed'){
                            LogWrite("`t$($activity.activity_name) has been re-scheduled for $($StartDate)")
                            DebugLogWrite("Schedule Change: $($activity.activity_name) $($StartDate)")
                        }
                    }
                }
            } # end of foreach $activity
            LogWrite("")
        }
    } # end of foreach $node
    if ($noActivities -eq $false){
        $subject = "Bot - Confirmed New Activities and Schedule Changes"
        DebugLogWrite("`nMESSAGE:`n$($message)")
        python emailBot/EmailBot.py $subject
    }
}
"$($(get-date).AddDays(-14))"
"$($(get-date).AddDays(42))"
# return
# Clear-Content log.txt

Starts
Schedule

# return
# Clear-Content log.txt