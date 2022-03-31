USING: help.markup help.syntax kernel ;
IN: protobuf

ARTICLE: "protobuf-parsing" "Protobuf parsing"
"An EBNF parser is implemented to create the requisite objects during runtime (skipping the code generation step most protobuf implementations use)"
"Each message type is created as a tuple (in the protobuf.tokenize vocab namespace), where the message fields are instantiated as slots of the tuple."
"primitive types are identified by the corresponding singletons: +uint32+ , etc"
;
