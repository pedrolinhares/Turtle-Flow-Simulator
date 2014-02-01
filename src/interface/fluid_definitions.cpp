/** @file fluid_definitions.cpp **/

#include "fluid_definitions.h"

int fluid_difinitions::getFluidCorrespondingInt(std::string fluidStr) {
  if (fluidStr == "Water")
    return static_cast<int>(FluidType::WATER);
  else if (fluidStr == "Oil")
    return static_cast<int>(FluidType::OIL);

  return static_cast<int>(FluidType::GAS);
}

std::string fluid_difinitions::getFluidCorrespondingStdString(FluidType fluid) {
  if (fluid == FluidType::WATER)
    return std::string("Water");
  else if (fluid == FluidType::OIL)
    return std::string("Oil");

  return std::string("Gas");
}