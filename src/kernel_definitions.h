#ifndef KERNEL_DEFINITIONS_H
#define KERNEL_DEFINITIONS_H

#ifdef __linux

namespace kernel_definitions {
  const char* GEOMETRY_FILENAME = "kernel/ArqCell1d.dat";
  const char* BLOCK_FILENAME = "kernel/ArqBlock.dat";
  const char* FLUID_FILENAME = "kernel/ArqWater.dat";
  const char* WELLS_FILENAME = "kernel/ArqWell1d.dat";
  const char* SOLUTION_FILENAME = "kernel/ArqInit1d.dat";
  const char* RESERVOIR_FILENAME = "kernel/ArqRes1d.dat";
  const char* NUMERIC_PROPERTIES_FILENAME = "kernel/ArqNumeric.dat";
  const char* BOUNDARY_CONDITION_FILENAME = "kernel/ArqBoundCond1d.dat";
  const char* KERNEL_COMMAND = "kernel/ReservoirSoftware";
}

#endif


#ifdef _WIN32

namespace kernel_definitions {
  const char* GEOMETRY_FILENAME = "kernel/ArqCell1d.dat";
  const char* BLOCK_FILENAME = "kernel/ArqBlock.dat";
  const char* FLUID_FILENAME = "kernel/ArqWater.dat";
  const char* WELLS_FILENAME = "kernel/ArqWell1d.dat";
  const char* SOLUTION_FILENAME = "kernel/ArqInit1d.dat";
  const char* RESERVOIR_FILENAME = "kernel/ArqRes1d.dat";
  const char* NUMERIC_PROPERTIES_FILENAME = "kernel/ArqNumeric.dat";
  const char* BOUNDARY_CONDITION_FILENAME = "kernel/ArqBoundCond1d.dat";
  const char* KERNEL_COMMAND = "../kernel/ReservoirSoftware";
}

#endif

#endif // KERNEL_DEFINITIONS_H