/** @file start_dialog.cpp */

#include <QtWidgets>
#include <iostream>
#include "start_dialog.h"

/**************************************************************************//**
  ** \brief class constructor that takes a parent pointer.
  **
  ** Creates the dialog by calling private methods that return the QGroupBox
  ** which contain the neccessary widgets.
  ****************************************************************************/
StartDialog::StartDialog(QWidget *parent) : QDialog(parent) {
  QVBoxLayout *mainLayout = new QVBoxLayout;

  QHBoxLayout *modelsLayouts = new QHBoxLayout;
  modelsLayouts->addWidget(createGridModels());
  modelsLayouts->addWidget(createPhaseModels());

  QHBoxLayout *otherLayout = new QHBoxLayout;
  otherLayout->addWidget(createPhasesBox());
  otherLayout->addWidget(createGridLayoutBox());

  QPushButton *ok_button = new QPushButton(tr("Ok"));
  QPushButton *close_button = new QPushButton(tr("Cancel"));

  ok_button->setDefault(true);

  QHBoxLayout *buttonsLayout = new QHBoxLayout;
  buttonsLayout->addStretch(1);
  buttonsLayout->addWidget(close_button);
  buttonsLayout->addWidget(ok_button);

  connect(close_button, SIGNAL(clicked()), this, SLOT(close()));
  connect(ok_button, SIGNAL(clicked()), this, SLOT(emitSignal()));
  connect(ok_button, SIGNAL(clicked()), this, SLOT(close()));

  mainLayout->addLayout(modelsLayouts);
  mainLayout->addLayout(otherLayout);
  mainLayout->addLayout(buttonsLayout);

  setLayout(mainLayout);
}

/**************************************************************************//**
  ** Creates the box with information regarding the grid.
  ** \return QGroupBox* that contains the widgets related.
  ****************************************************************************/
QGroupBox* StartDialog::createGridModels() {
  QGroupBox *gridModelBox = new QGroupBox(tr("Grid Model"));

  oneDimensionalRadio = new QRadioButton(tr("One Dimensional"));
  twoDimensionalRadio = new QRadioButton(tr("Two Dimensional"));
  threeDimensionalRadio = new QRadioButton(tr("Three Dimensional"));
  oneDimensionalRadio->setChecked(true);
  twoDimensionalRadio->setDisabled(true);
  threeDimensionalRadio->setDisabled(true);

  connect(twoDimensionalRadio, SIGNAL(toggled(bool)), this, SLOT(allowTwoDiminsional(bool)));

  QVBoxLayout *vbox = new QVBoxLayout;
  vbox->addWidget(oneDimensionalRadio);
  vbox->addWidget(twoDimensionalRadio);
  vbox->addWidget(threeDimensionalRadio);
  vbox->addStretch(1);
  gridModelBox->setLayout(vbox);

  return gridModelBox;
}

/**************************************************************************//**
  ** Creates the box with information regarding the number of phases.
  ** \return QGroupBox* that contains the widgets related.
  ****************************************************************************/
QGroupBox* StartDialog::createPhaseModels() {
  QGroupBox *fluidModelBox = new QGroupBox(tr("Fluid Model"));

  singlePhaseRadio = new QRadioButton(tr("Single Phase"));
  twoPhaseRadio = new QRadioButton(tr("Two-Phase"));
  threePhaseRadio = new QRadioButton(tr("Three-Phase"));
  singlePhaseRadio->setChecked(true);

  //because havent been implemented yet
  twoPhaseRadio->setDisabled(true);
  threePhaseRadio->setDisabled(true);

  QVBoxLayout *vbox = new QVBoxLayout;
  vbox->addWidget(singlePhaseRadio);
  vbox->addWidget(twoPhaseRadio);
  vbox->addWidget(threePhaseRadio);
  vbox->addStretch(1);
  fluidModelBox->setLayout(vbox);

  return fluidModelBox;
}

/**************************************************************************//**
  ** Creates the box with information regarding the type of the phases.
  ** \return QGroupBox* that contains the widgets related.
  ****************************************************************************/
QGroupBox* StartDialog::createPhasesBox() {
  QGroupBox *phasesBox = new QGroupBox(tr("Phases"));

  phaseOne = new QComboBox;
  phaseOne->insertItem(0, "Water");
  phaseOne->insertItem(1, "Oil");
  phaseOne->insertItem(2, "Gas");
  QLabel *phaseOneLabel = new QLabel(tr("Phase 1"));
  phaseOneLabel->setBuddy(phaseOne);

  QHBoxLayout *hBox1 = new QHBoxLayout;
  hBox1->addWidget(phaseOneLabel);
  hBox1->addWidget(phaseOne);

  phaseTwo = new QComboBox;
  phaseTwo->insertItem(0, "Water");
  phaseTwo->insertItem(1, "Oil");
  phaseTwo->insertItem(2, "Gas");
  QLabel *phaseTwoLabel = new QLabel(tr("Phase 2"));
  phaseTwoLabel->setBuddy(phaseTwo);

  QHBoxLayout *hBox2 = new QHBoxLayout;
  hBox2->addWidget(phaseTwoLabel);
  hBox2->addWidget(phaseTwo);


  phaseThree = new QComboBox;
  phaseThree->insertItem(0, "Water");
  phaseThree->insertItem(1, "Oil");
  phaseThree->insertItem(2, "Gas");
  QLabel *phaseThreeLabel = new QLabel(tr("Phase 3"));
  phaseThreeLabel->setBuddy(phaseThree);

  phaseTwo->setDisabled(true);
  phaseThree->setDisabled(true);

  QHBoxLayout *hBox3 = new QHBoxLayout;
  hBox3->addWidget(phaseThreeLabel);
  hBox3->addWidget(phaseThree);

  QVBoxLayout *vbox = new QVBoxLayout;
  vbox->addLayout(hBox1);
  vbox->addLayout(hBox2);
  vbox->addLayout(hBox3);
  // vbox->addStretch(1);
  phasesBox->setLayout(vbox);

  return phasesBox;
}

/**************************************************************************//**
  ** Creates the box with information regarding the layout of the grid
  ** (number of rows and columns).
  ** \return QGroupBox* that contains the widgets related.
  ****************************************************************************/
QGroupBox* StartDialog::createGridLayoutBox() {
  QLabel *rowns_label = new QLabel(tr("Lines: "));
  QLabel *columns_label = new QLabel(tr("columns: "));

  rows = new QSpinBox;
  columns = new QSpinBox;

  rows->setRange(1, 50);
  rows->setValue(20);
  columns->setRange(1, 50);
  columns->setValue(20);
  rows->setDisabled(true);

  rowns_label->setBuddy(rows);
  columns_label->setBuddy(columns);

  QVBoxLayout* gridLayout = new QVBoxLayout;
  gridLayout->addWidget(rowns_label);
  gridLayout->addWidget(rows);
  gridLayout->addWidget(columns_label);
  gridLayout->addWidget(columns);

  QGroupBox *gridBox = new QGroupBox(tr("Grid Layout"));
  gridBox->setLayout(gridLayout);

  return gridBox;
}

/**************************************************************************//**
  ** \brief Show the dialog on the screen.
  **
  ** Sets the default options in the dialog and calls the inherited show method.
  ****************************************************************************/
void StartDialog::show() {
  oneDimensionalRadio->setChecked(true);
  singlePhaseRadio->setChecked(true);
  phaseTwo->setDisabled(true);
  phaseThree->setDisabled(true);
  rows->setValue(20);
  columns->setValue(20);

  //calls parent's show
  QDialog::show();
}

/**************************************************************************//**
  ** \brief Gets the chosen grid model.
  ** \return type of dimension.
  ****************************************************************************/
std::string StartDialog::getGridModelChosen() {
  if (oneDimensionalRadio->isChecked())
    return std::string("oneDimensional");
  else if (twoDimensionalRadio->isChecked())
    return std::string("twoDimensional");
  else if (threeDimensionalRadio->isChecked())
    return std::string("threeDimensional");
}

/**************************************************************************//**
  ** \brief Gets the chosen type of phase.
  ** \return type of phase (single phase, two phases or three phases).
  ****************************************************************************/
std::string StartDialog::getPhaseModelChosen() {
 if (singlePhaseRadio->isChecked())
    return std::string("singlePhase");
  else if (twoPhaseRadio->isChecked())
    return std::string("twoPhase");
  else if (threePhaseRadio->isChecked())
    return std::string("threePhase");
}

/**************************************************************************//**
  ** \brief Gets the phase type.
  ** \return a map relating each phase to its chosen type.
  ****************************************************************************/
std::map<std::string, FluidType> StartDialog::getPhaseTypeChosen() {
  std::map<std::string, FluidType> phaseMap;

  std::string phase = getPhaseModelChosen();
  phaseMap["phaseOne"] = convertStringToFluidType(phaseOne);

  if (phase == "twoPhase") {
    phaseMap["phaseTwo"] = convertStringToFluidType(phaseTwo);
  }
    else if (phase == "threePhase") {
      phaseMap["phaseTwo"] = convertStringToFluidType(phaseTwo);
      phaseMap["phaseThree"] = convertStringToFluidType(phaseThree);
    }

  return phaseMap;
}

/**************************************************************************//**
  ** Converts a string to the specific FLuidType mapping.
  ** \return a FluidType mapping.
  ****************************************************************************/
FluidType StartDialog::convertStringToFluidType(QComboBox* comboBox) {
  if (comboBox->currentText() == "GAS")
    return FluidType::GAS;
  else if (comboBox->currentText() == "Oil")
    return FluidType::OIL;

  return FluidType::WATER;
}

//private slots

/**************************************************************************//**
  ** Enable the rows edit if it is two dimensional.
  ** \note private slot.
  ****************************************************************************/
void StartDialog::allowTwoDiminsional(bool toggled) {
  toggled == 1 ? rows->setDisabled(false) : rows->setDisabled(true);
}

/**************************************************************************//**
  ** Emits the dialogFinished signal.
  ** \note private slot.
  ****************************************************************************/
void StartDialog::emitSignal() {
  emit dialogFinished(getGridModelChosen(), getPhaseModelChosen(),
                      getPhaseTypeChosen(), rows->value(), columns->value());
}