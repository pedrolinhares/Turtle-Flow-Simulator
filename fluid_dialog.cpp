#include <QtWidgets>
#include <iostream>
#include "fluid_dialog.h"

FluidDialog::FluidDialog(QWidget *parent) : QDialog(parent) {
  QVBoxLayout *mainLayout = new QVBoxLayout;

  pvtTableWidget = new QTableWidget(1, 4, this);
  pvtTableWidget->setMaximumWidth(420);

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
void FluidDialog::insertRows(int i) {
  int numberOfNewRows = i - pvtTableWidget->rowCount();

  if (numberOfNewRows > 0)
    for(int j = 0; j < numberOfNewRows; j++)
      pvtTableWidget->insertRow(pvtTableWidget->rowCount());
  else
    for(int j = 0; j < -numberOfNewRows; j++)
      pvtTableWidget->removeRow(pvtTableWidget->rowCount() - 1);
    
}