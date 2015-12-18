var serialPortObject = new SerialPortDevice();
var bHasInitialized = false;
var bCleanupStarted = false;
var sPortName = "COM1";

//Create a custom dialog with only one exit button to exit the script when needed
function Dialog(parent)
{
	QDialog.call(this, parent);
	var frameStyle = QFrame.Sunken | QFrame.Panel;
	var layout = new QGridLayout;
	layout.setColumnStretch(1, 1);	
	layout.setColumnMinimumWidth(1, 500);
	/////////////////////////////////////////////////////
	this.exitButton = new QPushButton("Exit");	
	layout.addWidget(this.exitButton, 99, 0);
	/////////////////////////////////////////////////////
	this.setLayout(layout);
	this.windowTitle = "Menu Dialog";
}

Dialog.prototype = new QDialog();

Dialog.prototype.keyPressEvent = function(e /*QKeyEvent e*/)
{
	if(e.key() == Qt.Key_Escape)
		this.close();
	else
		QDialog.keyPressEvent(e);
}

Dialog.prototype.closeEvent = function() 
{
	Log("Dialog closeEvent() detected!");
	CleanupScript();
}

function myDataReceivedFunction()
{
	Log("myDataReceivedFunction arguments count: " + arguments.length);
	for (var i = 0; i < arguments.length; ++i)
	{
		Log("myDataReceivedFunction argument(" + i + "): " + arguments[i]);
	}
	serialPortObject.writeData("Echo: " + arguments[0]);
}

function ConnectDisconnectScriptFunctions(Connect)
//This function can connect or disconnect all signal/slot connections defined by the boolean parameter 
{
	if(Connect) //This parameter defines whether we should connect or disconnect the signal/slots.
	{
		Log("... Connecting Signal/Slots");
		try 
		{	
			mainDialog.exitButton["clicked()"].connect(this, this.CleanupScript);
			serialPortObject.SerialDataReceived.connect(this, this.myDataReceivedFunction);
		} 
		catch (e) 
		{
			Log(".*. Something went wrong connecting the Signal/Slots:" + e); //If a connection fails warn the user!
		}
	}
	else
	{
		Log("... Disconnecting Signal/Slots");
		try 
		{	
			mainDialog.exitButton["clicked()"].disconnect(this, this.CleanupScript);	 
			serialPortObject.SerialDataReceived.disconnect(this, this.myDataReceivedFunction);
		} 
		catch (e) 
		{
			Log(".*. Something went wrong disconnecting the Signal/Slots:" + e); //If a disconnection fails warn the user!
		}		
	}
}

function CleanupScript()//Cleanup
{
	if(bCleanupStarted)
		return;
	bCleanupStarted = true;
	//Close serial port
	if(bHasInitialized==true)
		serialPortObject.close();
	//Disconnect the signal/slots
	ConnectDisconnectScriptFunctions(false);
	//Close dialog
	mainDialog.close();
	//Set all functions and constructed objects to null
	myDataReceivedFunction = null;
	ConnectDisconnectScriptFunctions = null;
	CleanupScript = null;	
	//Dialog
	Dialog.prototype.keyPressEvent = null;
	Dialog.prototype.closeEvent = null;	
	Dialog.prototype.testFunction = null;
	Dialog.prototype = null;
	Dialog = null;
	//Objects
	mainDialog = null;
	serialPortObject = null;
	//Post
	Log("\nFinished script cleanup, ready for garbage collection!");
	BrainStim.cleanupScript();
}

var mainDialog = new Dialog();
mainDialog.show();
ConnectDisconnectScriptFunctions(true);
if(serialPortObject.setPortName(sPortName))
{
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
	bHasInitialized = true;
}
else
{
	Log("\nCould not use the requested port (" + sPortName + ") !!!\n")
	CleanupScript();
}