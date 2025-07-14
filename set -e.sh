set -e
cd $src
source $env

finish_true() {
    echo "true" > /tmp/$1
}

finish_false() {
    echo "false" > /tmp/$1
}

# rule-before-integrate
rule_before_integrate() {
    if [[ -n $CI_COMMIT_BRANCH ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-tags-permit-scan
rule_tags_permit_scan() {
    if [[ -n $CI_COMMIT_BRANCH ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-cppcheck-scan
rule_cppcheck_scan() {
    if [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc$') ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-x86-clang-tidy-scan
rule_x86_clang_tidy_scan() {
    if [[ $IMAGE_LIST =~ "x86" ]] && [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc$') ]]
    then
    finish_true $FUNCNAME
    echo "rule_x86_clang_tidy_scan is true 1"
    return
    fi

    if [[ $IMAGE_LIST =~ "x86" ]] && [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    echo "rule_x86_clang_tidy_scan is true 2"
    return
    fi
    echo "rule_x86_clang_tidy_scan is false"
    finish_false $FUNCNAME
}

# rule-arm-clang-tidy-scan
rule_arm_clang_tidy_scan() {
    if [[ $IMAGE_LIST =~ "arm" ]] && [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc$') ]]
    then
    finish_true $FUNCNAME
    echo "rule_arm_clang_tidy_scan is true 1"
    return
    fi

    if [[ $IMAGE_LIST =~ "arm" ]] && [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    echo "rule_arm_clang_tidy_scan is true 2"
    return
    fi
    echo "rule_arm_clang_tidy_scan is false"
    finish_false $FUNCNAME
}

# rule-rhel7.9-test
rule_rhel79_test() {
    if [[ $IMAGE_LIST =~ "rhel7.9" ]] && [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^app_home/|^src/|^test/|^include/|^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc|^CMakeLists\.txt$') ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ $IMAGE_LIST =~ "rhel7.9" ]] && [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-rhel8.6-test
rule_rhel86_test() {
    if [[ $IMAGE_LIST =~ "rhel8.6" ]] && [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^app_home/|^src/|^test/|^include/|^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc|^CMakeLists\.txt$') ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ $IMAGE_LIST =~ "rhel8.6" ]] && [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-rhel8.3-test
rule_rhel83_test() {
    if [[ $IMAGE_LIST =~ "rhel8.3" ]] && [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^app_home/|^src/|^test/|^include/|^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc|^CMakeLists\.txt$') ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ $IMAGE_LIST =~ "rhel8.3" ]] && [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-x86-kylin-v7-test
rule_x86_kylin_v7_test() {
    if [[ $IMAGE_LIST =~ "x86-kylin-v7" ]] && [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^app_home/|^src/|^test/|^include/|^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc|^CMakeLists\.txt$') ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ $IMAGE_LIST =~ "x86-kylin-v7" ]] && [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-x86-coverage
rule_x86_coverage() {
    if [[ $IMAGE_LIST =~ "x86" ]] && [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc$') ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ $IMAGE_LIST =~ "x86" ]] && [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-rhel8.10-test
rule_rhel810_test() {
    if [[ $IMAGE_LIST =~ "rhel8.10" ]] && [[ -n $CI_COMMIT_BRANCH ]] && [[ $(git diff --name-only HEAD^..HEAD | grep -E '^app_home/|^src/|^test/|^include/|^.*\.cpp|^.*\.hpp|^.*\.c|^.*\.h|^.*\.cc|^CMakeLists\.txt$') ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ $IMAGE_LIST =~ "rhel8.10" ]] && [[ -n $CI_COMMIT_TAG ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# rule-rhel8.10-integrate
rule_rhel810_integrate() {
    if [[ -n $CI_COMMIT_TAG ]] && [[ $IMAGE_LIST =~ "rhel8.10" ]] && [[ $CI_COMMIT_TAG =~ ^([0-9]+\.){2}[0-9]+$ ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ -n $CI_COMMIT_TAG ]] && [[ $IMAGE_LIST =~ "rhel8.10" ]] && [[ $CI_COMMIT_TAG =~ ^([0-9]+\.){2}[0-9]+\-+ ]]
    then
    finish_true $FUNCNAME
    return
    fi

    if [[ $CI_PIPELINE_SOURCE == "schedule" ]] && [[ $IMAGE_LIST =~ "rhel8.10" ]]
    then
    finish_true $FUNCNAME
    return
    fi

    finish_false $FUNCNAME
}

# 以下为最后一张图中列出的规则（仅函数声明，无具体逻辑，按图中原样保留）
rule_rhel810_test
rule_rhel810_integrate

rule_before_integrate
rule_tags_permit_scan
rule_cppcheck_scan
rule_x86_clang_tidy_scan
rule_arm_clang_tidy_scan
rule_rhel79_test
rule_rhel86_test
rule_rhel83_test
rule_x86_kylin_v7_test
rule_x86_coverage
rule_arm_kylin_coverage
rule_kylin_v10_test
rule_arm_clang_test
rule_rhel79_integrate
rule_rhel86_integrate
rule_rhel83_integrate
rule_x86_kylin_v7_integrate
rule_kylin_v10_integrate
rule_spec_format
rule_code_docs
rule_delivery
rule_tag_stop