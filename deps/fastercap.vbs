' Parse arguments so they can be passed to FasterCap
runstr = ""
For Each arg In Wscript.Arguments
  runstr = runstr + """" + arg + """"
Next

' Start FasterCap in automation mode
Dim FasterCap
Set FasterCap = CreateObject("FasterCap.Document")

' Register a callback function that will print the log
FasterCap.SetLogCallback GetRef("EchoLog"),"EchoLog"
couldRun = FasterCap.Run(runstr)

' Wait for the computation to be done
Do While FasterCap.IsRunning = True
  WScript.Sleep 50
Loop

' Make sure the log had time to echo
WScript.Sleep 100
exitCode = FasterCap.GetReturnStatus()

' If FasterCap could not run, exit early
If couldRun=0 Or exitCode<>0 Then
  CloseAndExit FasterCap,exitCode
End If

' Echo Capacitance Matrix
capmat = FasterCap.GetCapacitance()
b = UBound(capmat,1)
Dim row
For  i = 0 to b
  row = ""
    For j = 0 to b
      row = row + CStr(capmat(i,j)) + IIf(j=b,"",",")
    Next
  WScript.Echo row
Next

' Echo solve time, solve memory, conductor names and conductor number
WScript.Echo CStr(FasterCap.GetSolveTime())
WScript.Echo CStr(FasterCap.GetSolveMemory())
For Each cond In FasterCap.GetCondNames()
  WScript.Echo cond
Next
WScript.Echo CStr(b+1)

' Exit
CloseAndExit FasterCap, exitCode

' Helper functions
Function CloseAndExit(FasterCap,exitCode)
  ' Close FasterCap
  FasterCap.Quit
  Set FasterCap = Nothing
  ' Manually exit
  WScript.Quit(exitCode)
End Function

Function EchoLog(logString, color)
  WScript.Echo logString
End Function

Function IIf(bClause, sTrue, sFalse)
  If CBool(bClause) Then
    IIf = sTrue
  Else
    IIf = sFalse
  End If
End Function
