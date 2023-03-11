Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$DebugPreference = 'SilentlyContinue'
$InformationPreference = 'Continue'

Describe "Calculator" {

    BeforeAll {

        . "$PSScriptRoot\common.ps1"

        $deps = @{
            'Interop.UIAutomationClient' = '10.19041.0';
            'FlaUI.Core' = '4.0.0';
            'FlaUI.UIA3' =  '4.0.0';
        }

        Add-NuGetDependencies -NugetPackages $deps

        $uia = New-Object FlaUI.UIA3.UIA3Automation
        $cf = $uia.ConditionFactory

        $aut = [Diagnostics.Process]::Start('calc')
        $aut.WaitForInputIdle(5000) | Out-Null
        Start-Sleep -s 2

        # Retrieve the correct PID as this changes during application startup
        $autPid = ((Get-Process).where{ $_.MainWindowTitle -eq 'Calculator' })[0].Id

        $desktop = $uia.GetDesktop()
        $mw = $desktop.FindFirstDescendant($cf.ByProcessId($autPid))

        Write-Host "mw: $mw"
    }

    Context 'Can calculate' {

        It 'Solves 5 + 9' {
            # $btn = ($mw.FindFirstDescendant())
            $mw.FindFirstDescendant($cf.ByName('Five')).Click()
            $mw.FindFirstDescendant($cf.ByName('Plus')).Click()
            $mw.FindFirstDescendant($cf.ByName('Nine')).Click()
            $mw.FindFirstDescendant($cf.ByName('Equals')).Click()

            $result = $mw.FindFirstDescendant($cf.ByAutomationId('CalculatorResults')).Name.Split(' ')[2]
            $result | Should -Be 14

        }

    }

    AfterAll {
        $uia.Dispose()
        $aut.Dispose()
        Stop-Process -Force -Id $autPid
    }
}