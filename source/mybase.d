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
	QTableWidgetItem[][] table_items;
	string[string] table_header;
	ResultRange range;
	Connection conn;
	}
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
		@property host(string value) { _host = value;}
		@property port(string value) { _port = value;}
		@property user(string value) { _user = value;}
		@property password(string value) { _password = value;}
		@property dbname(string value) { _dbname = value;}
		@property table(string value) { _table = value;}

		//getters
		@property {
			string host() { return _host;}
			string port() { return _port;}
			string user() { return _user;}
			string password() { return _password;}
			string dbname() { return _dbname;}
			string table() {return _table;}
			bool connected() {return _connected;};
		}

		//Конект с параметрами определенными в классе
		bool connect(){
			//Формат строки подлключения "host=localhost;port=3306;user=yourname;pwd=pass123;db=mysqln_testdb"
			this.connStr = "host="~this.host~";port="~this.port~";user="~this.user~";pwd="~this.password~";db="~this.dbname;
			try {
				this.conn = new Connection(connStr);
			}catch (Exception e){
				this._connected = false;
				return false;
				}
			this._connected = true;
			return true;
		}
		//Коннект с параметрами определенными при вызове метода
		bool connect(string host,string port,string user,string password,string dbname){
			host = host;
			port = port;
			user = user;
			password = password;
			dbname = dbname;
			connStr = "host="~host~";port="~port~";user="~user~";pwd="~password~";db="~dbname;
			try {
				conn = new Connection(connStr);
			}catch (Exception e){
				_connected = false;
				return false;
				}
			_connected = true;
			return true;
			}

		void disconnect(){
			conn.close();
			}

		const (string)[] colNames(){
			const (string)[] result;
			foreach (elem; range.colNames){
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
			table = table_name;
			range = conn.query("SELECT * FROM "~"`"~table~"`");
			table_items = null;

			if (!range.empty){
				for(auto i = 0;!range.empty;i++){
					table_items ~= new QTableWidgetItem[][1];
					auto row = range.front();
					table_items[i] = new QTableWidgetItem[row.length];
					for(auto j = 0;j<=row.length-1;j++){
						table_items[i][j] = new QTableWidgetItem(1);
							if (!row.isNull(j)){
								table_items[i][j].setText(row[j]);
							}else {
								table_items[i][j].setText("");
							}
					}
					range.popFront();
				}
			return table_items;
			}
			return null;
		}

		Variant[string] getRow(int id,string table){
			
			table = table;
			range = conn.query("SELECT * FROM "~"`"~table~"` WHERE `id`="~to!string(id));
			auto aa = range.asAA;
			foreach(ref elem;aa){
				
				if (elem == null) {
					elem = "";
				}
			}
			
			return aa;
		}

		void close(){
			if (_connected == true)
				conn.close;
			}
			
		void updateRecord(string[string] data){
			auto id = data["id"];
			data.remove("id");
			if (data.length == 0) return;
			string queryString = "UPDATE `"~table~"` SET ";
			auto l = queryString.length;
			foreach (elem;data.byKey){
				queryString ~= ", "~"`"~elem~"`"~"="~"\""~data[elem]~"\"" ;
			}
			queryString = queryString[0..l]~queryString[l+1..$];
			queryString ~=  " WHERE `id`="~id;
			auto rowsAffected = conn.exec(queryString);
			
		}

		void newRecord(string[string] data){
			if (data.length == 0) return;
			string queryString = "INSERT INTO `"~table~"` (";
			auto l = queryString.length;
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
			auto rowsAffected = conn.exec(queryString);
		}

		void delRecord(int id){
			string queryString = "DELETE FROM `"~table~"` WHERE `id`=";
			queryString ~= to!string(id);
			auto rowsAffected = conn.exec(queryString);
		}
	}



