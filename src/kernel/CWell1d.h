//** @file CWell1d.h */

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
		~CWell1d(); ///< Well destructor;
		
		inline int Id() { return id; }; ///< Returns the well id;
		inline double Rate() { return rate; }; ///< Returns the well flow rate;
		inline void Rate( double _rate) { rate = _rate; }; ///< Sets the well flow rate.
		void Rate( double _rate, int _id); ///< Sets the well flow rate, and the well Id.
		double Cumulative_Phase1() { return cumulative_phase1; }; ///< Returns the cumulative volume of phase 1;
		void IterationtWell(double deltat) { cumulative_phase1 += rate*deltat;} ///< Makes the well Iterationt for cumulative volume;
	
};

#endif // CWell1d_h
