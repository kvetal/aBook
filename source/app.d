import std.stdio;
import qte5;
import core.runtime;
import forms;
import std.process;

//import std.string;
//import std.conv;


int main(string[] args)
{
	bool fDebug = true;
	if (1 == LoadQt(dll.QtE5Widgets,fDebug)) return 1;
	QApplication app = new QApplication(&Runtime.cArgs.argc, Runtime.cArgs.argv,1);
	Form1 f1 = new Form1();
	f1.show().saveThis(&f1);
	app.exec();
	scope(exit){
			if ((f1.db !is null) && f1.db.connected) f1.db.close();
	//spawnProcess("cmd.exe");
	}
	return 0;
}


