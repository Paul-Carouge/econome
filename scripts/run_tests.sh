#!/bin/bash
# Test runner for Économe — sets up libsqlite3.so path and Flutter PATH
export PATH="/opt/data/tools/flutter/bin:$PATH"
export LD_LIBRARY_PATH=/home/atlas/.local/lib:$LD_LIBRARY_PATH
exec flutter test "$@"
