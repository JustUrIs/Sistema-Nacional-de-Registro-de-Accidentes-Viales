@echo off
cd /d "%~dp0"
git init -b main
git config user.email "justurisbussines@gmail.com"
git config user.name "JustUrIs"
git remote add origin https://github.com/JustUrIs/Sistema-Nacional-de-Registro-de-Accidentes-Viales.git 2>nul || git remote set-url origin https://github.com/JustUrIs/Sistema-Nacional-de-Registro-de-Accidentes-Viales.git
git add 01_schema.sql 02_data.sql 03_consultas.sql schema_visual.html der_interactivo.html TD7_informe.tex TD7_informe.pdf
git commit -m "Primera entrega: esquema SQL, datos, consultas, informe LaTeX y visualizador HTML interactivo"
git push -u origin main
pause
