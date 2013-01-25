#!/bin/bash

INSTALL_DIR=/usr/lib/rapidftr
cd $INSTALL_DIR
bundle exec rake app:stop_thin

