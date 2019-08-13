@echo off
:: Initalize test files
set /A serial=19000
set surInitial=P

rmdir /s testBox\
rmdir /s testDest\
rmdir /s testSrc\

mkdir "./testBox/Box 5000"
mkdir testSrc
mkdir testDest

call :populate_folder_with_files .\testDest, 19000, 60, 20000, Z

mkdir testDest\bucket_1
call :populate_folder_with_files .\testDest\bucket_1, 13000, 50, 18000, T

mkdir testDest\bucket_2
call :populate_folder_with_files .\testDest\bucket_2, 12000, 100, 14000, T

exit /b 0

:populate_folder_with_files
for /l %%i in (%2,%3,%4) do (
    mkdir "%1\%%i-%5"
    echo: > "testSrc\%%i-%5.pdf"
)
exit /b 0
