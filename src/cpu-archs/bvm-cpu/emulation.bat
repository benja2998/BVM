@echo off

setlocal enabledelayedexpansion
chcp 65001 >nul

rem Request input for the BVM file name
set "bvm_file=%~1"

echo Current directory: %cd%

if not defined bvm_file (
    echo No argument provided. Falling back to user input.
    set /p "bvm_file=Enter the BVM file: "
    echo --- Begin execution below ---
)

if not exist "%bvm_file%" (
    echo File "%bvm_file%" does not exist.
    exit /b 1
)

rem Initialize register R1-R9

set "R1=0"
set "R2=0"
set "R3=0"
set "R4=0"
set "R5=0"
set "R6=0"
set "R7=0"
set "R8=0"
set "R9=0"

rem Load the example BVM file into memory (variables)
set "linenum=0"

for /f "tokens=*" %%a in (%bvm_file%) do (
    set /a linenum+=1
    set "line[!linenum!]=%%a"
)

rem Initialize the program counter
set "pc=1"
rem Initialize caller
set "caller=0"
rem Initialize ZF (Zero Flag)
set "ZF=0"

rem Do a loop in each line to store labels into variables

for /f "tokens=*" %%a in ('type "%bvm_file%"') do (
    set /a pc+=1
    echo %%a | findstr /r "^[a-zA-Z0-9_][a-zA-Z0-9_]*:" >nul
    if not errorlevel 1 (
        for /f "tokens=1 delims=:" %%f in ("%%a") do (
            set "label_%%f=!pc!"
        )
    )
)

set "pc=1" & rem Reset the program counter to 1

goto :main_loop

rem Main execution loop
:main_loop
if !pc! gtr !linenum! (
    echo Segmentation fault ^(core dumped^)
    exit /b 1
)

rem Basic hack to get the current line
for /f "tokens=*" %%a in ("!pc!") do (
    set "current_line=!line[%%a]!"
)

::echo Executing line !pc!: !current_line!

set /a pc+=1

rem Split the current line into command, operand1 and operand2
for /f "tokens=1,2,3 delims=, " %%b in ("!current_line!") do (
    set "command=%%b"
    set "operand1=%%c"
    set "operand2=%%d"
)

rem Handle SUB, ADD, MOV, PRN, and HLT commands
if "!command!"=="MOV" (
    rem This is a hack to get the source and destination registers
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Destination register is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Destination register is not defined.
            exit /b 1
        )
    )
    for /f "tokens=1" %%e in ("!operand2!") do (
        if not defined operand2 (
            echo Source operand is not defined.
            exit /b 1
        )

        if defined %%e (
            set "src=!%%e!"
            set "src_name=!operand2!"
        ) else (
            set "src=!operand2!"
            set "src_name=!operand2!"
        )
    )
    
    set "!dest_name!=!src!"
)

if "!command!"=="ADD" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Destination register is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Destination register is not defined.
            exit /b 1
        )
    )
    for /f "tokens=1" %%e in ("!operand2!") do (
        if not defined operand2 (
            echo Source operand is not defined.
            exit /b 1
        )

        if defined %%e (
            set "src=!%%e!"
            set "src_name=!operand2!"
        ) else (
            set "src=!operand2!"
            set "src_name=!operand2!"
        )
    )

    set /a !dest_name!=!dest_name! + !src!
)

if "!command!"=="SUB" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Destination register is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Destination register is not defined.
            exit /b 1
        )
    )
    for /f "tokens=1" %%e in ("!operand2!") do (
        if not defined operand2 (
            echo Source operand is not defined.
            exit /b 1
        )

        if defined %%e (
            set "src=!%%e!"
            set "src_name=!operand2!"
        ) else (
            set "src=!operand2!"
            set "src_name=!operand2!"
        )
    )

    set /a !dest_name!=!dest_name! - !src!
)


if "!command!"=="MUL" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Destination register is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Destination register is not defined.
            exit /b 1
        )
    )
    for /f "tokens=1" %%e in ("!operand2!") do (
        if not defined operand2 (
            echo Source operand is not defined.
            exit /b 1
        )

        if defined %%e (
            set "src=!%%e!"
            set "src_name=!operand2!"
        ) else (
            set "src=!operand2!"
            set "src_name=!operand2!"
        )
    )

    set /a !dest_name!=!dest_name! * !src!
)

if "!command!"=="VAR" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        set "dest=!%%e!"
        set "dest_name=!operand1!"
    )

    set "!dest_name!=0"
)


if "!command!"=="XOR" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Destination register is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Destination register is not defined.
            exit /b 1
        )
    )
    for /f "tokens=1" %%e in ("!operand2!") do (
        if not defined operand2 (
            echo Source operand is not defined.
            exit /b 1
        )

        if defined %%e (
            set "src=!%%e!"
            set "src_name=!operand2!"
        ) else (
            set "src=!operand2!"
            set "src_name=!operand2!"
        )
    )

    set /a !dest_name!=!dest_name!^!src!
)

if "!command!"=="VAR" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        set "dest=!%%e!"
        set "dest_name=!operand1!"
    )

    set "!dest_name!=0"
)

if "!command!"=="DIV" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Destination register is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Destination register is not defined.
            exit /b 1
        )
    )
    for /f "tokens=1" %%e in ("!operand2!") do (
        if not defined operand2 (
            echo Source operand is not defined.
            exit /b 1
        )

        if defined %%e (
            set "src=!%%e!"
            set "src_name=!operand2!"
        ) else (
            set "src=!operand2!"
            set "src_name=!operand2!"
        )
    )

    set /a !dest_name!=!dest_name! / !src!
)

rem Check if the command is PRN (Print Number)
if "!command!"=="PRN" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Operand to print is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Operand to print is not defined.
            exit /b 1
        )
    )

    echo !dest!
)

rem Check if the command is JMP

if "!command!"=="JMP" (
    rem This is a hack to get the label name
    for /f "tokens=1" %%g in ("!operand1!") do (
        set "label_name=label_%%g"
        set "label=!label_%%g!"

        if not defined label (
            echo Segmentation fault
            exit /b 1
        )

        set /a pc=label
    )
)

rem Check if the command is CALL

if "!command!"=="CALL" (
    rem This is a hack to get the label name
    for /f "tokens=1" %%g in ("!operand1!") do (
        set "label_name=label_%%g"
        set "label=!label_%%g!"

        if not defined label (
            echo Segmentation fault
            exit /b 1
        )

        set /a caller=pc & rem This is the difference between CALL and JMP

        set /a pc=label
    )
)

rem Check if the command is RET
if "!command!"=="RET" (
    if !caller! equ 0 (
        echo Segmentation fault
        exit /b 1
    )
    set /a pc=caller
    set /a caller=0
)

rem Check if the command is CMP
if "!command!"=="CMP" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Destination register is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Destination register is not defined.
            exit /b 1
        )
    )
    for /f "tokens=1" %%e in ("!operand2!") do (
        if not defined operand2 (
            echo Source operand is not defined.
            exit /b 1
        )

        if defined %%e (
            set "src=!%%e!"
            set "src_name=!operand2!"
        ) else (
            set "src=!operand2!"
            set "src_name=!operand2!"
        )
    )

    rem Compare the two registers
    set /a temp=!dest_name! - !src_name!
    if !temp! equ 0 (
        set "ZF=1" & rem Set Zero Flag to 1 if they are equal
    ) else (
        set "ZF=0" & rem Set Zero Flag to 0 if they are not equal
    )
)

rem Check if the command is JE (Jump if Equal)
if "!command!"=="JE" (
    if !ZF! equ 1 (
        rem This is a hack to get the label name
        for /f "tokens=1" %%g in ("!operand1!") do (
            set "label_name=label_%%g"
            set "label=!label_%%g!"

            if not defined label (
                echo Segmentation fault
                exit /b 1
            )

            set /a pc=label
        )
    )
)

rem Check if the command is JNE (Jump if Not Equal)
if "!command!"=="JNE" (
    if !ZF! equ 0 (
        rem This is a hack to get the label name
        for /f "tokens=1" %%g in ("!operand1!") do (
            set "label_name=label_%%g"
            set "label=!label_%%g!"

            if not defined label (
                echo Segmentation fault
                exit /b 1
            )

            set /a pc=label
        )
    )
)

rem Check if the command is PRA (Print ASCII)
if "!command!"=="PRA" (
    for /f "tokens=1" %%e in ("!operand1!") do (
        if not defined operand1 (
            echo Operand to print is not defined.
            exit /b 1
        )

        set "dest=!%%e!"
        set "dest_name=!operand1!"

        if not defined dest (
            echo Operand to print is not defined.
            exit /b 1
        )
    )

    rem Set variables for each ascii character
    set "ascii_32=` `"
    set "ascii_33=^!"
    set "ascii_34="""
    set "ascii_35=#"
    set "ascii_36=$"
    set "ascii_37=^%"
    set "ascii_38=&"
    set "ascii_39='"
    set "ascii_40=^("
    set "ascii_41=^)"
    set "ascii_42=*"
    set "ascii_43=+"
    set "ascii_44=^,"
    set "ascii_45=-"
    set "ascii_46=."
    set "ascii_47=/"
    set "ascii_48=0"
    set "ascii_49=1"
    set "ascii_50=2"
    set "ascii_51=3"
    set "ascii_52=4"
    set "ascii_53=5"
    set "ascii_54=6"
    set "ascii_55=7"
    set "ascii_56=8"
    set "ascii_57=9"
    set "ascii_58=:"
    set "ascii_59=;"
    set "ascii_60=<"
    set "ascii_61=="
    set "ascii_62=>"
    set "ascii_63=?"
    set "ascii_64=@"
    set "ascii_65=A"
    set "ascii_66=B"
    set "ascii_67=C"
    set "ascii_68=D"
    set "ascii_69=E"
    set "ascii_70=F"
    set "ascii_71=G"
    set "ascii_72=H"
    set "ascii_73=I"
    set "ascii_74=J"
    set "ascii_75=K"
    set "ascii_76=L"
    set "ascii_77=M"
    set "ascii_78=N"
    set "ascii_79=O"
    set "ascii_80=P"
    set "ascii_81=Q"
    set "ascii_82=R"
    set "ascii_83=S"
    set "ascii_84=T"
    set "ascii_85=U"
    set "ascii_86=V"
    set "ascii_87=W"
    set "ascii_88=X"
    set "ascii_89=Y"
    set "ascii_90=Z"
    set "ascii_91=["
    set "ascii_92=\"
    set "ascii_93=]"
    set "ascii_94=^"
    set "ascii_95=_"
    set "ascii_96=`"
    set "ascii_97=a"
    set "ascii_98=b"
    set "ascii_99=c"
    set "ascii_100=d"
    set "ascii_101=e"
    set "ascii_102=f"
    set "ascii_103=g"
    set "ascii_104=h"
    set "ascii_105=i"
    set "ascii_106=j"
    set "ascii_107=k"
    set "ascii_108=l"
    set "ascii_109=m"
    set "ascii_110=n"
    set "ascii_111=o"
    set "ascii_112=p"
    set "ascii_113=q"
    set "ascii_114=r"
    set "ascii_115=s"
    set "ascii_116=t"
    set "ascii_117=u"
    set "ascii_118=v"
    set "ascii_119=w"
    set "ascii_120=x"
    set "ascii_121=y"
    set "ascii_122=z"
    set "ascii_123={"
    set "ascii_124=^|"
    set "ascii_125=}"
    set "ascii_126=~"

    rem Print the ASCII character
    for /f "tokens=1" %%f in ("!dest!") do (
        set "ascii_char=!ascii_%%f!"
        if defined ascii_char (
            <nul set /p="!ascii_char!" & rem Print the character without a newline
        ) else if "!ascii_char!"=="10" (
            echo.
        ) else (
            <nul set /p="<Unknown>" & rem If the character is not defined, print a question mark
        )
    )
)

rem Check if the command is HLT (Halt)
if "!command!"=="HLT" (
    exit /b !R1!
)
goto main_loop
