/** @file kernel_definitions.h */
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

#ifndef KERNEL_DEFINITIONS_H
#define KERNEL_DEFINITIONS_H

#ifdef __linux

/**************************************************************************//**
** Defines the macros to be used as configuration files names.
******************************************************************************/
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

/**************************************************************************//**
** Defines the macros to be used as configuration files names.
******************************************************************************/
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