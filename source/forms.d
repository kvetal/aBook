module forms;

import std.stdio;
import qte5;
import core.runtime;
import std.string;
import std.conv;
import mybase;
import mysql;
import std.variant;
import app;
import std.datetime.date;
import mylib; 

extern (C) {
	void on_actionButton1(Form1* h){
		(*h).button1Click();
	}
	void on_actionButton3(Form1* h){
		(*h).button3Click();
	}
	void on_actionButton2(Form1* h){
		(*h).button2Click();
	}
	void on_signal(Form1* h,int n,int curr_r,int curr_c, int prev_r, int prev_c){
		(*h).cellChange(curr_r,curr_c,prev_r,prev_c);
	}
	
	void on_newButton(Form1* h){
		(*h).newButtonClick();
	}

	void on_delButton(Form1* h){
		(*h).delButtonClick();
	}
	
	void on_exit(Form1* h){
		(*h).fExit;
	}

}

class Form1 :QWidget {
	mydb db;
	private {
		ulong tRows,tCols;
		QVBoxLayout vLayAll; //Общ. верт выравниватель
		QHBoxLayout hLay1,hLay2,hLay3,hLay4; //Горизонтальный выравниватель
		QLabel Label1,Label_dbHost,Label_dbUser,Label_dbPort,Label_dbPwd,Label_dbName;
		QPushButton Button1,Button2,Button3, newButton, delButton;
		QAction actionButton1,actionButton3,actionButton2,actionNewButton, actionDelButton;
		QAction actionCellChanged,actionExit;
		QTableWidget Table1;
		QTableWidgetItem[][] items;
		QTableWidgetItem[] cols_header;
		QLineEdit LineEdit_dbHost,LineEdit_dbUser,LineEdit_dbPort,LineEdit_dbPwd,LineEdit_dbName;
	}
	this (QWidget parent, WindowType windowType){
		super(parent, windowType);
		this.resize(900,500);
		setWindowTitle("Адресная книга");
		vLayAll = new QVBoxLayout(this);
		hLay1 = new QHBoxLayout(null);
		hLay2 = new QHBoxLayout(null);
		hLay3 = new QHBoxLayout(null);
		hLay4 = new QHBoxLayout(null);
		LineEdit_dbHost = new QLineEdit(this);
		LineEdit_dbUser = new QLineEdit(this);
		LineEdit_dbPort = new QLineEdit(this);
		LineEdit_dbPwd = new QLineEdit(this);
		LineEdit_dbName = new QLineEdit(this);
		Label1 = new QLabel(this);
		(Label_dbHost = new QLabel(this)).setText("Host");
		(Label_dbPort = new QLabel(this)).setText("Port");
		(Label_dbUser = new QLabel(this)).setText("User");
		(Label_dbPwd = new QLabel(this)).setText("Password");
		(Label_dbName = new QLabel(this)).setText("Database");
		Button1 = new QPushButton("подключится к базе данных",this);
		Button2 = new QPushButton("Обновить",this);
		Button3 = new QPushButton("Редактировать",this);
		newButton = new QPushButton("Добавить",this);
		delButton = new QPushButton("Удалить",this);
		Button2.setEnabled(false);
		Button3.setEnabled(false);
		newButton.setEnabled(false);
		delButton.setEnabled(false);

		Table1 = new QTableWidget(this);
		
		LineEdit_dbPwd.setEchoMode(QLineEdit.EchoMode.Password);
		LineEdit_dbHost.setText("192.168.1.1");
		LineEdit_dbUser.setText("test");
		LineEdit_dbPort.setText("3306");
		LineEdit_dbPwd.setText("test");
		LineEdit_dbName.setText("storage");

		actionButton1 = new QAction(this,&on_actionButton1,aThis);
		actionButton3 = new QAction(this,&on_actionButton3,aThis);
		actionButton2 = new QAction(this,&on_actionButton2,aThis);
		actionNewButton = new QAction(this,&on_newButton,aThis);
		actionDelButton = new QAction(this,&on_delButton,aThis);
		actionCellChanged = new QAction(this,&on_signal,aThis);
		
		connects(Table1,"currentCellChanged(int, int, int, int)",actionCellChanged,"Slot_ANIIII(int, int, int, int)");
		connects(Button1,"clicked()",actionButton1,"Slot()");
		connects(Button2,"clicked()",actionButton2,"Slot()");
		connects(Button3,"clicked()",actionButton3,"Slot()");
		connects(newButton,"clicked()",actionNewButton,"Slot()");
		connects(delButton,"clicked()",actionDelButton,"Slot()");
		
		hLay1.addWidget(Button1);
		hLay2.addWidget(Label_dbHost).
			  addWidget(Label_dbPort).
			  addWidget(Label_dbUser).
			  addWidget(Label_dbPwd).
			  addWidget(Label_dbName);
		hLay3.addWidget(LineEdit_dbHost).
			  addWidget(LineEdit_dbPort).
			  addWidget(LineEdit_dbUser).
			  addWidget(LineEdit_dbPwd).
			  addWidget(LineEdit_dbName);
		hLay4.addWidget(Button2).addWidget(Button3).addWidget(newButton).addWidget(delButton);
		vLayAll.addWidget(Label1).addLayout(hLay1).addLayout(hLay2).addLayout(hLay3).addWidget(Table1).addLayout(hLay4);
		this.setCloseEvent(&on_exit,aThis);
	}

		
	void button1Click(){
		try {
			if (db !is null) db.close();
			db = new mydb;
			db.connect(LineEdit_dbHost.text!string,LineEdit_dbPort.text!string,LineEdit_dbUser.text!string,LineEdit_dbPwd.text!string,LineEdit_dbName.text!string);
		} catch (Exception e)
		{
			Label1.setText("Ошибка при подключении:"~e.msg);
		}
		if (db.connected){
			Label1.setText("Подключено к БД");
			fillTable1();
			Table1.setCurrentCell(0,0);
			Button2.setEnabled(true);
			Button3.setEnabled(true);
			newButton.setEnabled(true);
			delButton.setEnabled(true);
		}
		else{
			Label1.setText("Не подключено к БД");
		}
	}
	
	void button2Click(){
		fillTable1();
	}
	
	void fillTable1(){
		if ((db !is null) && db.connected){
			items = db.getItems("person");
			if (items !is null) {
				// получаем и задаем рвзмеры таблицы
				this.tRows = items.length;
				this.tCols = items[0].length;
				Table1.setRowCount(cast(int)this.tRows).setColumnCount(cast(int)this.tCols).hideColumn(0);
				//Заполняем заголовки столбцов
				if (cols_header is null){
					auto tmp_colNames = db.colNames; //Получаем имена Столбцов
					for (auto i = 0; i<=(tCols-1);i++){
						cols_header ~= new QTableWidgetItem(i).setText(tmp_colNames[i]);
					}
					foreach (e;cols_header){
						e.setNoDelete(true);
						}
					for (auto i = 0; i<=(tCols-1);i++){
						Table1.setHorizontalHeaderItem(i,cols_header[i]);
					}
				}
				//Присваеваем ячейкам таблицы итемы. 
				for (auto i = 0;i<=tRows-1;i++){
					for(auto j = 0;j<=tCols-1;j++){
						items[i][j].setFlags(items[i][j].flags-QtE.ItemFlag.ItemIsEditable);
						Table1.setItem(i,j,items[i][j]);
					}
				}
			}
		}else{
			Label1.setText("Не подключено к БД");
		}
	}

	void button3Click(){
		if ((db !is null) && db.connected){
			ContactEdit cc = new ContactEdit(this,QtE.WindowType.Dialog,db.getRow(Table1.item(Table1.currentRow,0).text!int,"person"),this.db);
			cc.saveThis(&cc);
			cc.exec();
			fillTable1();
			}
		}

	void newButtonClick(){
		if ((db !is null) && db.connected){
			ContactEdit cc = new ContactEdit(this,QtE.WindowType.Dialog,null,this.db);
			cc.saveThis(&cc);
			cc.exec();
			fillTable1();
			}
	}

	void delButtonClick(){
		this.db.delRecord(Table1.item(Table1.currentRow,0).text!int);
		fillTable1();
	}
	
	void cellChange(int curr_r,int curr_c, int prev_r, int prev_c){
		//
	}

	void fExit(){
		if ((db !is null) && db.connected) 
		{
			db.close();
		}
	}

}

extern (C){
	void on_okButton1(ContactEdit* h){
		(*h).okButtonClick();
	}
	void on_cancelButton1(ContactEdit* h){
		(*h).close();
	}
	void on_noteChanged(ContactEdit* h,int n){
		(*h).noteChanged();
	}
	
	void on_sexChanged(ContactEdit* h,int n){
		(*h).sexChanged();
	}
}

class ContactEdit : QDialog {
	mydb db;
	string id;
	private {
		QGridLayout gLay;
		QLineEdit f_nameEdit, m_nameEdit, l_nameEdit, b_dateEdit, emailEdit, m_phoneEdit;
		QLineEdit postcodeEdit, countryEdit, cityEdit, streetEdit, houseEdit, buildingEdit, apartmentEdit;
		QComboBox sexEdit;
		QPlainTextEdit noteEdit;
		QPushButton okButton,cancelButton;
		QLabel lFName, lMName, lLName, lB_Date,lEmail,lM_Phone, lSex, lNote;
		QLabel lPostcode, lCountry, lCity, lStreet, lHouse, lBuilding, lApartment;
		QAction actionOk, actionCancel, actionNoteChanged, actionSexChanged;
		QLineEdit[string] outData;
		bool noteModified = false;
		bool sexModified = false;
	}
	this(QWidget parent, QtE.WindowType fl, Variant[string] data, mydb db){
		this.db = db;
		super(parent,fl);
		this.resize(700,600);
		setWindowTitle("Редактирование записи.");
		gLay = new QGridLayout(this);
		f_nameEdit = new QLineEdit(this);
		m_nameEdit = new QLineEdit(this);
		l_nameEdit = new QLineEdit(this);
		b_dateEdit = new QLineEdit(this);
			QString datemask =  new QString("0000-00-00");
			b_dateEdit.setInputMask(datemask);
		emailEdit = new QLineEdit(this);
		m_phoneEdit = new QLineEdit(this);
			QString phonemask =  new QString("+0-000-000-00-00");
			m_phoneEdit.setInputMask(phonemask);
		sexEdit = new QComboBox(this);
		if (data is null) sexEdit.addItem("-",3).addItem("Ж",2).addItem("М",1);
		noteEdit = new QPlainTextEdit(this);
		postcodeEdit = new QLineEdit(this);
			QString pcodemask =  new QString("0000000000");
			postcodeEdit.setInputMask(pcodemask);
		countryEdit= new QLineEdit(this);
		cityEdit = new QLineEdit(this);
		streetEdit = new QLineEdit(this);
		houseEdit = new QLineEdit(this);
			QString nummask =  new QString("00000");
			houseEdit.setInputMask(nummask);
		buildingEdit = new QLineEdit(this);
		apartmentEdit = new QLineEdit(this);
			apartmentEdit.setInputMask(nummask);
			
		outData["f_name"] = f_nameEdit;
		outData["m_name"] = m_nameEdit;
		outData["l_name"] = l_nameEdit;
		outData["b_date"] = b_dateEdit;
		outData["email"] = emailEdit;
		outData["mobile_phone"] = m_phoneEdit;
		outData["postcode"] = postcodeEdit;
		outData["country"] = countryEdit;
		outData["city"] = cityEdit;
		outData["street"] = streetEdit;
		outData["house"] = houseEdit;
		outData["building"] = buildingEdit;
		outData["apartment"] = apartmentEdit;
		
		if (data !is null){
			this.id = data["id"].toString;
			f_nameEdit.setText(data["f_name"].toString);
			f_nameEdit.setModified(false);
			m_nameEdit.setText(data["m_name"].toString);
			m_nameEdit.setModified(false);
			l_nameEdit.setText(data["l_name"].toString);
			l_nameEdit.setModified(false);
			if (validDate(data["b_date"].toString)){
				Date dt = Date.fromSimpleString(data["b_date"].toString);
				b_dateEdit.setText(dt.toISOExtString());
			}
			b_dateEdit.setModified(false);
			emailEdit.setText(data["email"].toString);
			emailEdit.setModified(false);
			m_phoneEdit.setText(data["mobile_phone"].toString);
			m_phoneEdit.setModified(false);

			if (data["sex"] == "М") sexEdit.addItem("М",1).addItem("Ж",2).addItem("-",3);
				else if (data["sex"] == "Ж") sexEdit.addItem("Ж",2).addItem("М",1).addItem("-",3); 
					 else sexEdit.addItem("-",3).addItem("Ж",2).addItem("М",1);
		
			noteEdit.appendPlainText(data["note"]);

			postcodeEdit.setText(data["postcode"].toString);
			postcodeEdit.setModified(false);
			
			countryEdit.setText(data["country"].toString);
			countryEdit.setModified(false);
			
			cityEdit.setText(data["city"].toString);
			cityEdit.setModified(false);
			
			streetEdit.setText(data["street"].toString);
			streetEdit.setModified(false);
			
			houseEdit.setText(data["house"].toString);
			if (data["house"].toString == "") houseEdit.setText("0");
			houseEdit.setModified(false);
			
			buildingEdit.setText(data["building"].toString);
			buildingEdit.setModified(false);
			
			apartmentEdit.setText(data["apartment"].toString);
			if (data["apartment"].toString == "") apartmentEdit.setText("0");
			apartmentEdit.setModified(false);
		}
		okButton = new QPushButton("OK");
		cancelButton = new QPushButton("Отмена");
		lFName = new QLabel(this);
		lFName.setText("Имя");
		lMName = new QLabel(this);
		lMName.setText("Отчество");
		lLName = new QLabel(this);
		lLName.setText("Фамилия");
		lB_Date = new QLabel(this);
		lB_Date.setText("дата Рождения");
		lEmail = new QLabel(this);
		lEmail.setText("e-mail");
		lM_Phone = new QLabel(this);
		lM_Phone.setText("Моб. Телефон");
		lSex = new QLabel(this);
		lSex.setText("Пол");
		lNote = new QLabel(this);
		lNote.setText("Примечание");
		lPostcode = new QLabel(this);
		lPostcode.setText("Индекс");
		lCountry  = new QLabel(this);
		lCountry.setText("Страна");
		lCity  = new QLabel(this);
		lCity.setText("Нас.Пункт");
		lStreet  = new QLabel(this);
		lStreet.setText("Улица");
		lHouse  = new QLabel(this);
		lHouse.setText("Дом");
		lBuilding  = new QLabel(this);
		lBuilding.setText("Корпус");
		lApartment = new QLabel(this);
		lApartment.setText("Квартира");
		
		actionCancel = new QAction(this,&on_cancelButton1,aThis);
		actionNoteChanged = new QAction(this,&on_noteChanged,aThis);
		actionSexChanged = new QAction(this,&on_sexChanged,aThis);
		actionOk = new QAction(this,&on_okButton1,aThis);

		connects(cancelButton,"clicked()",actionCancel,"Slot()");
		connects(okButton,"clicked()",actionOk,"Slot()");
		connects(noteEdit,"textChanged()",actionNoteChanged,"Slot()");
		connects(sexEdit,"currentIndexChanged(int)",actionSexChanged,"Slot()");

		QtE.AlignmentFlag aLeftTop = QtE.AlignmentFlag.AlignTop+QtE.AlignmentFlag.AlignLeft;
		QtE.AlignmentFlag aCenterTop = QtE.AlignmentFlag.AlignTop+QtE.AlignmentFlag.AlignHCenter;
		QtE.AlignmentFlag aAxpand = QtE.AlignmentFlag.AlignExpanding;
		QtE.AlignmentFlag aRightTop = QtE.AlignmentFlag.AlignTop+QtE.AlignmentFlag.AlignRight;

		gLay.addWidget(lLName,0,0,aLeftTop).addWidget(lFName,0,1,aLeftTop).addWidget(lMName,0,2,aLeftTop)
			.addWidget(l_nameEdit,1,0,aLeftTop).addWidget(f_nameEdit,1,1,aLeftTop).addWidget(m_nameEdit,1,2,aLeftTop)
			.addWidget(lB_Date,2,0,aLeftTop).addWidget(lSex,2,1,aLeftTop)
			.addWidget(b_dateEdit,3,0,aLeftTop).addWidget(sexEdit,3,1,aLeftTop)
			.addWidget(lEmail,4,0,aLeftTop).addWidget(lM_Phone,4,1,aLeftTop)
			.addWidget(emailEdit,5,0,aLeftTop).addWidget(m_phoneEdit,5,1,aLeftTop)
			.addWidget(lPostcode,6,0).addWidget(lCountry,6,1).addWidget(lCity,6,2)
			.addWidget(postcodeEdit,7,0).addWidget(countryEdit,7,1).addWidget(cityEdit,7,2)
			.addWidget(lStreet,8,0,1,3).addWidget(lHouse,8,3).addWidget(lBuilding,8,4).addWidget(lApartment,8,5)
			.addWidget(streetEdit,9,0,1,3).addWidget(houseEdit,9,3).addWidget(buildingEdit,9,4).addWidget(apartmentEdit,9,5)
			.addWidget(lNote,10,0,aLeftTop)
			.addWidget(noteEdit,11,0,1,6,aAxpand)
			.addWidget(okButton,12,4,aRightTop).addWidget(cancelButton,12,5,aRightTop);
		setLayout(gLay);
	}

	void noteChanged(){
		this.noteModified = true; 
	}

	void sexChanged(){
		this.sexModified = true; 
	}

	void editRecord(){
		string[string] result;
		foreach(elem;outData.byKey){
			if (elem == "b_date"){
				if (!validDate(outData[elem].text!string)){
					QMessageBox msgBox = new QMessageBox(this);
					msgBox.setWindowTitle("Ошибка ввода даты.");
					msgBox.setText("Некорректная дата.");
					msgBox.setInformativeText("Не менять дату - \"OK\" \n Отменить для ввода корректной даты -\"Отмена\" ");
					msgBox.setStandardButtons((QMessageBox.StandardButton.Ok)| (QMessageBox.StandardButton.Cancel));
					msgBox.setIcon(QMessageBox.Icon.Question);
					int res = msgBox.exec();
					if (res == QMessageBox.StandardButton.Ok ) {
						continue;
					} else return;
				}
			}
			
			if (outData[elem].isModified) result[elem] = outData[elem].text!string;
		}
		if (this.noteModified) result["note"] = noteEdit.toPlainText!string;
		if (this.sexModified) result["sex"] = sexEdit.text!string;
		result["id"] = this.id;
		this.db.updateRecord(result);
		this.close();
	}

	void newRecord(){
		string[string] result;
		foreach(elem;outData.byKey){
			if (elem == "b_date"){
				if (!validDate(outData[elem].text!string)){
					QMessageBox msgBox = new QMessageBox(this);
					msgBox.setWindowTitle("Ошибка ввода даты.");
					msgBox.setText("Некорректная дата.");
					msgBox.setInformativeText("Не менять дату - \"OK\" \n Отменить для ввода корректной даты -\"Отмена\" ");
					msgBox.setStandardButtons((QMessageBox.StandardButton.Ok)| (QMessageBox.StandardButton.Cancel));
					msgBox.setIcon(QMessageBox.Icon.Question);
					int res = msgBox.exec();
					if (res == QMessageBox.StandardButton.Ok ) {
						continue;
					} else return;
				}
			}
			
			if (outData[elem].isModified) result[elem] = outData[elem].text!string;
		}
		if (this.noteModified) result["note"] = noteEdit.toPlainText!string;
		if (this.sexModified) result["sex"] = sexEdit.text!string;
		this.db.newRecord(result);
		this.close();
	}
	
	void okButtonClick(){
		if (id !is null){
			this.editRecord();
		} else {
			this.newRecord();
		}
		
	}
	
}
