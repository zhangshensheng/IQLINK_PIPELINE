#!/bin/bash
#set -x
# CI_COMMIT_TAG=1.0.0-alpha1
# CI_COMMIT_BRANCH=1.0.0-alpha1
GIT_DIFF=$(git diff --name-only HEAD^..HEAD | grep -E '^.*\.(cpp|hpp|c|h|cc)$')
GIT_DIFF_TEST=$(git diff --name-only HEAD^..HEAD | grep -E '^(app_home/|src/|test/|include/|.*\.(cpp|hpp|c|h|cc)|CMakeLists\.txt)$')
# GIT_DIFF=cpp
# GIT_DIFF_TEST=cpp
IMAGE_LIST_STR="arm-kylin-v10sp1 rhel7.9"
IFS=' ' read -r -a IMAGE_LIST <<<"$IMAGE_LIST_STR"
#IMAGE_LIST=($IMAGE_LIST_STR)
echo "制作镜像版本: ${IMAGE_LIST[*]}"
PARA_FILES="rule_before_integrate
rule_tags_permit_scan
rule_cppcheck_scan
rule_x86_clang_tidy_scan
rule_arm_clang_tidy_scan
rule_x86_coverage
rule_arm_kylin_coverage
rule_spec_format
rule_code_docs
rule_rhel7.9_test
rule_rhel8.3_test
rule_rhel8.6_test
rule_rhel8.10_test
rule_rhel7.9_integrate
rule_rhel8.3_integrate
rule_rhel8.6_integrate
rule_rhel8.10_integrate
rule_x86_kylin_v7_test
rule_x86_kylin_v10sp1_test
rule_x86_kylin_v10sp3_test
rule_x86_kylin_v7_integrate
rule_x86_kylin_v10sp1_integrate
rule_x86_kylin_v10sp3_integrate
rule_arm_kylin_v10sp1_test
rule_arm_kylin_v10sp3_test
rule_arm_kylin_v10sp1_integrate
rule_arm_kylin_v10sp3_integrate"

IFS=$'\n' read -r -d '' -a PARA_FILES_LIST <<<"$PARA_FILES"


function check_rule_lint() {
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

function check_rule_test() {
  if ([[ -n $CI_COMMIT_BRANCH ]] && [[ -n $GIT_DIFF_TEST ]]) || [[ -n $CI_COMMIT_TAG ]]; then
    for image in "${IMAGE_LIST[@]}"; do
      case "$image" in
      "rhel7.9")
        echo "true" >/tmp/rule_rhel7.9_test
        ;;
      "rhel8.3")
        echo "true" >/tmp/rule_rhel8.3_test
        ;;
      "rhel8.6")
        echo "true" >/tmp/rule_rhel8.6_test
        ;;
      "rhel8.10")
        echo "true" >/tmp/rule_rhel8.10_test
        ;;
      "x86-kylin-v7")
        echo "true" >/tmp/rule_x86_kylin_v7_test
        ;;
      "x86-kylin-v10sp1")
        echo "true" >/tmp/rule_x86_kylin_v10sp1_test
        ;;
      "x86-kylin-v10sp3")
        echo "true" >/tmp/rule_x86_kylin_v10sp3_test
        ;;
      "arm-kylin-v10sp1")
        echo "true" >/tmp/rule_arm_kylin_v10sp1_test
        ;;
      "arm-kylin-v10sp3")
        echo "true" >/tmp/rule_arm_kylin_v10sp3_test
        ;;
      *)
        echo "检测到未知镜像: $image，不执行特定操作"
        ;;
      esac
    done
  fi
}

function check_rule_release() {
  if [[ $CI_COMMIT_TAG =~ ^([0-9]+\.[0-9]+\.[0-9]+)-.+ ]] || [[ $CI_COMMIT_TAG =~ ^([0-9]+\.[0-9]+\.[0-9]+q)-.+ ]] || [[ $CI_PIPELINE_SOURCE =~ schedule ]]; then
    for image in "${IMAGE_LIST[@]}"; do
      case "$image" in
      "rhel7.9")
        echo "true" >/tmp/rule_rhel7.9_integrate
        ;;
      "rhel8.3")
        echo "true" >/tmp/rule_rhel8.3_integrate
        ;;
      "rhel8.6")
        echo "true" >/tmp/rule_rhel8.6_integrate
        ;;
      "rhel8.10")
        echo "true" >/tmp/rule_rhel8.10_integrate
        ;;
      "x86-kylin-v7")
        echo "true" >/tmp/rule_x86_kylin_v7_integrate
        ;;
      "x86-kylin-v10sp1")
        echo "true" >/tmp/rule_x86_kylin_v10sp1_integrate
        ;;
      "x86-kylin-v10sp3")
        echo "true" >/tmp/rule_x86_kylin_v10sp3_integrate
        ;;
      "arm-kylin-v10sp1")
        echo "true" >/tmp/rule_arm_kylin_v10sp1_integrate
        ;;
      "arm-kylin-v10sp3")
        echo "true" >/tmp/rule_arm_kylin_v10sp3_integrate
        ;;
      *)
        echo "检测到未知镜像: $image，不执行特定操作"
        ;;
      esac
    done
  fi
}

main() {
set -e
cd $src
source $env
echo "触发TAG/分支：$CI_COMMIT_TAG $CI_COMMIT_BRANCH"
echo "文件变动涉及：$GIT_DIFF_TEST $GIT_DIFF"
echo "创建参数文件默认赋值为FALSE:"
for file in ${PARA_FILES[@]}; do
  echo $file
  touch "/tmp/$file" && echo "false" >/tmp/$file # 创建空文件并赋值为false
done
if [[ -n $CI_COMMIT_BRANCH ]] || [[ -n $CI_COMMIT_TAG ]]; then
  echo "true" >/tmp/rule_before_integrate
  echo "true" >/tmp/rule_tags_permit_scan
fi
check_rule_lint
check_rule_test
check_rule_release
}
main