## OptimizationForOffscreenRender

[中文版](http://www.jianshu.com/p/ca51c9d3575b)

## Trigger Action

Four actions can trigger offscreen render:

1. RoundedCorener
2. Shadow
3. Mask
4. GroupOpacity(almost no impact to graphics performance in my demo)

Core Graphics API don't trigger offscreen render. You should check it with Core Animation Instruments with debug option 'Color Offscreen-Renderd Yellow'.

![Core Animation Instruments Debug Options](http://upload-images.jianshu.io/upload_images/37334-909659db842314aa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Another proof: [Andy Matuschak's comments on this](https://lobste.rs/s/ckm4uw/a_performance-minded_take_on_ios_design/comments/itdkfh), who was a member of the UIKit team and a speaker of [WWDC 2011: Understanding UIKit Rendering](https://developer.apple.com/videos/play/wwdc2011/121/). Andy Matuschak said edge antialiasing also tirgger offscreen render, I test on iOS 8 and iOS 9, it doesn't, maybe things have change. 

##Basics

The relationship between UIView and CALayer, and [CALayer's visual structure](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreAnimation_guide/SettingUpLayerObjects/SettingUpLayerObjects.html#//apple_ref/doc/uid/TP40004514-CH13-SW19).

![Relationship of UIView and CALayer](https://github.com/seedante/iOS-Note/blob/master/GraphicsPerformance/Relationship%20of%20UIView%20and%20CALayer.png?raw=true)

![UIImageView Structure](https://github.com/seedante/iOS-Note/blob/master/GraphicsPerformance/UIImageView%20Structure.png?raw=true)


##Trigger Condition:

1.Rounder Corener: 

	view.layer.cornerRadius > 0 
	view.layer.masksToBounds = true	
	
`cornerRadius`'s description:	
	
>Setting the radius to a value greater than 0.0 causes the layer to begin drawing rounded corners on its background. By default, the corner radius does not apply to the image in the layer’s contents property; it applies only to the background color and border of the layer. However, setting the masksToBounds property to YES causes the content to be clipped to the rounded corners.


So, if layer's `contents` is nil or `contents` has transparent background, you don't need to set `masksToBounds = true` to trigger offscreen render.
	
2.Shadow:`view.layer.shadowPath = nil`. A shadow with shadowPath won't trigger offcreen render.

3.Mask: always tirgger offscreen render.

4.GroupOpacity: `view.alpha != 1.0` and layer has nontrivial content. Note: in UITableView, only set `tableView.alpha != 1.0` can trigger offscreen render, and this has no impact to scroll performance in my demo.


##Optimization Solution:


###Avoid offscreen render if you can

1.**RounedCorner:**

if layer's `contents` is nil or this `contents` has a transparent background, you just need to set `cornerRadius`. For UILabel, UITextView and UIButton, you can just set layer's `backgroundColor` and `cornerRadius` to get a rounded corner. Note: UILabel's `backgroundColor` is not its layer's `backgroundColor`.
 
    //Set backgroundColor to get corner can be see 
    textView.backgroundColor = aColor
    textView.layer.cornerRadius = 5
    //Don't set label.backgroundColor = aColor
    label.layer.backgroundColor = aCGColor
    label.layer.cornerRadius = 5 
     
2.**Shadow**: specify a shadow path for a shadow.

###Rasterization

Rasterization works for all effects and has very good performance. This is fit for views which have static contents.

    view.layer.shouldRasterize = true
    view.layer.rasterizationScale = view.layer.contentsScale
About shadow, shadowPath is better: lower GPU utilization.

###Fake effect

1.Blend with a transparent view like:

![Transparent Overlay](https://github.com/seedante/iOS-Note/blob/master/GraphicsPerformance/Transparent%20Overlay.png?raw=true)

The best performance! Only problem is how get these image. Paint or draw. With a image, blend and mask get opposite effect. This solution is fit for rounded corner and mask. 

2.For RoundedCorener: redraw a rouned corner image with Core Graphics API. 

##Test Rasterization

Test Environment：

- iPad mini 1st generation with iOS 9.3.1
- Xcode 7.3 with Swift 2.2
- OS X 10.11.4

CPU Utilization for all testes are not high: the max utilization is almost 50%.

| Condition |RoundedCorner Count OnScreen | Average FPS |Average GPU Utilization |Trigger OffscreenRender | 
|---|---|---|---|---|---|
|shouldRasterize = false|10|almost 44|over 80%|YES
|shouldRasterize = true |10|over 55|under 20%|YES
|shouldRasterize = false |20|almost 35|under 90%|YES
|shouldRasterize = true |20|almost 55|almost 20%|YES

| Condition | Shadow Count OnScreen | Average FPS |Average GPU Utilization |Trigger OffscreenRender | 
|---|---|---|---|---|---|
|shouldRasterize = false|10|almost 38|almost 73%|YES
|shouldRasterize = true |10|over 55|under 30%|YES
|shadowPath != nil |10|over 56|under 15%|NO
|shouldRasterize = false |20|almost 22|almost 80%|YES
|shouldRasterize = true |20|almost 55|under 40%|YES
|shadowPath != nil |20|over 56|under 20%|NO
(when test shouldResterize, shadowPath = nil; when shadowPath!= nil, shouldResterize = false)

| Condition | Mask Count OnScreen | Average FPS |Average GPU Utilization |Trigger OffscreenRender | 
|---|---|---|---|---|---|
|shouldRasterize = false|10|almost 55|almost 60%|YES
|shouldRasterize = true |10|over 55|almost 20%|YES
|shouldRasterize = false |20|almost 37|almost 75%|YES
|shouldRasterize = true |20|almost 55|under 30%|YES
