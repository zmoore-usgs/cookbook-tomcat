
# This script is sourced by $CATALINA_HOME/bin/tomcat right before the daemon
# is started. The file is also sourced when "/opt/tomcat/bin/tomcat version" is
# run. While it can be used to make any change to the daemon's startup
# arguments, or even the daemon itself, care should be taken not to break
# things. Most changes should go in catalinaopts.sh. The following comments
# show default variable contents.

#				--dekester

# export INSTANCE_NAME="${name}"
# export CWD="$(pwd)"
# export CATALINA_HOME="/opt/tomcat"
# export CATALINA_BASE="$CATALINA_HOME/instance/$name"
# export CATALINA_CLASSPATH=""
# export JAVA_ENDORSED_DIRS="$CATALINA_BASE/endorsed:$CATALINA_HOME/endorsed"
# export JSVC_OUTPUT_OPTS="-outfile $CATALINA_BASE/logs/catalina.out -errfile &1"
# export JSVC_OPTS=" -server \
#                -cwd ${CWD} \
#                -wait 20 \
#                -procname tomcat_${INSTANCE_NAME} \
#                -classpath ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/commons-daemon.jar:${CATALINA_BASE}/bin/tomcat-juli.jar:${CATALINA_CLASSPATH} \
#                -Dcatalina.home=${CATALINA_HOME} \
#                -Dcatalina.base=${CATALINA_BASE} \
#                -Djava.endorsed.dirs=${JAVA_ENDORSED_DIRS} \
#                -Djava.io.tmpdir=${CATALINA_BASE}/temp \
#                -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
#                -Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties"

# export JAVA_HOME="/usr/java/default"

# Please don't change the next three lines.
CATALINA_OPTS="" # Default to empty string
source $CATALINA_BASE/bin/catalinaopts.sh
export CATALINA_OPTS

# export JSVC="${CATALINA_HOME}/bin/jsvc"
