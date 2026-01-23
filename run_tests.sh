#! /bin/bash

for test in *_test.c; do
    echo "Running ${test%.*}"
    make ${test%.*}
    ./${test%.*}
done
