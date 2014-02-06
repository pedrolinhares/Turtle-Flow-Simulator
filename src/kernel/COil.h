//** @file COil.h */
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

    virtual void Print(); ///< Prints all fluid data.

};

#endif  // COil_h
