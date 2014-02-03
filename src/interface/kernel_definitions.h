#ifndef KERNEL_DEFINITIONS_H
#define KERNEL_DEFINITIONS_H

#ifdef __linux

namespace kernel_definitions {
  const char* GEOMETRY_FILENAME = "reservoir_data/ArqCell1d.in";
  const char* BLOCK_FILENAME = "reservoir_data/ArqBlock.in";
  const char* FLUID_WATER_FILENAME = "reservoir_data/ArqWater.in";
  const char* FLUID_OIL_FILENAME = "reservoir_data/ArqOil.in";
  const char* FLUID_GAS_FILENAME = "reservoir_data/ArqGas.in";
  const char* WELLS_FILENAME = "reservoir_data/ArqWell1d.in";
  const char* SOLUTION_FILENAME = "reservoir_data/ArqInit1d.in";
  const char* RESERVOIR_FILENAME = "reservoir_data/ArqRes1d.in";
  const char* NUMERIC_PROPERTIES_FILENAME = "reservoir_data/ArqNumeric.in";
  const char* BOUNDARY_CONDITION_FILENAME = "reservoir_data/ArqBoundCond1d.in";
  const char* KERNEL_COMMAND = "./ReservoirSoftware";
}

#endif


#ifdef _WIN32

namespace kernel_definitions {
  const char* GEOMETRY_FILENAME = "reservoir_data/ArqCell1d.in";
  const char* BLOCK_FILENAME = "reservoir_data/ArqBlock.in";
  const char* FLUID_WATER_FILENAME = "reservoir_data/ArqWater.in";
  const char* FLUID_OIL_FILENAME = "reservoir_data/ArqOil.in";
  const char* FLUID_GAS_FILENAME = "reservoir_data/ArqGas.in";
  const char* WELLS_FILENAME = "reservoir_data/ArqWell1d.in";
  const char* SOLUTION_FILENAME = "reservoir_data/ArqInit1d.in";
  const char* RESERVOIR_FILENAME = "reservoir_data/ArqRes1d.in";
  const char* NUMERIC_PROPERTIES_FILENAME = "reservoir_data/ArqNumeric.in";
  const char* BOUNDARY_CONDITION_FILENAME = "reservoir_data/ArqBoundCond1d.in";
  const char* KERNEL_COMMAND = "ReservoirSoftware";
}

#endif

#endif // KERNEL_DEFINITIONS_H