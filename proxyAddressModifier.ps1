# Conectarse al servidor de Active Directory
Import-Module ActiveDirectory

# Configura los valores necesarios
$username = ""

# Obtener el usuario del directorio activo
function getUser($name){
    $local = "$name@casinomagic.local"
    $comar = "$name@casinomagic.com.ar"

    $principalNameLocal = Get-ADUser -Filter {UserPrincipalName -eq $local} -Properties *
    $principalNameComar = Get-ADUser -Filter {UserPrincipalName -eq $comar} -Properties *
    $samName = Get-ADUser -Filter {SamAccountName -eq $name} -Properties *


    if($principalNameLocal){
        return $principalNameLocal
    }
    elseif($principalNameComar) {
        return $principalNameComar
    }
    else {
        return $samName
    }
}

$user = getUser -name $username #-email $emailUser


if ($user) {
    $username = $user.UserPrincipalName.Split("@")[0]

    $nuevaDireccionProxy = "smtp:$username@casinomagicneuquen.mail.onmicrosoft.com"  # Reemplaza esto con la nueva direccion de proxy que desees agregar
    $defaultProxyAddress = "SMTP:$username@casinomagic.com.ar"
    
    # Verificar si el usuario tiene proxies addresses que terminan en "@casinomagic.local o "@casinomagic.com.ar""
    $hasLocal = $user.ProxyAddresses | Where-Object { $_ -like "*@casinomagic.local" }
    $hasComAr = $user.ProxyAddresses | Where-Object { $_ -like "*@casinomagic.com.ar" }

    if ($hasLocal) {
        # Eliminar los proxies addresses que cumplen con el criterio
        $user.ProxyAddresses.Remove($hasLocal)
        Set-ADUser -Instance $user
        Write-Host "Se eliminaron los proxies addresses que terminaban en '@casinomagic.local'."
    }

    if (-not $hasComAr) {
        # Agregar default proxy
        $user.ProxyAddresses.add($defaultProxyAddress)
        Set-ADUser -Instance $user
        Write-Host "Se agregó el proxy addresses que terminaban en '@casinomagic.com.ar' por default."
    }

    # Verificar si el usuario ya tiene la nueva direccion de proxy
    $proxyExiste = $user.ProxyAddresses -contains $nuevaDireccionProxy

    if (-not $proxyExiste) {
        # Agregar la nueva direccion de proxy
        $user.ProxyAddresses.add($nuevaDireccionProxy)

        Write-Host "Se agrego la nueva direccion de proxy al usuario."
        
        # Actualizar el usuario en Active Directory
        Set-ADUser -Instance $user
    } else {
        Write-Host "El usuario ya tiene esa direccion de proxy."
    }
} else {
    Write-Host "El usuario $username no fue encontrado en Active Directory."
}