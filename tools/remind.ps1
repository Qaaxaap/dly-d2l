<#
.SYNOPSIS
    扬声器提醒：响几声提示音，可选念一句中文。

.DESCRIPTION
    给学习节奏控制用的。AI 到点查进度，学习者没回话就叫他回来。

    提示音走 [console]::Beep（现代 Windows 会从默认音频设备出声，不受系统音量之外的
    额外设置影响），失败时退回 SystemSounds 提示音；两者都失败也只是静默跳过，
    不会让脚本报错退出——远程会话或没有音频设备的机器上照样能用。

    中文朗读用 .NET 自带的 System.Speech。系统没装中文语音包时只跳过朗读并打一行警告。

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/remind.ps1
    一声提示音。

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/remind.ps1 -Times 3
    连响三声，溜号了用这个。

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/remind.ps1 -Times 2 -Message "该看进度了"
    响两声，再念出来。
#>

param(
    [int]$Times = 1,
    [string]$Message = ""
)

# 出错也不要中断后面的步骤：提醒本身失败不该影响别的
$ErrorActionPreference = 'Continue'

if ($Times -lt 1 -or $Times -gt 10) {
    Write-Error "Times 要在 1 到 10 之间，收到的是 $Times"
    exit 2
}

# ---- 提示音 ----------------------------------------------------------------
function Invoke-AlertSound {
    # 880 Hz、250 毫秒，比默认的 800 Hz 短促音更容易听出来
    try {
        [console]::Beep(880, 250)
        return $true
    }
    catch {
        # 没有音频设备 / 远程会话：退回系统提示音，再不行就算了
        try {
            [System.Media.SystemSounds]::Exclamation.Play()
            return $true
        }
        catch {
            return $false
        }
    }
}

$ok = $true
for ($i = 1; $i -le $Times; $i++) {
    if (-not (Invoke-AlertSound)) { $ok = $false }
    if ($i -lt $Times) { Start-Sleep -Milliseconds 400 }
}

if ($ok) {
    Write-Output "响 $Times 声"
} else {
    Write-Output "响 $Times 声（没有音频设备，已静默跳过）"
}

# ---- 念一句 ----------------------------------------------------------------
if ($Message -ne "") {
    # 留一点间隔，别让语音盖住提示音
    Start-Sleep -Milliseconds 300
    try {
        Add-Type -AssemblyName System.Speech
        $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $synth.Volume = 100
        $synth.Rate = 0
        $synth.Speak($Message)
        Write-Output "已念：$Message"
    }
    catch {
        Write-Warning "朗读失败（多半是系统没有可用的语音包），提示音已经响过：$($_.Exception.Message)"
    }
}

exit 0
