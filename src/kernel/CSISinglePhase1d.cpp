//** @file CSinglePhase1d.cpp */
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

#include "CSISinglePhase1d.h"

using namespace std;

CSISinglePhase1d::CSISinglePhase1d(int _cpoints)
{
	/// Class constructor.
	cpoints = _cpoints;
}

CSISinglePhase1d::~CSISinglePhase1d()
{
	/// Class destructor.

}

double CSISinglePhase1d::Gamma( CGrid *grid, int i) {
	/// This function calculates de gamma value, for the Single-Phase Compressible-Flow model.

	double alphac = 5.614583; ///< Convertion units factor;

	double GAMMA, Vb, por0, rockcomp, FVF, BackFVF, deltap, backporosity, backpress;

	Vb = grid->Volume(i); ///< Volume of cell i;

    por0 = grid->Por0(i); ///< Inicial porosity in cell i;
    backpress = grid->BackPressure(i); ///< Back Pressure in cell i;
    backporosity = grid->Porosity( i, backpress ); ///< Porosity in back time iteration, at cell i;
    rockcomp = grid->RockComp(i); ///< Rock Compressibility in cell i;
    FVF = grid->FVF(i); ///< FVF in cell i;
    BackFVF = grid->BackFVF(i); ///< FVF in back iteration, at cell i;
    deltap = grid->Pressure(i) - grid->BackPressure(i); ///< delta P between to time iterations;

    if ( deltap == 0 )  {
	GAMMA = (Vb/alphac)*(por0*rockcomp/FVF);
	}
    else {
    	GAMMA = (Vb/alphac)*((por0*rockcomp/FVF) + ((1/FVF - 1/BackFVF)*backporosity/deltap));
    }
	return GAMMA;
}

void CSISinglePhase1d::BuildMatrix(CGrid *grid, double **A, double deltat)
{
	/// This function creates the coefficient matrix "A", using the grid data.
	///	It is used a Single-Phase Compressible-Flow model, described in chapter 8 of
	/// Ertekin, T., Abou-Kassem, J. & King, G., "Basic Reservoir Simulation", 2001.

    double Wi, Ci, Ei;
	double deltap;

    for (int i = 0 ; i < (cpoints) ; i++) {

    	Wi = grid->RightTrasmx(i-1);  ///< Calculating the west matrix element;

    	Ei = grid->RightTrasmx(i); ///< Calculating the east matrix element;

    	Ci = - Gamma(grid, i)/deltat - Ei - Wi;	///< Calculating the central matrix element;

        A[i][0] = Wi;
        A[i][1] = Ci;
        A[i][2] = Ei;
    }

    A[0][0] = 0; ///< Left wall boundary condition;
    A[cpoints-1][2] = 0; ///< Right wall boundary condition;
}

void CSISinglePhase1d::BuildCoefVector(CGrid *grid, double *b, double deltat){
	/// This function creates the free vector "b", using the grid data.
	///	It is used a Single-Phase Compressible-Flow model, described in chapter 8 of
	/// Ertekin, T., Abou-Kassem, J. & King, G., "Basic Reservoir Simulation", 2001.

	double Eig, Wig, Cig, Qg;


	for (int i = 0 ; i < (cpoints) ; i++) {

		Wig = grid->RightGravityTransmx(i-1);  ///< Calculating the west transmissibility;

    	Eig = grid->RightGravityTransmx(i);   ///< Calculating the east transmissibility;

    	Cig = - Eig - Wig;  ///< Calculating the central transmissibility;

		Qg =Wig*grid->Deepth(i-1) + Cig*grid->Deepth(i) + Eig*grid->Deepth(i+1); ///< Rate term;

    	double gama_dt, q;

    	gama_dt = Gamma(grid, i)/deltat;

    	q = grid->WellRate(i);  ///< Getting the well rate for cell i;

    	b[i] = Qg - (gama_dt*grid->BackPressure(i)) - q;  ///< Filling the b vector;

    	/// Left Boundary Condition ///
    	if (i == 0) {
    		b[i]  = b[i] - grid->RightTrasmx(-1)*grid->Pressure(-1);
    	}

    	/// Right Boundary Condition ///
    	if (i == (cpoints - 1)) {
    		b[i]  = b[i] - grid->RightTrasmx(cpoints)*grid->Pressure(cpoints);
    	}

    }

}

void CSISinglePhase1d::BuildSolution(CGrid *grid, double *x) {
	 /// This function builds the initial solution for the first problem iteration.
	 /// It is used to initiate the first solution.

	 for (int i = 0 ; i < (cpoints) ; i++) {

        x[i] =  grid->Pressure(i);

    }

}
