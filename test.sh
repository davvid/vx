#!/bin/sh
# make "vx" available; sharness chdirs into a subdirectory.
PATH="$PWD":"$PATH"
export PATH

test_description='vx test suite'

# sharness git://github.com/chriscool/sharness.git
. ./lib-sharness/sharness.sh


test_expect_success 'setup' '
	mkdir -p dist/bin &&
	cat >dist/bin/vx-test-script <<-\EOF &&
		#!/bin/sh
		echo "$1"
		if test -n "$2"
		then
			exit $2
		else
			exit 0
		fi
	EOF
	chmod +x dist/bin/vx-test-script
'

test_expect_success 'vx-test-script echo its inputs' '
	echo echo >expect &&
	./dist/bin/vx-test-script echo >actual &&
	test_cmp expect actual
'

test_expect_success 'vx activates plain ole directories' '
	echo activated >expect &&
	vx dist vx-test-script activated >actual &&
	test_cmp expect actual
'

test_expect_success 'vx preserves exit codes' '
	test_expect_code 42 vx dist vx-test-script code 42
'

test_expect_success 'vx does not accepts files' '
	test_expect_code 1 vx dist/bin/vx-test-script true
'

test_expect_success 'vx notices when the directory does not exist' '
	test_expect_code 1 vx notices-this-does-not-exist true
'

test_done
