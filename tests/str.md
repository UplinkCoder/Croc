module tests.str;

("123").toInt();
("123").toInt(8);
("123").toFloat();
("a").compare("b");
("a").icompare("b");
("a").find("a");
("a").find('a');
try ("a").find(4); catch(e){}
("a").ifind("a");
("a").ifind('a');
try ("a").ifind(4); catch(e){}
("a").rfind("a");
("a").rfind('a');
try ("a").rfind(4); catch(e){}
("a").irfind("a");
("a").irfind('a');
try ("a").irfind(4); catch(e){}
("a").toLower();
("A").toLower();
("a").toUpper();
("A").toUpper();
("a").repeat(0);
try ("a").repeat(-1); catch(e){}
string.join(["a", "b"], ",");
try string.join([1], ","); catch(e){}
("a").split();
("a").split("a");
("a").splitLines();
("a").strip();
("a").lstrip();
("a").rstrip();
("a").replace("a", "b");
foreach(v; "a"){}
foreach(v; "a", "reverse"){}