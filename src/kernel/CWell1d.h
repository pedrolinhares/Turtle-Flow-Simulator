/** @file CWell1d.h */
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

#ifndef CWell1d_h
#define CWell1d_h

/**
 * This class represents a one-dimensional well.
 * The one-dimensional well is the simplest well to model, and it can be setted only as a constant well rate.
 */

class CWell1d
{
	protected:
		
		int id; ///< Well Identificator;
		double rate; ///< Well flow rate. Positive is an injective well and negative is a producer one;
		double cumulative_phase1; ///< Cumulative produced or injeted of phase 1;

	public:

		CWell1d(); ///< Well constructor;
		CWell1d(double _rate) : rate(_rate), cumulative_phase1(0) {}; ///< Overloaded well constructor;
		CWell1d(double _rate, int _id) : rate(_rate), id(_id), cumulative_phase1(0) {}; ///< Overloaded well constructor;
		void SetWell1d( double _rate, int _id); ///< Sets the well flow rate, and the well Id.
		~CWell1d(); ///< Well destructor;

		inline int Id() { return id; }; ///< Returns the well id;
		inline double Rate() { return rate; }; ///< Returns the well flow rate;
		inline void Rate( double _rate) { rate = _rate; }; ///< Sets the well flow rate.
		double Cumulative_Phase1() { return cumulative_phase1; }; ///< Returns the cumulative volume of phase 1;
		void IterationtWell(double deltat) { cumulative_phase1 += rate*deltat;} ///< Makes the well Iterationt for cumulative volume;

};

#endif // CWell1d_h
