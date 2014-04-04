//** @file CTrid.cpp */

#include "CTrid.h" 

using namespace std;

CTrid::CTrid(int nl) : CSolver(nl) {
	/// Class constructor.
	      
      verror = new double[nlines];  ///< Creating verror;
}

CTrid::CTrid(int nl, int _maxiter, double _erro) : CSolver(nl, _maxiter, _erro) {
	/// Overloaded Class constructor.
	
	  verror = new double[nlines];  ///< Creating verror;
}

CTrid::~CTrid()
{
	/// Class destructor
	    
    delete [] verror; ///< Destructing verror;
         
}

void CTrid::GaussSeidel( double **a , double *b ,double *x)  {
    /// This is the Gauss-Seidel algorithm, optimized for tri-diagonal systems.
    /// The matrix does not have zeros in its construction, saving memory.
	     
    double erromax=1;
    int n=1;
         
     do {
        
        /// First Line of the tri-diagonal system
        verror[0]=x[0];  
        x[0]= (b[0] - a[0][2]*x[1])/a[0][1];
        verror[0] = (abs(verror[0]-x[0]))/abs(x[0]);
        
		/// Center of the tri-diagonal system 
        for (int i=1 ; i<(nlines-1) ; i++) {  
             verror[i]=x[i];
             x[i]= (b[i] - a[i][0]*x[i-1] - a[i][2]*x[i+1])/a[i][1];
             verror[i] = (abs(verror[i]-x[i]))/abs(x[i]);
        }
         
        /// Last Line of the tri-diagonal system 
        verror[(nlines-1)]=x[(nlines-1)];   
        x[(nlines-1)]= (b[(nlines-1)] - a[(nlines-1)][0]*x[(nlines-2)])/a[(nlines-1)][1];
        verror[(nlines-1)] = (abs(verror[(nlines-1)]-x[(nlines-1)]))/abs(x[(nlines-1)]);
         
        /// Error anlyses 
        erromax=verror[0];    
        for (int j=1 ; j<nlines ; j++) {
             if (verror[j] > erromax) {
                 erromax = verror[j];
             }
        }
        
        n++;
    }while((erromax>erro) and (n<maxiter));
    if ( n == maxiter) {
    	cout << "\nMaximum of iterations reached in Gauss-Seidel solver.\n";
    } 
}
