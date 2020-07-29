`master` 分支用于整合各分支代码，提供方便在 Vivado 中加入源码的 Tcl 脚本（在 `sources` 目录下）。建议其它分支之间不要互相包含、合并源码，以免造成诸如版本不同步之类的问题。

## 源码加入

为了方便自动化加入源码，需要每个分支在自己的源码文件夹下添加一个 `sources.tcl` 的 Tcl 脚本。具体内容可以参考 `cache/sources.tcl` 和 `superscalar_inorder_dual/sources.tcl` 这两个文件。

## 测试流程

当需要进行整体测试时，考虑从 `master` 分支新建一个分支（例如 `superscalar-testing`），然后将你的代码 merge 到该分支上：

```
git checkout master
git checkout -b superscalar-testing
git merge superscalar
```

然后在 `sources` 目录添加或修改对应的 Tcl 脚本。例如，加入一个新的 Tcl 脚本（`sources/superscalar-inorder.tcl`），作用是将 `cache` 的代码和 `superscalar_inorder_dual` 的代码一起加入 Vivado 中：

```
# 文件 "sources/superscalar-inorder.tcl"

# 切换工作目录
cd [file dirname [info script]]

# 加入 cache
source ../cache/sources.tcl
cd [file dirname [info script]]

# 加入 superscalar-inorder
source ../superscalar_inorder_dual/sources.tcl
cd [file dirname [info script]]

# 加入模块 "mycpu_top"
add_files ../cache/src/top/mycpu_top.sv
```

注意 `mycpu_top` 可能存在多个版本，需要根据需求选择正确的版本。

在 Vivado 中打开功能测试或性能测试或系统测试的工程，删除以前的代码。然后点击 “Tools”→“Run Tcl Scripts...”，选择之前写好的 `sources/superscalar-inorder.tcl` 文件，之后如果没有问题就会加入所有需要测试的源码。

测试完成后，将你的改动同步到 `master` 分支上：

```
# 在 superscalar-testing 分支提交改动
git add --all
git commit

# 将改动同步到 master 分支上
git fetch origin
git rebase origin/master
```

如果 rebase 中途发生冲突而失败，请参考 [public-doc](https://github.com/NSCSCC-2020-Fudan/public-doc) 中 “协同开发” 文档中的说明处理冲突。

最后上传改动到 GitHub，同时可以删去临时的测试分支：

```
git push origin master
git branch -d superscalar-testing
```