#include "kernel_definitions.h"

#ifdef __linux

std::string definitions::ARQ_BLOCKS_FILE = "reservoir_data/ArqBlock.in";
std::string definitions::ARQ_NUMERICS_FILE = "reservoir_data/ArqNumeric.in";
std::string definitions::ARQ_RESERVOIR_FILE = "reservoir_data/ArqRes1d.in";
std::string definitions::ARQ_WATER_FILE = "reservoir_data/ArqWater.in";
std::string definitions::ARQ_OIL_FILE = "reservoir_data/ArqOil.in";
std::string definitions::ARQ_GAS_FILE = "reservoir_data/ArqGas.in";
std::string definitions::ARQ_CELL1D_FILE = "reservoir_data/ArqCell1d.in";
std::string definitions::ARQ_WELL1D_FILE = "reservoir_data/ArqWell1d.in";
std::string definitions::ARQ_BOUNDARY_FILE = "reservoir_data/ArqBoundCond1d.in";
std::string definitions::ARQ_INIT_FILE = "reservoir_data/ArqInit1d.in";

std::string definitions::OUT_GRIDS_FILE = "reservoir_data/Out_GridPressure.out";
std::string definitions::OUT_WELLS_FILE = "reservoir_data/Out_Well_";

#endif

#ifdef _WIN32

std::string definitions::ARQ_BLOCKS_FILE = "reservoir_data/ArqBlock.in";
std::string definitions::ARQ_NUMERICS_FILE = "reservoir_data/ArqNumeric.in";
std::string definitions::ARQ_RESERVOIR_FILE = "reservoir_data/ArqRes1d.in";
std::string definitions::ARQ_WATER_FILE = "reservoir_data/ArqWater.in";
std::string definitions::ARQ_OIL_FILE = "reservoir_data/ArqOil.in";
std::string definitions::ARQ_GAS_FILE = "reservoir_data/ArqGas.in";
std::string definitions::ARQ_CELL1D_FILE = "reservoir_data/ArqCell1d.in";
std::string definitions::ARQ_WELL1D_FILE = "reservoir_data/ArqWell1d.in";
std::string definitions::ARQ_BOUNDARY_FILE = "reservoir_data/ArqBoundCond1d.in";
std::string definitions::ARQ_INIT_FILE = "reservoir_data/ArqInit1d.in";

std::string definitions::OUT_GRIDS_FILE = "reservoir_data/Out_GridPressure.out";
std::string definitions::OUT_WELLS_FILE = "reservoir_data/Out_Well_";

#endif