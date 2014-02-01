//** @file COil.h */

#ifndef COIL_H
#define COIL_H

#include <iostream>
#include "CFluid.h"

/**
 * This class is used to represent the oil fluid.
 * This class inherits all properties from CFluid.h
 */

class COil : public CFluid
{
  public:
    COil();  ///< Oil constructor;
    COil(double *data); ///< Overloaded Oil constructor;
    virtual ~COil();  ///< Oil destructor;

    virtual double FVF(double pres); ///< Returns the FVF of a specific pressure;
    virtual double Weight(double pres); ///< Returns the Specific Weight of a specific pressure;
    virtual double Viscosity(double pres); ///< Returns the Viscosity of a specific pressure;
    virtual double AveragePVTPressure(); ///< Returns the average pressure of the PVT test;

    virtual void PrintFluid(); ///< Prints all fluid data.

};

#endif  // COil_h