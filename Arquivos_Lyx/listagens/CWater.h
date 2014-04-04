//** @file CWater.h */

#ifndef CWater_h
#define CWater_h

#include <iostream>

#include "CFluid.h"

/**
 * This class is used to represent the water fluid.
 * This class inherits all properties from CFluid.h
 */

class CWater : public CFluid
{
	public:
		
		CWater(); ///< Water constructor;
		CWater(double *data); ///< Overloaded Water constructor;
		virtual ~CWater(); ///< Water destructor;
		
		virtual double FVF(double pres); ///< Returns the FVF of a specific pressure;
		virtual double Weight(double pres); ///< Returns the Specific Weight of a specific pressure;
		virtual double Viscosity(double pres); ///< Returns the Viscosity of a specific pressure;
		virtual double AveragePVTPressure(); ///< Returns the average pressure of the PVT test;
		
		virtual void PrintFluid(); ///< Prints all fluid data.
};

#endif  // CWater_h
