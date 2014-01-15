/** @file fluid_definitions.h 
** Creates some definitions to be used accross the interface. 
*/

#ifndef FLUID_DEFINITIONS_H
#define FLUID_DEFINITIONS_H

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

#endif //FLUID_DEFINITIONS_H