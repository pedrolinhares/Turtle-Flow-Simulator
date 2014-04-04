//** @file CFluid.h */

#ifndef CFluid_h
#define CFluid_h

#include <iostream>

#include "CDataControl.h"

/**
 * This class is an abstract class used to represent a fluid.
 * The fluid can be oil, gas or water, and specific properties can be modeled in these children classes.
 */
 
class CFluid
{
	protected:
		
		CDataControl *dcontrol; ///< Pointer to the simulation data;
		int pvtpoints; ///< Number of PVT points used to describe the fluid behaviour;
		double *pressure; ///< Array containing all pressure points in PVT;
		double *fvf; ///< Array containing all FVF points in PVT;
		double *weight; ///< Array containing all Specific Weight points in PVT;
		double *viscosity; ///< Array containing all viscosity points in PVT;
		
	public:
		
		CFluid(); ///< Fluid constructor;
		CFluid(CDataControl *_dcontrol); ///< Overloaded Fluid constructor;
		virtual ~CFluid(); ///< Fluid destructor;
		
		virtual double FVF(double pressure) = 0; ///< Returns the FVF of a specific pressure;
		virtual double Weight(double pressure) = 0; ///< Returns the Specific Weight of a specific pressure;
		virtual double Viscosity(double pressure) = 0; ///< Returns the Viscosity of a specific pressure;
		virtual double AveragePVTPressure() = 0; ///< Returns the average pressure of the PVT test;
		
		virtual void PrintFluid() = 0; ///< Prints all fluid data.
};

#endif // CFluid_h
