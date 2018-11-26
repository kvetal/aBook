/*
version 0.0.4
 */
module mylib;
import std.conv;
import std.string;
import std.datetime;
import std.traits : isIntegral, isFloatingPoint, Unqual;
import std.meta : allSatisfy;
import std.range;

bool validDate(int year, int month,int day )
{
	int[] days = [0,31,28,31,30,31,30,31,31,30,31,30,31];
	if( year % 4 == 0 ) days[2] = 29;
	if (( month < 1)||(month > 12 )) return false;
	if (( day < 1)||( day > days[month] )) return false;
	return true;
}

/*
Провверка корректности даты
Date validation check
*/
bool validDate(string _date )
{
	string[string] monthAA =["jan":"01","feb":"02","mar":"03","apr":"04","may":"05","jun":"06",
				"jul":"07","aug":"08","sep":"09","oct":"10","nov":"11","dec":"12"];
	if ((_date.length == 10) ||(_date.length == 11))
	{
		if (_date[5..8].toLower in monthAA){
			if (_date[0..4].isNumeric && _date[9..$].isNumeric){
				return validDate(to!int(_date[0..4]),to!int(monthAA[(_date[5..8].toLower)]),to!int(_date[9..$]));
	    		} else return false;
		}else{
			if (_date[0..4].isNumeric && _date[5..7].isNumeric && _date[8..$].isNumeric){
				return validDate(to!int(_date[0..4]),to!int(_date[5..7]),to!int(_date[8..$]));
		    	} else 
				return false;
		}
	} else
		return false;
}

/*
Код шаблонов template isNumberType(T) template allArithmetic(T...)
взят с сайта http://lhs-blog.info/programming/dlang/proverka-lyubogo-tipa-na-prinadlezhnost-k-chislovyim/
За что автору данного кода большое спасибо
Проверка типа на принадлежность к числовым

Template code template isNumberType (T) template allArithmetic (T ...)
taken from the site http://lhs-blog.info/programming/dlang/proverka-lyubogo-tipa-na-prinadlezhnost-k-chislovyim/
For which the author of this code thanks a lot
Type checking for belonging to numeric
*/
template isNumberType(T)
{
		enum bool isNumberType = isIntegral!(Unqual!T) || isFloatingPoint!(Unqual!T);
}
 
//Проверка набота типов на принадлежность к числовым.
template allArithmetic(T...)
if (T.length >= 1)
{
	enum bool allArithmetic = allSatisfy!(isNumberType, T);
}

/*
Перевод в троичную систему счисления

*/
string decToTri(int a)
{
	string res;
	int _mod, _div,temp;
	do
	{
		_mod = a/3;
		_div = a%3;
		temp = _mod*3;
		res =to!string(a-temp) ~ res;
		a = _mod;
	}
	while (_mod >0);
	return res;
}

unittest {
	assert(validDate("2020-02-29"));
	assert(validDate("2018-Apr-03"));
	assert(!validDate("2020-14-29"));
	assert(!validDate("2018-Agr-03"));
	assert(!validDate("2018-02-29"));
}

string decToOther(int a, int base)
{
	string res;
	int _mod, _div,temp;
	do
	{
		_mod = a/base;
		_div = a%base;
		temp = _mod*base;
		res =to!string(a-temp) ~ res;
		a = _mod;
	}
	while (_mod >0);
	return res;
}

unittest {
	assert(validDate("2020-02-29"));
	assert(validDate("2018-Apr-03"));
	assert(!validDate("2020-14-29"));
	assert(!validDate("2018-Agr-03"));
	assert(!validDate("2018-02-29"));
}

unittest {
	assert(decToTri(12345) == "121221020");
	assert(!(decToTri(12345) == "11221020"));
}