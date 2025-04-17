function Set-ConsoleOpacity {
  param(
      [ValidateRange(10, 100)]
      [int]$Opacity
  )

  # Check if pinvoke type already exists, if not import the relevant functions
  try {
      $Win32Type = [Win32.WindowLayer]
  }
  catch {
      $Win32Type = Add-Type -MemberDefinition @'
              [DllImport("user32.dll")]
              public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
  
              [DllImport("user32.dll")]
              public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
  
              [DllImport("user32.dll")]
              public static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);
'@ -Name WindowLayer -Namespace Win32 -PassThru
  }
  
  # Changes console to black
  function color ($bc, $fc) {
      $a = (Get-Host).UI.RawUI
      $a.BackgroundColor = $bc
      $a.ForegroundColor = $fc 
      Clear-Host 
  } 

  color 'black' 'white'

  # Get the console window width
  $consoleWidth = $Host.UI.RawUI.WindowSize.Width

  # Ensure console width is sufficient
  if ($consoleWidth -lt 21) {
      Write-Host "Console width is too small for the title." -ForegroundColor Red
      return
  }

  # Calculate the number of padding characters needed on each side
  $padding = [Math]::Floor(($consoleWidth - 21) / 2)

  # Ensure padding is non-negative
  if ($padding -lt 0) {
      $padding = 0
  }

  # Create the full title string with padding
  $fullTitle = '-' * $padding + ' WinFix script ' + '-' * $padding

  Write-Host $fullTitle -BackgroundColor White -ForegroundColor Black

  # Calculate opacity value (0-255)
  $OpacityValue = [int]($Opacity * 2.56) - 1

  # Grab the host window's handle
  $ThisProcess = Get-Process -Id $PID
  $WindowHandle = $ThisProcess.MainWindowHandle

  # Constants
  $GwlExStyle = -20
  $WsExLayered = 0x80000
  $LwaAlpha = 0x2

  if ($Win32Type::GetWindowLong($WindowHandle, -20) -band $WsExLayered -ne $WsExLayered) {
      # If Window isn't already marked "Layered", make it so
      [void]$Win32Type::SetWindowLong($WindowHandle, $GwlExStyle, $Win32Type::GetWindowLong($WindowHandle, $GwlExStyle) -bxor $WsExLayered)
  }

  # Set transparency
  [void]$Win32Type::SetLayeredWindowAttributes($WindowHandle, 0, $OpacityValue, $LwaAlpha)
}


Set-ConsoleOpacity -Opacity 93
