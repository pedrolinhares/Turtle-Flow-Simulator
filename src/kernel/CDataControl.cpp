//** @file CDataControl.cpp */
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

#include "CDataControl.h"

using namespace std;

CDataControl::CDataControl()
{
	/// class constructor
}

CDataControl::~CDataControl()
{
	/// class destructor
}

double * CDataControl::DataCGrid1d(string flname) {
    //This function opens a file and construct a vector with informations about the one-dimensional reservoir.

	ifstream fres(flname.c_str());

    if (fres.fail())
       {
            cerr << "There is no reservoir data." << endl;
            // cin.ignore();
            exit(EXIT_FAILURE);
       }

    int blknumber, cellnumber, fluidtype;
    double width;

    fres >> blknumber;
    fres >> cellnumber;
    fres >> width;
    fres >> fluidtype;


    double *data;
    data = new double[(cellnumber + 4)];

    data[0] = blknumber;
    data[1] = cellnumber;
    data[2] = width;
    data[3] = fluidtype;


    for(int i = 4; i <  (cellnumber+4) ; i++) {
            fres >> data[i];
    }

    fres.close();

    return data;
}

double * CDataControl::DataCBlock(string flname, int blknum) {
	//This function opens a file and construct a vector with informations about the block with ID blknumber.

    ifstream fblk(flname.c_str());

    if (fblk.fail()) {
      cerr << "There is no block data." << endl;
      // cin.ignore();
      exit(EXIT_FAILURE);
    }

   double trash;

  for (int j=0; j<(5*blknum); j++) {
    fblk >> trash;
  }

   double *data;
   data = new double[5];

   fblk >> data[0];
   fblk >> data[1];
   fblk >> data[2];
   fblk >> data[3];
   fblk >> data[4];

   fblk.close();

   return data;
}

double * CDataControl::DataCell1d(string flname, int cellnum) {
	//This function opens a file and construct a vector with informations about one-dimensional Cells.

	ifstream fcll(flname.c_str());

    if (fcll.fail()) {
      cerr << "There is no cell data." << endl;
      // cin.ignore();
      exit(EXIT_FAILURE);
     }

   double trash;

   for (int j=0; j<(4*cellnum); j++)
   {
   		fcll >> trash;
   }

   double *data;
   data = new double[4];

   fcll >> data[0];
   fcll >> data[1];
   fcll >> data[2];
   fcll >> data[3];

   fcll.close();

   return data;
}

double * CDataControl::DataCFluid(std::string flname) {
	//This function opens a file and construct a vector with informations about Fluid data from PVT simulation.

	ifstream ffluid(flname.c_str());

    if (ffluid.fail()) {
      return NULL;
    }


   double pvtpoints;
   ffluid >> pvtpoints;

   double *data;
   int lgt = (int) (4*pvtpoints+1);
   data = new double[lgt];

   data[0]=pvtpoints;

   for (int i=1 ; i < lgt ; i++) {
   		ffluid >> data[i];
   }

   return data;
}


double * CDataControl::DataCWell1d(std::string flname)  {
	//This function opens a file and construct a vector with informations about one-dimensional well.

	ifstream fwell(flname.c_str());

    if (fwell.fail()) {
      cerr << "There is no Well data." << endl;
      // cin.ignore();
      exit(EXIT_FAILURE);
       }

    double wellnumber;
    fwell >> wellnumber;

    int datapoints;
    datapoints = (int) (4*wellnumber + 1);

    double *data;
    data = new double[datapoints];

    data[0] = wellnumber;

    for (int j=1 ; j<=(4*wellnumber) ; j++) {
    	fwell >> data[j];
    }

    return data;
}


double * CDataControl::DataInitiate1d(std::string flname)  {
	//This function opens a file and construct a vector with informations about the pressure initialization.

	ifstream finit(flname.c_str());

    if (finit.fail()) {
      cerr << "There is no initialization data." << endl;
      // cin.ignore();
      exit(EXIT_FAILURE);
    }

    double *data;
    data = new double[2];
    finit >> data[0];
    finit >> data[1];

    return data;
}

double * CDataControl::DataNumeric(std::string flname)  {
	//This function opens a file and construct a vector with numerical informations used in simulation.

	ifstream fnum(flname.c_str());

  if (fnum.fail()) {
    cerr << "There is no Numeric data." << endl;
    // cin.ignore();
    exit(EXIT_FAILURE);
  }

    double *data;
    data = new double[7];

    for (int i=0; i<7; i++) {
    	fnum >> data[i];
    }

    return data;

}

double * CDataControl::DataBoundCond1d(std::string flname) {
	//This function opens a file and construct a vector with information about boundary condition parameters.
	ifstream fbcon(flname.c_str());

  if (fbcon.fail()) {
    cerr << "There is no Boundary Condition data." << endl;
    // cin.ignore();
    exit(EXIT_FAILURE);
  }

    double *data;
    data = new double[4];

    for (int i=0; i<4; i++) {
    	fbcon >> data[i];
    }

    return data;
}