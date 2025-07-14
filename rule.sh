#!/bin/bash

# GIT_DIFF=$(git diff --name-only HEAD^..HEAD | grep -E '^.*\.(cpp|hpp|c|h|cc)$')
# GIT_DIFF_TEST=$(git diff --name-only HEAD^..HEAD | grep -E '^(app_home/|src/|test/|include/|.*\.(cpp|hpp|c|h|cc)|CMakeLists\.txt)$')

GIT_DIFF=cpp
GIT_DIFF_TEST=app
IMAGE_LIST="arm-kylin-v10 rhel8.6"
IMAGE_LIST=($IMAGE_LIST)
PARA_FILES=(
"rule_rhel810_test"
"rule_rhel810_integrate"
"rule_before_integrate"
"rule_tags_permit_scan"
"rule_cppcheck_scan"
"rule_x86_clang_tidy_scan"
"rule_arm_clang_tidy_scan"
"rule_rhel79_test"
"rule_rhel86_test"
"rule_rhel83_test"
"rule_x86_kylin_v7_test"
"rule_x86_coverage"
"rule_arm_kylin_coverage"
"rule_kylin_v10_test"
"rule_arm_clang_test"
"rule_rhel79_integrate"
"rule_rhel86_integrate"
"rule_rhel83_integrate"
"rule_x86_kylin_v7_integrate"
"rule_kylin_v10_integrate"
"rule_spec_format"
"rule_code_docs"
"rule_delivery"
"rule_tag_stop"
)

check_rule_lint() {
  if ([[ -n $CI_COMMIT_BRANCH ]] && [[ -n $GIT_DIFF ]]) || [[ -n $CI_COMMIT_TAG ]]; then
    echo "true" >/tmp/rule_cppcheck_scan
    for image in "${IMAGE_LIST[@]}"; do
      if [[ "$image" =~ x86 ]]; then
        echo "true" >/tmp/rule_x86_clang_tidy_scan
      fi
      if [[ "$image" =~ arm ]]; then
        echo "true" >/tmp/rule_arm_clang_tidy_scan
      fi
    done
  fi
}

check_rule_test() {
  if ([[ -n $CI_COMMIT_BRANCH ]] && [[ -n $GIT_DIFF_TEST ]]) || [[ -n $CI_COMMIT_TAG ]]; then
    echo "有文件变动或者是tag"
    for image in "${IMAGE_LIST[@]}"; do
      case "$image" in
      "rhel7.9")
        echo "true" >/tmp/rule-rhel7.9-test
        ;;
      "rhel8.3")
        echo "true" >/tmp/rule-rhel8.3-test
        ;;
      "rhel8.6")
        echo "true" >/tmp/rule-rhel8.6-test
        ;;
      "rhel8.10")
        echo "true" >/tmp/rule-rhel8.10-test
        ;;
      "x86-kylin-v7")
        echo "true" >/tmp/rule_x86-kylin-v7_test
        ;;
      "x86-kylin-v10sp1")
        echo "true" >/tmp/rule_x86-kylin-v10sp1_test
        ;;
      "x86-kylin-v10sp3")
        echo "true" >/tmp/rule_x86-kylin-v10sp3_test
        ;;
      "arm-kylin-v10sp1")
        echo "true" >/tmp/rule_arm-kylin-v10sp1_test
        ;;
      "arm-kylin-v10sp3")
        echo "true" >/tmp/rule_arm-kylin-v10sp3_test
        ;;
      *)
        echo "检测到未知镜像: $image，不执行特定操作"
        ;;
      esac
    done
  fi
}

check_rule_release() {
  if [[ $CI_COMMIT_TAG =~ ^([0-9]+\.[0-9]+\.[0-9]+)-.+ ]] || [[ $CI_COMMIT_TAG =~ ^([0-9]+\.[0-9]+\.[0-9]+q)-.+ ]] || [[ $CI_PIPELINE_SOURCE =~ schedule ]]; then
    for image in "${IMAGE_LIST[@]}"; do
      case "$image" in
      "rhel7.9")
        echo "true" >/tmp/rule-rhel7.9-release
        ;;
      "rhel8.3")
        echo "true" >/tmp/rule-rhel8.3-release
        ;;
      "rhel8.6")
        echo "true" >/tmp/rule-rhel8.6-release
        ;;
      "rhel8.10")
        echo "true" >/tmp/rule-rhel8.10-release
        ;;
      "x86-kylin-v7")
        echo "true" >/tmp/rule_x86-kylin-v7_release
        ;;
      "x86-kylin-v10")
        echo "true" >/tmp/rule_x86-kylin-v10_release
        ;;
      esac
    done
  fi
}

# 调用生成函数
main() {
  # set -e
  # cd $src
  # source $env
  echo $CI_COMMIT_TAG $CI_COMMIT_BRANCH $GIT_DIFF
  echo "创建参数文件默认赋值为FALSE:"
  for file in $PARA_FILES; do
    touch "/tmp/$file" && echo "false" >/tmp/$file # 创建空文件并赋值为false
  done
  if [[ -n $CI_COMMIT_BRANCH ]] || [[ -n $CI_COMMIT_TAG ]]; then
    echo "true" >/tmp/rule_before_integrage
    echo "true" >/tmp/rule_tags_permit_scan
  fi
  check_rule_lint
  check_rule_test
  check_rule_release
}

main