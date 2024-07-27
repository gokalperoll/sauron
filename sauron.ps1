# Çalışma dizinini al
$workingDirectory = Get-Location

# ZIP dosyasının URL'si ve çıkartılacak dizin
$zipUrl = "https://github.com/samratashok/ADModule/archive/refs/heads/master.zip"
$outputFile = Join-Path -Path $workingDirectory -ChildPath "ADModule-main.zip"
$destinationFolder = Join-Path -Path $workingDirectory -ChildPath "ADModule"

# ZIP dosyasını indir
Write-Output "İndiriliyor: $zipUrl"
Invoke-WebRequest -Uri $zipUrl -OutFile $outputFile

# ZIP dosyasını çıkar
Write-Output "Çıkarılıyor: $outputFile"
Expand-Archive -Path $outputFile -DestinationPath $destinationFolder -Force

# ZIP dosyasını sil
Write-Output "ZIP dosyası temizleniyor."
Remove-Item $outputFile -Force

Write-Output "İşlem tamamlandı."

# Modül ve dosyaların yollarını belirleyin
$adModulePath = Join-Path -Path $destinationFolder -ChildPath "ADModule-master\ActiveDirectory"
$adModuleManifest = Join-Path -Path $adModulePath -ChildPath "ActiveDirectory.psd1"
$adModuleDll = Join-Path -Path $destinationFolder -ChildPath "ADModule-master\Microsoft.ActiveDirectory.Management.dll"
$importScript = Join-Path -Path $destinationFolder -ChildPath "ADModule-master\Import-ActiveDirectory.ps1"

# Execution Policy kontrolü ve ayarı
$currentPolicy = Get-ExecutionPolicy
Write-Output "Mevcut Execution Policy: $currentPolicy"

if ($currentPolicy -ne 'RemoteSigned') {
    Write-Output "Execution Policy 'RemoteSigned' olarak ayarlanıyor."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
} else {
    Write-Output "Execution Policy zaten 'RemoteSigned'."
}

# DLL ve PSD1 dosyasını yükleyin
if (Test-Path $adModuleDll) {
    Write-Output "DLL Yükleniyor: $adModuleDll"
    Import-Module $adModuleDll -Verbose
} else {
    Write-Output "DLL bulunamadı: $adModuleDll"
}

if (Test-Path $adModuleManifest) {
    Write-Output "Modül Yükleniyor: $adModuleManifest"
    Import-Module $adModuleManifest
} else {
    Write-Output "Modül manifest dosyası bulunamadı: $adModuleManifest"
}

# Import-ActiveDirectory.ps1 betiğini çalıştırma
if (Test-Path $importScript) {
    Write-Output "Betiği çalıştırma: $importScript"
    . $importScript
} else {
    Write-Output "Import betiği bulunamadı: $importScript"
}

Write-Output "Tüm işlemler tamamlandı."
