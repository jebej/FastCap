' Parse arguments so they can be passed to FastCap2
runstr = ""
For Each arg In Wscript.Arguments
  runstr = runstr + """" + arg + """"
Next

' Start FastCap2 in automation mode
Dim FastCap2
Set FastCap2 = CreateObject("FastCap2.Document")

' Register a callback function that will print the log
FastCap2.SetLogCallback GetRef("EchoLog"),"EchoLog"
couldRun = FastCap2.Run(runstr)

' Wait for the computation to be done
Do While FastCap2.IsRunning = True
  WScript.Sleep 50
Loop

' Make sure the log had time to echo
WScript.Sleep 100
exitCode = FastCap2.GetReturnStatus()

' If FastCap2 could not run, exit early
If couldRun=0 Or exitCode<>0 Then
  CloseAndExit FastCap2,exitCode
End If

' Echo Capacitance Matrix
capmat = FastCap2.GetCapacitance()
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
WScript.Echo CStr(FastCap2.GetSolveTime())
WScript.Echo CStr(FastCap2.GetSolveMemory())
For Each cond In FastCap2.GetCondNames()
  WScript.Echo cond
Next
WScript.Echo CStr(b+1)

' Exit
CloseAndExit FastCap2, exitCode

' Helper functions
Function CloseAndExit(FastCap2,exitCode)
  ' Close FastCap2
  FastCap2.Quit
  Set FastCap2 = Nothing
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
