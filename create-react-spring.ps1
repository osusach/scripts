
[string]$javaVersion = "17"
[int]$step = 1
[int]$totalSteps = 5

function Show-Osusach {
    param (
        [string]$message
    )
    Write-Host -BackgroundColor DarkYellow
    Write-Host -BackgroundColor Black
    Write-Host "$message" -NoNewline
    Write-Host -BackgroundColor DarkYellow
    Write-Host 
}

# Función para mostrar el progreso
function Update-Step {
    Write-Host
    Write-Host "Creando proyectos: [$step de $totalSteps]" -ForegroundColor Cyan
    Write-Host
    return 1 + $step
}

# Función para verificar la instalación de una herramienta
function Get-Program {
    param (
        [string]$command,
        [string]$installScript
    )
    
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        Write-Host "$command no está instalado. Instalando..."
        Invoke-Expression $installScript
    }
    else {
        Write-Host "$command ya está instalado."
    }
}
# Función para mostrar el menú y seleccionar opción por número
function Show-Menu {
    param (
        [string[]]$options
    )

    Write-Host

    # Mostrar las opciones del menú
    for ($i = 0; $i -lt $options.Length; $i++) {
        Write-Host " $($i + 1). $($options[$i])"
    }

    Write-Host 

    # Leer la selección del usuario
    $selection = Read-Host "Seleccione una opción por número"

    # Validar si la selección está en el rango válido
    if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $options.Length) {
        return $options[[int]$selection - 1]
    }
    else {
        Write-Host "Selección inválida. Por favor, elija un número entre 1 y $($options.Length)."
        return Show-Menu -options $options
    }
}
# Función de pregunta de si o no
function Show-Question {
    param (
        [string]$prompt,
        [string]$yes,
        [string]$no
    )
    $option = Read-Host -Prompt $prompt
    Write-Host
    if ($option -eq "s") {
        Invoke-Expression $yes
    }
    elseif ($option -eq "n") {
        Invoke-Expression $no
    }
    else {
        Show-Question $prompt $yes $no
    }
}

$step = Update-Step

$projectName = Read-Host -Prompt "> Ingresa el nombre del proyecto: "

mkdir $projectName
Set-Location -Path "./$projectName"
$frontendProjectName = "$projectName-frontend"
$backendProjectName = "$projectName-backend"

$step = Update-Step
# Verificar e instalar Node.js si es necesario
Get-Program -command "node" -installScript "winget install OpenJS.NodeJS"
# Verificar e instalar create-vite si es necesario
Get-Program -command "create-vite" -installScript "npm install -g create-vite"

# Crear el proyecto frontend con Vite y Vue.js
Write-Host "Creando el proyecto frontend con Vite y React..."
npx create-vite $frontendProjectName --template react

$step = Update-Step
# Navegar al directorio del proyecto frontend y instalar dependencias
Set-Location -Path $frontendProjectName
Write-Host "Instalando dependencias del frontend..."
npm install

# Agregar axios para solicitudes http al backend
Write-Host "Instalando axios para que podái conectarte a tu backend..."
npm install axios

Show-Osusach -message "Selecciona un framework de CSS"

# Mostrar el menú para opciones adicionales
$options = @("Agregar Tailwind CSS", "Agregar Bootstrap", "No agregar nada")
$selection = Show-Menu -options $options

switch ($selection) {
    "Agregar Tailwind CSS" {
        Write-Host "Agregando Tailwind CSS al proyecto frontend..."
        npm install -D tailwindcss postcss autoprefixer
        npx tailwindcss init -p

        # Configurar Tailwind CSS
        $tailwindConfig = "@tailwind base;\n@tailwind components;\n@tailwind utilities;"
        $tailwindConfig | Set-Content -Path "./src/assets/tailwind.css"

        (Get-Content -Path "./src/main.js") -replace "import './style.css';", "import './assets/tailwind.css';" | Set-Content -Path "./src/main.js"

        Write-Host "Tailwind CSS agregado correctamente."
    }
    "Agregar Bootstrap" {
        Write-Host "Agregando Bootstrap al proyecto frontend..."
        npm install bootstrap
        (Get-Content -Path "./src/main.js") + "`nimport 'bootstrap/dist/css/bootstrap.min.css';" | Set-Content -Path "./src/main.js"
        Write-Host "Bootstrap agregado correctamente."
    }
    "No agregar nada" {
        Write-Host "No se ha agregado ningún framework de CSS adicional."
    }
}

$step = Update-Step
# Regresar al directorio raíz
Set-Location -Path ..

Write-Host "Se instalará el proyecto con Java 17 " -NoNewline
Write-Host -ForegroundColor Red "<para fingeso no necesitái nada de la 21-22, para tbd implementando encriptación y jwt 21 y 22 tiran error>"
Write-Host

# Verificar e instalar JDK y Maven si es necesario
Get-Program -command "java" -installScript "winget install Oracle.OpenJDK.$javaVersion"
Get-Program -command "mvn" -installScript "winget install Apache.Maven"
Write-Host
# Crear el proyecto backend con Spring Boot usando Spring Initializr
Write-Host "Creando el proyecto backend con Spring Boot..."

$groupIdUser = Read-Host -Prompt "> Ingresa un groupID: "
$groupId = "osusach.$groupIdUser" # spam

Show-Osusach -message "Elige el tipo de proyecto"

$options = @("maven-project", "gradle-project", "gradle-project-kotlin")
$projectType = Show-Menu -options $options

$packageName = "$groupId.$projectName"

$backendDir = "./$backendProjectName"
Invoke-WebRequest -Uri "https://start.spring.io/starter.zip?type=$projectType&language=java&bootVersion=3.3.2&baseDir=$backendProjectName&groupId=$groupId&artifactId=$projectName&name=$projectName&description=Backend+project+for+Spring+Boot&packageName=$packageName&packaging=jar&javaVersion=$javaVersion&dependencies=data-jpa%2Cweb%2Cpostgresql%2Clombok" -OutFile "backend.zip"

# Descomprimir el archivo
Expand-Archive -Path backend.zip -DestinationPath $backendDir
Remove-Item backend.zip
Move-Item -Path "$backendProjectName/$backendProjectName/*" -Destination "$backendProjectName" -Force
Remove-Item "$backendProjectName/$backendProjectName"

$step = Update-Step

Show-Question -prompt "> Quieres instalar postgresSQL? (s/n)" -yes "winget install PostgreSQL.PostgreSQL.14 -e" -no "Write-Host 'Omitiendo postgres'"

$step = Update-Step

Show-Question -prompt "> Quieres instalar pgAdmin? (s/n)" -yes "winget install PostgreSQL.pgAdmin -e" -no "Write-Host 'Omitiendo pgAdmin'"

$step = Update-Step
Write-Host "Proyectos frontend y backend creados con éxito."
Write-Host "Para iniciar el proyecto frontend, navega a './$frontendProjectName' y ejecuta 'npm run dev'."
Write-Host "Para iniciar el proyecto backend, navega a './$backendProjectName' y ejecuta 'mvn spring-boot:run'."