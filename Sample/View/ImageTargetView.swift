import LiGScannerKit

class ImageTargetView: TargetView {
    let detectedImage = UIImage(named: "detectedTarget")
    let unknownImage = UIImage(named: "unknownTarget")
    
    var imageView: UIImageView? = nil
    
    override func setupUI() {
        self.imageView = UIImageView(image: unknownImage)
        if let v = imageView {
            addSubview(v)
            v.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            v.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            v.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            v.heightAnchor.constraint(equalTo: v.widthAnchor, multiplier: 1).isActive = true
        }
    }

    override func update(device: LightID) {
        if device.isDetected {
            imageView?.image = detectedImage
        } else {
            imageView?.image = unknownImage
        }
    }
}
