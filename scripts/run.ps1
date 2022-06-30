param(
	[string] $FilePath,
	[switch] $Debugger,
	[switch] $DisASM,
	[string[]] $GCCArgs = @('-m32')
)

#
# Skrypt do wygodniejszej kompilacji pojedynczych plików ASM.
#

if (! (Test-Path env:MINGW32_HOME)) {
	$env:MINGW32_HOME = "F:\msys64\mingw32\bin"
}
if (! (Test-Path env:NASM_HOME)) {
	$env:NASM_HOME = "C:\Program Files\NASM"
}

$env:Path = "$env:NASM_HOME;$env:MINGW32_HOME;$env:Path"

if (! (Test-Path -Path "$FilePath" -Type Leaf)) {
	Write-Host "File '$FilePath' doesn't exist!"
	exit 1
}

$type = "asmloader"
if (
	(Select-String -Path $FilePath -Pattern 'extern'  -Quiet -SimpleMatch) -And 
	(Select-String -Path $FilePath -Pattern 'section' -Quiet -SimpleMatch) -And
	(Select-String -Path $FilePath -Pattern 'global'  -Quiet -SimpleMatch)
) {
	$type = "gcc"
}

switch ($type) {
	"asmloader" {
		nasm.exe -o "$FilePath.bin" "$FilePath"
		if ($LastExitCode -ne 0) {
			exit 2
		}
		if ($DisASM) {
			ndisasm.exe -b 32 "$FilePath.bin"
		}
		else {
			if ($Debugger) {
				gdb.exe --args asmloader.exe "$FilePath.bin"
			}
			else {
				asmloader.exe "$FilePath.bin"
				Write-Host "Exit code: $LastExitCode"
			}
		}
		Remove-Item "$FilePath.bin"
	}
	"gcc" {
		nasm.exe -f win32 -o "$FilePath.o" "$FilePath"
		if ($LastExitCode -ne 0) {
			exit 2
		}
		if ($Debugger) {
			$GCCArgs += @("-ggdb")
		}
		gcc.exe @GCCArgs "$FilePath.o" -o "$FilePath.exe"
		if ($LastExitCode -ne 0) {
			exit 3
		}
		if ($DisASM) {
			objdump.exe -M intel -d "$FilePath.o"
		}
		else {
			if ($Debugger) {
				gdb.exe --args "$FilePath.exe"
			}
			else {
				& "$FilePath.exe"
				Write-Host "Exit code: $LastExitCode"
			}
		}
		Remove-Item "$FilePath.o"
		# Remove-Item "$FilePath.exe"
	}
}
