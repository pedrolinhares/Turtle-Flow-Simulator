//** @file CGas.h */

#ifndef CGAS_H
#define CGAS_H

#include <iostream>
#include "CFluid.h"

/**
 * This class is used to represent the gas fluid.
 * This class inherits all properties from CFluid.h
 */


class CGas : public CFluid
{
	public:
		CGas();  ///< Gas constructor;
		CGas(double *data); ///< Overloaded Gas constructor;
		virtual ~CGas();  ///< Gas destructor;
		
		virtual double FVF(double pres); ///< Returns the FVF of a specific pressure;
		virtual double Weight(double pres); ///< Returns the Specific Weight of a specific pressure;
		virtual double Viscosity(double pres); ///< Returns the Viscosity of a specific pressure;
		virtual double AveragePVTPressure(); ///< Returns the average pressure of the PVT test;
		
		virtual void PrintFluid(); ///< Prints all fluid data.
	
};

#endif //CGas_h
