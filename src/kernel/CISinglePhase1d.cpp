//** @file CISinglePhase1d.cpp */
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

#include "CISinglePhase1d.h"

using namespace std;

CISinglePhase1d::CISinglePhase1d(CGrid *grid, int _maxni, double _erroni) {
	/// Class Constructor
	
	cpoints = grid->CellNumber();
	maxni = _maxni;
	erroni = _erroni;
	
	elem_numb = MatrixElementsNumber(grid);
	
	/// Allocating the Matrix A ///
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
	Acol[colcount] = (cpoints - 2);
	colcount++;
	Acol[colcount] = (cpoints - 1);
	colcount++;
	
	/// Cumulating the Arow array
	for (int g = 0; g < cpoints ; g++) {
		Arow[g+1] = Arow[g] + Arow[g+1] ;
	}
	
	/// Constructing and Starting the Free Vector
	b = new double[cpoints]; 
	for (int j = 0; j < cpoints; j++) { b[j] = 0;}
	
	/// Constructing and Starting the Solution Vector
    Xni = new double[cpoints]; 
	for (int j = 0; j < cpoints; j++) { Xni[j] = 0;}
	
	/// Constructing and Starting the Pressure Solution Vector
	Xpress_ni = new double[cpoints];
	for (int j = 0; j < cpoints; j++) { Xpress_ni[j] = 0;}
		  
}

CISinglePhase1d::~CISinglePhase1d()
{
	/// Class destructor.
	delete [] Acol;
	Acol = NULL;
	
	delete [] Arow;
	Arow = NULL;
	
	delete [] Aval;
	Aval = NULL;
	
}

int CISinglePhase1d::MatrixElementsNumber(CGrid *grid) {
 /// This function run over all cells in problem and returns the number of elements
 ///that will be created in matrix A. It is used for pre-allocate memory for UMFPack matrix
 
 return (3*grid->CellNumber() - 2); /// Each cell is connected to other two, but the firs and last not, so (3*cells - first - last)
 
}

double CISinglePhase1d::CellResidual(CGrid *grid, double deltat, int celln) {
	/// This function returns the cell residual for the cell n. This residual is calculated using the single-phase
	/// implicit model, for a one-dimensional reservoir.
	
	double Wi, Wi_p, Ci, Ci_p,  Ei, Ei_p, Qi;
	
	/// Calculating the west transmissibility element:
		Wi = grid->RightTrasmX(celln-1);
		Wi_p = Wi*grid->Pressure(celln-1);  

	/// Calculating the east transmissibility element:
		Ei = grid->RightTrasmX(celln);
		Ei_p = Ei*grid->Pressure(celln+1);

	/// Calculating the central transmissibility element:
    Ci = - grid->Gamma(celln)/deltat - Ei - Wi;  
    Ci_p = Ci*grid->Pressure(celln); 
	
	/// Calculating the Qi element:
	Qi = RHSTerm(grid, deltat, celln);
		
	return ( Wi_p + Ci_p + Ei_p - Qi );
}

double CISinglePhase1d::RHSTerm(CGrid *grid, double deltat, int celln){
	/// This function returns the Right Hand Side term (Q_i) for the cell celln.
	///	It is used a Single-Phase Compressible-Flow model, described in chapter 8 of
	/// Ertekin, T., Abou-Kassem, J. & King, G., "Basic Reservoir Simulation", 2001.
	
	double Eig, Wig, Cig, Qg;
    double gama_dt, q, RHS_Qi;
  

	Wig = grid->RightGravityTransmX(celln-1);  ///< Calculating the west transmissibility;

	Eig = grid->RightGravityTransmX(celln);   ///< Calculating the east transmissibility;

	Cig = - Eig - Wig;  ///< Calculating the central transmissibility;

	Qg =Wig*grid->Deepth(celln-1) + Cig*grid->Deepth(celln) + Eig*grid->Deepth(celln+1); ///< Rate term;

	gama_dt = grid->Gamma(celln)/deltat;

	q = grid->WellRate(celln);  ///< Getting the well rate for cell i;

	RHS_Qi = Qg - (gama_dt*grid->BackPressure(celln)) - q;  ///< Filling the b vector;

	/// Left Boundary Condition ///
	//if (celln == 0) {
	//	RHS_Qi  = RHS_Qi - grid->RightTrasmx(-1)*grid->Pressure(-1);
	//}

	/// Right Boundary Condition ///
	//if (celln == (cpoints - 1)) {
	//	RHS_Qi  = RHS_Qi - grid->RightTrasmx(cpoints)*grid->Pressure(cpoints);
	//}

	return RHS_Qi;
}


double CISinglePhase1d::LeftResDer(CGrid *grid, int celln) {
	/// This function returns the left residual derivative for de cell n. 
	
	double leftpress, centerpress;
	leftpress = grid->Pressure(celln - 1);
	centerpress = grid->Pressure(celln);
	
	double leftdeepth, centerdeepth;
	leftdeepth = grid->Deepth(celln - 1);
	centerdeepth = grid->Deepth(celln);
	
	double lefttransmderiv, leftgravitderiv;
	lefttransmderiv = grid->CenterTransmXDer(celln - 1);
	leftgravitderiv = grid->CenterGravityTransmXDer( celln - 1);
	
	double lefttransmx;
	lefttransmx = grid->RightTrasmX(celln - 1);
	return ( (leftpress - centerpress)*lefttransmderiv + lefttransmx + (centerdeepth - leftdeepth)*leftgravitderiv );
}

double CISinglePhase1d::CentralResDer(CGrid *grid, double deltat, int celln) {
	/// This function returns the central residual derivative for de cell n. 
	
	double leftpress, centerpress, backcenterpress, rightpress;
	leftpress = grid->Pressure(celln - 1);
	centerpress = grid->Pressure(celln);
	backcenterpress = grid->BackPressure(celln);
	rightpress = grid->Pressure(celln + 1);
	
	double leftdeepth, centerdeepth, rightdeepth;
	leftdeepth = grid->Deepth(celln - 1);
	centerdeepth = grid->Deepth(celln);
	rightdeepth = grid->Deepth(celln + 1);
	
	double lefttransmx, righttransmx;
	lefttransmx = grid->RightTrasmX(celln - 1);
	righttransmx = grid->RightTrasmX(celln);
	
	double gamma_dt;
	gamma_dt = grid->Gamma(celln) / deltat;
	
	double lefttransmderiv, leftgravitderiv;
	lefttransmderiv = grid->RightTransmXDer(celln - 1);
	leftgravitderiv = grid->RightGravityTransmXDer(celln - 1);
	
	double righttransmderiv, rightgravitderiv;
	righttransmderiv = grid->CenterTransmXDer(celln);
	rightgravitderiv = grid->CenterGravityTransmXDer(celln);
	
	double gammaderiv;
	gammaderiv = grid->GammaDer(celln);
	
	double centralres;
	
	centralres = (leftpress - centerpress)*lefttransmderiv - lefttransmx - righttransmx;
	centralres = centralres - gamma_dt + (rightpress - centerpress)*righttransmderiv;
	centralres = centralres - (centerpress - backcenterpress)*gammaderiv/deltat + (centerdeepth - leftdeepth)*leftgravitderiv;
	centralres = centralres - (rightdeepth - centerdeepth)*rightgravitderiv;
	
	return centralres;
}

double CISinglePhase1d::RightResDer(CGrid *grid, int celln) {
	/// This function returns the right residual derivative for de cell n.
	
	double rightpress, centerpress;
	rightpress = grid->Pressure(celln + 1);
	centerpress = grid->Pressure(celln);
	
	double rightdeepth, centerdeepth;
	rightdeepth = grid->Deepth(celln + 1);
	centerdeepth = grid->Deepth(celln);
	
	double righttransmderiv, rightgravitderiv;
	righttransmderiv = grid->RightTransmXDer(celln);
	rightgravitderiv = grid->RightGravityTransmXDer(celln);
	
	double righttransmx;
	righttransmx = grid->RightTrasmX(celln);
	return ( (rightpress - centerpress)*righttransmderiv + righttransmx + (rightdeepth - centerdeepth)*rightgravitderiv ); 
}

void CISinglePhase1d::BuildJacobian(CGrid *grid, double deltat)
{
	/// This function creates the jacobian matrix "A", using the grid data.
	///	It is used a Single-Phase Compressible-Flow model, described in chapter 8 of
	/// Ertekin, T., Abou-Kassem, J. & King, G., "Basic Reservoir Simulation", 2001.
	
    double Wi, Ci, Ei;
	int elemcount = 0; ///< Counter to control the number of elements inserted in matrix A.
	
	/// Filling the first line of matrix A
	Ci = CentralResDer(grid, deltat, 0); ///< Calculating the central Jacobian Residual term;
	Ei = RightResDer(grid, 0); 	///< Calculating the east Jacobian Residual term;
	
		Aval[elemcount] = Ci;
	    elemcount++;
	    Aval[elemcount] = Ei;
	    elemcount++;
	
	/// Filling the middle A Elements
    for (int i = 1 ; i < (cpoints - 1) ; i++) {
		
		Wi = LeftResDer(grid,  i); ///< Calculating the west Jacobian Residual term;
		Ei = RightResDer(grid, i);	///< Calculating the east Jacobian Residual term;
    	Ci = CentralResDer(grid, deltat, i);	///< Calculating the central Jacobian Residual term;

	        Aval[elemcount] = Wi;
	        elemcount++;
	        Aval[elemcount] = Ci;
	        elemcount++;
	        Aval[elemcount] = Ei;
	        elemcount++;
    }
    
    /// Filling the last line of matrix A
    Wi = LeftResDer(grid, (cpoints - 1)); ///< Calculating the west matrix element;
	Ci = CentralResDer(grid, deltat, (cpoints - 1));	///< Calculating the central matrix element;
	
		Aval[elemcount] = Wi;
        elemcount++;
        Aval[elemcount] = Ci;
        elemcount++;	
}

void CISinglePhase1d::BuildCoefVector(CGrid *grid, double deltat){
	/// This function creates the free vector "b", using the grid data.
	///	It is used a Single-Phase Compressible-Flow model, described in chapter 8 of
	/// Ertekin, T., Abou-Kassem, J. & King, G., "Basic Reservoir Simulation", 2001.

	for (int i = 0 ; i < (cpoints) ; i++) {
		
		b[i] = - CellResidual(grid, deltat, i); ///< 

	}

}

void CISinglePhase1d::BuildInitialSolution(CGrid *grid) {
	 /// This function builds the initial solution for the first problem iteration.
	 /// It is used to initiate the first solution.

	 for (int i = 0 ; i < (cpoints) ; i++) {

        Xni[i] =  grid->Pressure(i) - grid->BackPressure(i);
        Xpress_ni[i] = grid->Pressure(i);

    }

}

void CISinglePhase1d::Iterationt(CGrid *grid, CSolverMatrix *solver, double deltat) {
	/// This function makes a time iteration in all cells of domain
	/// using the semi-implicit linearization model.
	
	//////////  Iteration used for linearizate the problem  /////////
       double er1, er1max;
       int h = 0;

       do {

         BuildJacobian(grid, deltat);  ///< Constructing the coeficient matrix, according to the grid data.        
         BuildCoefVector(grid, deltat); ///< Constructing the free vector, according to the grid data.
         
         //Print();

         solver->UMFPack( Acol, Arow, Aval, b, Xni, cpoints ); ///< Calling the solver used in this problem
         
         //Print();
	
        	 /////////  Error Analyzing  /////////

	         for (int j=0 ; j<cpoints; j++) {
	         	  Xpress_ni[j] = Xpress_ni[j] + Xni[j];
		          er1 = abs(Xni[j]);
		          if (j == 0) {
		            	er1max = er1;
		          } else {
		            	if (er1 > er1max) { er1max = er1; }
		          }
	         }

         grid->Iterationni(Xpress_ni);  ///< Updating the atual pressure in reservoir

         h++;

       } while ((h < maxni) && (er1max > erroni));

	grid->Iterationt(deltat);  ///< Updating the back pressure in all reservoir;

    cout.precision(4);
    cout << "     Linear Iterations - " << h;
    cout << "     Linear Error - " << er1max << "\n";

}

void CISinglePhase1d::Print() {
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
