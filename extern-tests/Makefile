# Include the nanopb provided Makefile rules
include nanopb/extra/nanopb.mk

# Compiler flags to enable all warnings & debug info
CFLAGS = -Wall -Werror -g -O0
CFLAGS += -I. -I$(NANOPB_DIR)

# C source code files that are required
CSRC  = simple-proto-test.c        # The main program
CSRC += simple-proto-test.pb.c     # The compiled protocol definition
CSRC += pb_encode.c  # The nanopb encoder
CSRC += pb_decode.c  # The nanopb decoder
CSRC += pb_common.c  # The nanopb common parts

# Build rule for the main program
simple-proto-test: $(CSRC)
	$(CC) $(CFLAGS) -osimple-proto-test $(CSRC)

# Build rule for the protocol
simple-proto-test.pb.c: simple-proto-test.proto
	$(PROTOC) $(PROTOC_OPTS) --nanopb_out=. simple-proto-test.proto

