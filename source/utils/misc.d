/++
	This module contains contains some misc. functions. (The name says that)
+/
module utils.misc;

import std.stdio;
import std.datetime;

///`integer is a `long` on 64 bit systems, and `int` on 32 bit systems
alias integer = ptrdiff_t;
///`uinteger` is a `ulong` on 64 bit systems, and `uint` on 32 bit systems
alias uinteger = size_t;

///Reads a file into an array of string
///Throws exception on failure
string[] fileToArray(string fname){
	File f = File(fname,"r");
	string[] r;
	string line;
	integer i=0;
	r.length=0;
	while (!f.eof()){
		if (i+1>=r.length){
			r.length+=5;
		}
		line=f.readln;
		if (line.length>0 && line[line.length-1]=='\n'){
			line.length--;
		}
		r[i]=line;
		i++;
	}
	f.close;
	r.length = i;
	return r;
}

/// Writes an array of string to a file
/// Throws exception on failure
void arrayToFile(string[] array, string fname){
	File f = File(fname,"w");
	uinteger i;
	for (i=0;i<array.length;i++){
		f.write(array[i],'\n');
	}
	f.close;
}

/// Returns true if an aray has an element, false if no
bool hasElement(T)(T[] array, T element){
	bool r = false;
	foreach(cur; array){
		if (cur == element){
			r = true;
			break;
		}
	}
	return r;
}
///
unittest{
	assert([0, 1, 2].hasElement(2) == true);
	assert([0, 1, 2].hasElement(4) == false);
}
/// Returns true if array contains all elements provided in an array, else, false
bool hasElement(T)(T[] array, T[] elements){
	bool r = true;
	elements = elements.dup;
	// go through the list and match as many elements as possible
	for (uinteger i = 0; i < elements.length; i ++){
		// check if it exists in array
		uinteger index = array.indexOf(elements[i]);
		if (index == -1){
			r = false;
			break;
		}
	}
	return r;
}
///
unittest{
	assert([0, 1, 2].hasElement([2, 0, 1]) == true);
	assert([0, 1, 2].hasElement([2, 0, 1, 1, 0, 2]) == true); // it works different-ly from `LinkedList.hasElements`
	assert([0, 1, 2].hasElement([1, 2]) == true);
	assert([0, 1, 2].hasElement([2, 4]) == false);
}
/// Returns true if all elements in array match with another array's elements.
/// Index, and the number of times the element is present in each array doesn't matter
/// 
/// `toMatch` is the array to perform the check on
/// `elements` is the array containing the elements that will be compared against
bool matchElements(T)(T[] toMatch, T[] elements){
	bool r = true;
	foreach(currentToMatch; toMatch){
		if (!elements.hasElement(currentToMatch)){
			r = false;
			break;
		}
	}
	return r;
}
///
unittest{
	assert("Hello".matchElements("aeloH") == true);
	assert("abcd".matchElements("cda") == false);
}

/// Returns the index of an element in an array, negative one if not found
integer indexOf(T)(T[] array, T element){
	integer i;
	for (i = 0; i < array.length; i++){
		if (array[i] == element){
			break;
		}
	}
	//check if it was not found, and the loop just ended
	if (i >= array.length || array[i] != element){
		i = -1;
	}
	return i;
}
///
unittest{
	assert([0, 1, 2].indexOf(1) == 1);
	assert([0, 1, 2].indexOf(4) == -1);
}

/// Removes element(s) from an array, and returns the modified array;
T[] deleteElement(T)(T[] dat, uinteger pos, uinteger count=1){
	T[] ar1, ar2;
	ar1 = dat[0..pos];
	ar2 = dat[pos+count..dat.length];
	return ar1~ar2;
}
///
unittest{
	assert([0, 1, 2].deleteElement(1) == [0, 2]);
	assert([0, 1, 2].deleteElement(0, 2) == [2]);
}

/// Inserts an array into another array, returns the result;
T[] insertElement(T)(T[] dat, T[] ins, uinteger pos){
	T[] ar1, ar2;
	ar1 = dat[0..pos];
	ar2 = dat[pos..dat.length];
	return ar1~ins~ar2;
}
///
unittest{
	assert([0, 2].insertElement([1, 1], 1) == [0, 1, 1, 2]);
	assert([2].insertElement([0, 1], 0) == [0, 1, 2]);
}
/// Inserts an element into an array
T[] insertElement(T)(T[] dat, T ins, uinteger pos){
	T[] ar1, ar2;
	ar1 = dat[0..pos];
	ar2 = dat[pos..dat.length];
	return ar1~[ins]~ar2;
}
///
unittest{
	assert([0, 2].insertElement(1, 1) == [0, 1, 2]);
	assert([2].insertElement(1, 0) == [1, 2]);
}

/// returns the reverse of an array
T[] reverseArray(T)(T[] s){
	integer i, writePos = 0;
	T[] r;
	r.length = s.length;

	for (i = s.length-1; writePos < r.length; i--){
		r[writePos] = s[i];
		writePos ++;
	}
	return r;
}
///
unittest{
	assert([1, 2, 3, 4].reverseArray == [4, 3, 2, 1]);
}

/// Returns true if a string is a number, with a decimal point, or without
bool isNum(string s, bool allowDecimalPoint=true){
	uinteger i;
	bool hasDecimalPoint = false;
	if (!allowDecimalPoint){
		hasDecimalPoint = true; // just a hack that makes it return false on "seeing" decimal point
	}
	foreach (c; s){
		if (c == '.' && !hasDecimalPoint){
			hasDecimalPoint = true;
		}else if (!"0123456789".hasElement(c)){
			return false;
		}
	}
	return true;
}
///
unittest{
	assert("32".isNum == true);
	assert("32.2".isNum == true);
	assert("32.2.4".isNum == false);
	assert("5.a".isNum == false);
	assert("thisIsAVar_1234".isNum == false);
	assert("5.3".isNum(false) == false);
	assert("53".isNum(false) == true);
}

/// Returns a string with all uppercase alphabets converted into lowercase
string lowercase(string s){
	static const ubyte diff = 'a' - 'A';
	char[] r = (cast(char[])s).dup;
	foreach (i, c; r){
		if (c >= 'A' && c <= 'Z'){
			r[i] = cast(char)(c+diff);
		}
	}
	return cast(string)r;
}
///
unittest{
	assert("ABcD".lowercase == "abcd");
	assert("abYZ".lowercase == "abyz");
}

/// returns true if all characters in a string are alphabets, uppercase, lowercase, or both
bool isAlphabet(string s){
	uinteger i;
	bool r=true;
	foreach (c; s){
		if ((c < 'a' || c > 'z') && (c < 'A' || c > 'Z')){
			return false;
		}
	}
	return true;
	/*for (i=0;i<s.length;i++){
		if ((s[i] < 'a' || s[i] > 'z') && (s[i]<'A' || s[i] > 'Z')){
			r = false;
			break;
		}
	}
	return r;*/
}
///
unittest{
	assert("aBcDEf".isAlphabet == true);
	assert("ABCd_".isAlphabet == false);
	assert("ABC12".isAlphabet == false);
}

/// generates a markdown table for some data.
/// 
/// `headings` is the headings for each column. Left-to-Right
/// `data` contains each row's data. All rows must be same length
string[] makeTable(T)(string[] headings, T[][] data){
	assert(headings.length > 0, "cannot make table with no headings");
	assert(data.length > 0, "cannot make table with no data");
	assert(headings.length == data[0].length, "headings.length does not equal data.length "~to!string(headings.length)~"!="~
		to!string(data[0].length));
	import utils.lists;
	// stores the data in string
	string[][] sData;
	// convert it all to string
	static if (is (T == string)){
		sData = data;
	}else{
		sData.length = data.length;
		foreach (rowNum, row; data){
			sData[rowNum].length = row.length;
			foreach (cellNum, cell; row){
				sData[rowNum][cellNum] = to!string(cell);
			}
		}
	}
	// now make the table
	LinkedList!string table = new LinkedList!string;
	// add headings
	{
		string line;
		string alignment;
		line = headings[0];
		alignment = "---";
		for (uinteger i = 1; i < headings.length; i ++){
			line ~= " | "~headings[i];
			alignment ~= " | ---";
		}
		table.append([line, alignment]);
	}
	// now begin with the data
	foreach (row; sData){
		string line/* = row[0]*/;
		foreach (cell; row){
			line ~= cell~" | ";
		}
		line.length -= 3;
		table.append (line);
	}
	string[] r = table.toArray;
	.destroy(table);
	return r;
}
