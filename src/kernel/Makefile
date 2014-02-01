CPP      = g++
CC       = gcc
OBJ      = main.o CSolver.o CTrid.o CGrid.o CGas.o COil.o CGrid1d.o CReservoir.o CBlock.o CRock.o CDataControl.o CCell1d.o CFluid.o CWater.o CModelType.o CSinglePhase.o CSinglePhase1d.o CWell1d.o kernel_definitions.o
LINKOBJ  = main.o CSolver.o CTrid.o CGrid.o CGas.o COil.o CGrid1d.o CReservoir.o CBlock.o CRock.o CDataControl.o CCell1d.o CFluid.o CWater.o CModelType.o CSinglePhase.o CSinglePhase1d.o CWell1d.o kernel_definitions.o
BIN      = ../../bin/ReservoirSoftware
LIBS     =
CXXFLAGS = $(CXXINCS) -o3 -std=c++11
CFLAGS   = $(INCS)
RM       = rm -f
OBJECTS_DIR = build/

.PHONY: all all-before all-after clean clean-custom

all: all-before $(BIN) all-after

clean: clean-custom
	${RM} $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(CPP) $(LINKOBJ) -o $(BIN) $(LIBS)

build/kernel_definitions.o: kernel_definitions.cpp
	$(CPP) -c kernel_definitions.cpp -o build/kernel_definitions.o $(CXXFLAGS)

build/main.o: main.cpp
	$(CPP) -c main.cpp -o build/main.o $(CXXFLAGS)

build/CSolver.o: CSolver.cpp
	$(CPP) -c CSolver.cpp -o build/CSolver.o $(CXXFLAGS)

build/CTrid.o: CTrid.cpp
	$(CPP) -c CTrid.cpp -o build/CTrid.o $(CXXFLAGS)

build/CGrid.o: CGrid.cpp
	$(CPP) -c CGrid.cpp -o build/CGrid.o $(CXXFLAGS)

build/CGrid1d.o: CGrid1d.cpp
	$(CPP) -c CGrid1d.cpp -o build/CGrid1d.o $(CXXFLAGS)

build/CReservoir.o: CReservoir.cpp
	$(CPP) -c CReservoir.cpp -o build/CReservoir.o $(CXXFLAGS)

build/CBlock.o: CBlock.cpp
	$(CPP) -c CBlock.cpp -o build/CBlock.o $(CXXFLAGS)

build/CRock.o: CRock.cpp
	$(CPP) -c CRock.cpp -o build/CRock.o $(CXXFLAGS)

build/CDataControl.o: CDataControl.cpp
	$(CPP) -c CDataControl.cpp -o build/CDataControl.o $(CXXFLAGS)

build/CCell1d.o: CCell1d.cpp
	$(CPP) -c CCell1d.cpp -o build/CCell1d.o $(CXXFLAGS)

build/CFluid.o: CFluid.cpp
	$(CPP) -c CFluid.cpp -o build/CFluid.o $(CXXFLAGS)

build/CWater.o: CWater.cpp
	$(CPP) -c CWater.cpp -o build/CWater.o $(CXXFLAGS)

build/COil.o: COil.cpp
	$(CPP) -c COil.cpp -o build/COil.o $(CXXFLAGS)

build/CGas.o: CGas.cpp
	$(CPP) -c CGas.cpp -o build/CGas.o $(CXXFLAGS)

build/CModelType.o: CModelType.cpp
	$(CPP) -c CModelType.cpp -o build/CModelType.o $(CXXFLAGS)

build/CSinglePhase.o: CSinglePhase.cpp
	$(CPP) -c CSinglePhase.cpp -o build/CSinglePhase.o $(CXXFLAGS)

build/CSinglePhase1d.o: CSinglePhase1d.cpp
	$(CPP) -c CSinglePhase1d.cpp -o build/CSinglePhase1d.o $(CXXFLAGS)

build/CWell1d.o: CWell1d.cpp
	$(CPP) -c CWell1d.cpp -o build/CWell1d.o $(CXXFLAGS)