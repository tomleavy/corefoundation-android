#!/bin/bash

cd swift-corelibs-foundation 
cd CoreFoundation
cd build
make -j8 VERBOSE=1
make install
