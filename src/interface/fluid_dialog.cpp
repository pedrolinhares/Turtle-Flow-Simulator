/** @file fluid_dialog.cpp */

#include <QtWidgets>
#include "fluid_dialog.h"

/**************************************************************************//**
** \brief constructor that takes the parent pointer.
**
** Creates the widgets that compose the dialog.
******************************************************************************/
FluidDialog::FluidDialog(QWidget *parent) : QDialog(parent) {
  QVBoxLayout *mainLayout = new QVBoxLayout;

  pvtTableWidget = new QTableWidget(1, 4, this);
  pvtTableWidget->setMaximumWidth(420);
  pvtTableWidget->setRowCount(2);

  QStringList labels;
  labels << "Pressure" << "FVF" << "Density" << "Viscosity";
  pvtTableWidget->setHorizontalHeaderLabels(labels);
  pvtTableWidget->resizeRowsToContents();

  // mainLayout->addLayout(pvtPointsLayout);
  mainLayout->addWidget(pvtTableWidget);
  mainLayout->addStretch();
  mainLayout->setAlignment(Qt::AlignCenter);

  setLayout(mainLayout);

  show();
}

//private slots
/**************************************************************************//**
** \brief Insert or remove rows in the table.
**
** As the user manipulates a QSpinBox, the number of rows are increased or
** decreased acording to the user input.
** \param i Number of rows the table should have, as inputed by user.
******************************************************************************/
void FluidDialog::insertOrRemoveRows(int i) {
  int numberOfNewRows = i - pvtTableWidget->rowCount();

  if (numberOfNewRows > 0)
    for(int j = 0; j < numberOfNewRows; j++)
      pvtTableWidget->insertRow(pvtTableWidget->rowCount());
  else
    for(int j = 0; j < -numberOfNewRows; j++)
      pvtTableWidget->removeRow(pvtTableWidget->rowCount() - 1);
}