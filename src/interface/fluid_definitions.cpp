/** @file fluid_definitions.cpp **/
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

#include "fluid_definitions.h"

int fluid_definitions::getFluidCorrespondingInt(std::string fluidStr) {
  if (fluidStr == "Water")
    return static_cast<int>(FluidType::WATER);
  else if (fluidStr == "Oil")
    return static_cast<int>(FluidType::OIL);

  return static_cast<int>(FluidType::GAS);
}

std::string fluid_definitions::getFluidCorrespondingStdString(FluidType fluid) {
  if (fluid == FluidType::WATER)
    return std::string("Water");
  else if (fluid == FluidType::OIL)
    return std::string("Oil");

  return std::string("Gas");
}