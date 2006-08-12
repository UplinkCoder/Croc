module minid.types;

import utf = std.utf;
import string = std.string;
import format = std.format;
import std.c.string;

import minid.opcodes;
import minid.state;

const uint MaxRegisters = Instruction.rs1Max >> 1;
const uint MaxConstants = Instruction.immMax;
const uint MaxUpvalues = Instruction.immMax;

// Don't know why this isn't in phobos.
char[] vformat(TypeInfo[] arguments, void* argptr)
{
	char[] s;
	
	void putc(dchar c)
	{
		utf.encode(s, c);
	}
	
	format.doFormat(&putc, arguments, argptr);

	return s;
}

class MDException : Exception
{
	public this(...)
	{
		super(vformat(_arguments, _argptr));
	}
}

int dcmp(dchar[] s1, dchar[] s2)
{
	auto len = s1.length;
	int result;

	if(s2.length < len)
		len = s2.length;

	result = memcmp(s1, s2, len);

	if(result == 0)
		result = cast(int)s1.length - cast(int)s2.length;

	return result;
}

// All available metamethods.
// These are kind of ordered by "importance," so that the most commonly-used ones are at the
// beginning for possible optimization purposes.
enum MM
{
	Index,
	IndexAssign,
	Cmp,
	ToString,
	Length,
	Add,
	Sub,
	Cat,
	Mul,
	Div,
	Mod,
	Neg,
	Call,
	And,
	Or,
	Xor,
	Shl,
	Shr,
	UShr,
	Com,
	AddEq,
	SubEq,
	CatEq,
	MulEq,
	DivEq,
	ModEq,
	AndEq,
	OrEq,
	XorEq,
	ShlEq,
	ShrEq,
	UShrEq
}

const dchar[][] MetaNames =
[
	MM.Add : "opAdd",
	MM.Sub : "opSub",
	MM.Cat : "opCat",
	MM.Mul : "opMul",
	MM.Div : "opDiv",
	MM.Mod : "opMod",
	MM.Neg : "opNeg",
	MM.Length : "opLength",
	MM.Cmp : "opCmp",
	MM.Index : "opIndex",
	MM.IndexAssign : "opIndexAssign",
	MM.Call : "opCall",
	MM.And : "opAnd",
	MM.Or : "opOr",
	MM.Xor : "opXor",
	MM.Shl : "opShl",
	MM.Shr : "opShr",
	MM.UShr : "opUShr",
	MM.Com : "opCom",
	MM.ToString : "opToString",
	MM.AddEq : "opAddEq",
	MM.SubEq : "opSubEq",
	MM.CatEq : "opCatEq",
	MM.MulEq : "opMulEq",
	MM.DivEq : "opDivEq",
	MM.ModEq : "opModEq",
	MM.AndEq : "opAndEq",
	MM.OrEq : "opOrEq",
	MM.XorEq : "opXorEq",
	MM.ShlEq : "opShlEq",
	MM.ShrEq : "opShrEq",
	MM.UShrEq : "opUShrEq"
];

public MDValue[] MetaStrings;

static this()
{
	MetaStrings = new MDValue[MetaNames.length];

	foreach(uint i, dchar[] name; MetaNames)
		MetaStrings[i].value = new MDString(name);
}

abstract class MDObject
{
	public uint length();
	
	// avoiding RTTI downcasts for speed
	public static enum Type
	{
		String,
		UserData,
		Closure,
		Table,
		Array
	}

	public MDString asString() { return null; }
	public MDUserData asUserData() { return null; }
	public MDClosure asClosure() { return null; }
	public MDTable asTable() { return null; }
	public MDArray asArray() { return null; }
	public abstract Type type();
	
	public static int compare(MDObject o1, MDObject o2)
	{
		if(o1.type == o2.type)
			return o1.opCmp(o2);
		else
			throw new MDException("Attempting to compare unlike objects");
	}

	public static int equals(MDObject o1, MDObject o2)
	{
		if(o1.type == o2.type)
			return o1.opEquals(o2);
		else
			throw new MDException("Attempting to compare unlike objects");
	}
}

class MDString : MDObject
{
	protected dchar[] mData;
	protected hash_t mHash;

	public this(dchar[] data)
	{
		mData = data.dup;
		mHash = typeid(typeof(mData)).getHash(&mData);
	}

	public this(char[] data)
	{
		mData = utf.toUTF32(data);
		mHash = typeid(typeof(mData)).getHash(&mData);
	}
	
	protected this()
	{
		
	}
	
	public override MDString asString()
	{
		return this;
	}
	
	public override Type type()
	{
		return Type.String;
	}

	public override uint length()
	{
		return mData.length;
	}

	public MDString opCat(MDString other)
	{
		// avoid double duplication ((this ~ other).dup)
		MDString ret = new MDString();
		ret.mData = this.mData ~ other.mData;
		ret.mHash = typeid(typeof(mData)).getHash(&ret.mData);
		return ret;
	}
	
	public MDString opCatAssign(MDString other)
	{
		return opCat(other);
	}

	public hash_t toHash()
	{
		return mHash;
	}
	
	public int opEquals(Object o)
	{
		MDString other = cast(MDString)o;
		assert(other);
		
		return mData == other.mData;
	}
	
	public int opEquals(char[] v)
	{
		return mData == utf.toUTF32(v);
	}
	
	public int opEquals(dchar[] v)
	{
		return mData == v;
	}

	public int opCmp(Object o)
	{
		MDString other = cast(MDString)o;
		assert(other);
		
		return dcmp(mData, other.mData);
	}

	public int opCmp(char[] v)
	{
		return dcmp(mData, utf.toUTF32(v));
	}

	public int opCmp(dchar[] v)
	{
		return dcmp(mData, v);
	}

	public static MDString concat(MDString[] strings)
	{
		uint l = 0;
		
		foreach(MDString s; strings)
			l += s.length;
			
		dchar[] result = new dchar[l];
		
		uint i = 0;
		
		foreach(MDString s; strings)
		{
			result[i .. i + s.length] = s.mData[];
			i += s.length;
		}

		return new MDString(result);
	}
	
	// Returns null on failure, so that the VM can give an error at the appropriate location
	public static MDString concat(MDValue[] values)
	{
		uint l = 0;

		foreach(MDValue v; values)
		{
			if(v.isString() == false)
				return null;

			l += v.asString().length;
		}
		
		dchar[] result = new dchar[l];
		
		uint i = 0;
		
		foreach(MDValue v; values)
		{
			MDString s = v.asString();
			result[i .. i + s.length] = s.mData[];
			i += s.length;
		}
		
		return new MDString(result);
	}
	
	public char[] toString()
	{
		return utf.toUTF8(mData);
	}
}

class MDUserData : MDObject
{
	protected MDTable mMetatable;

	public override MDUserData asUserData()
	{
		return this;
	}
	
	public override Type type()
	{
		return Type.UserData;
	}

	public override uint length()
	{
		throw new MDException("Cannot get the length of a userdatum");
	}
	
	public char[] toString()
	{
		return string.format("userdata 0x%0.8X", cast(void*)this);
	}
	
	public MDTable metatable()
	{
		return mMetatable;
	}
}

class MDClosure : MDObject
{
	protected bool mIsNative;
	protected MDTable mEnvironment;
	
	struct NativeClosure
	{
		int delegate(MDState) func;
		MDValue[] upvals;
	}
	
	struct ScriptClosure
	{
		MDFuncDef func;
		MDUpval[] upvals;
	}
	
	union
	{
		NativeClosure native;
		ScriptClosure script;
	}
	
	public this(MDState s, MDFuncDef def)
	{
		mIsNative = false;
		mEnvironment = s.mGlobals;
		script.func = def;
		script.upvals.length = def.mNumUpvals;
	}

	public override MDClosure asClosure()
	{
		return this;
	}
	
	public override Type type()
	{
		return Type.Closure;
	}

	public override uint length()
	{
		throw new MDException("Cannot get the length of a closure");
	}
	
	public char[] toString()
	{
		return string.format("closure 0x%0.8X", cast(void*)this);
	}
	
	public bool isNative()
	{
		return mIsNative;
	}
	
	public MDTable environment()
	{
		return mEnvironment;
	}
}

class MDTable : MDObject
{
	protected MDValue[MDValue] mData;
	protected MDTable mMetatable;
	
	public override MDTable asTable()
	{
		return this;
	}
	
	public override Type type()
	{
		return Type.Table;
	}

	public MDValue* opIndex(MDValue index)
	{
		return (index in mData);
	}

	public MDValue opIndexAssign(MDValue value, MDValue index)
	{
		mData[index] = value;
		return value;
	}
	
	public MDValue opIndexAssign(MDValue* value, MDValue index)
	{
		MDValue val = *value;
		mData[index] = val;
		return val;
	}

	public override uint length()
	{
		return mData.length;
	}
	
	public char[] toString()
	{
		return string.format("table 0x%0.8X", cast(void*)this);
	}
	
	public MDTable metatable()
	{
		return mMetatable;
	}
}

class MDArray : MDObject
{
	protected MDValue[] mData;
	
	public override MDArray asArray()
	{
		return this;
	}
	
	public override Type type()
	{
		return Type.Array;
	}

	public override uint length()
	{
		return mData.length;
	}
	
	public char[] toString()
	{
		return string.format("array 0x%0.8X", cast(void*)this);
	}
}

struct MDValue
{
	public static enum Type
	{
		None = -1,

		// Non-object types
		Null,
		Bool,
		Int,
		Float,

		// Object types
		String,
		Table,
		Array,
		Function,
		UserData
	}
	
	public static MDValue nullValue = { mType : Type.Null };

	public Type mType = Type.None;

	union
	{
		// Non-object types
		private bool mBool;
		private int mInt;
		private float mFloat;
	}
	
	// Object types
	// This has to be outside the union, so the GC doesn't confuse other types of
	// values for a pointer.
	private MDObject mObj;

	public int opEquals(MDValue* other)
	{
		if(this.mType != other.mType)
			throw new MDException("Attempting to compare unlike objects");

		switch(this.mType)
		{
			case Type.Null:
				return 1;
				
			case Type.Bool:
				return this.mBool == other.mBool;

			case Type.Int:
				return this.mInt == other.mInt;

			case Type.Float:
				return this.mFloat == other.mFloat;

			default:
				assert(this.mType != Type.None);
				return MDObject.equals(this.mObj, other.mObj);
		}
	}
	
	public bool rawEquals(MDValue* other)
	{
		if(this.mType != other.mType)
			throw new MDException("Attempting to compare unlike objects");
			
		switch(this.mType)
		{
			case Type.Null:
				return 1;
				
			case Type.Bool:
				return this.mBool == other.mBool;

			case Type.Int:
				return this.mInt == other.mInt;

			case Type.Float:
				return this.mFloat == other.mFloat;

			default:
				assert(this.mType != Type.None);
				return (this.mObj is other.mObj);
		}
	}

	public int opCmp(MDValue* other)
	{
		if(this.mType != other.mType)
			throw new MDException("Attempting to compare unlike objects");

		switch(this.mType)
		{
			case Type.Null:
				return 0;

			case Type.Bool:
				return (cast(int)this.mBool - cast(int)other.mBool);

			case Type.Int:
				return this.mInt - other.mInt;

			case Type.Float:
				if(this.mFloat < other.mFloat)
					return -1;
				else if(this.mFloat > other.mFloat)
					return 1;
				else
					return 0;

			default:
				assert(this.mType != Type.None);
				
				if(this.mObj is other.mObj)
					return 0;

				return MDObject.compare(this.mObj, other.mObj);
		}

		return -1;
	}
	
	public hash_t toHash()
	{
		switch(mType)
		{
			case Type.Null:
				return 0;

			case Type.Bool:
				return typeid(typeof(mBool)).getHash(&mBool);

			case Type.Int:
				return typeid(typeof(mInt)).getHash(&mInt);
				
			case Type.Float:
				return typeid(typeof(mFloat)).getHash(&mFloat);

			default:
				assert(mType != Type.None);
				return mObj.toHash();
		}
	}
	
	public uint length()
	{
		switch(mType)
		{
			case Type.None:
			case Type.Null:
			case Type.Bool:
			case Type.Int:
			case Type.Float:
				throw new MDException("Attempting to get length of %s value", typeString());

			default:
				return mObj.length();
		}
	}
	
	public Type type()
	{
		return mType;
	}
	
	public static char[] typeString(Type type)
	{
		switch(type)
		{
			case Type.None:		return "none";
			case Type.Null:		return "null";
			case Type.Bool:		return "bool";
			case Type.Int:		return "int";
			case Type.Float:	return "float";
			case Type.String:	return "string";
			case Type.Table:	return "table";
			case Type.Array:	return "array";
			case Type.Function:	return "function";
			case Type.UserData:	return "userdata";
		}
	}

	public char[] typeString()
	{
		return typeString(mType);
	}

	public bool isNone()
	{
		return (mType == Type.None);
	}
	
	public bool isNull()
	{
		return (mType == Type.Null);
	}
	
	public bool isNoneOrNull()
	{
		return (mType == Type.None || mType == Type.Null);
	}
	
	public bool isBool()
	{
		return (mType == Type.Bool);
	}
	
	public bool isNum()
	{
		return isInt() || isFloat();
	}

	public bool isInt()
	{
		return (mType == Type.Int);
	}
	
	public bool isFloat()
	{
		return (mType == Type.Float);
	}

	public bool isString()
	{
		return (mType == Type.String);
	}
	
	public bool isTable()
	{
		return (mType == Type.Table);
	}
	
	public bool isArray()
	{
		return (mType == Type.Array);
	}
	
	public bool isFunction()
	{
		return (mType == Type.Function);
	}
	
	public bool isUserData()
	{
		return (mType == Type.UserData);
	}
	
	public bool asBool()
	{
		assert(mType == Type.Bool);
		return mBool;
	}

	public int asInt()
	{
		if(mType == Type.Float)
			return cast(int)mFloat;
		else if(mType == Type.Int)
			return mInt;
		else
			assert(false);
	}

	public float asFloat()
	{
		if(mType == Type.Float)
			return mFloat;
		else if(mType == Type.Int)
			return cast(float)mInt;
		else
			assert(false);
	}

	public MDObject asObj()
	{
		assert(cast(uint)mType >= cast(uint)Type.String);
		return mObj;
	}

	public MDString asString()
	{
		assert(mType == Type.String);
		return mObj.asString();
	}
	
	public MDUserData asUserData()
	{
		assert(mType == Type.UserData);
		return mObj.asUserData();
	}

	public MDClosure asFunction()
	{
		assert(mType == Type.Function);
		return mObj.asClosure();
	}

	public MDTable asTable()
	{
		assert(mType == Type.Table);
		return mObj.asTable();
	}
	
	public MDArray asArray()
	{
		assert(mType == Type.Array);
		return mObj.asArray();
	}

	public bool isFalse()
	{
		return (mType == Type.Null) || (mType == Type.Bool && mBool == false) ||
			(mType == Type.Int && mInt == 0) || (mType == Type.Float && mFloat == 0.0);
	}
	
	public void setNull()
	{
		mType = Type.Null;
		mObj = null;
	}
	
	public void value(bool b)
	{
		mType = Type.Bool;
		mBool = b;
	}

	public void value(int n)
	{
		mType = Type.Int;
		mInt = n;
	}
	
	public void value(float n)
	{
		mType = Type.Float;
		mFloat = n;
	}

	public void value(MDString s)
	{
		mType = Type.String;
		mObj = s;
	}
	
	public void value(MDUserData ud)
	{
		mType = Type.UserData;
		mObj = ud;
	}
	
	public void value(MDClosure f)
	{
		mType = Type.Function;
		mObj = f;
	}
	
	public void value(MDTable t)
	{
		mType = Type.Table;
		mObj = t;
	}
	
	public void value(MDArray a)
	{
		mType = Type.Array;
		mObj = a;
	}

	public void value(MDValue v)
	{
		mType = v.mType;
		
		switch(mType)
		{
			case Type.None, Type.Null:
				break;
				
			case Type.Bool:
				mBool = v.mBool;
				break;
				
			case Type.Int:
				mInt = v.mInt;
				break;
				
			case Type.Float:
				mFloat = v.mFloat;
				break;
				
			default:
				mObj = v.mObj;
				break;
		}
	}
	
	public void value(MDValue* v)
	{
		mType = v.mType;
		
		switch(mType)
		{
			case Type.None, Type.Null:
				break;
				
			case Type.Bool:
				mBool = v.mBool;
				break;
				
			case Type.Int:
				mInt = v.mInt;
				break;
				
			case Type.Float:
				mFloat = v.mFloat;
				break;
				
			default:
				mObj = v.mObj;
				break;
		}
	}

	public char[] toString()
	{
		switch(mType)
		{
			case Type.None:
				return "none";
				
			case Type.Null:
				return "null";

			case Type.Bool:
				return string.toString(mBool);
				
			case Type.Int:
				return string.toString(mInt);
				
			case Type.Float:
				return string.toString(mFloat);
				
			default:
				return mObj.toString();
		}
	}
}

struct MDUpval
{
	// When open (parent scope is still on the stack), this points to a stack slot
	// which holds the value.  When the parent scope exits, the value is copied from
	// the stack into the closedValue member, and this points to closedMember.  
	// This means data should only ever be accessed through this member.
	MDValue* value;

	union
	{
		MDValue closedValue;
		
		// For the open upvalue doubly-linked list.
		struct
		{
			MDUpval* next;
			MDUpval* prev;
		}
	}
}

struct Location
{
	public uint line = 1;
	public uint column = 1;
	public char[] fileName;

	public static Location opCall(char[] fileName, uint line = 1, uint column = 1)
	{
		Location l;
		l.fileName = fileName;
		l.line = line;
		l.column = column;
		return l;
	}

	public char[] toString()
	{
		return string.format("%s(%d:%d)", fileName, line, column);
	}
}

class MDFuncDef
{
	package bool mIsVararg;
	package Location mLocation;
	package MDFuncDef[] mInnerFuncs;
	package MDValue[] mConstants;
	package uint mNumParams;
	package uint mNumUpvals;
	package uint mStackSize;
	package Instruction[] mCode;
	package uint[] mLineInfo;
	package dchar[][] mUpvalNames;

	struct LocVarDesc
	{
		char[] name;
		Location location;
		uint reg;
	}
	
	package LocVarDesc[] mLocVarDescs;
	
	struct SwitchTable
	{
		bool isString;

		union
		{
			int[] intValues;
			dchar[][] stringValues;
		}

		int[] offsets;
		int defaultOffset = -1;
	}

	package SwitchTable[] mSwitchTables;
}