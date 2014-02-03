#ifndef CPLOT_H
#define CPLOT_H

#include "CGnuplot.h"

#include <vector>
#include <string>

#include <fstream>
#include <sstream>
#include <iostream>

class CPlot
{
  protected:

    double time; ///< time that will be plotted;

    std::vector <double> x; ///< X axis data;
    std::vector <double> y; ///< Y axis data;

    /// Plot Properties
    std::string pstyle; ///< Gnuplot style;
    std::string xlabel, ylabel;  ///< Plot labels;
    std::string ptitle; ///< Plot title;
    std::string plabel; ///< Plot label;

    double marksize; ///< Size of markers;

    Gnuplot *plot;


  public:
    CPlot();
    ~CPlot();
    int PlotWellPressure(int welln); ///< Plot the pressure data for well n;
    int PlotWellProduction(int welln);  ///< Plot the cumulative production data for well n;
    int PlotGridPressure(double time, int ncells); ///< Plot the reservoir pressure for a specific time.
    int PlotCellPressure(int celln); ///< Plot the pressure profile for a specific cell in time.


    void PlotGraph(); ///< Plots a graph using the class parameters;
};

#endif
