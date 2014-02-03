/** @file filename_definitions.h */
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

#ifndef FILENAME_DEFINITIONS_H
#define FILENAME_DEFINITIONS_H

#include <string>

/**
 * Namespace that contains the macros that represent the configuration filenames
 */
namespace filename_definitions {

extern std::string ARQ_BLOCKS_FILE;
extern std::string ARQ_NUMERICS_FILE;
extern std::string ARQ_RESERVOIR_FILE;
extern std::string ARQ_WATER_FILE;
extern std::string ARQ_OIL_FILE;
extern std::string ARQ_GAS_FILE;
extern std::string ARQ_CELL1D_FILE;
extern std::string ARQ_WELL1D_FILE;
extern std::string ARQ_BOUNDARY_FILE;
extern std::string ARQ_INIT_FILE;

extern std::string OUT_GRIDS_FILE;
extern std::string OUT_WELLS_FILE;
}


#endif // FILENAME_DEFINITIONS_H