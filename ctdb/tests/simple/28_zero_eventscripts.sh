#!/bin/bash

test_info()
{
    cat <<EOF
Check that CTDB operated correctly if there are 0 event scripts

This test only does anything with local daemons.  On a real cluster it
has no way of updating configuration.
EOF
}

. "${TEST_SCRIPTS_DIR}/integration.bash"

ctdb_test_init "$@"

set -e

cluster_is_healthy

if [ -z "$TEST_LOCAL_DAEMONS" ] ; then
	echo "SKIPPING this test - only runs against local daemons"
	exit 0
fi

# Reset configuration
ctdb_restart_when_done

daemons_stop

echo "Starting CTDB with an empty eventscript directory..."
empty_dir=$(mktemp -d --tmpdir="$TEST_VAR_DIR")
ctdb_test_exit_hook_add "rmdir $empty_dir"
CTDB_EVENT_SCRIPT_DIR="$empty_dir" daemons_start

wait_until_ready

# If this fails to find processes then the tests fails, so look at
# full command-line so this will work with valgrind.  Note that the
# output could be generated with pgrep's -a option but it doesn't
# exist in older versions.
ps -p $(pgrep -f '\<ctdbd\>' | xargs | sed -e 's| |,|g') -o args ww

echo
echo "Good, that seems to work!"
