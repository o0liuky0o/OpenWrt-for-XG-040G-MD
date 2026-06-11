#!/bin/bash
# 安装和更新第三方软件包（精简版）
# 此脚本在 openwrt/package/ 目录下运行，在 feeds install 之后执行

UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)
	local REPO_NAME=${PKG_REPO#*/}

	echo " "
	echo "=========================================="
	echo "Processing: $PKG_NAME from $PKG_REPO"
	echo "=========================================="

	for NAME in "${PKG_LIST[@]}"; do
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)
		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not found directory: $NAME"
		fi
	done

	git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git"
	if [ ! -d "$REPO_NAME" ]; then
		echo "ERROR: Failed to clone $PKG_REPO"
		return 1
	fi

	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		rm -rf ./$REPO_NAME/
	elif [[ "$PKG_SPECIAL" == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
	echo "Done: $PKG_NAME"
}

echo "Starting package updates..."

# 删除 feeds 中的 sing-box，避免与 HomeProxy 冲突
rm -rf ../feeds/packages/net/sing-box
rm -rf ../package/feeds/packages/sing-box

# HomeProxy（代理软件）
UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "master"

# Argon 主题
UPDATE_PACKAGE "luci-theme-argon" "jerrykuku/luci-theme-argon" "master"
UPDATE_PACKAGE "luci-app-argon-config" "jerrykuku/luci-app-argon-config" "master"

# 设置 Argon 为默认主题
COLLECTION_MAKEFILES=$(find ../feeds/luci/collections/ -type f -name "Makefile" 2>/dev/null)
if [ -n "$COLLECTION_MAKEFILES" ]; then
	sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" $COLLECTION_MAKEFILES
	echo "Done setting default LuCI theme to argon"
fi

# QuickFile
UPDATE_PACKAGE "quickfile" "sbwml/luci-app-quickfile" "main" "name"

# DDNS-GO
UPDATE_PACKAGE "luci-app-ddns-go" "sbwml/luci-app-ddns-go" "main" "name"

# 定时任务
UPDATE_PACKAGE "luci-app-crontab" "sbwml/luci-app-crontab" "main" "name"

echo " "
echo "=========================================="
echo "Package updates completed!"
echo "=========================================="
