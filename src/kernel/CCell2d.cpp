//** @file CCell2d.cpp */
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

#include "CCell2d.h"

using namespace std;

CCell2d::CCell2d()
{
	/// CCell1d default constructor.
	
	alphac = 5.614583; ///< Convertion units factor;
	
	cellid = 0;
	deepth = 0;
	pressure = 0;
	backpressure = 0;
	gtransmx = 0;
	gtransmy = 0;

	well = NULL;
	rightcell = NULL;
	leftcell = NULL;
	frontcell = NULL;
	backcell = NULL;

}

CCell2d::CCell2d(int _cellid, double _deepth, CBlock2d *blk, CFluid *fld) {
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
	gtransmy = 0; ///< This value will be calculated after;
	

	leftcell = NULL; ///< The Reservoir is responsible to conect all the cells in domain.
	rightcell = NULL; ///< The Reservoir is responsible to conect all the cells in domain.
	frontcell = NULL; ///< The Reservoir is responsible to conect all the cells in domain.
	backcell = NULL; ///< The Reservoir is responsible to conect all the cells in domain.
}

CCell2d::CCell2d(CCell2d & _cell) {
	/// CCell2d copy constructor.
	
	alphac = 5.614583; ///< Convertion units factor;
	cellid = _cell.CellId();
	deepth = _cell.Deepth();
	pressure = _cell.Pressure();
	backpressure = _cell.BackPressure();
	
	block = _cell.Block();
	fluid = _cell.Fluid();
	well = _cell.Well();
	
	gtransmx = _cell.GTransmX();
	gtransmy = _cell.GTransmY();
	
	leftcell = _cell.LeftCell();
	rightcell = _cell.RightCell();
	frontcell = _cell.FrontCell();
	backcell = _cell.BackCell();

}

CCell2d::~CCell2d()
{
	/// Cell1d destructor.

}

void CCell2d::Print()
{
	/// This function prints all the cell data on screen. It is used to debuge the code, and it is not
	/// necessary in the final program.

	cout << "Cell ID - " << cellid << "\n";
	cout << "Cell Deepth - " << deepth << "\n";
	cout << "Cell Conected to Block - " << block->Blockid() << "\n";
	cout << "Cell Pressure - " << pressure << "\n";
	cout << "Cell Back Pressure - " << backpressure << "\n";
	cout << "Cell Geometric Transmissibility in x - " << gtransmx << "\n";
	cout << "Cell Geometric Transmissibility in y - " << gtransmy << "\n";
	cout << "Inicial Cell Porosity - " << Porosity() << "\n";
	cout << "Atual Cell Porosity - " << Porosity(backpressure) << "\n";

	if (rightcell != NULL) {

		cout << "Right ID - " << rightcell->CellId() << "\n" ;

	}

	if (leftcell != NULL) {

		cout << "Left ID - " << leftcell->CellId() << "\n" ;

	}
	
	if (backcell != NULL) {

		cout << "Back ID - " << backcell->CellId() << "\n" ;

	}
	
	if (frontcell != NULL) {

		cout << "Front ID - " << frontcell->CellId() << "\n" ;

	}

	cout << "Right Transmissibility - " << RightTransmX() << "\n";	
	cout << "Front Transmissibility - " << FrontTransmY() << "\n";
	
	if (well != NULL) {
		cout << "Well Rate - " << well->Rate() << "\n";
	}

}

double CCell2d::RightTransmX() {
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

double CCell2d::RightGravityTransmX() {
	/// This function calculates the right gravitational transmissibility between adjacent cells in domain.
	/// the gravitational transmissibility is calculated as a product between the transmissibility and
	/// the specific weight of the fluid inside the cell.

	double rtransmx;

	rtransmx = RightTransmX(); ///< Calculating the transmissibility between adjacent cells in domain;
	if (rtransmx == 0 ) { return 0; } ///< Right Block is NULL.
	double pright, pmed, spcweight;

	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.

	spcweight = fluid->Weight(pmed); ///< Average specific weight of fluid between cells;

	return spcweight*rtransmx;
}

double CCell2d::FrontTransmY() {
	/// This function calculates the front transmissibility between adjacent cells in domain.
	/// the transmissibility is calculated as a product between the geometric transmissibility and
	/// the fluid properties inside the cell.

	if (gtransmy == 0) { return 0; }; ///< geometric transmissibility NULL means that the front block is NULL.

	double pfront, pmed;

	pfront = frontcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pfront + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.

	double visc, fvf;

	visc = fluid->Viscosity(pmed); ///< Average viscosity between cells;
	fvf = fluid->FVF(pmed); ///< Average FVF between cells;

	return gtransmy/(visc*fvf);
}

double CCell2d::FrontGravityTransmY() {
	/// This function calculates the front gravitational transmissibility between adjacent cells in domain.
	/// the gravitational transmissibility is calculated as a product between the transmissibility and
	/// the specific weight of the fluid inside the cell.

	double rtransmy;

	rtransmy = FrontTransmY(); ///< Calculating the transmissibility between adjacent cells in domain;
	if (rtransmy == 0 ) { return 0; } ///< Front Block is NULL.
	double pfront, pmed, spcweight;

	pfront = frontcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pfront + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.

	spcweight = fluid->Weight(pmed); ///< Average specific weight of fluid between cells;

	return spcweight*rtransmy;
}

double CCell2d::Gamma(double CellVolume) {
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

double CCell2d::GammaDer(double CellVolume) {
	 ///This function returns the derivative of the gamma function in relation of the pressure in his block;
	 /// It is d Gamma     
	 ///       ----             dGamma/dP_(AtualBlock) 
     ///       dP_(i)
	
	 double por_0, por_n;
	 por_0 = block->Porosity();
	 por_n = block->Porosity(backpressure);
	 
	 double deltap, BackFVF, FVF;
	 BackFVF =  fluid->FVF(backpressure); ///< FVF in back iteration, at cell i;
	 FVF = fluid->FVF(pressure); ///< FVF in cell i;
	 deltap = pressure - backpressure; ///< delta P between to time iterations;
	 
	 double derFVF;
	 derFVF = fluid->FVF_Derivative(pressure);
	 
	 double der_gamma;
	
	 
	if ( deltap == 0 )  {
	
		der_gamma = - (CellVolume/alphac)*(por_0*block->RockComp()*derFVF)/(FVF*FVF);
	}
    else {
   
    	der_gamma = (CellVolume/alphac)*((por_n/BackFVF)*(FVF*FVF - BackFVF*FVF - BackFVF*deltap*derFVF)/(FVF*FVF*deltap*deltap) - (por_0*block->RockComp()*derFVF)/(FVF*FVF));
   
   	}
    	 
	 return der_gamma;
}

double CCell2d::RightTransmXDer( ) {
	 ///This function returns the derivative of the X transmissibility in relation of the pressure in the right block;
	 /// It is d Txr     
	 ///       ----             dTrx/dP_(RightBlock) 
     ///       dP_(i+1)
	 
	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.
		
	double pright, pmed; 
	
	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
	
	double visc_med, FVF_med;
	visc_med = fluid->Viscosity(pmed);
	FVF_med = fluid->FVF(pmed);
	
	double der_visc, der_FVF;
	/// OBS: It is interesting that the numerical derivative calculetion is double of the interpolation case.
	///der_visc = (fluid->Viscosity(pmed_epsilon) - fluid->Viscosity(pmed)) / epsilon;  
	der_visc = fluid->Viscosity_Derivative(pmed);
	der_FVF = fluid->FVF_Derivative(pmed);
	
	return  ( - gtransmx*(FVF_med*der_visc + visc_med*der_FVF) / (2. * (visc_med*FVF_med) * (visc_med*FVF_med)) ); /// Analytical derivative; 
}

double CCell2d::CenterTransmXDer( ) {
	 ///This function returns the derivative of the X transmissibility in relation of the pressure in the center block;
	 /// It is d Txr     
	 ///       ----             dTrx/dP_(AtualBlock) 
     ///       dP_(i)
	 
	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.
		
	double pright, pmed; 
	
	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
	
	double visc_med, FVF_med;
	visc_med = fluid->Viscosity(pmed);
	FVF_med = fluid->FVF(pmed);
	
	/// OBS: It is interesting that the numerical derivative calculetion is double of the interpolation case.
	///der_visc = (fluid->Viscosity(pmed_epsilon) - fluid->Viscosity(pmed)) / epsilon;  
	
	double der_visc, der_FVF;
	der_visc = fluid->Viscosity_Derivative(pmed);
	der_FVF = fluid->FVF_Derivative(pmed);
		
	return  ( - gtransmx*(FVF_med*der_visc + visc_med*der_FVF) / (2. * (visc_med*FVF_med) * (visc_med*FVF_med)) ); /// Numerical derivative; 
}

double CCell2d::FrontTransmYDer( ) {
	 ///This function returns the derivative of the Y transmissibility in relation of the pressure in the front block;
	 /// It is d Try     
	 ///       ----             dTry/dP_(FrontBlock) 
     ///       dP_(j+1)
	 
	if (gtransmy == 0) { return 0; }; ///< geometric transmissibility NULL means that the front block is NULL.
		
	double pfront, pmed; 
	
	pfront = frontcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pfront + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
	
	double visc_med, FVF_med;
	visc_med = fluid->Viscosity(pmed);
	FVF_med = fluid->FVF(pmed);
	
	/// OBS: It is interesting that the numerical derivative calculetion is double of the interpolation case.
	///der_visc = (fluid->Viscosity(pmed_epsilon) - fluid->Viscosity(pmed)) / epsilon;  
	double der_visc, der_FVF;
	der_visc = fluid->Viscosity_Derivative(pmed);
	der_FVF = fluid->FVF_Derivative(pmed);
	
	return  ( - gtransmy*(FVF_med*der_visc + visc_med*der_FVF) / (2. * (visc_med*FVF_med) * (visc_med*FVF_med)) ); /// Analytical derivative; 
}

double CCell2d::CenterTransmYDer( ) {
	 ///This function returns the derivative of the Y transmissibility in relation of the pressure in the center block;
	 /// It is d Try     
	 ///       ----             dTry/dP_(AtualBlock) 
     ///       dP_(i)
	 
	if (gtransmy == 0) { return 0; }; ///< geometric transmissibility NULL means that the front block is NULL.
		
	double pfront, pmed; 
	
	pfront = frontcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pfront + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
	
	double visc_med, FVF_med;
	visc_med = fluid->Viscosity(pmed);
	FVF_med = fluid->FVF(pmed);
	
	/// OBS: It is interesting that the numerical derivative calculetion is double of the interpolation case.
	///der_visc = (fluid->Viscosity(pmed_epsilon) - fluid->Viscosity(pmed)) / epsilon;  
	double der_visc, der_FVF;
	der_visc = fluid->Viscosity_Derivative(pmed);
	der_FVF = fluid->FVF_Derivative(pmed);
		
	return  ( - gtransmy*(FVF_med*der_visc + visc_med*der_FVF) / (2. * (visc_med*FVF_med) * (visc_med*FVF_med)) ); /// Numerical derivative; 
}


double CCell2d::RightGravityTransmXDer( ) {
	 ///This function returns the derivative of the Gravitational X transmissibility in relation of the pressure in the right block;
	 /// It is d TGxr     
	 ///       ----             dTGrx/dP_(RightBlock) 
     ///       dP_(i+1)
	 
	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.
		
	double pright, pmed; 
	
	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
		
	double  weight_med, right_transmx;
	weight_med = fluid->Weight(pmed); ///< Specific Weight at average pressure;
	right_transmx = RightTransmX(); ///< Right Transmissibility;
	
	double der_transmx, der_weight;
	der_transmx = RightTransmXDer();  ///< Transmissibility Derivative at average pressure;
	der_weight = fluid->Weight_Derivative(pmed);  ///< Specific weight derivative at average pressure;
	
	return  ( 0.5*( weight_med*der_transmx + right_transmx*der_weight) ); /// Analytical derivative; 
}

double CCell2d::CenterGravityTransmXDer( ) {
	 ///This function returns the derivative of the Gravitational X transmissibility in relation of the pressure in the center block;
	 /// It is d TGxr     
	 ///       ----             dTGrx/dP_(AtualBlock) 
     ///       dP_(i)
	 
	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.
		
	double pright, pmed; 
	
	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
		
	double  weight_med, right_transmx;
	weight_med = fluid->Weight(pmed); ///< Specific Weight at average pressure;
	right_transmx = RightTransmX(); ///< Right Transmissibility;
	
	double der_transmx, der_weight;
	der_transmx = CenterTransmXDer();  ///< Transmissibility Derivative at average pressure;
	der_weight = fluid->Weight_Derivative(pmed);  ///< Specific weight derivative at average pressure;
	
	return  ( 0.5*( weight_med*der_transmx + right_transmx*der_weight) ); /// Analytical derivative; 	
}

double CCell2d::FrontGravityTransmYDer( ) {
	 ///This function returns the derivative of the Gravitational Y transmissibility in relation of the pressure in the front block;
	 /// It is d TrGy     
	 ///       ----             dTrGy/dP_(FrontBlock) 
     ///       dP_(j+1)
	 
	if (gtransmy == 0) { return 0; }; ///< geometric transmissibility NULL means that the front block is NULL.
		
	double pfront, pmed; 
	
	pfront = frontcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pfront + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
		
	double  weight_med, front_transmy;
	weight_med = fluid->Weight(pmed); ///< Specific Weight at average pressure;
	front_transmy = FrontTransmY(); ///< Right Transmissibility;
	
	double der_transmy, der_weight;
	der_transmy = FrontTransmYDer();  ///< Transmissibility Derivative at average pressure;
	der_weight = fluid->Weight_Derivative(pmed);  ///< Specific weight derivative at average pressure;
	
	return  ( 0.5*( weight_med*der_transmy + front_transmy*der_weight) ); /// Analytical derivative; 
}

double CCell2d::CenterGravityTransmYDer( ) {
	 ///This function returns the derivative of the Gravitational Y transmissibility in relation of the pressure in the center block;
	 /// It is d TrGy     
	 ///       ----             dTrGy/dP_(AtualBlock) 
     ///       dP_(i)
	 
	if (gtransmy == 0) { return 0; }; ///< geometric transmissibility NULL means that the front block is NULL.
		
	double pfront, pmed; 
	
	pfront = frontcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pfront + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.
		
	double  weight_med, front_transmy;
	weight_med = fluid->Weight(pmed); ///< Specific Weight at average pressure;
	front_transmy = FrontTransmY(); ///< Right Transmissibility;
	
	double der_transmy, der_weight;
	der_transmy = CenterTransmYDer();  ///< Transmissibility Derivative at average pressure;
	der_weight = fluid->Weight_Derivative(pmed);  ///< Specific weight derivative at average pressure;
	
	return  ( 0.5*( weight_med*der_transmy + front_transmy*der_weight) ); /// Analytical derivative; 	
}


int CCell2d::WellId() {
	///This function returns the Id of the well inside the cell.
	///If there is no well inside the cell, return 0;
	if (well == NULL) {
		return 0;
	}
	else{
		return well->Id();
	}

}

double CCell2d::WellCumulative_Phase1() {
	/// This function returns the cumulative volume of the phase 1, produced or injected by the well inside the cell.
	/// If there is no well inside the cell, the function returns 0.

	if (well == NULL) {
		return 0;
	}
	else{
		return well->Cumulative_Phase1();
	}
}

double CCell2d::WellRate() {
	/// This function returns the well flow rate of the well inside the cell.
	/// If there is no well inside the cell, the function returns 0.

	if (well == NULL) { return 0; }
	else { return well->Rate();	}
}
