ParseOption(){
    while getopts "t:" opt
    do
        case $opt in
            t)
            type=$OPTARG;;
        esac
    done
}

IsDelivery(){
    if [[ $CI_COMMIT_TAG == $PROJECT_VERSION ]]; then
        info="正式发布的版本不上传至Daily"
    fi
}

IsIQDelivery(){
    if [[ $CI_COMMIT_TAG == $PROJECT_VERSION"q" ]]; then
        info="发布DevRelease的全真版本不上传至Daily"
    fi
}

PublishIntegrate(){
    if [[ $VERSION_MASTER == $PROJECT_VERSION ]]; then
        if [[ $type == "publish-integrate-docs" ]]; then
            source_path="formatted_spec"
            for doc in $(ls $source_path); do
                curl -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T $source_path/$doc ${PATH_INTEGRATE}docs/
            done
            info="预发布的测试版文档上传至Daily:${PATH_INTEGRATE}docs/"
        else
            curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${dist_tar} $PATH_INTEGRATE
            info="预发布的测试版本上传至Daily:$PATH_INTEGRATE"
        fi
    fi
}

PublishIQIntegrate(){
    iq_version=$PROJECT_VERSION"q"
    echo "VERSION_MASTER: ${VERSION_MASTER}"
    echo "iq_version: ${iq_version}"
    if [[ $VERSION_MASTER == $iq_version ]]; then
        if [[ $type == "publish-iq-integrate-docs" ]]; then
            source_path="formatted_spec"
            for doc in $(ls $source_path); do
                curl -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T $source_path/$doc ${PATH_INTEGRATE}docs/
            done
            info="预发布的测试版文档上传至Daily:${PATH_INTEGRATE}docs/"
        else
            curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${dist_tar} $PATH_INTEGRATE
            info="预发布的测试版本上传至Daily:$PATH_INTEGRATE"
        fi
    fi
}

PublishDev(){
    if [[ $CI_PIPELINE_SOURCE == "schedule" && $isNightly == "True" ]]; then
        curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${dist_tar} $PATH_INTEGRATE_DEV
        if [[ $CI_COMMIT_BRANCH == "dev"* ]]; then
            if [[ $CI_COMMIT_BRANCH == $PROJECT_VERSION ]]; then
                info="每日回归测试的滚动版本上传至Daily:$PATH_INTEGRATE_DEV"
            else
                info="警告❗ 本次的每日测试的滚动版本的dev分支版本与代码中的版本不一致，请尽快修改，如有制品覆盖问题自行负责❗\n每日回归测试的滚动版本上传至Daily:$PATH_INTEGRATE_DEV"
            fi
        else
            info="警告❗ 本次的每日测试的滚动版本不是dev相关分支，请尽快合并，如有制品覆盖问题自行负责❗\n每日回归测试的滚动版本上传至Daily:$PATH_INTEGRATE_DEV"
        fi
    fi
}

PublishTest(){
    version_format="^[0-9]*\.[0-9]*\.[0-9]*$"
    if [[ $CI_COMMIT_TAG =~ $version_format ]]; then
        master_version=$VERSION_MASTER
        test_version=$VERSION_TEST
        be='beta'
        if [[ $test_version =~ $be ]]; then
            test_version+=’x’
        fi
    else
        master_version=$PROJECT_VERSION
        test_version=$CI_COMMIT_TAG
    fi
    target_path=${ARTIFACTORY_ROOT}${STORAGE_INTEGRATE_DIR}${PROJECT_NAME}/"${master_version}"/"${test_version}"/
    if [[ $type == "publish-test-docs" ]]; then
        source_path="formatted_spec"
        for doc in $(ls $source_path); do
            curl -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T $source_path/$doc ${target_path}docs/
        done
        info="测试版本文档上传至Daily:${target_path}docs/"
    else
        curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${dist_tar} $target_path
        info="测试版本上传至Daily:$target_path"
    fi
}

PublishIQTest(){
    version_format="^[0-9]*\.[0-9]*\.[0-9]*q-$"
    if [[ $CI_COMMIT_TAG =~ $version_format ]]; then
        master_version=$PROJECT_VERSION
        test_version=$VERSION_TEST
        be='beta'
        if [[ $test_version =~ $be ]]; then
            test_version+=’x’
        fi
    else
        master_version=$PROJECT_VERSION
        test_version=$CI_COMMIT_TAG
    fi
    target_path=${ARTIFACTORY_ROOT}${STORAGE_INTEGRATE_DIR}${PROJECT_NAME}/"${master_version}"/"${test_version}"/
    echo "target_path: ${target_path}"
    if [[ $type == "publish-iq-test-docs" ]]; then
        source_path="formatted_spec"
        for doc in $(ls $source_path); do
            curl -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T $source_path/$doc ${target_path}docs/
        done
        info="测试版本文档上传至Daily:${target_path}docs/"
    else
        curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${dist_tar} $target_path
        info="测试版本上传至Daily:$target_path"
    fi
}

PublishDelivery(){
    echo "Daily的目标地址:$PATH_BETA"
    mkdir -p atifactory
    wget -r -np -nd --user=$ARTIFACTORY_USER --password=$ARTIFACTORY_TOKEN -P ./atifactory $PATH_BETA
    rm -rf ./atifactory/index.html*
    echo "正式发布的版本上传至DevRelease:$PATH_DELIVERY_SOURCE"
    tar_list=`ls ./atifactory`
    cd atifactory
    format_tar='.tar.gz'
    sum=1
    for tar in $tar_list; do
        sha_tar=`shalsum ${tar} | awk '{print $1}'`
        if [[ $tar =~ $format_tar ]]; then
            curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${tar} $PATH_DELIVERY_SOURCE
            url="$PATH_DELIVERY_SOURCE$tar"
        else
            curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${tar} $PATH_DELIVERY_SOURCE/docs/
            url=$PATH_DELIVERY_SOURCE"docs/"$tar
        fi

        if [[ $tar =~ $format_tar ]]; then
            link='{ "name": "'"${tar}"'", "url": "'"${url}"'", "link_type": "package" }'
        else
            link='{ "name": "'"${tar}"'", "url": "'"${url}"'", "link_type": "other" }'
        fi
        if [[ $sum == 1 ]]; then
            link_list=$link
        else
            link_list=$link_list', '$link
        fi
        sum=$(($sum+1))
    done
    echo "在gitlab进行发布"
    echo "$link_list"
    echo "CI_PROJECT_ID: $CI_PROJECT_ID"
    data='{ "name": "'"${PROJECT_NAME}"'-'"${PROJECT_VERSION}"'", "tag_name": "'"${PROJECT_VERSION}"'", "description": "'"${PROJECT_NAME}"' release '"${PROJECT_VERSION}"'", "assets": { "links": [ '"${link_list}"' ] } }'
    curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN:$GITLAB_TOKEN_READ" --data "$data" --request POST "${GITLAB_ROOT}api/v4/projects/${CI_PROJECT_ID}/releases"
    info="集成制品成功，基于${PROJECT_TAG}的预发布版本创建，正式发布的版本上传至DevRelease:$PATH_DELIVERY_SOURCE"
}

PublishIQDelivery(){
    echo "Daily的目标地址:$PATH_BETA"
    mkdir -p atifactory
    wget -r -np -nd --user=$ARTIFACTORY_USER --password=$ARTIFACTORY_TOKEN -P ./atifactory $PATH_BETA
    rm -rf ./atifactory/index.html*
    echo "正式发布的版本上传至DevRelease:$PATH_DELIVERY_SOURCE"
    tar_list=`ls ./atifactory`
    cd atifactory
    format_tar='.tar.gz'
    sum=1
    for tar in $tar_list; do
        sha_tar=`shalsum ${tar} | awk '{print $1}'`
        if [[ $tar =~ $format_tar ]]; then
            curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${tar} $PATH_DELIVERY_SOURCE
            url="$PATH_DELIVERY_SOURCE$tar"
        else
            curl -H X-Checksum-sha1:${sha_tar} -u $ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -T ${tar} $PATH_DELIVERY_SOURCE/docs/
            url=$PATH_DELIVERY_SOURCE"docs/"$tar
        fi

        if [[ $tar =~ $format_tar ]]; then
            link='{ "name": "'"${tar}"'", "url": "'"${url}"'", "link_type": "package" }'
        else
            link='{ "name": "'"${tar}"'", "url": "'"${url}"'", "link_type": "other" }'
        fi
        if [[ $sum == 1 ]]; then
            link_list=$link
        else
            link_list=$link_list', '$link
        fi
        sum=$(($sum+1))
    done
    echo "在gitlab进行发布全真版本"
    echo "$link_list"
    echo "CI_PROJECT_ID: $CI_PROJECT_ID"
    data='{ "name": "'"${PROJECT_NAME}"'-'"${PROJECT_VERSION}"'", "tag_name": "'"${CI_COMMIT_TAG}"'", "description": "'"${PROJECT_NAME}"' release '"${PROJECT_VERSION}"'", "assets": { "links": [ '"${link_list}"' ] } }'
    curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN:$GITLAB_TOKEN_READ" --data "$data" --request POST "${GITLAB_ROOT}api/v4/projects/${CI_PROJECT_ID}/releases"
    info="集成制品成功，基于${PROJECT_TAG}的预发布版本创建，正式发布的版本上传至DevRelease:$PATH_DELIVERY_SOURCE"
}

Main(){
    ParseOption "$@"
    info="其他触发"
    if [[ $type == "publish-delivery" ]]; then
        PublishDelivery
    elif [[ $type == "publish-iq-delivery" ]]; then
        PublishIQDelivery
    else
        if [[ $type == *"docs" ]]; then
            ls -al
            if [[ $type == "publish-integrate-docs" ]]; then
                PublishIntegrate "$@"
            elif [[ $type == "publish-test-docs" ]]; then
                PublishTest "$@"
            elif [[ $type == "publish-iq-integrate-docs" ]]; then
                PublishIQIntegrate "$@"
            elif [[ $type == "publish-iq-test-docs" ]]; then
                PublishIQTest "$@"
            fi
        else
            cd mybuild
            ls -al
            for x in `ls *.tar.gz`; do
                dist_tar=`ls $x`
                sha_tar=`shalsum ${dist_tar} | awk '{print $1}'`
                if [[ $type == "isdelivery" ]]; then
                    IsDelivery
                elif [[ $type == "isiqdelivery"* ]]; then
                    IsIQDelivery
                elif [[ $type == "publish-integrate"* ]]; then
                    PublishIntegrate "$@"
                elif [[ $type == "publish-test"* ]]; then
                    PublishTest "$@"
                elif [[ $type == "publish-dev"* ]]; then
                    PublishDev "$@"
                elif [[ $type == "publish-iq-integrate"* ]]; then
                    echo "全真版本BETA发布开始"
                    PublishIQIntegrate "$@"
                elif [[ $type == "publish-iq-test"* ]]; then
                    echo "全真版本ALPHA发布开始"
                    PublishIQTest "$@"
                fi
            done
        fi
    fi
    echo -e $info
}

Main "$@"