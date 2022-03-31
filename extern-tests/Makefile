# Include the nanopb provided Makefile rules
include nanopb/extra/nanopb.mk

# Compiler flags to enable all warnings & debug info
CFLAGS = -Wall -Werror -ggdb -O0
CFLAGS += -I. -I$(NANOPB_DIR)

# C source code files that are required
CSRC  = simple-proto-test.c        # The main program
CSRC += simple-proto-test.pb.c     # The compiled protocol definition
CSRC += pb_encode.c  # The nanopb encoder
CSRC += pb_decode.c  # The nanopb decoder
CSRC += pb_common.c  # The nanopb common parts

CSRC_ALT  = word-format-test.c        # The main program
CSRC_ALT += word-format-test.pb.c     # The compiled protocol definition
CSRC_ALT += pb_encode.c  # The nanopb encoder
CSRC_ALT += pb_decode.c  # The nanopb decoder
CSRC_ALT += pb_common.c  # The nanopb common parts

simple-proto-test: $(CSRC)
	$(CC) $(CFLAGS) -osimple-proto-test $(CSRC)

# Build rule for the protocol
simple-proto-test.pb.c: simple-proto-test.proto
	$(PROTOC) $(PROTOC_OPTS) --nanopb_out=. simple-proto-test.proto

word-format-test: $(CSRC_ALT)
	$(CC) $(CFLAGS) -oword-format-test $(CSRC_ALT)

# Build rule for the protocol
word-format-test.pb.c: word-format-test.proto
	$(PROTOC) $(PROTOC_OPTS) --nanopb_out=. word-format-test.proto
