#include "kernel_definitions.h"

#ifdef __linux

std::string definitions::ARQ_BLOCKS_FILE = "kernel/ArqBlock.dat";
std::string definitions::ARQ_NUMERICS_FILE = "kernel/ArqNumeric.dat";
std::string definitions::ARQ_RESERVOIR_FILE = "kernel/ArqRes1d.dat";
std::string definitions::ARQ_WATER_FILE = "kernel/ArqWater.dat";
std::string definitions::ARQ_OIL_FILE = "kernel/ArqOil.dat";
std::string definitions::ARQ_GAS_FILE = "kernel/ArqGas.dat";
std::string definitions::ARQ_CELL1D_FILE = "kernel/ArqCell1d.dat";
std::string definitions::ARQ_WELL1D_FILE = "kernel/ArqWell1d.dat";
std::string definitions::ARQ_BOUNDARY_FILE = "kernel/ArqBoundCond1d.dat";
std::string definitions::ARQ_INIT_FILE = "kernel/ArqInit1d.dat";

std::string definitions::OUT_GRIDS_FILE = "kernel/Out_GridPressure.out";
std::string definitions::OUT_WELLS_FILE = "kernel/Out_Well_";

#endif

#ifdef _WIN32

std::string definitions::ARQ_BLOCKS_FILE = "kernel/ArqBlock.dat";
std::string definitions::ARQ_NUMERICS_FILE = "kernel/ArqNumeric.dat";
std::string definitions::ARQ_RESERVOIR_FILE = "kernel/ArqRes1d.dat";
std::string definitions::ARQ_WATER_FILE = "kernel/ArqWater.dat";
std::string definitions::ARQ_OIL_FILE = "kernel/ArqOil.dat";
std::string definitions::ARQ_GAS_FILE = "kernel/ArqGas.dat";
std::string definitions::ARQ_CELL1D_FILE = "kernel/ArqCell1d.dat";
std::string definitions::ARQ_WELL1D_FILE = "kernel/ArqWell1d.dat";
std::string definitions::ARQ_BOUNDARY_FILE = "kernel/ArqBoundCond1d.dat";
std::string definitions::ARQ_INIT_FILE = "kernel/ArqInit1d.dat";

std::string definitions::OUT_GRIDS_FILE = "kernel/Out_GridPressure.out";
std::string definitions::OUT_WELLS_FILE = "kernel/Out_Well_";

#endif