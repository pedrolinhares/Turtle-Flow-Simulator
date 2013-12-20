#include <QtWidgets>
#include <iostream>
#include "startDialog.h"

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

QGroupBox* StartDialog::createGridModels() {
  QGroupBox *gridModelBox = new QGroupBox(tr("Grid Model"));

  oneDimensionalRadio = new QRadioButton(tr("One Dimensional"));
  twoDimensionalRadio = new QRadioButton(tr("Two Dimensional"));
  threeDimensionalRadio = new QRadioButton(tr("Three Dimensional"));
  oneDimensionalRadio->setChecked(true);
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

std::string StartDialog::getGridModelChosen() {
  if (oneDimensionalRadio->isChecked())
    return std::string("oneDimensional");
  else if (twoDimensionalRadio->isChecked())
    return std::string("twoDimensional");
  else if (threeDimensionalRadio->isChecked())
    return std::string("threeDimensional");
}

std::string StartDialog::getPhaseModelChosen() {
 if (singlePhaseRadio->isChecked())
    return std::string("singlePhase");
  else if (twoPhaseRadio->isChecked())
    return std::string("twoPhase");
  else if (threePhaseRadio->isChecked())
    return std::string("threePhase"); 
}

std::map<std::string, std::string> StartDialog::getPhaseTypeChosen() {
  std::map<std::string, std::string> phaseMap;

  std::string phase = getPhaseModelChosen();
  phaseMap["phaseOne"] = phaseOne->currentText().toStdString();

  if (phase == "twoPhase") {
    phaseMap["phaseTwo"] = phaseTwo->currentText().toStdString();
  } 
    else if (phase == "threePhase") {
      phaseMap["phaseTwo"] = phaseTwo->currentText().toStdString();
      phaseMap["phaseThree"] = phaseThree->currentText().toStdString();
    }

  return phaseMap;
}

//private slots

void StartDialog::allowTwoDiminsional(bool toggled) {
  toggled == 1 ? rows->setDisabled(false) : rows->setDisabled(true);
}

void StartDialog::emitSignal() {
  emit dialogFinished(getGridModelChosen(), getPhaseModelChosen(), 
                      getPhaseTypeChosen(), rows->value(), columns->value());
}