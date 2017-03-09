# PublicProject
* 代码学习仓库

本仓库由Developer刘撰写, 非盈利性质, 任何人不得拿去做商业竞争, 如转载还请@我的仓库, 感谢

runtime 实际上为大家介绍runtime的一些知识, 总六个系统, 了解OC底层工作的原理
CoreGraphics 为大家演示了几个基于Graphics绘制的小栗子
随后也将陆陆续续的上传一些小文件共大家使用

# CirleView 轮播小控件
* @see XMCirleView
* 你可以很方便的创建它
```js
+ (XMCirleView *)cirleViewWithImages:(NSArray *)images placeholder:(UIImage *)placeholder
interval:(NSTimeInterval)interval delegate:(id<XMCirleViewDelegate>)delegate;
```

# QuartzView 
* 展示的是基于CoreGraphics框架, 的一些绘制方法

# XMAttrLabel
* 基于CoreText框架下的图文混排列工具, 图片的高是文字高度, 宽度由你定义
* 支持添加视图
* 支持链接等功能
