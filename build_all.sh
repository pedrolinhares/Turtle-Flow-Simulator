#!/bin/bash
echo "**Building Interface**"
make -f ./Makefile
sleep 1

echo "**Building Kernel**"
cd ./src/kernel
make -f Makefile
cd -

sleep 1
echo "**Building Finnished**"
