//
//  ClipImageVC.swift
//  ClipImage
//
//  Created by hujunhua on 13/05/2017.
//  Copyright © 2017 hujunhua. All rights reserved.
//

import UIKit

protocol ClipImageVCDelegate {
    func clipImageVC(_ clipImageVC: ClipImageVC, didFinishClipingImage image: UIImage)
}

class ClipImageVC: UIViewController {

    let ScreenWidth = UIScreen.main.bounds.size.width
    let ScreenHeight = UIScreen.main.bounds.size.height
    let clipRectWidth = UIScreen.main.bounds.size.width * 0.8
    let TimesThanMin: CGFloat = 5.0
    
    var delegate: ClipImageVCDelegate?
    var image: UIImage!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        automaticallyAdjustsScrollViewInsets = false
        
        initUI()
        settingScrollViewZoomScale()
    }

    func initUI() {
        let maskView = UIView.init(frame: view.bounds)
        maskView.backgroundColor = UIColor.clear
        maskView.isUserInteractionEnabled = false
        
        let clipRectX = (ScreenWidth - clipRectWidth) / 2.0
        let clipRectY = (ScreenHeight - clipRectWidth) / 2.0
        
        let path = UIBezierPath.init(rect: view.bounds)
        let ovalPath = UIBezierPath.init(ovalIn: CGRect.init(x: clipRectX, y: clipRectY, width: clipRectWidth, height: clipRectWidth))
        path.append(ovalPath)
        
        let shaperLayer = CAShapeLayer.init()
        shaperLayer.fillRule = kCAFillRuleEvenOdd
        shaperLayer.path = path.cgPath
        shaperLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        
        let whiteCircleLayer = CAShapeLayer.init()
        whiteCircleLayer.lineWidth = 2;
        whiteCircleLayer.path = ovalPath.cgPath
        whiteCircleLayer.fillColor = UIColor.clear.cgColor
        whiteCircleLayer.strokeColor = UIColor.white.cgColor
        shaperLayer.addSublayer(whiteCircleLayer)
        
        maskView.layer.addSublayer(shaperLayer)
        
        let bottomView = UIView.init(frame: CGRect.init(x: 0, y: ScreenHeight - 60, width: ScreenWidth, height: 60))
        bottomView.backgroundColor = UIColor.white
        
        let confirmButton = UIButton.init(frame: CGRect.init(x: 20, y: 10, width: ScreenWidth - 40, height: 40))
        confirmButton.backgroundColor = UIColor.black
        confirmButton.setTitle("Confirm", for: UIControlState.normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        confirmButton.addTarget(self, action: #selector(ClipImageVC.confirmButtonAction(_:)), for: UIControlEvents.touchUpInside)
        bottomView.addSubview(confirmButton)
        
        scrollView = UIScrollView.init(frame: view.bounds)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clear
        scrollView.contentInset = UIEdgeInsets.init(top: clipRectY, left: clipRectX, bottom: clipRectY, right: clipRectX)
        view.addSubview(scrollView)
        
        let imageViewH = image.size.height / image.size.width * ScreenWidth
        imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: imageViewH))
        imageView.image = image
        scrollView.addSubview(imageView)

        let offsetY = (scrollView.bounds.height - imageViewH) / 2.0
        scrollView.setContentOffset(CGPoint.init(x: 0, y: -offsetY), animated: false)
        
        view.addSubview(maskView)
        view.addSubview(bottomView)
    }
    
    func settingScrollViewZoomScale() {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        if imageWidth > imageHeight {
            scrollView.minimumZoomScale = clipRectWidth / (imageHeight / imageWidth * ScreenWidth);
        } else {
            scrollView.minimumZoomScale = clipRectWidth / ScreenWidth;
        }
        scrollView.maximumZoomScale = (scrollView.minimumZoomScale) * TimesThanMin
        scrollView.zoomScale = scrollView.minimumZoomScale > 1 ? scrollView.minimumZoomScale : 1
    }
    
    // MARK: - Action
    func confirmButtonAction(_ button: UIButton) {
        let image = clipImage()
        delegate?.clipImageVC(self, didFinishClipingImage: image!)
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Private
    func clipImage() -> UIImage? {
        let offset = scrollView.contentOffset
        let imageSize = imageView.image?.size
        let scale = (imageView.frame.size.width) / (imageSize?.width)!
        
        let clipRectX = (ScreenWidth - clipRectWidth) / 2.0
        let clipRectY = (ScreenHeight - clipRectWidth) / 2.0
     
        let rectX = (offset.x + clipRectX) / scale
        let rectY = (offset.y + clipRectY) / scale
        let rectWidth = clipRectWidth / scale
        let rectHeight = rectWidth
        
        let rect = CGRect.init(x: rectX, y: rectY, width: rectWidth, height: rectHeight)
        let fixedImage = fixedImageOrientation(image)
        let resultImage = fixedImage?.cgImage?.cropping(to: rect)
        let clipImage = UIImage.init(cgImage: resultImage!)
        
        return clipImage;
    }

    func fixedImageOrientation(_ image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let π = Double.pi
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: imageWidth, y: imageHeight)
            transform = transform.rotated(by: CGFloat(π))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: imageWidth, y: 0)
            transform = transform.rotated(by: CGFloat(π / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: imageHeight)
            transform = transform.rotated(by: CGFloat(-π / 2))
        default:
            break
        }
        
        switch image.imageOrientation {
        case .up, .upMirrored:
            transform = transform.translatedBy(x: imageWidth, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: imageHeight, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        let context = CGContext.init(data: nil,
                                     width: Int(imageWidth),
                                     height: Int(imageHeight),
                                     bitsPerComponent: Int(image.cgImage!.bitsPerComponent),
                                     bytesPerRow: Int((image.cgImage?.bytesPerRow)!),
                                     space: CGColorSpaceCreateDeviceRGB(),
                                     bitmapInfo: (image.cgImage?.bitmapInfo.rawValue)!)
        context!.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(image.cgImage!, in: CGRect.init(x: 0, y: 0, width: imageHeight, height: imageWidth))
        default:
            context?.draw(image.cgImage!, in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
        }
        
        let fixedImage = UIImage.init(cgImage: context!.makeImage()!)
        return fixedImage
    }
    
}

extension ClipImageVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
