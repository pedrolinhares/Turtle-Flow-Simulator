//** @file CWater.cpp */
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

#include "CWater.h"
#include <cstdlib>

using namespace std;

CWater::CWater() {
  /// Water constructor;
}

CWater::CWater(double *data) {
  /// Overloaded water constructor.
  /// This constructor constructs the water class using the data array from DataControl.

  pvtpoints = (int) data[0];

  pressure = new double[pvtpoints]; ///< Creating the pressure array from data;
  fvf = new double[pvtpoints]; ///< Creating the FVF array from data;
  weight = new double[pvtpoints]; ///< Creating the specific weight array from data;
  viscosity = new double[pvtpoints]; ///< Creating the viscosity array from data;

  for (int i=0 ; i < pvtpoints ; i++) {

      pressure[i] = data[4*i+1];
      fvf[i] = data[4*i+2];
      weight[i] = data[4*i+3];
      viscosity[i] = data[4*i+4];

  }

}
CWater::~CWater() {
  /// Water destructor.

  delete [] fvf;
  delete [] weight;
  delete [] viscosity;
}

double CWater::FVF(double pres) {
  /// Function that interpolates FVF from de PVT data.
  /// This function uses the linear interpolation model.

  if ((pres < pressure[0]) || (pres > pressure[pvtpoints-1])) { ///< If the reservoir pressure is out of PVT test, the user will be warned.
    cout << "Error - Pressure out of PVT range \n";
    cin.ignore();
    return 0;
  }

  int imin=0;

  while (pres > pressure[imin]) { imin++; } ///< Searching the position of the pressure in the PVT tabble;
  imin--;
  if (imin == (pvtpoints - 1)) {return fvf[imin]; } ///< This case is used when the pressure is the last pressure of the PVT tabble.

  return fvf[imin]+(pres-pressure[imin])*(fvf[imin+1]-fvf[imin])/(pressure[imin+1]-pressure[imin]);
}

double CWater::Weight(double pres) {
  /// Function that interpolates Specific Weight from de PVT data.
  /// This function uses the linear interpolation model.

  if ((pres < pressure[0]) || (pres > pressure[pvtpoints-1])) { ///< If the reservoir pressure is out of PVT test, the user will be warned.
    cerr << "Error - Pressure out of PVT range \n";
    // cin.ignore();
    exit(EXIT_FAILURE);
  }

  int imin=0;

  while (pres > pressure[imin]) { imin++; } ///< Searching the position of the pressure in the PVT tabble;
  imin--;
  if (imin == (pvtpoints - 1)) { return weight[imin]; } ///< This case is used when the pressure is the last pressure of the PVT tabble.

  return weight[imin]+(pres-pressure[imin])*(weight[imin+1]-weight[imin])/(pressure[imin+1]-pressure[imin]);
}

double CWater::Viscosity(double pres) {
  /// Function that interpolates Viscosity from de PVT data.
  /// This function uses the linear interpolation model.

  if ((pres < pressure[0]) || (pres > pressure[pvtpoints-1])) { ///< If the reservoir pressure is out of PVT test, the user will be warned.
    cerr << "Error - Pressure out of PVT range \n";
    // cin.ignore();
    exit(EXIT_FAILURE);
  }

  int imin=0;

  while (pres > pressure[imin]) { imin++; } ///< Searching the position of the pressure in the PVT tabble;
  imin--;
  if (imin == (pvtpoints - 1)) { return viscosity[imin]; } ///< This case is used when the pressure is the last pressure of the PVT tabble.

  return viscosity[imin]+(pres-pressure[imin])*(viscosity[imin+1]-viscosity[imin])/(pressure[imin+1]-pressure[imin]);
}

double CWater::AveragePVTPressure() {
  /// This function returns the average pressure of the PVT test.
  /// The function uses the linear averaging model.

  return (pressure[0]+pressure[pvtpoints-1])/2;
}

void CWater::PrintFluid() {
  /// This function prints all the fluid data on screen. It is used to debug the code, and it is not
  /// necessary in the final program.

  cout << "Press \t  FVF  \t  Weight \t  Viscosity \n";
  for (int j=0 ; j<pvtpoints ; j++) {
    cout << pressure[j] << "\t";
    cout << fvf[j] << "\t";
    cout << weight[j] << "\t";
    cout << viscosity[j] << "\n";
  }
}
