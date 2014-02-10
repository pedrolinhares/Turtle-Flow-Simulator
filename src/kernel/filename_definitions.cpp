/** @file filename_definitions.cpp */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz.
 *
 *  TFS is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  TFS is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TFS.  If not, see <http://www.gnu.org/licenses/>.
 *****************************************************************************/

#include "filename_definitions.h"

#ifdef __linux

std::string filename_definitions::ARQ_MODEL_FILE = "../reservoir_data/ArqModel.in";
std::string filename_definitions::ARQ_GRID1d_FILE = "../reservoir_data/ArqGrid1d.in";
std::string filename_definitions::ARQ_WELL1D_FILE = "../reservoir_data/ArqWell1d.in";
std::string filename_definitions::ARQ_GAS_FILE = "../reservoir_data/ArqGas.in";
std::string filename_definitions::ARQ_OIL_FILE = "../reservoir_data/ArqOil.in";
std::string filename_definitions::ARQ_WATER_FILE = "../reservoir_data/ArqWater.in";

std::string filename_definitions::OUT_GRID_FILE = "../reservoir_data/Out_GridPressure.out";
std::string filename_definitions::OUT_WELLS_FILE = "../reservoir_data/Out_Well_";

#endif

#ifdef _WIN32

std::string filename_definitions::ARQ_MODEL_FILE = "../reservoir_data/ArqModel.in";
std::string filename_definitions::ARQ_GRID1d_FILE = "../reservoir_data/ArqGrid1d.in";
std::string filename_definitions::ARQ_WELL1D_FILE = "../reservoir_data/ArqWell1d.in";
std::string filename_definitions::ARQ_GAS_FILE = "../reservoir_data/ArqGas.in";
std::string filename_definitions::ARQ_OIL_FILE = "../reservoir_data/ArqOil.in";
std::string filename_definitions::ARQ_WATER_FILE = "../reservoir_data/ArqWater.in";

std::string filename_definitions::OUT_GRID_FILE = "../reservoir_data/Out_GridPressure.out";
std::string filename_definitions::OUT_WELLS_FILE = "../reservoir_data/Out_Well_";

#endif
