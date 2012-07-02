#!/bin/sh

tmp=`mktemp /tmp/csvtools_test_XXXXX`
tmpdir=`mktemp -d /tmp/csvtools_test_dir_XXXX`

function assertEquals() {
    if [ "$1" != "$2" ] ; then
        msg="$3: '$1' != '$2'"
        if [ "$4" ] ; then
            msg="$msg: $4"
        fi
        echo "$msg"
    fi
}

function assertFileEquals() {
    assertEquals "`cat "$1" | sort`" "`cat "$2" | sort`" "$3"
}

function assertFile1stLineEquals() {
    assertEquals "`head -n 1 "$1"`" "`head -n 1 "$2"`" "$3"
}

function assertFileBut1stLineEquals() {
    assertEquals "`tail -n +2 "$1" | sort`" \
                 "`tail -n +2 "$2" | sort`" \
                 "$3"
}

../aggregate --by=Date,Hour --fact=DataTransfer < test.csv > "$tmp"
assertFile1stLineEquals    test_aggregate_1_expected.csv "$tmp" \
                           "aggregate --by" "wrong columns"
assertFileBut1stLineEquals test_aggregate_1_expected.csv "$tmp" \
                           "aggregate --by" "wrong result"

../aggregate --by-all-except=Date,Hour --input-file=test.csv > "$tmp"
assertFile1stLineEquals    test_aggregate_2_expected.csv "$tmp" \
                           "aggregate --by-all-except""wrong columns"
assertFileBut1stLineEquals test_aggregate_2_expected.csv "$tmp" \
                           "aggregate --by-all-except" "wrong result"

../clean_mapping "Browser" test_browser.csv "Browser" < test.csv > "$tmp"
assertFile1stLineEquals    test.csv "$tmp" "clean mapping" "wrong columns"
assertFileBut1stLineEquals test_clean_mapping_expected.csv "$tmp" \
                           "clean mapping" "wrong result"
../clean_mapping "Browser" test_browser.csv "Browser" test.csv > "$tmp"
assertFile1stLineEquals    test.csv "$tmp" "wrong columns"
assertFileBut1stLineEquals test_clean_mapping_expected.csv "$tmp" \
                           "clean mapping" "wrong result"
../check_mapping "Browser" test_browser.csv "Browser" < test.csv > "$tmp"
assertFileEquals test_check_mapping_expected.csv "$tmp" "check_mapping"

../list_headers test.csv > "$tmp"
assertFileEquals test_list_headers_expected.csv "$tmp" "list_headers file argument"
../list_headers < test.csv > "$tmp"
assertFileEquals test_list_headers_expected.csv "$tmp" "list_headers stdin"

../surrogate --keep-header --input-file=test_browser.csv --output-dir="$tmpdir" \
    dim_browser > "$tmp"
assertFileEquals test_surrogate_browser_result.csv "$tmp" "surrogate simple - result"
assertFileEquals test_surrogate_dim_browser_result.csv "$tmpdir"/dim_browser.csv \
    "surrogate simple - created lookup"
../surrogate --keep-header --input-file=test.csv --output-dir="$tmpdir" \
    --input-lookups-dir="$tmpdir" \
    KEEP dim_browser UNUSED.date UNUSED.hour > "$tmp"
assertFileEquals test_surrogate_test_result.csv "$tmp" "surrogate complex - result"
assertFileEquals test_surrogate_dim_browser_result2.csv "$tmpdir"/dim_browser.csv \
    "surrogate complex - updated lookup"

rm -f "$tmp"
rm -f "$tmpdir"/*
rmdir "$tmpdir"
