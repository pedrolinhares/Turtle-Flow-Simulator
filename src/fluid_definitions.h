#ifndef FLUID_DEFINITIONS_H
#define FLUID_DEFINITIONS_H

enum class FluidType { WATER=1, OIL, GAS };

inline int getFluidCorrespondingInt(FluidType fluid) {
  return static_cast<int>(fluid);
}

#endif //FLUID_DEFINITIONS_H