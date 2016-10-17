

### DFPlayer
DFPlayer基于AVPlayer封装，支持播放、缓冲/进度显示、标题显示、暂停、载入动画、错误状态（timeout和刷新重播）、进度拖动、全屏等功能，并提供一个控制面板的默认实现。
###### 几个特性包括：
- 1）控制面板的UI控件可通过实现protocol方法来满足自定义需求；
- 2）播放器和视频的可通过delegate监测来满足更多业务需求；
- 3）提供常规配置，如自动播放、最小可自动播放缓冲等；
- 4）Swift2.2 , iOS8+；


### 0.01版本
- 0.01版本提供一个从0开始的播放器雏形，只支持播放、缓冲/进度显示以及标题显示（如下图）。
- 主要熟悉AVPlayer的基本使用方法，同时探索如何满足自定义控制面板的UI控件这个特性。

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3024625-46338e3aa3b18d43.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
