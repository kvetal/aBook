module mybase;

import mysql;
import std.string;
import std.stdio;
import std.variant;
import qte5;
import std.conv;
import std.datetime.date;

class mydb{
	private {
	string _host;
	string _port;
	string _user;
	string _password;
	string _dbname;
	string _table;
	string connStr;
	bool _connected;
	ResultRange range;
	QTableWidgetItem[][] table_items;
	string[string] table_header;
	}
	Connection conn;

	//Конструктор по умолчанию
	this(){
		this._connected = false;
		this.table_header = ["f_name":"Имя","l_name":"Фамилия","m_name":"Отчество","b_date":"День рождения","sex":"Пол","email":"е-почта","mobile_phone":"Моб. телефон","note":"Заметки","postcode":"Индекс","country":"Страна","city":"Город","street":"Улица","house":"Дом","building":"строение","apartment":"Квартира"];
	}
	
	//Конструктор сразу с подключением в БД
	this(string host,string port,string user,string password,string dbname){
		this();
		this.host = host;
		this.port = port;
		this.user = user;
		this.password = password;
		this.dbname = dbname;
		this.connStr = "host="~this.host~";port="~this.port~";user="~this.user~";pwd="~this.password~";db="~this.dbname;
		try {
			this.conn = new Connection(connStr);
			this._connected = true;
		}catch (Exception e){
			this._connected = false;
			}
	}
	
		//setters
		@property host(string value) { this._host = value;}
		@property port(string value) {this._port = value;}
		@property user(string value) {this._user = value;}
		@property password(string value) {this._password = value;}
		@property dbname(string value) {this._dbname = value;}
		@property table(string value) {this._table = value;}

		//getters
		@property {
			string host() { return this._host;}
			string port() { return this._port;}
			string user() { return this._user;}
			string password() { return this._password;}
			string dbname() { return this._dbname;}
			string table() {return this._table;}
			bool connected() {return this._connected;};
		}

		//Конект с параметрами определенными в классе
		bool connect(){
			//Формат строки подлключения "host=localhost;port=3306;user=yourname;pwd=pass123;db=mysqln_testdb"
			this.connStr = "host="~this.host~";port="~this.port~";user="~this.user~";pwd="~this.password~";db="~this.dbname;
			try {
				this.conn = new Connection(connStr);
			}catch (Exception e){
				this._connected = false;
				writeln(e.msg);
				return false;
				}
			this._connected = true;
			return true;
		}
		//Коннект с параметрами определенными при вызове метода
		bool connect(string host,string port,string user,string password,string dbname){
			this.host = host;
			this.port = port;
			this.user = user;
			this.password = password;
			this.dbname = dbname;
			this.connStr = "host="~host~";port="~port~";user="~user~";pwd="~password~";db="~dbname;
			try {
				this.conn = new Connection(connStr);
			}catch (Exception e){
				this._connected = false;
				return false;
				}
			this._connected = true;
			return true;
			}

		void disconnect(){
			this.conn.close();
			}

		const (string)[] colNames(){
			const (string)[] result;
			foreach (elem; this.range.colNames){
				if ((elem in table_header) !is null) {
					result ~= table_header[elem];
				}else {
					result ~= elem;
				}
			}
			
			return result;
		}

		//Возвращает массив QTableWidgetItem[][] либо null при неудаче
		QTableWidgetItem[][] getItems(string table_name){
			this.table = table_name;
			this.range = this.conn.query("SELECT * FROM "~"`"~this.table~"`");
			this.table_items = null;

			if (!this.range.empty){
				for(auto i = 0;!range.empty;i++){
					this.table_items ~= new QTableWidgetItem[][1];
					auto row = this.range.front();
					this.table_items[i] = new QTableWidgetItem[row.length];
					for(auto j = 0;j<=row.length-1;j++){
						this.table_items[i][j] = new QTableWidgetItem(1);
							if (!row.isNull(j)){
								this.table_items[i][j].setText(row[j]);
							}else {
								this.table_items[i][j].setText("");
							}
					}
					this.range.popFront();
				}
			return this.table_items;
			}
			return null;
		}

		Variant[string] getRow(int id,string table){
			
			this.table = table;
			this.range = this.conn.query("SELECT * FROM "~"`"~this.table~"` WHERE `id`="~to!string(id));
			auto aa = range.asAA;
			//writeln(aa);
			foreach(ref elem;aa){
				
				if (elem == null) {
					elem = "";
				}
			//writeln(aa);
			}
			
			return aa;
		}

		void close(){
			if (this._connected == true)
				this.conn.close;
			}
			
		void updateRecord(string[string] data){
			auto id = data["id"];
			data.remove("id");
			if (data.length == 0) return;
			string queryString = "UPDATE `"~this.table~"` SET ";
			foreach (elem;data.byKey){
				queryString ~= ", "~"`"~elem~"`"~"="~"\""~data[elem]~"\"" ;
			}
			
			queryString = queryString[0..20]~queryString[21..$];
			queryString ~=  " WHERE `id`="~id;
			auto rowsAffected = this.conn.exec(queryString);
			
		}

		void newRecord(string[string] data){
			writeln(data);//
			//"INSERT INTO `tablename` (`id`, `name`) VALUES (?,?)"
			if (data.length == 0) return;
			string queryString = "INSERT INTO `"~this.table~"` (";
			int l = queryString.length;
			
			foreach (elem;data.byKey){
				queryString ~= ", "~"`"~elem~"`";
			}
			queryString ~= ") VALUES (";
			queryString = queryString[0..l]~queryString[l+1..$];
			l = queryString.length;
			
			foreach (elem;data.byKey){
				queryString ~= ", "~"\""~data[elem]~"\"";
			}
			queryString = queryString[0..l]~queryString[l+1..$];
			queryString ~= ")";
			writeln(queryString);
			//queryString = queryString[0..20]~queryString[21..$];
			auto rowsAffected = this.conn.exec(queryString);
		}

		void delRecord(int id){
			string queryString = "DELETE FROM `"~this.table~"` WHERE `id`=";
			queryString ~= to!string(id);
			writeln(queryString);
			writeln(id);
			auto rowsAffected = this.conn.exec(queryString);
		}
	}


	
unittest {
	mydb myDB;
	myDB = new.mydb();
	myDB.host = "192.168.1.1";
	assert(myDB.host == "192.168.1.1");
	myDB.port = "3306";
	assert(myDB.port == "3306");
	myDB.user = "kvetal";
	assert(myDB.user == "kvetal");
	myDB.password = "kvetal";
	assert(myDB.password == "kvetal");
	myDB.dbname = "storage";
	assert(myDB.dbname == "storage");
	myDB.table = "person";
	assert(myDB.table == "person");
	assert (myDB.connect() == true);
	myDB.conn.close();
	assert (myDB.connect("192.168.1.1","3306","kvetal","kvetal","storage") == true);
	myDB.conn.close();
}

unittest {
	mydb myDB;
	myDB = new.mydb();
	assert (myDB.connect("192.168.1.1","3306","kvetal","kvetal","storage") == true);
	myDB.table = "person";
	assert(myDB.table == "person");
	ResultRange range = myDB.conn.query("SELECT * FROM "~"`"~myDB.table~"`");
	writeln(range);
	
	
	writeln("\n\n","range rowCount = ",range,"\n\n");
	writeln("range colNameS :",range.colNames);
	int id = 5;
	writeln("-----------------------------");
	range = myDB.conn.query("SELECT * FROM "~"`"~myDB.table~"` WHERE `id`="~to!string(id));
	writeln(range);
	writeln("-----------------------------");
	myDB.conn.close();
	
}
