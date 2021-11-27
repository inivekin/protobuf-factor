USING: arrays kernel math math.parser peg peg.ebnf multiline sequences sets strings ;
! FIXME(kevinc) peg USE is only for ignore keyword because emptyStatements keep bringing them into the output?
IN: protobuf.tokenize

TUPLE: protobuf syntax def ;

TUPLE: message name fields ;
TUPLE: enum name map ;
TUPLE: oneof name fields ;

TUPLE: identifier child? parents name ;

TUPLE: field repeated? type name value ;

ERROR: unsupported-proto-version ;

: full-ident>identifier ( vec -- obj )
    first3 >string identifier boa ;

! FIXME(kevinc) can use the ebnf And rule to not need this
: prefix-initial-char ( vec -- str )
    dup pop append ;

EBNF: tokenize [=[

tokenizer = default
comment = ( "//" (!("\n") .)* "\n" ) | ( "/*" (!("*/") .)* "*/" )
comments = comment*
space = " " | "\r" | "\t" | "\n"
spaces = space*

meta = (comment | space)*

letter = [a-zA-Z]
decimalDigit = [0-9]
octalDigit   = [0-7]
hexDigit     = [0-9] | [A-F] | [a-f]

underscore = "_" => [[ first ]]

ident = letter ( letter | decimalDigit | underscore )* => [[ prefix-initial-char >string ]]
fullIdent = ident ( "." ident )*
messageName = ident
enumName = ident
fieldName = ident
oneofName = ident
mapName = ident
serviceName = ident
rpcName = ident
messageType = "."? ( ident "." )* ident => [[ full-ident>identifier ]]
enumType = "."? ( ident "." )* ident => [[ full-ident>identifier ]]

intLit     = meta~ decimalLit | octalLit | hexLit
decimalLit = meta~ [0-9] ( decimalDigit )* => [[ prefix-initial-char string>number ]]
octalLit   = meta~ "0" { octalDigit } => [[ prefix-initial-char oct> ]]
hexLit     = meta~ "0"~ ( "x" | "X" )~ hexDigit hexDigit* => [[ prefix-initial-char hex> ]]

floatLit = meta~ ( decimals "." decimals? exponent? | decimals exponent | "." decimals exponent? ) | "inf" | "nan"
decimals  = decimalDigit decimalDigit*
exponent  = meta~ ( "e" | "E" ) ( "+" | "-" )? decimals 

boolLit = meta~ ("true" | "false" )

strLit = meta~ (( "'" charValue* "'" ) |  ( '"' charValue* '"' ))
charValue = hexEscape | octEscape | charEscape
hexEscape = meta~ '\\' ( "x" | "X" ) hexDigit hexDigit
octEscape = meta~ '\\' octalDigit octalDigit octalDigit
charEscape = meta~ '\\' ( "a" | "b" | "f" | "n" | "r" | "t" | "v" | '\\' | "'" | '"' )
quote = "'" | '"'

emptyStatement = ((meta ";")+)~

constant = meta~ (fullIdent | ( ( "-" | "+" )? intLit ) | ( ( "-" | "+" )? floatLit ) | strLit | boolLit )

syntax = meta~ "syntax"~ meta~ "="~ meta~ quote~ "proto"~ [2-3] quote~ meta~ ";"~ => [[ digit> dup 3 = [ unsupported-proto-version throw ] unless ]]

import = meta~ "import" meta~ ( "weak" | "public" ) meta~ strLit meta~ ";"~

package = meta~ "package" fullIdent meta~ ";"~

optionName = ( ident | "(" fullIdent ")" ) ( "." ident )+
option = meta~ "option" meta~ optionName meta~  "=" constant meta~ ";"~

type = meta~ ("double" | "float" | "int32" | "int64" | "uint32" | "uint64" | "sint32" | "sint64" | "fixed32" | "fixed64" | "sfixed32" | "sfixed64" | "bool" | "string" | "bytes" | messageType | enumType )
fieldNumber = intLit

field = meta~ ( "repeated" )? meta~ type meta~ ident meta~ "="~ meta~ fieldNumber meta~ ( "[" fieldOptions "]" )? meta~ ";"~ => [[ [ first >boolean ] [ rest first3 ] bi field boa ]]
fieldOptions = meta~ fieldOption meta~ ( "," meta~ fieldOption )*
fieldOption = meta~ optionName meta~ "=" meta~ constant

oneof = meta~ "oneof"~ meta~ ident meta~ "{"~ ( meta~ ( option | oneofField | emptyStatement~ ))* meta~ "}"~ => [[ first2 oneof boa ]]
oneofField = meta~ type meta~ ident meta~ "="~ meta~ fieldNumber ( "[" fieldOptions "]" )? meta~ ";"~ => [[ f swap first3 field boa ]]

mapField = meta~ "map" meta~ "<" meta~ keyType meta~ "," meta~ type meta~ ">" meta~ mapName meta~ "=" meta~ fieldNumber meta~ ( "[" fieldOptions "]" )? meta~ ";"~
keyType = meta~ ("int32" | "int64" | "uint32" | "uint64" | "sint32" | "sint64" | "fixed32" | "fixed64" | "sfixed32" | "sfixed64" | "bool" | "string" )

reserved = meta~ "reserved" meta~ ( ranges | fieldNames ) meta~ ";"~
ranges = meta~ range ( meta~ "," meta~ range )*
range = meta~ intLit ( meta~ "to" meta~ ( intLit | "max" ) )?
fieldNames = meta~ fieldName ( meta~ ","~ meta~ fieldName )* => [[ prefix-initial-char ]]

enum = meta~ "enum"~ meta~ enumName meta~ enumBody => [[ first2 [ >string ] [ ] bi* enum boa ]]
enumBody = meta~ "{"~ meta~ ( option | enumField | emptyStatement~ )* meta~ "}"~
enumField = meta~ ident meta~ "="~ meta~ ( "-" )? meta~ intLit ( meta~ "["~ meta~ enumValueOption ( meta~ ","~  meta~ enumValueOption )* meta~ "]"~ )? meta~ ";"~ => [[ first3 swap [ neg ] when [ >string ] [ ] bi* 2array ]]
enumValueOption = meta~ optionName meta~ "="~ meta~ constant

message = meta~ "message"~ meta~ ident meta~ messageBody => [[ first2 [ >string ] [ [ ignore = ] reject ] bi* message boa ]]
messageBody = meta~ "{"~ meta~ ( field | enum | message | option | oneof | mapField | reserved | emptyStatement )* meta~ "}"~

service = meta~ "service" meta~ serviceName meta~ "{" (meta~ ( option | rpc | emptyStatement ))* meta~ "}"
rpc = meta~ "rpc" meta~ rpcName meta~ "(" meta~ ( "stream" )? meta~ messageType meta~ ")" meta~ "returns" meta~ "(" meta~ ( "stream" )? meta~ messageType meta~ ")" (meta~ ( meta~ "{"~ (meta~ (option | emptyStatement ))* meta~ "}"~ ) | meta~ ";"~)

topLevelDef = ( message | enum | service )
proto = meta~ syntax (meta~ ( import | package | option | topLevelDef | emptyStatement ))* => [[ unclip-slice swap first protobuf boa ]]

rule = proto
]=]

! FIXME(kevin) official protobuf descriptor: decimalLit = [1-9] ( decimalDigit )*
! this does not allow for an enum value of 0, does google not actually use these defs?

! FIXME(kevinc) protobuf entry for fieldNumber is also invalid EBNF

! FIXME(kevinc) fieldNumber had asemicolon and was always followed by another semicolon in othe things like oneofs...

! charValue = hexEscape | octEscape | charEscape | /[^\0\n\\]/
