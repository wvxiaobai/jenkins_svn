#!/usr/bin/sh
#set -v
echo $WORKSPACE
echo $JENKINS_HOME

#进去工作区
cd $WORKSPACE
cd ../
workspace=$(pwd)

cd $WORKSPACE
local_file=$(pwd)
echo $local_file
echo $JOB_NAME

#建立log工作目录
local_file_w=$(pwd)

if [ ! -d log ]; then
	mkdir log
fi

cd log
local_file_log=$(pwd)

#建立打包工作目录
if [ ! -d dist ]; then
	mkdir dist
fi

last_vsersion=0
if [ -f "svn.txt" ]; then
	#是否存在上次更新
	last_vsersion=$(cat svn.txt | awk '{print $0}')
	echo $last_vsersion
	echo $SVN_REVISION
	if [ $SVN_REVISION -eq $last_vsersion ]; then
		#svn没有更新，执行上次构建
		if [ -f "svn.txt" ]; then
			last_vsersion=$(cat svn_last.txt | awk '{print $0}')
			echo $last_vsersion
		fi
	fi

	if [ $last_vsersion ]; then

		#建立工作子目录
		if [ ! -d $last_vsersion ]; then
			mkdir $last_vsersion
		else
			mv $last_vsersion $last_vsersion"_"${BUILD_NUMBER}
			mkdir $last_vsersion
		fi
		cd $last_vsersion

		if [ ! -d svn ]; then
			mkdir svn
		fi

		local_file_v=$(pwd)
		echo "解析"$last_vsersion"版本文件开始>>>>>>>>>>>>>>"

		svn_url_tmp=$SVN_URL
		echo ${svn_url_tmp//[ ]/%20}
		svn_url_tmp=${svn_url_tmp//[ ]/%20}
		svn diff -r $last_vsersion:HEAD --summarize $svn_url_tmp --username wangw --password mnLE8h10 --no-auth-cache >$local_file_v/svn_log.txt

		rm svn_cp.sh -f
		rm ./svn/svn_rm.sh -f
		touch ./svn/svn_rm.sh
		php $workspace/svn.php $local_file_v $local_file

		echo "解析"$last_vsersion"版本文件结束>>>>>>>>>>>>>>"

		if [ -f "svn_cp.sh" ]; then
			echo "执行"$last_vsersion"解析命令开始>>>>>>>>>>>>>>"
			cat svn_cp.sh | while read line; do
				echo "File:${line}"
				${line}
			done

			#svn_cp.sh
			echo "执行"$last_vsersion"解析命令结束>>>>>>>>>>>>>>"

			echo "执行"$last_vsersion"打包命令开始>>>>>>>>>>>>>>"
			cd svn
			tar -czf $JOB_NAME.${BUILD_NUMBER}.${SVN_REVISION}.tar.gz *
			mv $JOB_NAME.${BUILD_NUMBER}.${SVN_REVISION}.tar.gz ../../dist/
			echo "执行"$last_vsersion"打包命令结束>>>>>>>>>>>>>>"
		fi

	fi

else

	echo "第一次更新所有文件都要打包>>>>>>>>>>>>>>"
	#last_vsersion=$SVN_REVISION
	#cd $WORKSPACE
	#rm svn_rm.sh  -f
	#touch svn_rm.sh
	#tar -czf $JOB_NAME.${BUILD_NUMBER}.${SVN_REVISION}.tar.gz --exclude=log *
	#mv  $JOB_NAME.${BUILD_NUMBER}.${SVN_REVISION}.tar.gz log/dist/
fi

cd $local_file_log
#标记上次更新
echo $SVN_REVISION
if [ $last_vsersion -eq 0 ]; then
	last_vsersion=$SVN_REVISION
fi
echo $last_vsersion
echo $SVN_REVISION >svn.txt
echo $last_vsersion >svn_last.txt

cd $WORKSPACE
