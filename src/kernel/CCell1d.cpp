//** @file CCell1d.cpp */
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

#include "CCell1d.h"

using namespace std;

CCell1d::CCell1d()
{
	/// CCell1d default constructor.
	
	alphac = 5.614583; ///< Convertion units factor;
	
	cellid = 0;
	deepth = 0;
	pressure = 0;
	backpressure = 0;
	gtransmx = 0;

	well = NULL;
	rightcell = NULL;
	leftcell = NULL;

}

CCell1d::CCell1d(int _cellid, double _deepth, CBlock *blk, CFluid *fld) {
	/// Overloaded CCell1d constructor.
	/// This cell is created with data from reservoir, and with pointers to the
	/// block and fluid related to this cell.

	alphac = 5.614583; ///< Convertion units factor;
	
	cellid = _cellid;
	deepth = _deepth;

	block = blk;
	fluid = fld;
	well = NULL;

	pressure = fluid->AveragePVTPressure(); ///< It is only starting the cell pressure, this value will be changed according to simulation
	gtransmx = 0; ///< This value will be calculated after;

	leftcell = NULL; ///< The Reservoir is responsible to conect all the cells in domain.
	rightcell = NULL; ///< The Reservoir is responsible to conect all the cells in domain.
}

CCell1d::CCell1d(CCell1d & _cell) {
	/// CCell1d copy constructor.
	
	alphac = 5.614583; ///< Convertion units factor;
	cellid = _cell.CellId();
	deepth = _cell.Deepth();
	pressure = _cell.Pressure();
	backpressure = _cell.BackPressure();
	gtransmx = _cell.GTransmx();
	block = _cell.Block();
	fluid = _cell.Fluid();
	well = _cell.Well();
	leftcell = _cell.LeftCell();
	rightcell = _cell.RightCell();

}

CCell1d::~CCell1d()
{
	/// Cell1d destructor.

}

void CCell1d::Print()
{
	/// This function prints all the cell data on screen. It is used to debuge the code, and it is not
	/// necessary in the final program.

	cout << "Cell ID - " << cellid << "\n";
	cout << "Cell Deepth - " << deepth << "\n";
	cout << "Cell Conected to Block - " << block->Blockid() << "\n";
	cout << "Cell Pressure - " << pressure << "\n";
	cout << "Cell Back Pressure - " << backpressure << "\n";
	cout << "Cell Geometric Transmissibility - " << gtransmx << "\n";
	cout << "Inicial Cell Porosity - " << Porosity() << "\n";
	cout << "Atual Cell Porosity - " << Porosity(backpressure) << "\n";

	if (rightcell != NULL) {

		cout << "Right ID - " << rightcell->CellId() << "\n" ;

	}

	if (leftcell != NULL) {

		cout << "Left ID - " << leftcell->CellId() << "\n" ;

	}

	cout << "Right Transmissibility - " << RightTransmx() << "\n";
	if (well != NULL) {
		cout << "Well Rate - " << well->Rate() << "\n";
	}

}

double CCell1d::RightTransmx() {
	/// This function calculates the right transmissibility between adjacent cells in domain.
	/// the transmissibility is calculated as a product between the geometric transmissibility and
	/// the fluid properties inside the cell.

	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.

	double pright, pmed;

	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.

	double visc, fvf;

	visc = fluid->Viscosity(pmed); ///< Average viscosity between cells;
	fvf = fluid->FVF(pmed); ///< Average FVF between cells;

	return gtransmx/(visc*fvf);
}

double CCell1d::RightGravityTransmx() {
	/// This function calculates the right gravitational transmissibility between adjacent cells in domain.
	/// the gravitational transmissibility is calculated as a product between the transmissibility and
	/// the specific weight of the fluid inside the cell.

	double rtransmx;

	rtransmx = RightTransmx(); ///< Calculating the transmissibility between adjacent cells in domain;
	if (rtransmx == 0 ) { return 0; } ///< Right Block is NULL.
	double pright, pmed, spcweight;

	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.

	spcweight = fluid->Weight(pmed); ///< Average specific weight of fluid between cells;

	return spcweight*rtransmx;
}

double CCell1d::Gamma(double CellVolume) {
	/// This function returns the gamma factor for this cell, calculated as the compressible model.
	
	double  FVF, BackFVF, deltap;
	
	deltap = pressure - backpressure; ///< delta P between to time iterations;
	FVF = fluid->FVF(pressure); ///< FVF in cell i;
	BackFVF =  fluid->FVF(backpressure); ///< FVF in back iteration, at cell i;

	if ( deltap == 0 )  {
		return (CellVolume/alphac)*(block->Porosity()*block->RockComp()/FVF);
	}
    else {
    	return (CellVolume/alphac)*((block->Porosity()*block->RockComp()/FVF) + ((1/FVF - 1/BackFVF)*block->Porosity(backpressure)/deltap));
    }
    
}

double CCell1d::GammaDer(double CellVolume) {
	 ///This function returns the derivative of the gamma function in relation of the pressure in his block;
	 /// It is d Gamma     
	 ///       ----             dGamma/dP_(AtualBlock) 
     ///       dP_(i)
	 /// First  it will be implemented numerically, and then analyticaly.
	 
	double  FVF, BackFVF, deltap, gamma;
	
	deltap = pressure - backpressure; ///< delta P between to time iterations;
	FVF = fluid->FVF(pressure); ///< FVF in cell i;
	BackFVF =  fluid->FVF(backpressure); ///< FVF in back iteration, at cell i;

	if ( deltap == 0 )  {
		gamma = (CellVolume/alphac)*(block->Porosity()*block->RockComp()/FVF);
	}
    else {
    	gamma = (CellVolume/alphac)*((block->Porosity()*block->RockComp()/FVF) + ((1/FVF - 1/BackFVF)*block->Porosity(backpressure)/deltap));
    }
    
    
    double epsilon = 0.1;
    double  FVF_eps, BackFVF_eps, deltap_eps, gamma_eps;
    
    deltap_eps = pressure + epsilon - backpressure; ///< delta P between to time iterations;
	FVF_eps = fluid->FVF(pressure + epsilon); ///< FVF in cell i;
	BackFVF_eps =  fluid->FVF(backpressure); ///< FVF in back iteration, at cell i;

	if ( deltap == 0 )  {
		gamma_eps = (CellVolume/alphac)*(block->Porosity()*block->RockComp()/FVF_eps);
	}
    else {
    	gamma_eps = (CellVolume/alphac)*((block->Porosity()*block->RockComp()/FVF_eps) + ((1/FVF_eps - 1/BackFVF_eps)*block->Porosity(backpressure)/deltap_eps));
    }
    
	 return (gamma_eps - gamma)/epsilon;
	 
}
double CCell1d::RightTransmxDer( ) {
	 ///This function returns the derivative of the X transmissibility in relation of the pressure in the right block;
	 /// It is d Txr     
	 ///       ----             dTrx/dP_(RightBlock) 
     ///       dP_(i+1)
	 /// First  it will be implemented numerically, and then analyticaly.
	 
	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.
	
	/// Numerical Calculation ///
	double epsilon = 0.1;
	
	double pright, pmed, pmed_epsilon; 
	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
	
	pmed_epsilon = (pright + epsilon + pressure) / 2.; ///< Average pressure with epsilon factor;
	
	double transmx, transmx_epsilon;
	transmx =  gtransmx/(fluid->Viscosity(pmed) * fluid->FVF(pmed));
	transmx_epsilon =  gtransmx/(fluid->Viscosity(pmed_epsilon) * fluid->FVF(pmed_epsilon));
	 
	return (transmx_epsilon - transmx)/epsilon;	/// Numerical derivative; 
}

double CCell1d::CenterTransmxDer( ) {
	 ///This function returns the derivative of the X transmissibility in relation of the pressure in the center block;
	 /// It is d Txr     
	 ///       ----             dTrx/dP_(AtualBlock) 
     ///       dP_(i)
	 /// First  it will be implemented numerically, and then analyticaly.
	 
	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.
	
	/// Numerical Calculation ///
	double epsilon = 0.1;
	
	double pright, pmed, pmed_epsilon; 
	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
	
	pmed_epsilon = (pright + pressure + epsilon) / 2.; ///< Average pressure with epsilon factor;
	
	double transmx, transmx_epsilon;
	transmx =  gtransmx/(fluid->Viscosity(pmed) * fluid->FVF(pmed));
	transmx_epsilon =  gtransmx/(fluid->Viscosity(pmed_epsilon) * fluid->FVF(pmed_epsilon));
	 
	return (transmx_epsilon - transmx)/epsilon;	/// Numerical derivative; 
}

double CCell1d::RightGravityTransmxDer( ) {
	 ///This function returns the derivative of the Gravitational X transmissibility in relation of the pressure in the right block;
	 /// It is d TGxr     
	 ///       ----             dTGrx/dP_(RightBlock) 
     ///       dP_(i+1)
	 /// First  it will be implemented numerically, and then analyticaly.
	 
	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.
	
	/// Numerical Calculation ///
	double epsilon = 0.1;
	
	double pright, pmed, pmed_epsilon; 
	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
	
	pmed_epsilon = (pright + epsilon + pressure) / 2.; ///< Average pressure with epsilon factor;
	
	double transmx, transmx_epsilon;
	transmx =  gtransmx/(fluid->Viscosity(pmed) * fluid->FVF(pmed));
	transmx_epsilon =  gtransmx/(fluid->Viscosity(pmed_epsilon) * fluid->FVF(pmed_epsilon));
	
	double gravtransmx;
	gravtransmx = transmx*fluid->Weight(pmed);
	
	double gravtransmx_eps;
	gravtransmx_eps = transmx_epsilon*fluid->Weight(pmed_epsilon);
	
	return (gravtransmx_eps - gravtransmx)/epsilon;	/// Numerical derivative;
	
}

double CCell1d::CenterGravityTransmxDer( ) {
	 ///This function returns the derivative of the Gravitational X transmissibility in relation of the pressure in the center block;
	 /// It is d TGxr     
	 ///       ----             dTGrx/dP_(RightBlock) 
     ///       dP_(i+1)
	 /// First  it will be implemented numerically, and then analyticaly.
	 
	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.
	
	/// Numerical Calculation ///
	double epsilon = 0.1;
	
	double pright, pmed, pmed_epsilon; 
	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
	
	pmed_epsilon = (pright + pressure + epsilon) / 2.; ///< Average pressure with epsilon factor;
	
	double transmx, transmx_epsilon;
	transmx =  gtransmx/(fluid->Viscosity(pmed) * fluid->FVF(pmed));
	transmx_epsilon =  gtransmx/(fluid->Viscosity(pmed_epsilon) * fluid->FVF(pmed_epsilon));
	
	double gravtransmx;
	gravtransmx = transmx*fluid->Weight(pmed);
	
	double gravtransmx_eps;
	gravtransmx_eps = transmx_epsilon*fluid->Weight(pmed_epsilon);
	
	return (gravtransmx_eps - gravtransmx)/epsilon;	/// Numerical derivative;
	
}

int CCell1d::WellId() {
	///This function returns the Id of the well inside the cell.
	///If there is no well inside the cell, return 0;
	if (well == NULL) {
		return 0;
	}
	else{
		return well->Id();
	}

}

double CCell1d::WellCumulative_Phase1() {
	/// This function returns the cumulative volume of the phase 1, produced or injected by the well inside the cell.
	/// If there is no well inside the cell, the function returns 0.

	if (well == NULL) {
		return 0;
	}
	else{
		return well->Cumulative_Phase1();
	}
}

double CCell1d::WellRate() {
	/// This function returns the well flow rate of the well inside the cell.
	/// If there is no well inside the cell, the function returns 0.

	if (well == NULL) { return 0; }
	else { return well->Rate();	}
}
