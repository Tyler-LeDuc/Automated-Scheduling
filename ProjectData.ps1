function GetParcelName($Project_ID){
    if ($project_ID -eq 'ec01w'){
        return ' -'
    }
    elseif ($project_ID -eq 'ec02b'){
        return '-'    
    }
    elseif ($project_ID -eq 'gw11x'){
        return '-'    
    }
    elseif ($project_ID -eq 'gw11x'){
        return '-'    
    }
    elseif ($project_ID -eq 'cs00c'){
        return '-'    
    }
    elseif ($project_ID -eq 'cs00k'){
        return '-'    
    }
    elseif ($project_ID -eq 'cs00p'){
        return '-'
    }
    elseif ($project_ID -eq 'ec00b'){
        return '-'
    }
    elseif ($project_ID -eq 'gw09w'){
        return 'P 9'
    }
    elseif ($project_ID -eq 'gw12w'){
        return 'P 12'
    }
    elseif ($project_ID -eq 'gw13b'){
        return 'P 13'
    }
    elseif ($project_ID -eq 'gw14w'){
        return 'P 14'
    }
    elseif ($project_ID -eq 'es03d'){
        return 'P 3'
    }
    elseif ($project_ID -eq 'es02d'){
        return 'P 2'
    }
    elseif ($project_ID -eq 'es01w'){
        return 'P 1'
    }
    elseif ($project_ID -eq 'es04x'){
        return ' P 4'       
    }
    elseif ($project_ID -eq 'bf01h'){
        return 'P 1'
    }
    elseif ($project_ID -eq 'es05v'){
        return '-'
    }
}
function GetSubdivision($Project_ID){
    if ($project_ID -eq 'ec01w'){
        return 'Northshore'
    }
    elseif ($project_ID -eq 'gw11x'){
        return 'Sonoma Coast'
    }
    elseif ($project_ID -eq 'gw11x'){
        return 'Sonoma Coast'      
    }
    elseif ($project_ID -eq 'es04x'){
        return 'Sonoma Coast'
    }
    elseif ($project_ID -eq 'cs00c'){
        return 'Union Pacific'       
    }
    elseif ($project_ID -eq 'cs00k'){
        return 'Boston&Maine'
    }
    elseif ($project_ID -eq 'cs00p'){
        return 'Central Vermont'
    }
    elseif ($project_ID -eq 'ec00b'){
        return 'Calistoga'
    }
    elseif ($project_ID -eq 'gw13b'){
        return 'Calistoga'
    }
    elseif ($project_ID -eq 'ec02b'){
        return 'Calistoga' 
    }
    elseif ($project_ID -eq 'gw09w'){
        return 'Cottonwood'
    }
    elseif ($project_ID -eq 'gw12w'){
        return 'Cottonwood'
    }
    elseif ($project_ID -eq 'gw14w'){
        return 'Raintree'
    }
    elseif ($project_ID -eq 'es03d'){
        return 'Silverado'
    }
    elseif ($project_ID -eq 'es02d'){
        return 'Silverado'
    }
    elseif ($project_ID -eq 'es01w'){
        return 'Northshore'
    }
    elseif ($project_ID -eq 'bf01h'){
        return 'Barney Farms'   
    }
    elseif ($project_ID -eq 'es05v'){
        return "Redwood Valley"
    }
}

function GetCommunity($Project_ID){
    if ($project_ID -eq 'ec01w'){
        return 'Estrella Commons'
    }
    elseif ($project_ID -eq 'ec02b'){
        return 'Estrella Commons S'
    }
    elseif ($project_ID -eq 'gw11x'){
        return 'Glennwilde'
    }
    elseif ($project_ID -eq 'gw11x'){
        return 'Glennwilde'
    }
    elseif ($project_ID -eq 'cs00c'){
        return 'Cooley Station'
    }
    elseif ($project_ID -eq 'cs00k'){
        return 'Cooley Station'
    }
    elseif ($project_ID -eq 'cs00p'){
        return 'Cooley Station'
    }
    elseif ($project_ID -eq 'ec00b'){
        return 'Estrella Commons N' 
    }
    elseif ($project_ID -eq 'gw09w'){
        return 'Glennwilde'
    }
    elseif ($project_ID -eq 'gw12w'){
        return 'Glennwilde'
    }
    elseif ($project_ID -eq 'gw13b'){
        return 'Glennwilde'
    }
    elseif ($project_ID -eq 'gw14w'){
        return 'Glennwilde'
    }
    elseif ($project_ID -eq 'es03d'){
        return 'Escalante' 
    }
    elseif ($project_ID -eq 'es02d'){
        return 'Escalante'
    }
    elseif ($project_ID -eq 'es01w'){
        return 'Escalante'
    }
    elseif ($project_ID -eq 'es04x'){
        return 'Escalante'
    }
    elseif ($project_ID -eq 'bf01h'){
        return 'Groves'        
    }
    elseif ($project_ID -eq 'es05v'){
        return "Escalante"
    }
}

function GetSaveToPath($Project_ID){
    if ($project_ID -eq 'ec01w'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Estrella Commons/Northshore"
    }
    elseif ($project_ID -eq 'ec00b'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Estrella Commons N/Calistoga"
    }
    elseif ($project_ID -eq 'ec02b'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Estrella Commons S/Calistoga"
    }
    elseif ($project_ID -eq 'es02d'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Escalante/Silverado"
    }
    elseif ($project_ID -eq 'es01w'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Escalante/North Shore"
    }
    elseif ($project_ID -eq 'es04x'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Escalante/Sonoma Coast"
    }
    elseif ($project_ID -eq 'gw12w'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Glennwilde/Cottonwood"
    }
    elseif ($project_ID -eq 'gw14w'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Glennwilde/Raintree"
    }
    elseif ($project_ID -eq 'bf01h'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Barney Farms/Groves"   
    }
    elseif ($project_ID -eq 'es05v'){
        return "C:/Users/Robot/Lighting Design/Lighting Design - Test/AZ Builders/Fulton Homes/Escalante/Redwood Valley"
    }
    elseif ($project_ID -eq 'gw11x'){
        return $false 
    }
    elseif ($project_ID -eq 'gw11x'){
        return $false
    }
    elseif ($project_ID -eq 'cs00c'){
        return $false
    }
    elseif ($project_ID -eq 'cs00k'){
        return $false
    }
    elseif ($project_ID -eq 'gw09w'){
        return $false
    }
    elseif ($project_ID -eq 'gw13b'){
        return $false
    }
    elseif ($project_ID -eq 'es03d'){
        return $false
    }
    elseif ($project_ID -eq 'cs00p'){
        return $false
    }
    else{
        return $false
    }
}