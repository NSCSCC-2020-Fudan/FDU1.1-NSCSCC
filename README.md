`master` 分支用于整合各分支代码，提供方便在 Vivado 中加入源码的 Tcl 脚本（在 `sources` 目录下）。建议其它分支之间不要互相包含、合并源码，以免造成诸如版本不同步之类的问题。

## 源码加入

为了方便自动化加入源码，需要每个分支在自己的源码文件夹下添加一个 `sources.tcl` 的 Tcl 脚本。具体内容可以参考 `cache/sources.tcl` 和 `superscalar_inorder_dual/sources.tcl` 这两个文件。例如：

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

常用 Tcl 命令：

切换到当前脚本所在的目录：

```
cd [file dirname [info script]]
```

调用另外的脚本：

```
source ../cache/sources.tcl
```

添加文件：

```
add_files ../cache/src/top/mycpu_top.sv
add_files [glob src/*.sv]
```

设置全局 include：

```
set_property is_global_include true [get_files src/xsim/global.svh]
```

## 开发流程

因为队伍人数不多，所以整个仓库只需要一个长期的 master 分支就可以了。开发的过程相当于不断给 master 分支打补丁。基本的操作流程如下：

准备开发前：

* 更新你的本地仓库：

```
git fetch
```

* 从最新的 master 处新建一个分支。例如，如果要增加三级 Fetch，可以新建一个叫做 3-stage-fetch 的分支：

```
git checkout -b 3-stage-fetch origin/master
```

之后就可以开始写代码了。写完代码后尽量先和 master 上已有的代码一起测试后，在更新到 master 分支。测试流程见下一小节。

## 测试流程

记得先更新本地仓库：

```
git fetch
```

当需要进行整体测试时，先将你做的尝试 rebase 到 master 分支上。此时建议新建一个分支进行测试，以方便在意外时恢复测试前的状态。例如，假设你的现在在 superscalar 分支上，建立一个新的分支 superscalar-testing 用于测试：

```
git checkout -b superscalar-testing
git rebase origin/master
```

如果 rebase 中出现冲突，请参考 [public-doc](https://github.com/NSCSCC-2020-Fudan/public-doc) 中 “协同开发” 文档中的说明处理冲突。

测试成功后，可以将原来的 superscalar 分支移到 superscalar-testing 处，并且这个测试分支就不需要了。

```
git checkout superscalar
git reset --hard superscalar-testing
git branch -d superscalar-testing
```

push 分支代码的时候可能需要使用 `-f` 参数。

```
git push -f origin superscalar
```

## 提交改动

经过上述测试流程后，你的分支应该是在 master 分支前面的。此时只需要将 master 分支移到你的分支上即可：

```
git checkout master
git merge --ff-only superscalar
```

最后 push 代码：

```
git push origin master
```