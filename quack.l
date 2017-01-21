%{
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#define MaxStringLength 1024
char GlobalString[MaxStringLength];
int GlobalCursor = 0;

ofstream GlobalErrorFile;

int LineNumber = 1;
%}

%x COMMENT
%x TRIPLEQUOTE

%%

"/*" BEGIN(COMMENT);
<COMMENT>(.) ;
<COMMENT>(\n) LineNumber++;
<COMMENT><<EOF>> GlobalErrorFile << LineNumber << ": Comment not terminated" << endl;
<COMMENT>"*/" BEGIN(INITIAL);

["]["]["] { BEGIN(TRIPLEQUOTE); GlobalCursor = 0; }
<TRIPLEQUOTE>(.) { if(GlobalCursor < MaxStringLength) {GlobalString[GlobalCursor++] = *yytext;} }
<TRIPLEQUOTE>(\n) LineNumber++;
<TRIPLEQUOTE><<EOF>> GlobalErrorFile << LineNumber << ": Triple quote not terminated" << endl;
<TRIPLEQUOTE>["]["]["] { BEGIN(INITIAL); cout << LineNumber << " " << "STRING_LIT" << " \"" << GlobalString << "\"" << endl; }

[ \t\r] ;
\n LineNumber++;

"//".*"\n" ;
["](([\\][0btnrf"\\])|[^\\"])*(["]|\n) cout << LineNumber << " " << "STRING_LIT" << " \"" << yytext << "\"" << endl;

";" cout << LineNumber << " " << ";" << " \"" << yytext << "\"" << endl;
"(" cout << LineNumber << " " << "(" << " \"" << yytext << "\"" << endl;
")" cout << LineNumber << " " << ")" << " \"" << yytext << "\"" << endl;
"{" cout << LineNumber << " " << "{" << " \"" << yytext << "\"" << endl;
"}" cout << LineNumber << " " << "}" << " \"" << yytext << "\"" << endl;
"." cout << LineNumber << " " << "." << " \"" << yytext << "\"" << endl;
"," cout << LineNumber << " " << "," << " \"" << yytext << "\"" << endl;
":" cout << LineNumber << " " << ":" << " \"" << yytext << "\"" << endl;
"=" cout << LineNumber << " " << "=" << " \"" << yytext << "\"" << endl;
"==" cout << LineNumber << " " << "==" << " \"" << yytext << "\"" << endl;
"<=" cout << LineNumber << " " << "<=" << " \"" << yytext << "\"" << endl;
"<" cout << LineNumber << " " << "<" << " \"" << yytext << "\"" << endl;
">=" cout << LineNumber << " " << ">=" << " \"" << yytext << "\"" << endl;
">" cout << LineNumber << " " << ">" << " \"" << yytext << "\"" << endl;
"+" cout << LineNumber << " " << "+" << " \"" << yytext << "\"" << endl;
"-" cout << LineNumber << " " << "-" << " \"" << yytext << "\"" << endl;
"*" cout << LineNumber << " " << "*" << " \"" << yytext << "\"" << endl;
"/" cout << LineNumber << " " << "/" << " \"" << yytext << "\"" << endl;

"class" cout << LineNumber << " " << "CLASS" << " \"" << yytext << "\"" << endl;
"def" cout << LineNumber << " " << "DEF" << " \"" << yytext << "\"" << endl;
"extends" cout << LineNumber << " " << "EXTENDS" << " \"" << yytext << "\"" << endl;
"if" cout << LineNumber << " " << "IF" << " \"" << yytext << "\"" << endl;
"elif" cout << LineNumber << " " << "ELIF" << " \"" << yytext << "\"" << endl;
"else" cout << LineNumber << " " << "ELSE" << " \"" << yytext << "\"" << endl;
"while" cout << LineNumber << " " << "WHILE" << " \"" << yytext << "\"" << endl;
"return" cout << LineNumber << " " << "RETURN" << " \"" << yytext << "\"" << endl;

"String" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"Integer" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"Obj" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"Boolean" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"true" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"false" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"and" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"or" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"not" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"Nothing" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
"none" cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;

[a-zA-Z_][a-zA-Z0-9_]* cout << LineNumber << " " << "IDENT" << " \"" << yytext << "\"" << endl;
[0-9]+ cout << LineNumber << " " << "INT_LIT" << " \"" << yytext << "\"" << endl;

. GlobalErrorFile << LineNumber << ": Unknown token at... " << yytext << endl;

%%

int
main(int argc, char **argv)
{
	if(argc > 1)
	{
		FILE *QuackFile = fopen(argv[1], "r");
		GlobalErrorFile.open("error.txt");

		if(QuackFile)
		{
			yyin = QuackFile;
			yylex();
		}
		else
		{
			printf("Could not read quack file\n");
		}
	}
	GlobalErrorFile.close();
	
	return(0);
}
