import UIKit

@objc protocol QrCodeScannerControllerDelegate: class {
  @objc func injectQrCodeController()
  @objc func loadAfterScanning(url: URL)
  @objc func computeHostURL(newHost: String) -> URL
}


class QrCodeScannerController: UIViewController, QRViewDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var qrView: QRView!
    @IBOutlet weak var qrMaskView: QRMaskView!

    weak var delegate: QrCodeScannerControllerDelegate?

    private var uiState: State = .idle {
        didSet {
            if (oldValue != uiState) {
                updateUIState()
            }
        }
    }

    func launchApp(_ url: URL) {
        uiState = .idle
        qrView.stopScanning()
        //let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        delegate?.loadAfterScanning(url: url)
    }

    func qrScanningSucceeded(_ str: String?) {
        if uiState == .loading {
            return
        }

        uiState = .loading
        if let urlString = str, let delegate = delegate {
            //let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
            let url: URL = delegate.computeHostURL(newHost: urlString)

            validateUrl(url) { (running) in
                guard running  else {
                    self.uiState = .invalidInput
                    return
                }
                self.launchApp(url)
            }
            return
        }
        uiState = .invalidQRCode
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupQrCodeMask(size: view.frame.size)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setupQrCodeMask(size: size)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiState = .idle
        qrView.startScanning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        qrView.stopScanning()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        qrView.delegate = self

        textField.layer.cornerRadius = 30
        if let placeHolderText = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

private let MAX_MASK_SIZE = CGFloat(350)
private let MASK_RELATIVE_SIZE = CGFloat(0.6)

extension QrCodeScannerController {
    private func validateUrl(_ url: URL, onCompletion: @escaping (_ valid: Bool) -> Void) {
        URLValidator.validate(url, onCompletion: onCompletion)
        return

    }

    private func setupQrCodeMask(size: CGSize) {
        let minDim = min(size.width, size.height)
        var maskSize = minDim * MASK_RELATIVE_SIZE
        maskSize = maskSize > MAX_MASK_SIZE ? MAX_MASK_SIZE : maskSize
        qrMaskView.mask(rect: CGRect(x: (size.width - maskSize) / 2, y: (size.height - maskSize) / 2, width: maskSize, height: maskSize))
    }

    private enum State {
        case idle
        case loading
        case invalidInput
        case invalidQRCode
    }

    private func updateUIState() {
        switch uiState {
        case .idle:
            textField.layer.opacity = 1
            break
        case .loading:
            textField.layer.opacity = 0.5
            break
        case .invalidInput:
            textField.layer.opacity = 1
            showErrorDialog(error: "Please verify that your App is running.")
            break
        case .invalidQRCode:
            textField.layer.opacity = 1
            showErrorDialog(error: "This is not a Valid QR code.")
            break
        }
    }

    private func showErrorDialog(error: String) {
        let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 16

        navigationController?.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            alert.dismiss(animated: true)
        }
    }
}
