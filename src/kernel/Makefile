# Declaration of variables
CPP = g++
CXXINCS =
CXXFLAGS = $(CXXINCS) -o3 -std=c++11

# File names
TARGET = ../../bin/ReservoirSoftware
SOURCES = $(wildcard *.cpp)
OBJSDIR = build
OBJECTS = $(patsubst %.cpp, $(OBJSDIR)/%.o, $(SOURCES))

# Main target
$(TARGET): $(OBJECTS)
	$(CPP) $(OBJECTS) -o $(TARGET)

# To obtain object files
$(OBJSDIR)/%.o: %.cpp
	$(CPP) -c $(CXXFLAGS) $< -o $@

# To remove generated files
clean:
	rm -f $(TARGET) $(OBJECTS)
