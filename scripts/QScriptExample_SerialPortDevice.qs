var tTimer = new TriggerTimer();
var nMaxIdleTime = 5000;
var bHasInitialized = false;
var serialPortObject = new SerialPortDevice();

function myDataReceivedFunction()
{
	Log("myDataReceivedFunction arguments count: " + arguments.length);
	for (var i = 0; i < arguments.length; ++i)
	{
		Log("myDataReceivedFunction argument(" + i + "): " + arguments[i]);
	}
	serialPortObject.writeData("Echo: " + arguments[0]);
	tTimer.startTimer(nMaxIdleTime);
}

function myFinalCleanup()//Cleanup
{
	if(bHasInitialized==true)
	{
		serialPortObject.SerialDataReceived.disconnect(this, this.myDataReceivedFunction);
		tTimer.timeout.disconnect(this, myFinalCleanup);
		tTimer.stopTimer();
		serialPortObject.close();
	}
	tTimer = null;
	myDataReceivedFunction = null;
	serialPortObject = null;
	myFinalCleanup = null;
	Log("Finished script Cleanup!");
	BrainStim.cleanupScript();
}

if(serialPortObject.setPortName("COM1"))
{
	serialPortObject.SerialDataReceived.connect(this, this.myDataReceivedFunction);
	Log(serialPortObject.open(3));
	//        NotOpen = 0x0000,
	//        ReadOnly = 0x0001,
	//        WriteOnly = 0x0002,
	//        ReadWrite = ReadOnly | WriteOnly,
	//        Append = 0x0004,
	//        Truncate = 0x0008,
	//        Text = 0x0010,
	//        Unbuffered = 0x0020
	Log(serialPortObject.portName());
	Log(serialPortObject.setBaudRate(19200));
	Log(serialPortObject.baudRate());
	Log(serialPortObject.setFlowControl(0));//NoFlowControl = 0
	Log(serialPortObject.flowControl());
	Log(serialPortObject.setParity(0));//QSerialPort::NoParity));//NoParity = 0
	Log(serialPortObject.parity());
	Log(serialPortObject.setDataBits(8));//Data8 = 8
	Log(serialPortObject.dataBits());
	Log(serialPortObject.setStopBits(1));//OneStop = 1
	Log(serialPortObject.stopBits());

	tTimer.startTimer(nMaxIdleTime);
	tTimer.timeout.connect(this, myFinalCleanup); 
	bHasInitialized = true;
}
else
{
	Log("Could not use the requested port!!")
	myFinalCleanup();
}