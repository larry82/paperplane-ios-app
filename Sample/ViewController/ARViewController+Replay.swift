import Foundation
import ReplayKit

extension ARViewController: RPPreviewViewControllerDelegate {
    ///開始錄影按鈕
    func startRecording() {
        //確認錄製器目前可否使用
        self.isRecording = true
        
        videoBtnWindow?.didTouched = {
            self.stopRecording()
        }
        
        recorder.startRecording { error in
            guard error == nil else {
                print("recoder error", error as Any)
                self.isRecording = false
                self.videoBtnWindow?.stopCounting()
                return
            }
            self.videoBtnWindow?.startCounting()
        }
    }
    
    ///關閉錄影按鈕
    func stopRecording() {
        recorder.stopRecording { getPreview, error in
            //preview 錄製後觀看controller 確認可否使用
            guard error == nil else{
                print("recoder error", error as Any)
                self.isRecording = false
                self.videoBtnWindow?.stopCounting()
                return
            }
            
            guard getPreview != nil,
                let preview = getPreview else {
                print("preview error")
                return
            }
            
            //加入previewController 的delegate
            preview.previewControllerDelegate = self
            preview.modalPresentationStyle = .overCurrentContext
            self.present(preview, animated: true, completion: nil)
            
            //錄影bool設定為結束
            self.isRecording = false
        }
    }
    
    ///判斷目前開始錄影還是結束錄影動作
    func startScreenRecording() {
        if self.isRecording {
            // We did not expect this function called in recording state
            print("Something wrong while screen recording button is touched")
        } else {
            self.startRecording()
        }
    }
    
    ///錄影按鈕UI設定 true=錄影中
    func changeReplayButtonUi(isRecording: Bool) {
        if isRecording {
            replayButtonTypeSetUp(isHidden: true)
        } else {
            replayButtonTypeSetUp(isHidden: false)
        }
    }
    
    ///設定錄影狀態需要隱藏物件、按鈕圖片更改
    func replayButtonTypeSetUp(isHidden: Bool) {
        videoBtnWindow?.isHidden = !isHidden
        switchButtonsVisibility(isHidden: isHidden)
    }
    
    ///點選刪除時關閉preview
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true, completion: nil)
    }
}
