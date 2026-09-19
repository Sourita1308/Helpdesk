@echo off
title HelpDesk Lite - Internal IT Ticketing & Asset Tracker
echo ==================================================================
echo   Starting HelpDesk Lite Server (Embedded Apache Tomcat)...
echo ==================================================================
call "%~dp0mvnw.cmd" exec:java
pause
