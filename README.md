# scripts
Scripts de utilidad para estudiantes

Script para crear un front con vue3 y un back con spring: (WINDOWS)
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser;
Invoke-RestMethod -Uri https://raw.githubusercontent.com/osusach/scripts/main/create-vue3-spring.ps1 -OutFile create-vue3-spring.ps1;
.\create-vue3-spring.ps1 -frontendProjectName "my-vue-app" -backendProjectName "my-spring-app"

```
|variable|uso|
|-|-|
|frontendProjectName|Nombre del front|
|backendProjectName|Nombre del back|
|skipJavaBuild|$True (default) o $False, se salta un `mvn clean install`|