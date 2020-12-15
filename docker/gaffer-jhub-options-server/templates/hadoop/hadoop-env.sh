# export HADOOP_HEAPSIZE_MAX=
# export HADOOP_HEAPSIZE_MIN=
export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true"
export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}
export HADOOP_OPTIONAL_TOOLS="hadoop-aws"
