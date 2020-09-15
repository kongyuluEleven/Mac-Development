//
//  KSwiftyCameraVC.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/9.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import MetalPetal
import AVKit
import SnapKit

let TEST_URL = "http://m.kekenet.com/menu/201206/185740.shtml"

let HOLDE_PLACE_TEXT = "请在此处输入你想要跟踪失败的文字，然后点击《拷贝》按钮"

let TEXT_COPY_DEFAULT = """
 Passage 37. Life Lessons
 Sometimes people come into your life and you know right away that they were meant to be there,
 to serve some sort of purpose,teach you a lesson, or to help you figure out who you are or who you want to become. You never know who these people may be—a roommate, a neighbor, a professor, a friend, a lover, or even a complete stranger—but when you lock eyes with them,you know at that very moment they will affect your life in some profound way. Sometimes things happen to you that may seem horrible,painful, and unfair at first,but in reflection you find that without overcoming those obstacles you would have never realized your potential, strength,willpower, or heart. Everything happens for a reason. Nothing happens by chance or by means of good or bad luck. Illness,injury, love, lost moments of true greatness, and sheer stupidity all occur to test the limits of your soul. Without these small tests, whatever they may be, life would be like a smoothly paved straight flat road to nowhere. It would be safe and comfortable,but dull and utterly pointless.
 The people you meet who affect your life, and the success and downfalls you experience, help to create who you are and who you become. Even the bad experiences can be learned from. In fact, they are sometimes the most important ones. If someone loves you, give love back to them in whatever way you can, not only because they love you, but because in a way, they are teaching you to love and how to open your heart and eyes to things. If someone hurts you, betrays you, or breaks your heart,forgive them, for they have helped you learn about trust and the importance of being cautious to whom you open your heart. Make every day count. Appreciate every moment and take from those moments everything that you possibly can for you may never be able to experience it again. Talk to people that you have never talked to before, and listen to what they have to say. Let yourself fall in love, break free, and set your sights high. Hold your head up because you have every right to. Tell yourself you are a great individual and believe in yourself, for if you don’t believe in yourself, it will be hard for others to believe in you.
"""

enum SliderType:Int {
    case fontSize
    case speed
    
    var min:Float {
        switch self {
        case .fontSize:
            return 10
        case .speed :
            return 0.1
        }
    }
    
    var max:Float {
        switch self {
        case .fontSize:
            return 80
        case .speed :
            return 1.0
        }
    }
}


enum LrcMoveType:Int {
    case autoMove
    case speechMove
}

let kScreenW = UIScreen.main.bounds.size.width      //屏幕宽
let kScreenH = UIScreen.main.bounds.size.height     //屏幕高

let kMaxSeconds : Int = 60

class KSwiftyCameraVC: KBaseRenderController {
    
    @IBOutlet weak var controlBgView: UIView!
    
    //@IBOutlet weak var labelOpenLrc: UILabel!
    
    @IBOutlet weak var switchOpenMatting: UISwitch!
    @IBOutlet weak var labelOpenMatting: UILabel!
    @IBOutlet weak var captureButton    : KRecordButton!
    @IBOutlet weak var flipCameraButton : UIButton!
    @IBOutlet weak var flashButton      : UIButton!
    @IBOutlet weak var btnSpeak: UIButton!
    @IBOutlet weak var lrcTextView: UITextView!
    @IBOutlet weak var lrcTextViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnLanguage: UIButton!
    //@IBOutlet weak var switchShowLrc: UISwitch!
    @IBOutlet weak var btnFontSet: UIButton!
    @IBOutlet weak var btnSpeedSet: UIButton!
    @IBOutlet weak var btnBeaty: UIButton!
    //@IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lrcSegmentControl: UISegmentedControl!
    @IBOutlet weak var btnEditText: UIButton!
    
    @IBOutlet weak var beatyBgView: UIView!
    @IBOutlet weak var beatyEnableSwitch: UISwitch!
    
    @IBOutlet weak var beatyFinishButton: UIButton!
    @IBOutlet weak var beatyResetButton: UIButton!
    @IBOutlet weak var beatyEnableLabel: UILabel!
    
    @IBOutlet weak var beatyMopiLabel: UILabel!
    @IBOutlet weak var beatyMopiSlider: UISlider!
    @IBOutlet weak var beatyBaoguangLabel: UILabel!
    @IBOutlet weak var beatyBaoguangSlider: UISlider!
    @IBOutlet weak var beatyMeibaiLabel: UILabel!
    @IBOutlet weak var beatyMeibaiSlider: UISlider!
    @IBOutlet weak var beatyBaoheLabel: UILabel!
    @IBOutlet weak var beatyBaoheSlider: UISlider!
    

    @IBOutlet weak var fontSetBgView: UIView!
    @IBOutlet weak var fontEnableLabel: UILabel!
    
    @IBOutlet weak var fontEnableSwitch: UISwitch!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontScrollSpeedLabel: UILabel!
    @IBOutlet weak var fontScrollSpeedSlider: UISlider!
    @IBOutlet weak var fontAreaSizeLabel: UILabel!
    @IBOutlet weak var fontAreaSizeSlider: UISlider!
    @IBOutlet weak var fontResetButton: UIButton!
    @IBOutlet weak var fontFinishButton: UIButton!

    @IBOutlet weak var filtersView: UIView!
    @IBOutlet weak var btnFilterSetFinished: UIButton!
    @IBOutlet weak var segementFilterSet: UISegmentedControl!
    
    @IBOutlet weak var fliterEnableSwitch: UISwitch!
    @IBOutlet weak var fliterEnableLabel: UILabel!
    
    //MARK:- 懒加载属性
    fileprivate lazy var hdhTimeView : HDHTimerView = {
        let timeView = HDHTimerView.getTimerView()
        timeView.maxSeconds = kMaxSeconds
        //        timeView.backgroundColor = UIColor.groupTableViewBackground
        let x = (kScreenW - timeView.frame.size.width) / 2.0
        let rect = CGRect.init(x: x, y: 100, width: timeView.frame.size.width, height: timeView.frame.size.height)
        timeView.frame = rect
        timeView.backgroundColor = .clear
        return timeView
    }()
    
    fileprivate lazy var hdhProgressBarView : HDHProgressBarView = {
        let progressBarView = HDHProgressBarView.getProgressBarView()
        progressBarView.frame = CGRect(x: 0, y: 250, width: kScreenW, height: progressBarView.frame.size.height)
        progressBarView.finishedTime = kMaxSeconds
        progressBarView.backgroundColor = .clear
        return progressBarView
    }()
    
    private let folderName = "videos"
    private var camera: Camera?
    private let videoQueue = DispatchQueue(label: "com.metalpetal.MetalPetalDemo.videoCallback")
    private let audioQueue = DispatchQueue(label: "com.metalpetal.MetalPetalDemo.audioCallback")
    private var recorder: MovieRecorder?
    private var isRecording = false
    private var pixelBufferPool: MTICVPixelBufferPool?
    private var currentVideoURL: URL?
    
    private var isFrontCamera = true
    
    private var speechRecognizer:SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var lock = NSLock.init()
    private var originText:String = TEXT_COPY_DEFAULT
    private var matchRange:NSRange?
    private var lastMatchRange:NSRange?
    private var curScrollRange:NSRange?
    private var isShowLrc:Bool = true
    
    private var language:String = "en-US"
    private var languageTitle:String = "English"
    
    private let TEXTVIEW_MIN_H = 200
    
    //private var sliderType:SliderType = .fontSize
    private var lrcFontSize:Float = 30.0 {
        didSet {
            
        }
    }
    
    private var lrcFontColor:UIColor = .white
    private var lrcFontMatchColor:UIColor = .red
    
    private var lrcSpeed:Float = 0.3 {
        didSet {
            
        }
    }
    
    private var lrcScrollAreaHeigh:Float = 300.0 {
        didSet {
            
        }
    }
    
    private var timer = Timer()
    private var recordTimer:Timer?
    
    private let colorLookupFilter: MTIColorLookupFilter = {
        let filter = MTIColorLookupFilter()
        filter.inputColorLookupTable = MTIImage(image: UIImage(named: "ColorLookup512")!, isOpaque: true)
        return filter
    }()
    
    //是否允许美颜
    private var isBeautyEnabled = true
    
    //是否允许滤镜
    private var isCustomFilterEnabled = true
    
    //是否允许抠图
    private var isMattingEnabled = false
    
    //滤镜处理
    fileprivate var filterCollectionView: UICollectionView!
    fileprivate var toolCollectionView: UICollectionView!
    fileprivate var filterControlView: KFilterControlView?
    fileprivate var originInputImage: MTIImage?
    public var croppedImage: UIImage!
    fileprivate var adjustFilter = MTBasicAdjustFilter()
    fileprivate var allFilters: [MTFilter.Type] = []
    fileprivate var cachedFilters: [Int: MTFilter] = [:]
    fileprivate var currentSelectFilterIndex: Int = 0
    fileprivate var currentAdjustStrengthFilter: MTFilter?
    fileprivate var currentUseFliter: MTFilter?
    fileprivate var allTools: [KFilterToolItem] = []
    fileprivate var thumbnails: [String: UIImage] = [:]
    
    deinit {
        stopTimer()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetalCamera()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        initUI()
        checkAuthor()
        //recordButtonTapped()
        controlBgView.backgroundColor = .clear
        //controlBgView.addSubview(backgroundPicker)
        
        self.view.bringSubviewToFront(controlBgView)
        bringPickerViewToFront()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera?.startRunningCaptureSession()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera?.stopRunningCaptureSession()
        //captureButton.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        rotateCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        toggleFlashAnimation()
    }

    @IBAction func btnCancelClicked(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    @IBAction func btnSpeakClicked(_ sender: Any) {
        //OSSSpeech.shared.recordVoice()
        
    }
    
    @IBAction func btnStartClicked(_ sender: Any) {
        recordButtonTapped()
    }
    
    @IBAction func btnLanguageClicked(_ sender: Any) {
        let vc = KLanguageListTableVC()
        vc.delegate = self
        let nav = NavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    //开启字幕
    @IBAction func swicthShowLrcClicked(_ sender: Any) {
        if let switchButton = sender as? UISwitch {
            isShowLrc = switchButton.isOn
            updateTextRange()
            if isShowLrc,lrcSegmentControl.selectedSegmentIndex == LrcMoveType.autoMove.rawValue  {
                stopTimer()
                startTimer()
            } else {
                stopTimer()
            }
            
            lrcTextView.isHidden = !switchButton.isOn
        }
    }
    
    @IBAction func btnFontSetClicked(_ sender: Any) {
        fontSetBgView.isHidden = false
        self.view.bringSubviewToFront(fontSetBgView)
    }
    
    @IBAction func btnSpeedSetClicked(_ sender: Any) {
        //点击滤镜
        filtersView.isHidden = false
        self.view.bringSubviewToFront(filtersView)
    }
    
    @IBAction func btnBeatyClicked(_ sender: Any) {
        beatyBgView.isHidden = false
        self.view.bringSubviewToFront(beatyBgView)
    }
    
    
    @IBAction func lrcSegmentControlValueChanged(_ sender: Any) {
        guard let segmentControl = sender as? UISegmentedControl else {
            return
        }
        let index = segmentControl.selectedSegmentIndex
        
        if index == LrcMoveType.autoMove.rawValue { // 自动滚动
            startTimer()
            //停止语音识别
            stopAudioRecording()
        } else { // 语音识别滚动
            stopTimer()
            //开启语音识别
            restartAudioRecord()
        }
        
    }
    
    //开启抠图
    @IBAction func switchOpenMattingValueChanged(_ sender: Any) {
        guard let switchButton = sender as? UISwitch else {return}
        filterSwitchValueChanged(switchButton)
    }
    
    
    @IBAction func beatyEnableSwitchValueChanged(_ sender: Any) {
        guard let switchButton = sender as? UISwitch else {return}
        isBeautyEnabled = switchButton.isOn
        UserDefaults.standard.setValue(isBeautyEnabled, forKey: UserDefaultsKeys.isBeautyEnableKey)
    }
    
    @IBAction func beatyResetButtonClicked(_ sender: Any) {
        beatyBgView.isHidden = true
    }
    
    @IBAction func beatyFinishButtonClicked(_ sender: Any) {
        beatyBgView.isHidden = true
    }
    
    @IBAction func beatyMopiSliderValueChanged(_ sender: Any) {
    }
    
    @IBAction func beatyBaoguangSliderValueChanged(_ sender: Any) {
    }
    
    @IBAction func beatyMeibaiSliderValueChanged(_ sender: Any) {
    }
    
    @IBAction func beatyBaoheSliderValueChanged(_ sender: Any) {
    }
    
    
    @IBAction func fontEnableSwitchValueChanged(_ sender: Any) {
        if let switchButton = sender as? UISwitch {
            isShowLrc = switchButton.isOn
            updateTextRange()
            if isShowLrc,lrcSegmentControl.selectedSegmentIndex == LrcMoveType.autoMove.rawValue  {
                stopTimer()
                startTimer()
            } else {
                stopTimer()
            }
            
            lrcTextView.isHidden = !switchButton.isOn
        }
    }
    
    
    @IBAction func fontFinishButtonClicked(_ sender: Any) {
        fontSetBgView.isHidden =  true
    }
    @IBAction func fontResetButtonClicked(_ sender: Any) {
        fontSetBgView.isHidden =  true
    }
    
    @IBAction func fontAreasizeSliderValueChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        
        let value = slider.value
        lrcScrollAreaHeigh = value
        UserDefaults.standard.set(lrcScrollAreaHeigh, forKey: UserDefaultsKeys.scrollAreaHeighKey)
        
        lrcTextViewConstraint.constant = CGFloat(lrcScrollAreaHeigh)
        self.view.layoutIfNeeded()
    }
    @IBAction func fontScrollSpeedSliderValuedChanged(_ sender: Any) {
    }
    
    @IBAction func fontSizeSliderValueChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        
        let value = slider.value
        lrcFontSize = value
        updateFont()
        UserDefaults.standard.set(lrcFontSize, forKey: UserDefaultsKeys.fontSizeKey)
        
    }
    
    
    @IBAction func fontScrollSpeedSliderTouchDown(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        
        stopTimer()
    }
    
    @IBAction func fontScrollSpeedSliderTouchUp(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        
        let value = slider.value
        lrcSpeed = value
        UserDefaults.standard.set(lrcSpeed, forKey: UserDefaultsKeys.scrollSpeedKey)
        startTimer()
    }
    
    
    @IBAction func fontColorRedButtonClicked(_ sender: Any) {
        lrcFontColor = .red
        lrcFontMatchColor = .yellow
        updateTextRange()
    }
    
    @IBAction func fontColorGreenButtonClicked(_ sender: Any) {
        lrcFontColor = .green
        lrcFontMatchColor = .yellow
        updateTextRange()
    }
    
    @IBAction func fontColorBlueButtonClicked(_ sender: Any) {
        lrcFontColor = .blue
        lrcFontMatchColor = .white
        updateTextRange()
    }
    
    @IBAction func fontColorYellowButtonClicked(_ sender: Any) {
        lrcFontColor = .yellow
        lrcFontMatchColor = .green
        updateTextRange()
    }
    
    @IBAction func fontColorBrownButtonClicked(_ sender: Any) {
        lrcFontColor = .purple
        lrcFontMatchColor = .white
        updateTextRange()
    }
    
    @IBAction func fontColorWhiteButtonClicked(_ sender: Any) {
        lrcFontColor = .white
        lrcFontMatchColor = .red
        updateTextRange()
    }
    
    @IBAction func fontColorPinkButtonClicked(_ sender: Any) {
        lrcFontColor = .orange
        lrcFontMatchColor = .green
        updateTextRange()
    }
    
    @IBAction func btnEditTextClicked(_ sender: Any) {
        let vc = KEditLrcTextController()
        vc.deleage = self
        vc.orginText = originText
        let nav = NavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func btnFilterViewFinshClicked(_ sender: Any) {
        filtersView.isHidden = true
    }
    
    @IBAction func segmentFilterSetValueChanged(_ sender: Any) {
        
        guard let segmentControl = sender as? UISegmentedControl else {
            return
        }
        let index = segmentControl.selectedSegmentIndex
        if index == 0 {
            addCollectionView(at: 0)
        } else {
            addCollectionView(at: 1)
        }
    }
    
    @IBAction func fliterEnableSwitchValueChanged(_ sender: Any) {
        if let switchButton = sender as? UISwitch {
            isCustomFilterEnabled = switchButton.isOn
            UserDefaults.standard.setValue(isCustomFilterEnabled, forKey: UserDefaultsKeys.isFliterEnableKey)
        }
    }
    
    
}

// MARK: - UI 设置
extension KSwiftyCameraVC {
    
    private func bringSubsUIToFront() {
        
    }
    
    private func setupSwiftCamera() {
//        shouldPrompToAppSettings = true
//        cameraDelegate = self
//        maximumVideoDuration = 10.0
//        shouldUseDeviceOrientation = true
//        allowAutoRotate = true
//        audioEnabled = true
//        flashMode = .auto
    }
    
    private func initUI() {

        flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        captureButton.buttonEnabled = true
        captureButton.delegate = self
        titleLable.text = ""
        //lrcTextView.text = ""
        lrcTextView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        lrcTextView.font = UIFont.systemFont(ofSize: 20)

        
        //self.navigationController?.navigationBar.isHidden = true
        btnStart.setImage(UIImage(named: "microphone-icon"), for: .normal)
        
        updateTextRange()
        
        //lrcFontSize = SliderType.fontSize.max * 0.5
        //lrcSpeed = SliderType.speed.max * 0.5
        if let fontSize = UserDefaults.standard.float(forKey: UserDefaultsKeys.fontSizeKey) {
            lrcFontSize = fontSize
        }
        if let speed = UserDefaults.standard.float(forKey: UserDefaultsKeys.scrollSpeedKey) {
            lrcSpeed = speed
        }
        
        if let heigh = UserDefaults.standard.float(forKey: UserDefaultsKeys.scrollAreaHeighKey) {
            lrcScrollAreaHeigh = heigh
        }

        updateSliderUI()

        
        lrcSegmentControl.tintColor = .green
        lrcSegmentControl.selectedSegmentIndex = 0
        
        //初始化美颜设置
        isBeautyEnabled  = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBeautyEnableKey)
        beatyEnableSwitch.isOn = isBeautyEnabled
        initBeautySetView()
    
        //初始化字体设置
        initFontSetView()
        lrcTextView.borderColor = .yellow
        initRecordTimeUI()
        
        //初始化滤镜
        initFilterData()
        initFilterUI()
        
    }
    
    private func initBeautySetView() {
        //添加美颜设置View
        self.view.addSubview(beatyBgView)
        beatyBgView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(250)
        }
        beatyBgView.isHidden = true
    }
    
    private func initFontSetView() {
        //添加字体设置View
        self.view.addSubview(fontSetBgView)
        fontSetBgView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(250)
        }
        
        fontSetBgView.isHidden = true
        
        btnFontSet.setTitle("字幕设置", for: .normal)
        fontEnableSwitch.isOn = isShowLrc
    }
    
    private func initRecordTimeUI() {
        //进度条
        view.addSubview(hdhProgressBarView)
        
        //计时器
        view.addSubview(hdhTimeView)
        
        hdhProgressBarView.snp.makeConstraints { (make) in
            make.left.right.equalTo(lrcTextView)
            make.bottom.equalTo(lrcTextView.snp.top).offset(20)
            make.height.equalTo(20)
        }
        
        hdhTimeView.snp.makeConstraints { (make) in
            make.left.equalTo(lrcTextView)
            make.bottom.equalTo(hdhProgressBarView.snp.top)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        
        hdhTimeView.timeCompleteBlock = { [weak self] (maxSeconds) in
            print("计时到了：\(maxSeconds)秒")
            //recordTimeLabel.text = "录音完成"
        }
    }
    
    
    private func updateUI() {
        btnLanguage.setTitle(languageTitle, for: .normal)
    }
}



// MARK: - SwiftyCamButtonDelegate
extension KSwiftyCameraVC:SwiftyCamButtonDelegate {
    func longPressDidReachMaximumDuration() {
        print("\(#function)")
        stopRecord()
    }
    
    func setMaxiumVideoDuration() -> Double {
        return 120.0
    }
    
    func buttonWasTapped() {
        print("\(#function)")
        if isRecording {
            stopVideoRecord()
            
        } else {
            
            WZBCountdownLabel.play(withNumber: 5, endTitle: "go", begin: { [weak self] (label) in
                print("开始")
                DispatchQueue.main.async {
                    guard let self = self else {return}
                    self.hdhTimeView.reset()
                    self.hdhProgressBarView.reset()
                }
            }) { [weak self] (lable) in
                print("完成")
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.startVideoRecord()
                }
            }
        }
    }
    
    private func startVideoRecord() {
        if !self.isRecording {
            self.stopTimer()
            self.lrcResetOffset()
            
            
            self.startRecord()
            self.captureButton.growButton()
            self.startRecordTimer()
            
            if lrcSegmentControl.selectedSegmentIndex == 1 {
                restartAudioRecord()
            } else {
                self.startTimer()
            }
            hdhTimeView.reset()
            hdhProgressBarView.reset()
            
            hdhTimeView.start()
            hdhProgressBarView.start()
        }
    }
    
    private func stopVideoRecord() {
        stopRecord()
        invalidateRecordTimer()
        captureButton.shrinkButton()
        self.stopTimer()
        self.lrcResetOffset()
        if lrcSegmentControl.selectedSegmentIndex == 1 {
            stopAudioRecording()
        }
        
        hdhTimeView.stop()
        hdhProgressBarView.stop()
    }
    
    @objc fileprivate func timerFinished() {
        DispatchQueue.main.async {
            self.stopVideoRecord()
        }
    }
    
    fileprivate func startRecordTimer() {
        recordTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kMaxSeconds), target: self, selector:  #selector(timerFinished), userInfo: nil, repeats: false)
    }
    
    // End timer if UILongPressGestureRecognizer is ended before time has ended
    
    fileprivate func invalidateRecordTimer() {
        recordTimer?.invalidate()
        recordTimer = nil
    }
    
    func buttonDidBeginLongPress() {
        print("\(#function)")
        startRecord()
    }
    
    func buttonDidEndLongPress() {
        print("\(#function)")
        stopRecord()
    }


}



// MARK: - Metal Camera设置
extension KSwiftyCameraVC {
    private func bringPickerViewToFront() {
        mtiImageView.frame = self.view.frame
        btnPicker.frame = CGRect(x: view.bounds.width - btnPicker.width, y: view.bounds.height - btnPicker.height-60, width: 60, height: 60)
        
        let buttonFrame = btnPicker.frame
        var pickerFrame = CGRect(x: 0, y: 0, width: 80, height: view.bounds.height * 0.5)
        pickerFrame.origin.x = view.bounds.width - pickerFrame.width
        pickerFrame.origin.y = buttonFrame.minY - pickerFrame.height - 20
        backgroundPicker.frame = pickerFrame
        self.controlBgView.addSubview(backgroundPicker)
        self.controlBgView.addSubview(btnPicker)
        self.controlBgView.bringSubviewToFront(btnPicker)
    }
    
    private func setupMetalCamera() {
        createDir()
        camera = Camera(captureSessionPreset: .vga640x480, defaultCameraPosition: .front, configurator: .portraitFrontMirroredVideoOutput)
        try? camera?.enableVideoDataOutput(on: self.videoQueue, delegate: self)
        try? camera?.enableAudioDataOutput(on: self.audioQueue, delegate: self)
        camera?.videoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        isMattingEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isMattingEnableKey)
        switchOpenMatting.isOn = isMattingEnabled
        btnPicker.isHidden = !isMattingEnabled
    }
    
    private func createDir()  {
        let path = "\(NSTemporaryDirectory())/\(folderName)"
        let fileManager = FileManager()
        try? fileManager.removeItem(atPath: path)
        
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("\(error)")
        }
    }
    
    private func rotateCamera() {
        camera?.stopRunningCaptureSession()
        pixelBufferPool = nil
        
        if isFrontCamera {
            camera = Camera(captureSessionPreset: .medium, configurator: .portraitFrontMirroredVideoOutput)
        } else {
            camera = Camera(captureSessionPreset: .vga640x480, defaultCameraPosition: .front, configurator: .portraitFrontMirroredVideoOutput)
        }
        isFrontCamera = !isFrontCamera
        
        try? camera?.enableVideoDataOutput(on: self.videoQueue, delegate: self)
        try? camera?.enableAudioDataOutput(on: self.audioQueue, delegate: self)
        camera?.videoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        camera?.startRunningCaptureSession()
        
    }

    private func currentPixelBufferBool(for pixelBuffer: CVPixelBuffer) -> MTICVPixelBufferPool? {
        if pixelBufferPool != nil {
            return pixelBufferPool
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        pixelBufferPool = try? MTICVPixelBufferPool(pixelBufferWidth: width,
                                                    pixelBufferHeight: height,
                                                    pixelFormatType: kCVPixelFormatType_32BGRA,
                                                    minimumBufferCount: 30)
        return pixelBufferPool
    }
    
    private func startRecord() {
        if isRecording {
            return
        }

        let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(folderName)/\(UUID().uuidString).mp4")
        self.currentVideoURL = url
        print("录像路径:\(url)")
        var configuration = MovieRecorder.Configuration()
        configuration.isAudioEnabled = true
        configuration.audioSettings = camera?.audioDataOutput?.recommendedAudioSettingsForAssetWriter(writingTo: .mp4) as! [String : Any]
        let recorder = MovieRecorder(url: url, configuration: configuration, delegate: self)
        self.recorder = recorder
        recorder.prepareToRecord()
        
        self.isRecording = true
    }
    
    private func stopRecord() {
        self.recorder?.finishRecording()
    }
    
    private func filterSwitchValueChanged(_ sender: UISwitch) {
        isMattingEnabled = sender.isOn
        UserDefaults.standard.setValue(isMattingEnabled, forKey: UserDefaultsKeys.isMattingEnableKey)
        btnPicker.isHidden = !isMattingEnabled
    }

    private func recordingStopped() {
        self.recorder = nil
        self.isRecording = false
    }
    
    private func showPlayerViewController(url: URL) {

        if isMattingEnabled {
            let vc = KMedaiFileMattingVC()
            navigationController?.pushViewController(vc, animated: true)
            vc.videoAsset = AVURLAsset(url: url)
            vc.play()
        } else {
            let playerViewController = AVPlayerViewController()
            let player = AVPlayer(url: url)
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
    
}

// MARK: - Metal Camera 视频帧输出
extension KSwiftyCameraVC : AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            return
        }
        
        if CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Audio {
            //当前是音频，直接添加到缓存
            DispatchQueue.main.async {
                if self.isRecording {
                    self.recorder?.append(sampleBuffer: sampleBuffer)
                }
            }
            return
            
        } else if CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Video {
            //处理音频
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            var outputSampleBuffer = sampleBuffer
            let inputImage = MTIImage(cvPixelBuffer: pixelBuffer, alphaType: .alphaIsOne)
            var outputImage = inputImage
            if self.isMattingEnabled {
                self.mattingFilter.inputImage = inputImage
                self.generateMask(from: pixelBuffer)
                if let image = self.mattingFilter.outputImage?.withCachePolicy(.persistent) {
                    outputImage = image
                }
            }
            
            if self.isBeautyEnabled {
                self.colorLookupFilter.inputImage = outputImage
                if let image = self.colorLookupFilter.outputImage?.withCachePolicy(.persistent) {
                    outputImage = image
                }
            }
            
            if self.isCustomFilterEnabled, let filter = currentUseFliter {
                filter.inputImage = outputImage
                if let image = filter.outputImage {
                    outputImage = image
                }
            }
            
            
            DispatchQueue.main.async {
                if self.isRecording {
                    let bufferPool = self.currentPixelBufferBool(for: pixelBuffer)
                    if let pixelBuffer = try? bufferPool?.makePixelBuffer(allocationThreshold: 30) {
                        do {
                            try self.context.render(outputImage, to: pixelBuffer)
                            if let smbf = SampleBufferUtilities.makeSampleBufferByReplacingImageBuffer(of: sampleBuffer, with: pixelBuffer) {
                                outputSampleBuffer = smbf
                            }
                        } catch {
                            print("\(error)")
                        }
                    }
                    self.recorder?.append(sampleBuffer: outputSampleBuffer)
                }
                self.mtiImageView.image = outputImage
            }
        }
        
    }
    
    

}




// MARK: - Metal Camera MovieRecorderDelegate
extension KSwiftyCameraVC: MovieRecorderDelegate {
    
    func movieRecorderDidFinishPreparing(_ recorder: MovieRecorder) {
        
    }
    
    func movieRecorderDidCancelRecording(_ recorder: MovieRecorder) {
        recordingStopped()
    }
    
    func movieRecorder(_ recorder: MovieRecorder, didFailWithError error: Error) {
        recordingStopped()
    }
    
    func movieRecorderDidFinishRecording(_ recorder: MovieRecorder) {
        recordingStopped()
        if let url = self.currentVideoURL {
            showPlayerViewController(url: url)
        }
    }
    
    func movieRecorder(_ recorder: MovieRecorder, didUpdateWithTotalDuration totalDuration: TimeInterval) {
        print(totalDuration)
    }
}



// MARK: -UI更新
extension KSwiftyCameraVC {
    
    
    private func updateSliderUI() {
        
        //设置字体
        var type = SliderType.fontSize
        fontSizeSlider.minimumValue = type.min
        fontSizeSlider.maximumValue = type.max
        print("font min=\(type.min),max = \(type.max)")
        fontSizeSlider.setValue(lrcFontSize, animated: false)
        updateFont()
        
        //设置滚动速度
        type = SliderType.speed
        fontScrollSpeedSlider.minimumValue = type.min
        fontScrollSpeedSlider.maximumValue = type.max
        print("speed min=\(type.min),max = \(type.max)")
        fontScrollSpeedSlider.setValue(lrcSpeed, animated: false)
        
        fontAreaSizeSlider.minimumValue = Float(TEXTVIEW_MIN_H)
        fontAreaSizeSlider.maximumValue = Float(self.view.bounds.height)
        fontAreaSizeSlider.setValue(lrcScrollAreaHeigh)

    }
    
    private func updateFont() {
        //更新textView字体
        updateTextRange()
    }
    
    private func updateSpeed() {
        stopTimer()
        startTimer()
    }
}


// MARK: -字幕滚动
extension KSwiftyCameraVC {
    
    private func lrcResetOffset() {
        DispatchQueue.main.async {
            
            let pt = self.lrcTextView.contentOffset
            let n = CGFloat(0)
            self.lrcTextView.setContentOffset(CGPoint(x: pt.x, y: n), animated: true)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.1), repeats: true, block: { [weak self] (time) in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                let pt = self.lrcTextView.contentOffset
                let n = pt.y + self.lrcTextView.bounds.size.height * 0.1 * CGFloat(self.lrcSpeed)
                self.lrcTextView.setContentOffset(CGPoint(x: pt.x, y: n), animated: true)
                
                //print("n=\(n), offset=\(self.lrcTextView.contentOffset)")
                
                if n > self.lrcTextView.contentSize.height - self.lrcTextView.bounds.size.height {
                    self.stopTimer()
                    return
                }
            }

        })
    }
    
    private func stopTimer() {
        //定时器暂停
        timer.fireDate = Date.distantFuture
        //定时器销毁
        timer.invalidate()
    }
}

// MARK: - UIScrollViewDelegate
extension KSwiftyCameraVC:UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //定时器暂停
        timer.fireDate = Date.distantFuture
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //计时器继续
        timer.fireDate = Date.distantPast

    }
}

// MARK: -选择语言
extension KSwiftyCameraVC:KLanguageListTableVCDelegate {
    func KLanguageListTableVCDidSelectLanguage(_ language: OSSVoiceEnum) {
        self.language = language.rawValue
        self.languageTitle = language.title
        updateUI()
        stopSpeech()
    }
}

// MARK: SFSpeechRecognizerDelegate
extension KSwiftyCameraVC:SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnStart.isEnabled = true
            changeTip(text: "Start Recording")
        } else {
            btnStart.isEnabled = false
            changeTip(text: "Recognition Not Available")
        }
    }
}

// MARK: -语音识别
extension KSwiftyCameraVC {
    
    private func changeTip(text:String) {
        titleLable.text = text
    }
    
    func recordButtonTapped() {
        if audioEngine.isRunning {
            stopAudioRecording()
        } else {
            restartAudioRecord()
        }
    }
    
    private func restartAudioRecord() {
        do {
            try startAudioRecording()
            changeTip(text: "Stop Recording")
            
        } catch {
            changeTip(text: "Recording Not Available")
        }
    }
    
    private func setupSiri() {
        print("重新初始化speechRecognizer：\(language)")
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))
        speechRecognizer?.delegate = self
        speechRecognizer?.defaultTaskHint = .dictation
    }
    
    private func updateTextRange() {
        
        if !isShowLrc {
            lrcTextView.text = ""
            lrcTextView.attributedText = nil
            return
        }
        //1. 连续布局属性 - 关掉
        lrcTextView.layoutManager.allowsNonContiguousLayout = false
        //连续布局属性 默认是true的，如果不设置false 每次都会出现一闪一闪的
        //2. 设置textview的可见范围
        let atrStr = NSAttributedString(string: originText)
        let attrTitle = NSMutableAttributedString.init(attributedString: atrStr)
        let paraStyle = NSMutableParagraphStyle.init()
        paraStyle.setParagraphStyle(NSParagraphStyle.default)
        paraStyle.alignment = .center
        paraStyle.lineSpacing = 6
        let range = NSMakeRange(0, attrTitle.length)
        attrTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: paraStyle, range: range)
        attrTitle.addAttribute(.font, value: UIFont.systemFont(ofSize: CGFloat(lrcFontSize)), range: range)
        attrTitle.addAttribute(.foregroundColor, value: lrcFontColor, range: range)
        if let matchRange = matchRange {
            attrTitle.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: CGFloat(lrcFontSize)), range: matchRange)
            attrTitle.addAttribute(.foregroundColor, value: lrcFontMatchColor, range: matchRange)
            lrcTextView.selectedRange = matchRange // optional
            
            let more = min(matchRange.upperBound + 10, range.upperBound)
            let scrollRange =  NSMakeRange(matchRange.lowerBound,more)
            //lrcTextView.scrollRangeToVisible(scrollRange)
            
            let rect = lrcTextView.layoutManager.boundingRect(forGlyphRange: scrollRange, in: lrcTextView.textContainer)
            lrcTextView.contentOffset = CGPoint(x: 0, y: rect.origin.y - lrcTextView.bounds.size.height * 0.2)
        }
        lrcTextView.attributedText = attrTitle
        
    }
    
    private func checkAuthor() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.btnStart.isEnabled = true
                    self.btnStart.tintColor = .blue
                    
                case .denied:
                    self.btnStart.isEnabled = false
                    self.btnStart.tintColor = .darkGray
                    self.changeTip(text: "User denied access to speech recognition")
                    
                case .restricted:
                    self.btnStart.isEnabled = false
                    self.btnStart.tintColor = .darkGray
                    self.changeTip(text: "Speech recognition restricted on this device")
                    
                case .notDetermined:
                    self.btnStart.isEnabled = false
                    self.btnStart.tintColor = .darkGray
                    self.changeTip(text: "Speech recognition not yet authorized")
                    
                default:
                    self.btnStart.isEnabled = false
                    self.btnStart.tintColor = .darkGray
                }
            }
        }
    }
    
    private func startAudioRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        
        //recognitionRequest.requiresOnDeviceRecognition = true
        if speechRecognizer == nil {
            setupSiri()
        }

        guard let speechRecognizer = speechRecognizer else {
            return
        }
        
        self.btnStart.tintColor = .red
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            
            guard let self = self else {return}
            var isFinal = false
            
            self.btnStart.tintColor = .red
            
            if let result = result {
                self.titleLable.text = result.bestTranscription.formattedString
                print("识别到：\(result.bestTranscription.formattedString)")
                
                DispatchQueue.global().async {
                    self.match(result: result)
                }
                
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                print("error=\(String(describing: error))")
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btnStart.isEnabled = true
                self.btnStart.tintColor = .blue
                self.changeTip(text: "Start Recording")
            }
        }
        
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime)  in
            self?.recognitionRequest?.append(buffer)
            //print("*****buffer call back ")
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        //textView.text = "(Go ahead, I'm listening)"
    }
       
       
    private func stopAudioRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        btnStart.isEnabled = false
        changeTip(text: "Stopping")
        self.btnStart.tintColor = .darkGray
        
        self.audioEngine.stop()
    }
    
    private func stopSpeech() {
        stopAudioRecording()
        let inputNode = audioEngine.inputNode
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.btnStart.isEnabled = true
        self.btnStart.tintColor = .blue
        self.changeTip(text: "Start Recording")
        
        self.speechRecognizer?.delegate = nil
        self.speechRecognizer = nil
    }
    
    private func match(result:SFSpeechRecognitionResult) {

        lock.lock()
        defer { lock.unlock() }
        
        let best = result.bestTranscription
        var j = best.segments.count - 1
        var list = [SFTranscriptionSegment]()
        list.append(contentsOf: best.segments)
        
        let compareStr = originText.replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "。", with: " ")
            .replacingOccurrences(of: "?", with: " ")
            .replacingOccurrences(of: "!", with: " ")

        
        //print("需要匹配的语句：compareStr=\(compareStr)")
        var bestTrasnStr = best.formattedString.replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "。", with: " ")
            .replacingOccurrences(of: "?", with: " ")
            .replacingOccurrences(of: "!", with: " ")
        
        if let range = compareStr.nsranges(of: bestTrasnStr).first {
            self.matchRange = range
            if let last = self.lastMatchRange, let jiao = range.intersection(last) {
                self.matchRange = range.union(jiao)
            }
            print("🍺0 匹配到: range=\(String(describing: self.matchRange)), bestTrasnStr = \(bestTrasnStr)")
            DispatchQueue.main.async {
                self.updateTextRange()
            }
            self.lastMatchRange = self.matchRange
            return
        }
        
        bestTrasnStr = best.formattedString.lowercased().replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "。", with: " ")
            .replacingOccurrences(of: "?", with: " ")
            .replacingOccurrences(of: "!", with: " ")
        
        if let range = compareStr.nsranges(of: bestTrasnStr).first {
            self.matchRange = range
            if let last = self.lastMatchRange, let jiao = range.intersection(last) {
                self.matchRange = range.union(jiao)
            }
            print("🍺1 匹配到: range=\(String(describing: self.matchRange)), bestTrasnStr = \(bestTrasnStr)")
            DispatchQueue.main.async {
                self.updateTextRange()
            }
            self.lastMatchRange = self.matchRange
            return
        }

        while j >= 0 {
             let translate = list.map({ (item) -> String in
                 return item.substring
             }).joined(separator: " ")
             //print("j = \(j),translate = \(translate)")
             //let matchRang = compareStr.localizedStandardCompare(translate)
             let ranges = compareStr.nsranges(of: translate)
             if ranges.count > 0 {
                 
                 if ranges.count == 1 {
                     
                     self.matchRange = ranges.first
                     if let last = self.lastMatchRange,  let current = ranges.first, let jiao = current.intersection(last) {
                         self.matchRange = current.union(jiao)
                     }
                     print("🍺 匹配到: range=\(String(describing: self.matchRange)), translate = \(translate)")
                     DispatchQueue.main.async {
                         self.updateTextRange()
                     }
                     self.lastMatchRange = self.matchRange
                     return
                 }
                 else {
                     ranges.forEach { (item) in
                         //print("***匹配到多个遍历 : range=\(String(describing: item))")
                         if let last = self.lastMatchRange {
                             if let jiao = item.intersection(last) {
                                 self.matchRange = item.union(jiao)
                                 print("🍺🍺🍺1 匹配到: range=\(String(describing: self.matchRange))")
                                 DispatchQueue.main.async {
                                     self.updateTextRange()
                                 }
                                 self.lastMatchRange = self.matchRange
                                 return
                             } else if item.contains(last.location) {
                                 self.matchRange = item
                                 print("🍺🍺🍺2 匹配到: range=\(String(describing: self.matchRange))")
                                 DispatchQueue.main.async {
                                     self.updateTextRange()
                                 }
                                 self.lastMatchRange = self.matchRange
                                 return
                             }
                         }
                     }
                 }
             }
             
             list.removeFirst()
             j = j - 1
         }
                        
    }
}

// UI Animations
extension KSwiftyCameraVC {
    
    fileprivate func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
        }
    }
    
    fileprivate func showButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func toggleFlashAnimation() {
//        //flashEnabled = !flashEnabled
//        if flashMode == .auto{
//            flashMode = .on
//            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControl.State())
//        }else if flashMode == .on{
//            flashMode = .off
//            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControl.State())
//        }else if flashMode == .off{
//            flashMode = .auto
//            flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
//        }
    }
}


// MARK: - SwiftyCamViewControllerDelegate
extension KSwiftyCameraVC:SwiftyCamViewControllerDelegate {
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did start running")
        captureButton.buttonEnabled = true
    }
    
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did stop running")
        captureButton.buttonEnabled = false
    }
    

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let newVC = KPictureDisplayVC(image: photo)
        self.present(newVC, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did Begin Recording")
        captureButton.growButton()
        hideButtons()
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
        captureButton.shrinkButton()
        showButtons()
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        let newVC = KVideoDisplayVC(videoURL: url)
        self.present(newVC, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        print("Did focus at point: \(point)")
        focusAnimationAt(point)
    }
    
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print("Zoom level did change. Level: \(zoom)")
        print(zoom)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print("Camera did change to \(camera.rawValue)")
        print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }

}


// MARK: - KEditLrcTextControllerDeleage
extension KSwiftyCameraVC:KEditLrcTextControllerDeleage {
    
    func KEditLrcTextController_didSaveText(content: String) {
        lock.lock()
        defer { lock.unlock() }
        
        //停止语音识别
        stopAudioRecording()
        stopTimer()
        
        originText = content
        updateTextRange()
    }
    
    func KEditLrcTextController_didStartCamera(content: String) {
        lock.lock()
        defer { lock.unlock() }
        
        //停止语音识别
        stopAudioRecording()
        stopTimer()
        
        originText = content
        updateTextRange()
        
    }
}


// MARK: - 滤镜处理
extension KSwiftyCameraVC {
    private func initFilterData() {
        allFilters = MTFilterManager.shared.allFilters
        croppedImage = UIImage(named: "material_0.jpg")
        let ciImage = CIImage(cgImage: croppedImage.cgImage!)
        let originImage = MTIImage(ciImage: ciImage, isOpaque: true)
        originInputImage = originImage
        
        generateFilterThumbnails()
    }
    
    private func initFilterUI() {
        self.view.addSubview(filtersView)
        
        filtersView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        filtersView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(250)
        }
        
        setupFilterCollectionView()
        setupToolDataSource()
        setupToolCollectionView()
        btnFilterSetFinished.setTitle("完成", for: .normal)
        
        isCustomFilterEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isFliterEnableKey)
        fliterEnableSwitch.isOn = isCustomFilterEnabled
        filtersView.isHidden = true
        
        
    }
    
    fileprivate func setupFilterCollectionView() {
    
        let frame = CGRect(x: 0, y: 0, width: filtersView.bounds.width, height: filtersView.bounds.height - 44)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: 104, height: frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        filterCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.showsHorizontalScrollIndicator = false
        filterCollectionView.showsVerticalScrollIndicator = false
        filtersView.addSubview(filterCollectionView)
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        filterCollectionView.register(KFilterPickerCell.self, forCellWithReuseIdentifier: NSStringFromClass(KFilterPickerCell.self))
        filterCollectionView.reloadData()
        
        filterCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(segementFilterSet.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    fileprivate func setupToolCollectionView() {
        let frame = CGRect(x: 0, y: 0, width: filtersView.bounds.width, height: filtersView.bounds.height - 44)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: 98, height: frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        toolCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        toolCollectionView.backgroundColor = .clear
        toolCollectionView.showsHorizontalScrollIndicator = false
        toolCollectionView.showsVerticalScrollIndicator = false
        toolCollectionView.dataSource = self
        toolCollectionView.delegate = self
        toolCollectionView.register(KToolPickerCell.self, forCellWithReuseIdentifier: NSStringFromClass(KToolPickerCell.self))
        toolCollectionView.reloadData()
        
    }
    
    fileprivate func setupToolDataSource() {
        allTools.removeAll()
        allTools.append(KFilterToolItem(type: .adjust, slider: .adjustStraighten))
        allTools.append(KFilterToolItem(type: .brightness, slider: .negHundredToHundred))
        allTools.append(KFilterToolItem(type: .contrast, slider: .negHundredToHundred))
        allTools.append(KFilterToolItem(type: .structure, slider: .zeroToHundred))
        allTools.append(KFilterToolItem(type: .warmth, slider: .negHundredToHundred))
        allTools.append(KFilterToolItem(type: .saturation, slider: .negHundredToHundred))
        allTools.append(KFilterToolItem(type: .color, slider: .negHundredToHundred))
        allTools.append(KFilterToolItem(type: .fade, slider: .zeroToHundred))
        allTools.append(KFilterToolItem(type: .highlights, slider: .negHundredToHundred))
        allTools.append(KFilterToolItem(type: .shadows, slider: .negHundredToHundred))
        allTools.append(KFilterToolItem(type: .vignette, slider: .zeroToHundred))
        allTools.append(KFilterToolItem(type: .tiltShift, slider: .tiltShift))
        allTools.append(KFilterToolItem(type: .sharpen, slider: .zeroToHundred))
    }
    
    fileprivate func generateFilterThumbnails() {
        DispatchQueue.global().async {
            
            let size = CGSize(width: 200, height: 200)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            self.croppedImage.draw(in: CGRect(origin: .zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let image = scaledImage {
                for filter in self.allFilters {
                    let image = MTFilterManager.shared.generateThumbnailsForImage(image, with: filter)
                    self.thumbnails[filter.name] = image
                    DispatchQueue.main.async {
                        self.filterCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    fileprivate func addCollectionView(at index: Int) {
        let isFilterTabSelected = index == 0
        UIView.animate(withDuration: 0.5, animations: {
            if isFilterTabSelected {
                self.toolCollectionView.removeFromSuperview()
                self.filtersView.addSubview(self.filterCollectionView)
                
                self.filterCollectionView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.segementFilterSet.snp.bottom).offset(20)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(120)
                }
                
            } else {
                self.filterCollectionView.removeFromSuperview()
                self.filtersView.addSubview(self.toolCollectionView)
                
                self.toolCollectionView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.segementFilterSet.snp.bottom).offset(20)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(120)
                }
            }
        }) { (finish) in

        }

    }
    
    fileprivate func presentFilterControlView(for tool: KFilterToolItem) {
        
        //adjustFilter.inputImage = imageView.image
        adjustFilter.inputImage = originInputImage
        let width = self.filtersView.bounds.width
        let height = self.filtersView.bounds.height + 44 + view.safeAreaInsets.bottom
        let frame = CGRect(x: 0, y: view.bounds.height - height + 44, width: width, height: height)
    
        let value = valueForFilterControlView(with: tool)
        let controlView = KFilterControlView(frame: frame, filterTool: tool, value: value)
        controlView.delegate = self
        filterControlView = controlView
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.addSubview(controlView)
            controlView.setPosition(offScreen: false)
        }) { finish in
            self.title = tool.title
        }
    }
    
    fileprivate func dismissFilterControlView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.filterControlView?.setPosition(offScreen: true)
        }) { finish in
            self.filterControlView?.removeFromSuperview()
            self.title = "Editor"
        }
    }
    
    fileprivate func valueForFilterControlView(with tool: KFilterToolItem) -> Float {
        switch tool.type {
        case .adjustStrength:
            return 1.0
        case .adjust:
            return 0
        case .brightness:
            return adjustFilter.brightness
        case .contrast:
            return adjustFilter.contrast
        case .structure:
            return 0
        case .warmth:
            return adjustFilter.temperature
        case .saturation:
            return adjustFilter.saturation
        case .color:
            return 0
        case .fade:
            return adjustFilter.fade
        case .highlights:
            return adjustFilter.highlights
        case .shadows:
            return adjustFilter.shadows
        case .vignette:
            return adjustFilter.vignette
        case .tiltShift:
            return adjustFilter.tintShadowsIntensity
        case .sharpen:
            return adjustFilter.sharpen
        }
    }
    
    fileprivate func getFilterAtIndex(_ index: Int) -> MTFilter {
        if let filter = cachedFilters[index] {
            return filter
        }
        let filter = allFilters[index].init()
        cachedFilters[index] = filter
        return filter
    }
}

// MARK: - 滤镜处理
extension KSwiftyCameraVC {
}

extension KSwiftyCameraVC: KFilterControlViewDelegate {
    
    func filterControlViewDidPressCancel() {
        dismissFilterControlView()
    }
    
    func filterControlViewDidPressDone() {
        dismissFilterControlView()
    }
    
    func filterControlViewDidStartDragging() {
        
    }
    
    func filterControlView(_ controlView: KFilterControlView, didChangeValue value: Float, filterTool: KFilterToolItem) {
        
        if filterTool.type == .adjustStrength {
            currentAdjustStrengthFilter?.strength = value
            //imageView.image = currentAdjustStrengthFilter?.outputImage
            return
        }
        
        switch filterTool.type {
        case .adjust:
            break
        case .brightness:
            adjustFilter.brightness = value
            break
        case .contrast:
            adjustFilter.contrast = value
            break
        case .structure:
            break
        case .warmth:
            adjustFilter.temperature = value
            break
        case .saturation:
            adjustFilter.saturation = value
            break
        case .color:
            adjustFilter.tintShadowsColor = .green
            adjustFilter.tintShadowsIntensity = 1
            break
        case .fade:
            adjustFilter.fade = value
            break
        case .highlights:
            adjustFilter.highlights = value
            break
        case .shadows:
            adjustFilter.shadows = value
            break
        case .vignette:
            adjustFilter.vignette = value
            break
        case .tiltShift:
            adjustFilter.tintShadowsIntensity = value
        case .sharpen:
            adjustFilter.sharpen = value
        default:
            break
        }
        //imageView.image = adjustFilter.outputImage
    }
    
    func filterControlViewDidEndDragging() {
        
    }
    
    func filterControlView(_ controlView: KFilterControlView, borderSelectionChangeTo isSelected: Bool) {
        if isSelected {
            let blendFilter = MTIBlendFilter(blendMode: .overlay)
            let filter = getFilterAtIndex(currentSelectFilterIndex)
            blendFilter.inputBackgroundImage = filter.borderImage
            //blendFilter.inputImage = imageView.image
            //imageView.image = blendFilter.outputImage
        } else {
//            let filter = getFilterAtIndex(currentSelectFilterIndex)
//            filter.inputImage = originInputImage
//            imageView.image = filter.outputImage
        }
    }
}

extension KSwiftyCameraVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filterCollectionView {
            return allFilters.count
        }
        return allTools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == filterCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(KFilterPickerCell.self), for: indexPath) as! KFilterPickerCell
            let filter = allFilters[indexPath.item]
            cell.update(filter)
            cell.thumbnailImageView.image = thumbnails[filter.name]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(KToolPickerCell.self), for: indexPath) as! KToolPickerCell
            let tool = allTools[indexPath.item]
            cell.update(tool)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
            if currentSelectFilterIndex == indexPath.item {
                if indexPath.item != 0 {
                    let item = KFilterToolItem(type: .adjustStrength, slider: .zeroToHundred)
                    presentFilterControlView(for: item)
                    currentAdjustStrengthFilter = allFilters[currentSelectFilterIndex].init()
                    currentAdjustStrengthFilter?.inputImage = originInputImage
                    currentUseFliter = currentAdjustStrengthFilter
                }
            } else {
                let filter = allFilters[indexPath.item].init()
                filter.inputImage = originInputImage
                //imageView.image = filter.outputImage
                currentSelectFilterIndex = indexPath.item
                currentUseFliter = filter
            }
        } else {
            let tool = allTools[indexPath.item]
            presentFilterControlView(for: tool)
        }
    }
    
}
