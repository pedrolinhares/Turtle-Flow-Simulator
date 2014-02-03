/** @file fluid_definitions.h */
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

/** Creates some definitions to be used accross the interface.
*/

#ifndef FLUID_DEFINITIONS_H
#define FLUID_DEFINITIONS_H

#include <string>

namespace fluid_definitions {

  /**************************************************************************//**
  ** \enum FluidType
  ** Definition about the fluid type representation.
  ******************************************************************************/
  enum class FluidType { WATER=1, OIL, GAS };

  /**************************************************************************//**
  ** Makes cast between FluidType and int.
  ** \return the integer corresponding code to the specific FluidType.
  ******************************************************************************/
  inline int getFluidCorrespondingInt(FluidType fluid) {
    return static_cast<int>(fluid);
  }

  /**************************************************************************//**
  ** Makes cast between String and int.
  ** \return the integer corresponding code to the specific FluidType.
  ******************************************************************************/
  int getFluidCorrespondingInt(std::string fluidStr);

  /**************************************************************************//**
  ** Makes cast between FluidType and string.
  ** \return the string corresponding to the specific FluidType.
  ******************************************************************************/
  extern std::string getFluidCorrespondingStdString(FluidType fluid);
}

#endif //FLUID_DEFINITIONS_H