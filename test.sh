#!/bin/sh
# make "vx" available; sharness chdirs into a subdirectory.
PATH="$PWD":"$PATH"
export PATH
unset PYTHONPATH
unset PYTHON

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

test_expect_success 'vx parses pyvenv.cfg for the python version' '
	mkdir -p env37/lib/python3.7/site-packages &&
	cat >env37/pyvenv.cfg <<-\EOF &&
		version = 3.7.4
	EOF
	echo /env37/lib/python3.7/site-packages >expect &&
	vx env37 sh -c "echo \$PYTHONPATH" |
	sed -e "s#.*/env#/env#" >actual &&
	test_cmp expect actual
'

test_expect_success 'vx finds python2.7 in the absense of pyvenv.cfg' '
	mkdir -p env27/bin &&
	cp -p dist/bin/vx-test-script env27/bin/python2.7 &&
	mkdir -p env27/lib/python2.7/site-packages &&
	echo /env27/lib/python2.7/site-packages >expect &&
	vx env27 sh -c "echo \$PYTHONPATH" | sed -e "s#.*/env#/env#" >actual &&
	test_cmp expect actual
'

test_expect_success 'vx queries PYTHON=customX.Y for site-packages' '
	mkdir -p envXY/bin &&
	mkdir -p envXY/lib/pythonX.Y/site-packages &&
	cat >envXY/bin/customX.Y <<-\EOF &&
		#!/bin/sh
		echo pythonX.Y
	EOF
	chmod +x envXY/bin/customX.Y &&
	echo /envXY/lib/pythonX.Y/site-packages >expect &&
	PYTHON=customX.Y vx envXY sh -c "echo \$PYTHONPATH" |
	sed -e "s#.*/env#/env#" >actual &&
	test_cmp expect actual
'

test_expect_success 'vx finds modules in lib64' '
	mkdir -p env64/lib64/python3.7/site-packages &&
	cat >env64/pyvenv.cfg <<-\EOF &&
		version = 3.7
	EOF
	echo /env64/lib64/python3.7/site-packages >expect &&
	vx env64 sh -c "echo \$PYTHONPATH" |
	sed -e "s#.*/env#/env#" >actual &&
	test_cmp expect actual
'

test_done
