/** \file grid.cpp */

#include "grid.h"

/** \brief basic constructor, takes number of rows, columns and parent pointer */
Grid::Grid(int row, int column, QWidget* parent) : QTableWidget(row, column, parent) {}