# scripts

Scripts de utilidad para estudiantes

Los siguientes scripts fueron creados en 2024 y pueden estar desactualizados si el curso cambió, crea un issue si ocurre!

## winget

Para instalar software los scripts usan winget, una herramienta nativa en Windows 10/11 desde 2020

Si estás usando una versión antigua de Windows 10, puede ser que necesites instalarlo: https://aka.ms/getwinget

## Scripts para FINGESO

Script para crear un front con vue3 y un back con spring: (WINDOWS)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser;
Invoke-RestMethod -Uri https://raw.githubusercontent.com/osusach/scripts/main/fingeso-1.ps1 | Invoke-Expression

```

## Scripts para TINGESO

Script para crear un front con react y un back con spring: (WINDOWS)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser;
Invoke-RestMethod -Uri https://raw.githubusercontent.com/osusach/scripts/main/tingeso-1.ps1 | Invoke-Expression

```
