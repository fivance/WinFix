function Optimize-Network {
  Clear-Host
  Write-Host "Optimizing network adapter settings..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  $progresspreference = 'silentlycontinue'
  # Disable all adapter settings keep ipv4
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_lltdio -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_implat -ErrorAction SilentlyContinue
  Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_rspndr -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_server -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_msclient -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_pacer -ErrorAction SilentlyContinue
  # Rerun so settings stick
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_lltdio -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_implat -ErrorAction SilentlyContinue
  Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_rspndr -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_server -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_msclient -ErrorAction SilentlyContinue
  Disable-NetAdapterBinding -Name "*" -ComponentID ms_pacer -ErrorAction SilentlyContinue
  
  Clear-Host
  Write-Host "Applying Cloudflare DNS servers for adapter..." -ForegroundColor Cyan
  Start-Sleep -Seconds 3
  $progresspreference = 'silentlycontinue'
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("1.1.1.1","1.0.0.1")
  
  Clear-Host 
  Write-Host 'Applying network settings to limit upload bandwidth and improve latency under load...' -ForegroundColor Cyan
      Start-Sleep -Seconds 3
     
      $NIC = @()
      foreach ($a in Get-NetAdapter -Physical | Select-Object DeviceID, Name) { 
        $NIC += @{ $($a | Select-Object Name -ExpandProperty Name) = $($a | Select-Object DeviceID -ExpandProperty DeviceID) }
      }
      
  
      $enableQos = {    
        New-Item 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' 'Do not use NLA' 1 -type string -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' DisableUserTOSSetting 0 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' NonBestEffortLimit 80 -type dword -force -ea 0 
        Get-NetQosPolicy | Remove-NetQosPolicy -Confirm:$False -ea 0
        Remove-NetQosPolicy 'Bufferbloat' -Confirm:$False -ea 0
        New-NetQosPolicy 'Bufferbloat' -Precedence 254 -DSCPAction 46 -NetworkProfile Public -Default -MinBandwidthWeightAction 25
      }
      &$enableQos *>$null
  
      $tcpTweaks = {
        $NIC.Values | ForEach-Object {
          Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$_" TcpAckFrequency 2 -type dword -force -ea 0  
          Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$_" TcpNoDelay 1 -type dword -force -ea 0
        }
        if (Get-Item 'HKLM:\SOFTWARE\Microsoft\MSMQ') { Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters' TCPNoDelay 1 -type dword -force -ea 0 }
        Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' NetworkThrottlingIndex 0xffffffff -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' SystemResponsiveness 10 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' NonBestEffortLimit 80 -type dword -force -ea 0 
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' LargeSystemCache 0 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' Size 3 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' DefaultTTL 64 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' MaxUserPort 65534 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' TcpTimedWaitDelay 30 -type dword -force -ea 0
        New-Item 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' 'Do not use NLA' 1 -type string -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' DnsPriority 6 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' HostsPriority 5 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' LocalPriority 4 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' NetbtPriority 7 -type dword -force -ea 0
        Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' DisableTaskOffload -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' MaximumReassemblyHeaders 0xffff -type dword -force -ea 0 
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters' FastSendDatagramThreshold 1500 -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters' DefaultReceiveWindow $(2048 * 4096) -type dword -force -ea 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters' DefaultSendWindow $(2048 * 4096) -type dword -force -ea 0
      }
      &$tcpTweaks *>$null
  
  
      $NIC.Keys | ForEach-Object { Disable-NetAdapter -InterfaceAlias "$_" -Confirm:$False }
  
      $netAdaptTweaks = {
        foreach ($key in $NIC.Keys) {
          $netProperty = Get-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'NetworkAddress' -ErrorAction SilentlyContinue
          if ($null -ne $netProperty.RegistryValue -and $netProperty.RegistryValue -ne ' ') {
            $mac = $netProperty.RegistryValue 
          }
          Get-NetAdapter -Name "$key" | Reset-NetAdapterAdvancedProperty -DisplayName '*'
          if ($null -ne $mac) { 
            Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'NetworkAddress' -RegistryValue $mac 
          }
          $rx = (Get-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*ReceiveBuffers').NumericParameterMaxValue  
          $tx = (Get-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*TransmitBuffers').NumericParameterMaxValue
          if ($null -ne $rx -and $null -ne $tx) {
            Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*ReceiveBuffers' -RegistryValue $rx # $rx 1024 320
            Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*TransmitBuffers' -RegistryValue $tx # $tx 2048 160
          }
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*InterruptModeration' -RegistryValue 0 # Off 0 On 1
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'ITR' -RegistryValue 0 # Off 0 Adaptive 65535
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*RSS' -RegistryValue 1
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*NumRssQueues' -RegistryValue 2
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*PriorityVLANTag' -RegistryValue 1
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*FlowControl' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*JumboPacket' -RegistryValue 1514
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*HeaderDataSplit' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'TcpSegmentation' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'RxOptimizeThreshold' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'WaitAutoNegComplete' -RegistryValue 1
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'PowerSavingMode' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*SelectiveSuspend' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'EnableGreenEthernet' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'AdvancedEEE' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword 'EEE' -RegistryValue 0
          Set-NetAdapterAdvancedProperty -Name "$key" -RegistryKeyword '*EEE' -RegistryValue 0
        }
  
      }
      &$netAdaptTweaks *>$null
  
  
      $netAdaptTweaks2 = { $NIC.Keys | ForEach-Object {
          Set-NetAdapterRss -Name "$_" -NumberOfReceiveQueues 2 -MaxProcessorNumber 4 -Profile 'NUMAStatic' -Enabled $true -ea 0
          Enable-NetAdapterQos -Name "$_" -ea 0
          Enable-NetAdapterChecksumOffload -Name "$_" -ea 0
          Disable-NetAdapterRsc -Name "$_" -ea 0
          Disable-NetAdapterUso -Name "$_" -ea 0
          Disable-NetAdapterLso -Name "$_" -ea 0
          Disable-NetAdapterIPsecOffload -Name "$_" -ea 0
          Disable-NetAdapterEncapsulatedPacketTaskOffload -Name "$_" -ea 0
        }
          
        Set-NetOffloadGlobalSetting -TaskOffload Enabled
        Set-NetOffloadGlobalSetting -Chimney Disabled
        Set-NetOffloadGlobalSetting -PacketCoalescingFilter Disabled
        Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing Disabled
        Set-NetOffloadGlobalSetting -ReceiveSideScaling Enabled
        Set-NetOffloadGlobalSetting -NetworkDirect Enabled
        Set-NetOffloadGlobalSetting -NetworkDirectAcrossIPSubnets Allowed -ea 0
      }
      &$netAdaptTweaks2 *>$null
  
      $NIC.Keys | ForEach-Object { Enable-NetAdapter -InterfaceAlias "$_" -Confirm:$False }
  
      $netShTweaks = {
        netsh winsock set autotuning on                                    # Winsock send autotuning
        netsh int udp set global uro=disabled                              # UDP Receive Segment Coalescing Offload - 11 24H2
        netsh int tcp set heuristics wsh=disabled forcews=enabled          # Window Scaling heuristics
        netsh int tcp set supplemental internet minrto=300                 # Controls TCP retransmission timeout. 20 to 300 msec.
        netsh int tcp set supplemental internet icw=10                     # Controls initial congestion window. 2 to 64 MSS
        netsh int tcp set supplemental internet congestionprovider=newreno # Controls the congestion provider. Default: cubic
        netsh int tcp set supplemental internet enablecwndrestart=disabled # Controls whether congestion window is restarted.
        netsh int tcp set supplemental internet delayedacktimeout=40       # Controls TCP delayed ack timeout. 10 to 600 msec.
        netsh int tcp set supplemental internet delayedackfrequency=2      # Controls TCP delayed ack frequency. 1 to 255.
        netsh int tcp set supplemental internet rack=enabled               # Controls whether RACK time based recovery is enabled.
        netsh int tcp set supplemental internet taillossprobe=enabled      # Controls whether Tail Loss Probe is enabled.
        netsh int tcp set security mpp=disabled                            # Memory pressure protection (SYN flood drop)
        netsh int tcp set security profiles=disabled                       # Profiles protection (private vs domain)
  
        netsh int tcp set global rss=enabled                    # Enable receive-side scaling.
        netsh int tcp set global autotuninglevel=Normal         # Fix the receive window at its default value
        netsh int tcp set global ecncapability=enabled          # Enable/disable ECN Capability.
        netsh int tcp set global timestamps=enabled             # Enable/disable RFC 1323 timestamps.
        netsh int tcp set global initialrto=1000                # Connect (SYN) retransmit time (in ms).
        netsh int tcp set global rsc=disabled                   # Enable/disable receive segment coalescing.
        netsh int tcp set global nonsackrttresiliency=disabled  # Enable/disable rtt resiliency for non sack clients.
        netsh int tcp set global maxsynretransmissions=4        # Connect retry attempts using SYN packets.
        netsh int tcp set global fastopen=enabled               # Enable/disable TCP Fast Open.
        netsh int tcp set global fastopenfallback=enabled       # Enable/disable TCP Fast Open fallback.
        netsh int tcp set global hystart=enabled                # Enable/disable the HyStart slow start algorithm.
        netsh int tcp set global prr=enabled                    # Enable/disable the Proportional Rate Reduction algorithm.
        netsh int tcp set global pacingprofile=off              # Set the periods during which pacing is enabled. off: Never pace.
  
        netsh int ip set global loopbacklargemtu=enable         # Loopback Large Mtu
        netsh int ip set global loopbackworkercount=4           # Loopback Worker Count 1 2 4
        netsh int ip set global loopbackexecutionmode=inline    # Loopback Execution Mode adaptive|inline|worker
        netsh int ip set global reassemblylimit=267748640       # Reassembly Limit 267748640|0
        netsh int ip set global reassemblyoutoforderlimit=48    # Reassembly Out Of Order Limit 32
        netsh int ip set global sourceroutingbehavior=drop      # Source Routing Behavior drop|dontforward
        netsh int ip set dynamicport tcp start=32769 num=32766  # DynamicPortRange tcp
        netsh int ip set dynamicport udp start=32769 num=32766  # DynamicPortRange udp
      }
      &$netShTweaks *>$null
      Clear-Host
      Write-Host "Successfully applied network tweaks." -ForegroundColor Green
      Start-Sleep -Seconds 3  
}