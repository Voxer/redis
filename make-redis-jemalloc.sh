#!/bin/bash - 
#===============================================================================
#
#          FILE:  make-redis-jemalloc.sh
# 
#         USAGE:  ./make-redis-jemalloc.sh 
# 
#   DESCRIPTION:  Code to build redis-server that uses jemalloc
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: George Kola (), georgekola@gmail.com
#       COMPANY: 
#       CREATED: 02/ 9/14 07:31:12 AM UTC
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

#git clone  -b 2.8-voxer-jemalloc --recursive git@github.com:georgekola/redis.git
#cd redis/deps
cd deps
rm -rf jemalloc
git clone -b Voxer-Solaris git@github.com:georgekola/jemalloc.git
cd jemalloc
./autogen.sh --with-jemalloc-prefix=je_
cd ../..
make MALLOC=jemalloc V=1
