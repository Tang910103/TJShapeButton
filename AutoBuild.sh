
#!/bin/bash -ilex

# 使用方法:
# step1: 将该脚本放在工程的根目录下（跟.xcworkspace文件or .xcodeproj文件同目录）
# step2: 根据情况修改下面的参数
# step3: 打开终端，执行脚本。（输入sh ，然后将脚本文件拉到终端，会生成文件路径，然后enter就可）

# =============项目自定义部分(自定义好下列参数后再执行该脚本)=================== #

# 指定项目的scheme名称（也就是工程的target名称），必填
scheme_name="TJButton"

# method，打包的方式。方式分别为 1.development, 2.ad-hoc, 3.app-store, 4.enterprise 。必填
method=2

# 指定打包编译的模式，如：1.Release, 2.Debug...
build_configuration=1


#  下面两个参数只是在手动指定Pofile文件的时候用到，如果使用Xcode自动管理Profile,直接留空就好
# (跟method对应的)mobileprovision文件名，需要先双击安装.mobileprovision文件.手动管理Profile时必填
mobileprovision_name=""

# 项目的bundleID，手动管理Profile时必填
bundle_identifier=""

#输出错误信息
showError(){
echo "\n\033[31;1m错误：${1}  \033[0m\n"
exit 1
}
showInfo() {
echo "\033[32m${1}  \033[0m"
}

# method 验证,分别为 1.development, 2.ad-hoc, 3.app-store, 4.enterprise 。必填
if [ $method == 1 ]; then
method="development"
elif [ $method == 2 ]; then
method="ad-hoc"
elif [ $method == 3 ]; then
method="app-store"
elif [ $method == 4 ]; then
method="enterprise"
else
showError "你必须选择一个（method）打包方式"
fi

# 检查打包编译的模式，如：1.Release, 2.Debug...
case $build_configuration in
1)  build_configuration="Release"
;;
2)  build_configuration="Debug"
;;
*)  showError "你必须选择一个（build_configuration）编译模式"
;;
esac


# 换行符
__LINE_BREAK_LEFT="\n\033[32;1m*********"
__LINE_BREAK_RIGHT="***************\033[0m\n"
__SLEEP_TIME=0.3

# 获取项目名称
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

# 是否编译工作空间 (例:若是用Cocopods管理的.xcworkspace项目,赋值true;用Xcode默认创建的.xcodeproj,赋值false)
if [ -d ./${project_name%.*}.xcworkspace ] ; then
is_workspace=true
else
is_workspace=false
fi

if [ ${#scheme_name} == 0 ]; then
showError "scheme_name 为必填项"${scheme_name}
fi

echo "\033[33;1m--------------------脚本配置参数检查--------------------"
echo "is_workspace=${is_workspace}"
echo "workspace_name=${project_name}"
echo "project_name=${project_name}"
echo "scheme_name=${scheme_name}"
echo "build_configuration=${build_configuration}"
echo "bundle_identifier=${bundle_identifier}"
echo "method=${method}"
echo "mobileprovision_name=${mobileprovision_name}"
echo "--------------------------------------------------------\033[0m\n"

# =======================脚本的一些固定参数定义(无特殊情况不用修改)====================== #

# 获取当前脚本所在目录
script_dir="$( cd "$( dirname "$0"  )" && pwd  )"
# 工程根目录
project_dir=$script_dir

# 时间
DATE=`date`
# 指定输出导出文件夹路径
export_path="$project_dir/项目"
# 指定输出归档文件路径
export_archive_path="$(cd ~/Library/Developer/Xcode/Archives/ && pwd)/$(DATE '+%Y-%m-%d')/$scheme_name$(DATE '+%Y%m%d%H%M%S').xcarchive"
# 指定输出ipa文件夹路径
export_ipa_path="$export_path/$scheme_name$(DATE '+%Y%m%d%H%M%S')"
# 指定输出ipa名称
ipa_name="${scheme_name}_$(DATE '+%Y%m%d%H%M%S')"
# 指定导出ipa包需要用到的plist配置文件的路径
export_options_plist_path="$project_dir/ExportOptions.plist"

echo "--------------------脚本固定参数检查--------------------"
echo "\033[33;1mproject_dir=${project_dir}"
echo "DATE=${DATE}"
echo "export_path=${export_path}"
echo "export_archive_path=${export_archive_path}"
echo "export_ipa_path=${export_ipa_path}"
echo "export_options_plist_path=${export_options_plist_path}"
echo "ipa_name=${ipa_name} \033[0m"

# =======================自动打包部分(无特殊情况不用修改)====================== #

echo "------------------------------------------------------"
echo "\033[32m开始构建项目  \033[0m"
# 进入项目工程目录
cd ${project_dir}

# 指定输出文件目录存在删除旧文件
if [ -d "$export_path" ] ; then
rm -r -f $export_path
showInfo "删除($export_path)"
fi
# 指定输出ipa文件夹路径不存在c则新建
if [ -d "$export_ipa_path" ] ; then
echo $export_ipa_path
else
mkdir -pv $export_ipa_path
fi

# 判断编译的项目类型是workspace还是project
if $is_workspace ; then
# 编译前清理工程
xcodebuild clean -workspace ${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${build_configuration}

xcodebuild archive -workspace ${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${build_configuration} \
-archivePath ${export_archive_path}
else
# 编译前清理工程
xcodebuild clean -project ${project_name}.xcodeproj \
-scheme ${scheme_name} \
-configuration ${build_configuration}
-alltargets

xcodebuild archive -project ${project_name}.xcodeproj \
-scheme ${scheme_name} \
-configuration ${build_configuration} \
-archivePath ${export_archive_path}
fi

#  检查是否构建成功
#  xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if [ -d "$export_archive_path" ] ; then
echo "\033[32;1m项目构建成功 🚀 🚀 🚀  \033[0m"
else
echo "\033[31;1m项目构建失败 😢 😢 😢  \033[0m"
showError $export_archive_path
exit 1
fi
echo "------------------------------------------------------"

echo "\033[32m开始导出ipa文件 \033[0m"

# 先删除export_options_plist文件
if [ -f "$export_options_plist_path" ] ; then
#echo "${export_options_plist_path}文件存在，进行删除"
rm -f $export_options_plist_path
fi
# 根据参数生成export_options_plist文件
/usr/libexec/PlistBuddy -c  "Add :method String ${method}"  $export_options_plist_path
/usr/libexec/PlistBuddy -c  "Add :compileBitcode Bool false"  $export_options_plist_path
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:"  $export_options_plist_path
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:${bundle_identifier} String ${mobileprovision_name}"  $export_options_plist_path


xcodebuild  -exportArchive \
-archivePath ${export_archive_path} \
-exportPath ${export_ipa_path} \
-exportOptionsPlist ${export_options_plist_path} \
-allowProvisioningUpdates

# 检查ipa文件是否存在
if [ -f "$export_ipa_path/$scheme_name.ipa" ] ; then
echo "\033[32;1mexportArchive ipa包成功,准备进行重命名\033[0m"
else
echo "\033[31;1mexportArchive ipa包失败 😢 😢 😢     \033[0m"
exit 1
fi

# 修改ipa文件名称
mv $export_ipa_path/$scheme_name.ipa $export_ipa_path/$ipa_name.ipa

# 检查文件是否存在
if [ -f "$export_ipa_path/$ipa_name.ipa" ] ; then
#fir上传不一定能成功，可以使用插件
#fir p "$export_ipa_path/$ipa_name.ipa" -T "8062cc5e837fe15ccf97622eea40b654" -Q
#fir login 8062cc5e837fe15ccf97622eea40b654

echo "\033[32;1m导出 ${ipa_name}.ipa 包成功 🎉  🎉  🎉   \033[0m"
#    open $export_path
else
echo "\033[31;1m导出 ${ipa_name}.ipa 包失败 😢 😢 😢     \033[0m"
exit 1
fi

# 删除export_options_plist文件（中间文件）
if [ -f "$export_options_plist_path" ] ; then
showInfo "删除临时文件{export_options_plist_path}"
rm -f $export_options_plist_path
fi
showInfo "导出文件路径：$export_path"
# 输出打包总用时
echo "\033[36;1m使用AutoPackageScript打包总用时: ${SECONDS}s \033[0m"
echo "\n\n"

exit 0
