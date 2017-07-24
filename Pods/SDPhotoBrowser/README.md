## SDPhotoBrowser
一款轻量级的图片浏览器, 采用全 `Swift`写, 依赖于 `Kingfisher` 图片下载库, 支持本地以及网络图片浏览

## Installation 
### CocoaPods

```
use_frameworks!
pod 'SDPhotoBrowser', '~> 0.0.3'
```
## Usage
- 创建一个 `SDPhotoBrowserViewController` 浏览器

```Swift
let photoBrowserViewController = SDPhotoBrowserViewController()
photoBrowserViewController.photoUrlArray = photoUrl
//  self.navigationController?.pushViewController(photoBrowserViewController, animated: true)
self.present(photoBrowserViewController, animated: true, completion: nil)
```
- 或者直接使用 `SDPhotoBrowserViewController` 提供的快速构造方法, 将图片数组传以及 `startIndex` 给 `SDPhotoBrowserViewController` 的实例对象

```Swift
let photoBrowserViewController = SDPhotoBrowserViewController(WithPhotoUrlArray: photoUrl, startIndex: 0, delegate: self)
//  self.navigationController?.pushViewController(photoBrowserViewController, animated: true)
self.present(photoBrowserViewController, animated: true, completion: nil)
```
- `navBar` 上提供四个按钮, 第一个默认是返回按钮, 点击后返回上一层. 其余三个按钮默认隐藏, 想要自定义按钮的事件以及图片, 可以调用 `SDPhotoBrowserViewController` 的 `func config(named name: String, of position: SDButtonPosition, callBack: (() -> Void)?)` 方法, 可以如下:

```Swift
photoBrowserViewController.configNavBarButton(named: "nav_close_on", of: .rightOne, callBack: nil)
```
- 实现 `SDPhotoBrowserViewControllerDelegate` 的代理方法, 可以自定义 `toolView`, `toolView` 默认是显示在浏览器的底部位置

```Swift
func toolViewHeight(for photoBrowser: SDPhotoBrowserViewController) -> CGFloat {
   return 120
}
    
func customToolView(for photoBrowser: SDPhotoBrowserViewController) -> UIView {
   let toolView = UIView()
   
   toolView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
   
   titleLabel = UILabel()
   titleLabel.textColor = UIColor.white
   titleLabel.translatesAutoresizingMaskIntoConstraints = false
   toolView.addSubview(titleLabel)
   
   toolView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: toolView, attribute: .centerY, multiplier: 1.0, constant: 0))
   toolView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: toolView, attribute: .left, multiplier: 1.0, constant: 15))
   toolView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: toolView, attribute: .right, multiplier: 1.0, constant: -15))
   
   return toolView
}
```
- 如果想根据图片的偏移量刷新 `toolView` 上控件的显示, 只需要实现以下代理方法即可:

```Swift
func photoBrowser(_ photoBrowser: SDPhotoBrowserViewController, didChangedToPageAtIndex index: Int) {
        
    titleLabel.text = photoTitleArray[index]
}
```


