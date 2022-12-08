Window 平台：
* 装好WSL
* 在仓库最外层 进入WSL
* 运行 `sudo scripts/build-binaries.sh`
* 如果有luarock 环境问题，就先把环境问题处理
* 去build/bin/luacheck.exe 拿出来用就行

# 已知的坑
* 在stage.run运行前后不能用作用域为整个文件的local变量记录状态，因为Build完之后会有并行检测的设定
