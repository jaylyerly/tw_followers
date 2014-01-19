#!/bin/sh
set -e

#brew update
#brew install xctool

#sudo pip install cpp-coveralls --use-mirrors
#sudo easy_install cpp-coveralls

git clone https://github.com/jaylyerly/cpp-coveralls.git
cd cpp-coveralls
sudo python setup.py install 

