#include <QtGui>
#include <QMessageBox>
#include <iostream>
#include "grid.h"

Grid::Grid(int row, int column, QWidget* parent) : QTableWidget(row, column, parent) {

}

bool Grid::isBeingEdited() {
	std::cout << this->state();
 if (this->state() == QAbstractItemView::EditingState)
   return true;
 else
   return false;
};

bool Grid::okToContinue () {
 if (isBeingEdited()){
 	int r = QMessageBox::warning(this, tr("Save Changes?"),
                        tr("The document has been modified. \n"
                        "Do you want to save your changes?"),
                        QMessageBox::Yes | QMessageBox::Default,
                        QMessageBox::No,
                        QMessageBox::Cancel | QMessageBox::Escape);
    if (r == QMessageBox::No)
    	return true;
    else if (r == QMessageBox::Yes)
    	saveGrid();
    else
      return false;
 } else
     return true;
}

bool Grid::saveGrid() {

}