import FontAwesomeKit
import UIKit
import CocoaLumberjack

let URL_FIELD_HEIGHT = 29

typealias BackAction = (Any?) -> Void
typealias ForwardAction = (Any?) -> Void
typealias HomeAction = (Any?) -> Void
typealias ReloadAction = (Any?) -> Void
typealias CancelAction = (Any?) -> Void
typealias GoAction = (String?) -> Void
typealias DebugButtonToggledAction = (Bool) -> Void
typealias SettingsAction = () -> Void
typealias ResetTrackingAction = () -> Void
typealias SwitchCameraAction = () -> Void

class BarView: UIView, UITextFieldDelegate {
    
    // MARK: - Properties & Outlets
    
    @objc var backActionBlock: BackAction?
    @objc var forwardActionBlock: ForwardAction?
    @objc var homeActionBlock: HomeAction?
    @objc var reloadActionBlock: ReloadAction?
    @objc var cancelActionBlock: CancelAction?
    @objc var goActionBlock: GoAction?
    @objc var debugButtonToggledAction: DebugButtonToggledAction?
    @objc var settingsActionBlock: SettingsAction?
    @objc var restartTrackingActionBlock: ResetTrackingAction?
    @objc var switchCameraActionBlock: SwitchCameraAction?

    @IBOutlet private weak var urlField: URLTextField!
    @IBOutlet private weak var backBtn: UIButton!
    @IBOutlet private weak var forwardBtn: UIButton!
    @IBOutlet private weak var homeBtn: UIButton!
    @IBOutlet private weak var debugBtn: UIButton!
    @IBOutlet private weak var settingsBtn: UIButton!
    private weak var reloadBtn: UIButton?
    private weak var cancelBtn: UIButton?
    private weak var ai: UIActivityIndicatorView?
    @IBOutlet private weak var restartTrackingBtn: UIButton!
    @IBOutlet private weak var switchCameraBtn: UIButton!

    // MARK: - View Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func setup() {
        backBtn.setImage(UIImage(named: "back"), for: .disabled)
        forwardBtn.setImage(UIImage(named: "forward"), for: .disabled)
        backBtn.isEnabled = false
        forwardBtn.isEnabled = false

        urlField.delegate = self

        let i = UIActivityIndicatorView(style: .gray)
        urlField.leftView = i
        urlField.leftViewMode = .unlessEditing
        i.hidesWhenStopped = true
        self.ai = i

        urlField.clearButtonMode = .whileEditing
        urlField.returnKeyType = .go

        urlField.textContentType = .URL
        urlField.placeholder = "Search or enter website name"
        urlField.layer.cornerRadius = CGFloat(URL_FIELD_HEIGHT / 4)
        urlField.textAlignment = .center

        let reloadButton = UIButton(type: .custom)
        reloadButton.setImage(UIImage(named: "reload"), for: .normal)
        reloadButton.addTarget(self, action: #selector(BarView.reloadAction(_:)), for: .touchDown)
        reloadButton.frame = CGRect(x: 0, y: 0, width: CGFloat(URL_FIELD_HEIGHT), height: CGFloat(URL_FIELD_HEIGHT))
        reloadButton.isHidden = false

        let cancelButton = UIButton(type: .custom)
        cancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        cancelButton.addTarget(self, action: #selector(BarView.cancelAction(_:)), for: .touchDown)
        cancelButton.frame = CGRect(x: 0, y: 0, width: CGFloat(URL_FIELD_HEIGHT), height: CGFloat(URL_FIELD_HEIGHT))
        cancelButton.isHidden = true

        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(URL_FIELD_HEIGHT), height: CGFloat(URL_FIELD_HEIGHT)))
        rightView.addSubview(reloadButton)
        rightView.addSubview(cancelButton)
        self.cancelBtn = cancelButton
        self.reloadBtn = reloadButton

        urlField.rightView = rightView
        urlField.rightViewMode = .unlessEditing

        debugBtn.setImage(UIImage(named: "debugOff"), for: .normal)
        debugBtn.setImage(UIImage(named: "debugOn"), for: .selected)

        var error: Error?
        let streetViewIcon = try? FAKFontAwesome.init(identifier: "fa-street-view", size: 24)
        if error != nil {
            print("\(error?.localizedDescription ?? "")")
        } else {
            let streetViewImage: UIImage? = streetViewIcon?.image(with: CGSize(width: 24, height: 24))
            restartTrackingBtn.setImage(streetViewImage, for: .normal)
            restartTrackingBtn.tintColor = UIColor.gray
        }

        //    FAKFontAwesome *undoViewIcon = [FAKFontAwesome  iconWithIdentifier:@"fa-undo" size:24 error:&error];
        //    if (error != nil) {
        //        NSLog(@"%@", [error localizedDescription]);
        //    } else {
        //        UIImage* undoViewImage = [undoViewIcon imageWithSize:CGSizeMake(24, 24)];
        //        [[self switchCameraBtn] setImage:undoViewImage forState:UIControlStateNormal];
        //        [[self switchCameraBtn] setTintColor:[UIColor grayColor]];
        //    }
    }

    // MARK: - Helpers
    
    @objc func urlFieldText() -> String? {
        return urlField.text
    }
    
    // MARK: - Actions
    
    @objc func startLoading(_ url: String?) {
        ai?.startAnimating()
        cancelBtn?.isHidden = false
        reloadBtn?.isHidden = true
        urlField.text = url
    }
    
    @objc func finishLoading(_ url: String?) {
        ai?.stopAnimating()
        cancelBtn?.isHidden = true
        reloadBtn?.isHidden = false
    }
    
    @objc func setBackEnabled(_ enabled: Bool) {
        backBtn.isEnabled = enabled
    }
    
    @objc func setForwardEnabled(_ enabled: Bool) {
        forwardBtn.isEnabled = enabled
    }
    
    func setDebugSelected(_ selected: Bool) {
        debugBtn.isSelected = selected
    }
    
    @objc func setDebugVisible(_ visible: Bool) {
        debugBtn.isHidden = !visible
    }
    
    @objc func setRestartTrackingVisible(_ visible: Bool) {
        restartTrackingBtn.isHidden = !visible
    }
    
    @objc func hideKeyboard() {
        urlField.resignFirstResponder()
    }
    
    @objc func isDebugButtonSelected() -> Bool {
        return debugBtn.isSelected
    }
    
    @objc func hideCameraFlipButton() {
        switchCameraBtn.removeFromSuperview()
    }
    
    // MARK: - Button Actions
    
    @IBAction func backAction(_ sender: Any) {
        DDLogDebug("backAction")
        urlField.resignFirstResponder()
        backActionBlock?(sender)
    }

    @IBAction func forwardAction(_ sender: Any) {
        DDLogDebug("forwardAction")
        urlField.resignFirstResponder()
        forwardActionBlock?(sender)
    }

    @IBAction func homeAction(_ sender: Any) {
        DDLogDebug("homeAction")
        homeActionBlock?(sender)
    }

    @IBAction func reloadAction(_ sender: Any) {
        DDLogDebug("reloadAction")
        urlField.resignFirstResponder()
        reloadActionBlock?(sender)
    }

    @IBAction func cancelAction(_ sender: Any) {
        DDLogDebug("cancelAction")
        urlField.resignFirstResponder()
        cancelActionBlock?(sender)
    }

    @IBAction func debugAction(_ sender: Any) {
        debugBtn.isSelected = !debugBtn.isSelected
        debugButtonToggledAction?(debugBtn.isSelected)
    }

    @IBAction func settingsAction() {
        settingsActionBlock?()
    }

    @IBAction func restartTrackingAction(_ sender: Any) {
        restartTrackingActionBlock?()
    }

    @IBAction func switchCameraAction(_ sender: Any) {
        switchCameraActionBlock?()
    }

    // MARK: - UITextField Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        goActionBlock?(textField.text)
        return true
    }

    // MARK: - UIView

    // This function increases the hitboxes of the forwardBtn/backBtn
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let minXPos = backBtn.frame.maxX
        let maxXPos = forwardBtn.frame.minX

        let increaseValue: CGFloat = (maxXPos - minXPos) / 2

        let icreasedBackRect = CGRect(x: backBtn.frame.origin.x - increaseValue, y: backBtn.frame.origin.y - increaseValue, width: backBtn.frame.size.width + increaseValue * 2, height: backBtn.frame.size.height + increaseValue * 2)

        let icreasedForwardRect = CGRect(x: forwardBtn.frame.origin.x - increaseValue, y: forwardBtn.frame.origin.y - increaseValue, width: forwardBtn.frame.size.width + increaseValue * 2, height: forwardBtn.frame.size.height + increaseValue * 2)

        if icreasedBackRect.contains(point) {
            return backBtn
        }

        if icreasedForwardRect.contains(point) {
            return forwardBtn
        }

        return super.hitTest(point, with: event)
    }
}

class URLTextField: UITextField {
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: CGFloat(URL_FIELD_HEIGHT), height: CGFloat(URL_FIELD_HEIGHT))
    }
}