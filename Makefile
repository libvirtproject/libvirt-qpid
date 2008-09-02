# 
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#  
#    http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.
# 

SRC_DIR     = .
QPID_DIR    = /usr/local
SCHEMA_FILE = $(SRC_DIR)/libvirt-schema.xml
GEN_DIR     = $(SRC_DIR)/gen
OUT_FILE    = $(SRC_DIR)/libvirt-qpid

CC           = gcc
LIB_DIR      = $(QPID_DIR)/lib
CC_INCLUDES  = -I$(SRC_DIR) -I$(QPID_DIR)/include -I$(GEN_DIR)
CC_FLAGS     = -g -O2
LD_FLAGS     = -lqpidclient -lqpidcommon -lvirt -L$(LIB_DIR)
SPEC_DIR     = $(MGEN_DIR)
MGEN_DIR     = $(QPID_DIR)/share/managementgen
TEMPLATE_DIR = $(MGEN_DIR)/templates
MGEN         = $(MGEN_DIR)/main.py
OBJ_DIR      = $(SRC_DIR)/.libs

vpath %.cpp $(SRC_DIR):$(GEN_DIR)
vpath %.d   $(OBJ_DIR)
vpath %.o   $(OBJ_DIR)

cpps    = $(wildcard $(SRC_DIR)/*.cpp)
cpps   += $(wildcard $(GEN_DIR)/*.cpp)
deps    = $(addsuffix .d, $(basename $(cpps)))
objects = $(addsuffix .o, $(basename $(cpps)))

.PHONY: all clean

#==========================================================
# Pass 0: generate source files from schema
ifeq ($(MAKELEVEL), 0)

all: gen
	$(MAKE)

gen:
	$(MGEN) $(SCHEMA_FILE) $(SPEC_DIR)/management-types.xml $(TEMPLATE_DIR) $(GEN_DIR)

clean:
	rm -rf $(GEN_DIR) $(OUT_FILE) *.d *.o


#==========================================================
# Pass 1: generate dependencies
else ifeq ($(MAKELEVEL), 1)

all: $(deps)
	$(MAKE)

%.d : %.cpp
	$(CC) -M $(CC_FLAGS) $(CC_INCLUDES) $< > $@


#==========================================================
# Pass 2: build project
else ifeq ($(MAKELEVEL), 2)

$(OUT_FILE) : $(objects)
	$(CC) -o $(OUT_FILE) $(CC_FLAGS) $(LD_FLAGS) $(objects)

include $(deps)

%.o : %.cpp
	$(CC) -c $(CC_FLAGS) $(CC_INCLUDES) -o $@ $<

endif


