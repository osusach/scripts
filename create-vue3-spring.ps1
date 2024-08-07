param (
    [bool]$skipJavaBuild = $true,
    [string]$frontendProjectName = "vue-frontend",
    [string]$backendProjectName = "spring-backend",
    [string]$javaVersion = "21",
    [int]$step = 1,
    [int]$totalSteps = 7
)

# Función para mostrar el progreso
function Update-Step {
    Write-Host
    Write-Host "Creando proyectos: [$step de $totalSteps]" -ForegroundColor Cyan
    Write-Host
    return 1 + $step
}

# Función para verificar la instalación de una herramienta
function Check-Install {
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

    # Mostrar las opciones del menú
    for ($i = 0; $i -lt $options.Length; $i++) {
        Write-Host "$($i + 1). $($options[$i])"
    }

    # Leer la selección del usuario
    $selection = Read-Host "Seleccione una opción por número"

    # Validar si la selección está en el rango válido
    if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $options.Length) {
        return $options[[int]$selection - 1]
    } else {
        Write-Host "Selección inválida. Por favor, elija un número entre 1 y $($options.Length)."
        return Show-Menu -options $options
    }
}

$step = Next-Step
# Verificar e instalar Node.js si es necesario
Check-Install -command "node" -installScript "winget install OpenJS.NodeJS"

# Verificar e instalar create-vite si es necesario
Check-Install -command "create-vite" -installScript "npm install -g create-vite"

# Crear el proyecto frontend con Vite y Vue.js
Write-Host "Creando el proyecto frontend con Vite y Vue.js..."
npx create-vite $frontendProjectName --template vue

$step = Next-Step
# Navegar al directorio del proyecto frontend y instalar dependencias
Set-Location -Path $frontendProjectName
Write-Host "Instalando dependencias del frontend..."
npm install

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
        Write-Host "No se ha agregado ningún CSS framework adicional."
    }
}

$step = Next-Step
# Regresar al directorio raíz
Set-Location -Path ..

# Verificar e instalar JDK y Maven si es necesario
Check-Install -command "java" -installScript "winget install Oracle.OpenJDK.$javaVersion"
Check-Install -command "mvn" -installScript "winget install Apache.Maven"

# Crear el proyecto backend con Spring Boot usando Spring Initializr
Write-Host "Creando el proyecto backend con Spring Boot..."
$backendDir = "./$backendProjectName"
Invoke-WebRequest -Uri "https://start.spring.io/starter.zip?type=maven-project&language=java&bootVersion=3.3.2&baseDir=$backendProjectName&groupId=com.example&artifactId=demo&name=demo&description=Demo+project+for+Spring+Boot&packageName=com.example.demo&packaging=jar&javaVersion=$javaVersion&dependencies=data-jpa%2Cweb%2Cpostgresql%2Clombok" -OutFile "backend.zip"

# Descomprimir el archivo
Expand-Archive -Path backend.zip -DestinationPath $backendDir
Remove-Item backend.zip
Move-Item -Path "$backendProjectName/$backendProjectName/*" -Destination "$backendProjectName" -Force
Remove-Item "$backendProjectName/$backendProjectName"

$step = Next-Step
if ($skipJavaBuild) {
    Write-Host "Omitiendo build de java..."
} else {
    # Navegar al directorio del proyecto backend y compilar
    Set-Location -Path $backendDir
    Write-Host "Instalando dependencias del backend y compilando..."
    mvn clean install
}

# Regresar al directorio raíz
Set-Location -Path ..

$step = Next-Step
Write-Host "Proyectos frontend y backend creados con éxito."
Write-Host "Para iniciar el proyecto frontend, navega a './$frontendProjectName' y ejecuta 'npm run dev'."
Write-Host "Para iniciar el proyecto backend, navega a './$backendProjectName' y ejecuta 'mvn spring-boot:run'."
