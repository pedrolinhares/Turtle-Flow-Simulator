#!/bin/bash
echo "**Building Interface**"
qmake
make -f ./Makefile
sleep 1

echo "**Building Kernel**"
cd ./src/kernel
make -f Makefile
cd -

echo "**Building Finnished**"
