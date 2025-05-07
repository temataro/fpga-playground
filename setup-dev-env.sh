#!/usr/bin/bash

sudo apt-get install -y build-essential clang bison flex libreadline-dev \
                        gawk tcl-dev libffi-dev git mercurial graphviz   \
                        xdot pkg-config libftdi-dev libboost-all-dev \
                        cmake libeigen3-dev

mkdir -p Tools && cd Tools
git clone https://github.com/YosysHQ/icestorm.git icestorm
cd icestorm
make -j$(nproc)
sudo make install
cd ..

git clone https://github.com/cseed/arachne-pnr.git arachne-pnr
cd arachne-pnr
make -j$(nproc)
sudo make install
cd ..

git clone https://github.com/YosysHQ/nextpnr nextpnr
cd nextpnr
cmake . -B build -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local && cmake --build build
cd build
make -j$(nproc)
sudo make install
cd ../..

git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
git submodule update --init
make -j$(nproc)
sudo make install
cd ..
