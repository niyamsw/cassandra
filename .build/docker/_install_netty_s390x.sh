#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

[ "x" != "x${CASSANDRA_DIR:-}" ] || { echo "CASSANDRA_DIR must be defined"; exit 1; }
[ "x" != "x${DIST_DIR:-}" ] || { echo "DIST_DIR must be defined"; exit 1; }

if ! command -v dpkg >/dev/null 2>&1 || [ "$(dpkg --print-architecture)" != "s390x" ]; then
    exit 0
fi

netty_stage_dir="/opt/netty-s390x"
[ -d "${netty_stage_dir}" ] || exit 0

# The working s390x combination is the Java wrapper jar plus the native boringssl jar.
netty_jars=(
    netty-tcnative-classes-2.0.70.Final.jar
    netty-tcnative-boringssl-static-2.0.70.Final-linux-s390_64.jar
)

for jar in "${netty_jars[@]}"; do
    [ -f "${netty_stage_dir}/${jar}" ] || exit 0
done

for target_dir in "${CASSANDRA_DIR}/lib" "${DIST_DIR}/lib/jars"; do
    mkdir -p "${target_dir}"
    rm -f "${target_dir}"/netty-tcnative*.jar

    for jar in "${netty_jars[@]}"; do
        cp -f "${netty_stage_dir}/${jar}" "${target_dir}/${jar}"
    done
done
