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

CSISinglePhase1d::CSISinglePhase1d(CGrid *grid, int _maxni, double _erroni) {
	/// Class Constructor
	
	cpoints = grid->CellNumber();
	maxni = _maxni;
	erroni = _erroni;
	
	elem_numb = MatrixElementsNumber(grid);
	
	/// Allovating the Matrix A ///
	Acol = new int[elem_numb]; 
	Arow = new int[cpoints + 1]; 
	Aval = new double[elem_numb];
	
	/// Starting the Aval ///
	for (int j = 0; j < elem_numb; j++) { Aval[j] = 0; }
	
	/// Starting Acol and Arow ///
	/// For this is needed to access all cells in domain and verify their neighbours
	/// For 1d case, the cells are accessed from left to right.
	
	int colcount = 0; ///< Counter used to fill the Acol;
	
	/// First Cell
	Arow[0] = 0;
	Arow[1] = 2;
	Acol[colcount] = 0;
	colcount++;
	Acol[colcount] = 1;
	colcount++;
	
	/// Middle Cells 
	for (int i = 1 ; i < (cpoints - 1) ; i++ ) {
		Arow[(i+1)] = 3;
		Acol[colcount] = (i - 1);
		colcount++;
		Acol[colcount] = i;
		colcount++;
		Acol[colcount] = (i + 1);
		colcount++;
	}
	
	/// Last Cell
	Arow[cpoints] = 2;
	Acol[colcount] = (cpoints - 1);
	colcount++;
	Acol[colcount] = cpoints;
	colcount++;
	
	/// Cumulating the Arow array
	for (int g = 0; g < cpoints ; g++) {
		Arow[g+1] = Arow[g] + Arow[g+1] ;
	}
	
	/// Constructing the Free Vector
	b = new double[cpoints]; 
	
	/// Constructing the Solution Vector
    Xni = new double[cpoints]; 
		  
}

CSISinglePhase1d::~CSISinglePhase1d()
{
	/// Class destructor.
	delete [] Acol;
	Acol = NULL;
	
	delete [] Arow;
	Arow = NULL;
	
	delete [] Aval;
	Aval = NULL;
	
}

int CSISinglePhase1d::MatrixElementsNumber(CGrid *grid) {
 /// This function run over all cells in problem and returns the number of elements
 ///that will be created in matrix A. It is used for pre-allocate memory for UMFPack matrix
 
 return (3*grid->CellNumber() - 2); /// Each cell is connected to other two, but the firs and last not, so (3*cells - first - last)
 
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

void CSISinglePhase1d::BuildMatrix(CGrid *grid, double deltat)
{
	/// This function creates the coefficient matrix "A", using the grid data.
	///	It is used a Single-Phase Compressible-Flow model, described in chapter 8 of
	/// Ertekin, T., Abou-Kassem, J. & King, G., "Basic Reservoir Simulation", 2001.

    double Wi, Ci, Ei;
	double deltap;
	int elemcount = 0; ///< Counter to control the number of elements inserted in matrix A.
	
	/// Filling the first line of matrix A
	Wi = 0; ///< There is no west matrix element;
	Ei = grid->RightTrasmx(0); ///< Calculating the east matrix element;
	Ci = - Gamma(grid, 0)/deltat - Ei - Wi;	///< Calculating the central matrix element;
	
		Aval[elemcount] = Ci;
	    elemcount++;
	    Aval[elemcount] = Ei;
	    elemcount++;
	
	/// Filling the middle A Elements
    for (int i = 1 ; i < (cpoints - 1) ; i++) {
		
		Wi = grid->RightTrasmx(i-1); ///< Calculating the west matrix element;
		Ei = grid->RightTrasmx(i);	///< Calculating the east matrix element;	
    	Ci = - Gamma(grid, i)/deltat - Ei - Wi;	///< Calculating the central matrix element;

	        Aval[elemcount] = Wi;
	        elemcount++;
	        Aval[elemcount] = Ci;
	        elemcount++;
	        Aval[elemcount] = Ei;
	        elemcount++;
    }
    
    /// Filling the last line of matrix A
    Wi = grid->RightTrasmx(cpoints - 2); ///< Calculating the west matrix element;
    Ei = 0;	///< There is no east matrix element;
	Ci = - Gamma(grid, (cpoints - 1))/deltat - Ei - Wi;	///< Calculating the central matrix element;
	
		Aval[elemcount] = Wi;
        elemcount++;
        Aval[elemcount] = Ci;
        elemcount++;	

}

void CSISinglePhase1d::BuildCoefVector(CGrid *grid, double deltat){
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

void CSISinglePhase1d::BuildInitialSolution(CGrid *grid) {
	 /// This function builds the initial solution for the first problem iteration.
	 /// It is used to initiate the first solution.

	 for (int i = 0 ; i < (cpoints) ; i++) {

        Xni[i] =  grid->Pressure(i);

    }

}

void CSISinglePhase1d::Iterationt(CGrid *grid, CSolverMatrix *solver, double deltat) {
	/// This function makes a time iteration in all cells of domain
	/// using the semi-implicit linearization model.
	
	//////////  Iteration used for linearizate the problem  /////////
       double er1, er1max;
       int h = 0;

       do {

         BuildMatrix(grid, deltat);  ///< Constructing the coeficient matrix, according to the grid data.        
         BuildCoefVector(grid, deltat); ///< Constructing the free vector, according to the grid data.
         
         Print();
         
         solver->UMFPack( Acol, Arow, Aval, b, Xni, cpoints ); ///< Calling the solver used in this problem

        	 /////////  Error Analyzing  /////////

	         for (int j=0 ; j<cpoints; j++) {
		          er1 = abs(Xni[j] - grid->Pressure(j));
		          if (j == 0) {
		            	er1max = er1;
		          } else {
		            	if (er1 > er1max) { er1max = er1; }
		          }
	         }

         grid->Iterationni(Xni);  ///< Updating the atual pressure in reservoir

         h++;

       } while ((h < maxni) && (er1max > erroni));

	grid->Iterationt(deltat);  ///< Updating the back pressure in all reservoir;

    cout.precision(4);
    cout << "     Linear Iterations - " << h;
    cout << "     Linear Error - " << er1max << "\n";

}

void CSISinglePhase1d::Print() {
	///This function prints on screen all the matrix. It is used to debug the code.
	
	cout << "\nCumulative Row Array (Arow):\n";
	for (int i = 0; i < (cpoints + 1) ; i++ ) { cout << Arow[i] << endl; }
	
	cout << "\nColumn index for all elements (Acol):\n";
	for (int i = 0; i < elem_numb ; i++ ) { cout << Acol[i] << endl; }
	
	cout << "\nValue for all elements (Aval):\n";
	for (int i = 0; i < elem_numb ; i++ ) { cout << Aval[i] << endl; }
	
	cout << "\nValue of free vector (b):\n";
	for (int i = 0; i < (cpoints) ; i++ ) { cout << b[i] << endl; }
	
	cout << "\nValue of solution x (Xni):\n";
	for (int i = 0; i < (cpoints) ; i++ ) { cout << Xni[i] << endl; }
	
}
