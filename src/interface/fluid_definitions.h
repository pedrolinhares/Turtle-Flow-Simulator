/** @file fluid_definitions.h
** Creates some definitions to be used accross the interface.
*/

#ifndef FLUID_DEFINITIONS_H
#define FLUID_DEFINITIONS_H

#include <string>

namespace fluid_difinitions {

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