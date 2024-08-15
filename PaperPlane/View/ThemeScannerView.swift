import UIKit

class ThemeScannerView: ScannerView {
    override func setupUI() {
        let tv = ImageTargetView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        if let size = tv.unknownImage?.size {
            tv.frame.size = size
        }
        targetView = tv

        super.setupUI()
    }
}
