//
//  TableViewController.swift
//  OffscreenRenderDemo
//
//  Created by seedante on 16/4/20.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit


class TableViewController: UITableViewController {

    let cellIdentifier = "Cell"
    let avatorImageL = UIImage(named: "L80.png")
    let avatorImageR = UIImage(named: "R80.png")
    let blendImage = UIImage(named: "RecRoundMask.png")
    let maskImage = UIImage(named: "RoundMask.png")
//    let maskImageNoEffect = UIImage(named: "L80.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*GroupOpacity Test: No obvious impact to performance almost in this demo.*/
//        enableGroupOpacityOn(view)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let labelL = cell.viewWithTag(30) as! UILabel
        let labelR = cell.viewWithTag(40) as! UILabel
        labelL.text = "OffscreenRender" + String(indexPath.row)
        labelR.text = String(indexPath.row) + "离屏渲染"
        
        //I test on iPad mini 1st generation, iOS 9.3.1, latter iOS devices maybe have better performance.
        
        //No effect Test
        displayCell(cell)
        
        /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        /*RounderCorner Test*/
        
        //System Rounded Corner: if layer's contents is not nil, masksToBounds must be true. Is cornerRadius bigger, performance worse? No, when cornerRadius > 0, performance is same almost.
//        applySystemRoundedCornerOn(cell)
        
        /*RounedCorner solution:
         1. Redraw contents and clip as rouned corner contens;
         2. Blend with a view which has transparent part contents, like a mask. The best performance! Here I use a UIImageView with part transparent contents.
         */
        
        //Redraw in main thread, put it in background thread is better.
//        redrawRounedCornerInMainThreadOn(cell)
        
        //Redraw in background thread, performance is nice.
//        redrawRoundedCornerInBackgroundThreadOn(cell)
        
        //This solution needs a image which is partly transparent. You can paint it by Sketch, PaintCode, or draw it with Core Graphics API.
//        blendRoundedCornerOn(cell)
        
        /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        /*Shadow Test: shadow is not compatible with system rouned corner, because layer.masksToBounds can't be true in shadow affect.*/
//        dropShadownOn(cell)
        
        //Optimization for shadow: a shadow path can cancel offscreen render effect
//        let avatorViewL = cell.viewWithTag(10) as! UIImageView
//        specifyShadowPathOn(avatorViewL)
//        let avatorViewR = cell.viewWithTag(20) as! UIImageView
//        specifyShadowPathOn(avatorViewR)
        
        /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        /*Mask Test: Is maskLayer more transparent part, performance better? No obvious impact.*/
//        applyMaskOn(cell)
        
        /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        //Ultimate solution: Rasterization, works for roundedCorner, shadow, mask and has very good performance.
//        enableRasterizationOn(cell)
        
        //Simulate danamic content
//        dynamicallyUpdateCell(cell)
        return cell
    }
    
    func dynamicallyUpdateCell(cell: UITableViewCell){
        
        let number = Int(UInt32(arc4random()) % UInt32(10))
        
        let labelL = cell.viewWithTag(30) as! UILabel
        labelL.text = "OffscreenRender" + String(number)
        
        let labelR = cell.viewWithTag(40) as! UILabel
        labelR.text = String(number) + "离屏渲染"
        
        
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        avatorViewL.layer.cornerRadius = CGFloat(number)
        avatorViewL.clipsToBounds = true
        
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewR.layer.cornerRadius = CGFloat(number)
        avatorViewR.clipsToBounds = true
        
        let delay = NSTimeInterval(number) * 0.1
        performSelector(#selector(TableViewController.dynamicallyUpdateCell(_:)), withObject: cell, afterDelay: delay)
    }
 
    func displayCell(cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        avatorViewL.image = avatorImageL
        
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewR.image = avatorImageR
    }
    
    func applySystemRoundedCornerOn(cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        avatorViewL.image = avatorImageL
        avatorViewL.layer.cornerRadius = 10
        avatorViewL.layer.masksToBounds = true

        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewR.image = avatorImageR
        avatorViewR.layer.cornerRadius = 10
        avatorViewR.layer.masksToBounds = true
    }
    
    func redrawRounedCornerInMainThreadOn(cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let roundedCornerImageL = drawImage(image: avatorImageL!, rectSize: CGSize(width: 80, height: 80), roundedRadius: 10.0)
        avatorViewL.image = roundedCornerImageL

        
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        let roundedCornerImageR = drawImage(image: avatorImageR!, rectSize: CGSize(width: 80, height: 80), roundedRadius: 10.0)
        avatorViewR.image = roundedCornerImageR

    }
    
    func redrawRoundedCornerInBackgroundThreadOn(cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let roundedCornerImageL = drawImage(image: self.avatorImageL!, rectSize: CGSize(width: 80, height: 80), roundedRadius: 10.0)
            let roundedCornerImageR = drawImage(image: self.avatorImageR!, rectSize: CGSize(width: 80, height: 80), roundedRadius: 10.0)
            dispatch_async(dispatch_get_main_queue(), {
                avatorViewL.image = roundedCornerImageL
                avatorViewR.image = roundedCornerImageR
            })
        })

    }
    
    func blendRoundedCornerOn(cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewL.image = avatorImageL
        avatorViewR.image = avatorImageR
        
        let blendViewL =  cell.viewWithTag(50) as! UIImageView
        blendViewL.image = blendImage
        blendViewL.hidden = false
        
        let blendViewR =  cell.viewWithTag(60) as! UIImageView
        blendViewR.image = blendImage
        blendViewR.hidden = false
    }
    
    func dropShadownOn(cell: UITableViewCell){
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewL.image = avatorImageL
        avatorViewR.image = avatorImageR
        
        avatorViewL.layer.shadowColor = UIColor.redColor().CGColor
        avatorViewL.layer.shadowOffset = CGSize(width: 5, height: 5)
        avatorViewL.layer.shadowOpacity = 1
        
        avatorViewR.layer.shadowColor = UIColor.redColor().CGColor
        avatorViewR.layer.shadowOffset = CGSize(width: 5, height: 5)
        avatorViewR.layer.shadowOpacity = 1
    }
    
    //Optimization for shadow
    func specifyShadowPathOn(view: UIView) {
        let path = UIBezierPath(rect: view.bounds)
        view.layer.shadowPath = path.CGPath
    }

    
    func applyMaskOn(cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewL.image = avatorImageL
        avatorViewR.image = avatorImageR
        
        if #available(iOS 8.0, *) {
            avatorViewL.maskView = UIImageView(image: maskImage)
            avatorViewR.maskView = UIImageView(image: maskImage)
        } else {
            let maskLayer1 = CALayer()
            maskLayer1.frame = avatorViewL.bounds
            maskLayer1.contents = maskImage?.CGImage
            avatorViewL.layer.mask = maskLayer1
            
            let maskLayer2 = CALayer()
            maskLayer2.frame = avatorViewR.bounds
            maskLayer2.contents = maskImage?.CGImage
            avatorViewR.layer.mask = maskLayer2
        }
        
        //Or use CAShapeLayer
//        let roundedRectPath = UIBezierPath(roundedRect: avatorViewL.bounds, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 10, height: 10))
//        let shapeLayerL = CAShapeLayer()
//        shapeLayerL.path = roundedRectPath.CGPath
//        avatorViewL.layer.mask = shapeLayerL
//        
//        let shapeLayerR = CAShapeLayer()
//        shapeLayerR.path = roundedRectPath.CGPath
//        avatorViewR.layer.mask = shapeLayerR
    }
    
    func enableGroupOpacityOn(view: UIView) {
        /*
         Group Opacity Test:
         
         -------------------------------------------------------------------------------------------------------------------------------------------------------------
         var allowsGroupOpacity: Bool
         
         Discussion:
         
         When the value is YES and the layer’s opacity property value is less than 1.0, the layer is allowed to composite itself as a group separate from its parent.
         This gives correct results when the layer contains multiple opaque components, but may reduce performance.
         
         The default value is read from the boolean UIViewGroupOpacity property in the main bundle’s Info.plist file.
         If no value is found, the default value is YES for apps linked against the iOS 7 SDK or later and NO for apps linked against an earlier SDK.
         -------------------------------------------------------------------------------------------------------------------------------------------------------------
         In WWDC 2014 419: Advanced Graphics and Animation Performance, performance consideration:
         
         Will introduce offscreen passes:
         If layer is not opaque (opacity != 1.0)
         And if layer has nontrivial content (child layers or background image)
         -->Sub view hierarchy needs to be composited before being blended
         Always turn it off if not needed.
         
         layer's opacity = view's alpha
         -------------------------------------------------------------------------------------------------------------------------------------------------------------
         So, `allowsGroupOpacity` is `true` in this project with default configuration.
         But in UITableView, 'cell.alpha != 1.0' can't trigger offscreen render and can't change alpha actualy, cell.contentView.alpha do. 
         How trigger offscreen render on cell? Set 'tableView.alpha != 1.0', you can check it with `Color Offscreen-Rendered Yellow` in Core Animation Instruments.
         But(again), no impact to scroll performance.
         You can easily get offscreen render on general view which has subview by change its alpha < 1.
         -------------------------------------------------------------------------------------------------------------------------------------------------------------
         */
        view.alpha = 0.9
    }
    
    /* 
     //Ultimate Solution: Rasterization
     
     Typical use cases:
     Avoid redrawing expensive effects for static content 
     Avoid redrawing of complex view hierarchies
     */
    func enableRasterizationOn(view: UIView) {
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = view.layer.contentsScale
    }
}
