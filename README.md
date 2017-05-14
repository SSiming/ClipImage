# ClipImage

###App中大部分都有的头像上传之图片裁剪功能实现
在实现这个功能的时候，考虑了一些 `App` 没有考虑到的一些注意点，整体来说，这个 `Demo` 达到了一个不错的用户体验。具体注意点如下：

- 进入页面的时候，图片显示的大小和默认位置，及图片的缩放比例
- 缩放的时候，手指捏合的可操作区域(这点希望是整个屏幕都可以，而不是暴露出来的圆形区域)
- 缩放之后，图片的可移动的区域(这点希望图片的边可以正好和圆形相切)
- 最后就是正确的裁剪范围

具体介绍可参考：[简单的聊一聊头像上传之图片裁剪](http://www.jianshu.com/p/91c27c854ece)
