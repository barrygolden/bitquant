#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OG_COMPILE_PLATFORM_NATIVE=1
ncpus=`nproc`
if [ $ncpus -gt 4 ]; then
ncpus=4
fi

if [ -e $HOME/bitquant.conf ] ;  then
echo "Reading configuration from $HOME/bitquant.conf"
. $HOME/bitquant.conf
fi
cd $SCRIPT_DIR
. ../web/scripts/norootcheck.sh

pushd ../../OG-Tools/corporate-parent > /dev/null
mvn install
popd

pushd ../../OG-Platform  > /dev/null
#mvn install -Dmaven.test.skip=True
for project in projects/OG-Master examples/examples-simulated ; do
echo "Building $project"
pushd $project > /dev/null
mvn install -Dmaven.test.skip=True
popd > /dev/null
done
pushd examples/examples-simulated > /dev/null
mvn opengamma:server-init -DclassName=com.opengamma.examples.simulated.tool.ExampleDatabaseInit  -DconfigFile=classpath:/toolcontext/toolcontext-examplessimulated.properties
popd > /dev/null
popd > /dev/null

if [ -n "$OG_COMPILE_PLATFORM_NATIVE" ]; then
pushd ../../OG-Tools/corporate-parent > /dev/null
mvn install
popd > /dev/null

source $SCRIPT_DIR/rebuild-oglang.sh
fi

