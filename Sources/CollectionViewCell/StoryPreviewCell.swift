//
//  StoryPreviewCell.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import AVKit
import EasyPeasy
import SafariServices

protocol StoryPreviewProtocol: UIViewController {
    func didCompletePreview()
    func moveToPreviousStory()
    func didTapCloseButton()
}
enum SnapMovementDirectionState {
    case forward
    case backward
}
//Identifiers
fileprivate let snapViewTagIndicator: Int = 8

final class StoryPreviewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    //MARK: - Delegate
    public weak var delegate: StoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    
    //MARK:- Private iVars
    private lazy var storyHeaderView: StoryPreviewHeaderView = {
        let v = StoryPreviewHeaderView()
        return v
    }()

    private lazy var actionButton: UIButton = {
        let button =  UIButton()
        button.isHidden = true
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        return button
    }()

    private var actionButtonLink: String?

    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.easy.layout(Size(48))
        imageView.isHidden = true
        imageView.image = UIImage(named: "iconError", in: Bundle.module, with: nil)
        imageView.tag = 100
        return imageView
    }()

    var activityIndicator: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()

    private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        lp.delegate = self
        return lp
    }()
    private lazy var tap_gesture: UITapGestureRecognizer = {
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTapSnap(_:)))
        tg.cancelsTouchesInView = false;
        tg.numberOfTapsRequired = 1
        tg.delegate = self
        return tg
    }()
    private var previousSnapIndex: Int {
        return snapIndex - 1
    }
    private var snapViewXPos: CGFloat {
        return (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
    }
    
    public var headers = [String: String]()
    
    private var videoSnapIndex: Int = 0

    var longPressGestureState: UILongPressGestureRecognizer.State?

    var baseURL: String!
    
    //MARK:- Public iVars
    public var direction: SnapMovementDirectionState = .forward
    public let scrollview: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.isScrollEnabled = false
        return sv
    }()

    var snapIndex: Int = 0 {
        didSet {
            scrollview.isUserInteractionEnabled = true
            if snapIndex < story?.snaps.count ?? 0 {
                if let snap = story?.snaps[snapIndex] {
                    configureActionButton(snap)

                    if snap.mediaType != .video {
                        if let snapView = getSnapview() {
                            startRequest(snapView: snapView, with: snap.mediaUrl(baseURL: baseURL), withHeaders: headers)
                        } else {
                            if direction == .forward {
                                let snapView = createSnapView()
                                startRequest(snapView: snapView, with: snap.mediaUrl(baseURL: baseURL), withHeaders: headers)
                            }
                        }
                    } else {

                        if let videoView = getVideoView(with: snapIndex) {
                            startPlayer(videoView: videoView, withRemoteURL: snap.mediaUrl(baseURL: baseURL))
                        } else {
                            let videoView = createVideoView()
                            startPlayer(videoView: videoView, withRemoteURL: snap.mediaUrl(baseURL: baseURL))
                        }
                    }
                }
            }

        }
    }
    public var story: Story? {
        didSet {
            storyHeaderView.story = story
        }
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollview.frame = bounds
        setupUIElements()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        direction = .forward
        clearScrollViewGarbages()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Private functions
    private func setupUIElements() {
        scrollview.delegate = self
        scrollview.isPagingEnabled = true
        contentView.addSubview(scrollview)
        contentView.addSubview(storyHeaderView)
        contentView.addSubview(actionButton)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(errorImageView)
        scrollview.addGestureRecognizer(longPress_gesture)
        scrollview.addGestureRecognizer(tap_gesture)
        scrollview.layer.cornerRadius = 8
        scrollview.layer.masksToBounds = true

        scrollview.easy.layout(Left().to(contentView.safeAreaLayoutGuide, .left), Top().to(contentView.safeAreaLayoutGuide, .top), Right().to(contentView.safeAreaLayoutGuide, .right), Bottom().to(contentView.safeAreaLayoutGuide, .bottom), Width().like(contentView, .width).with(.low), Height().like(contentView, .height).with(.low))
        storyHeaderView.easy.layout(Left(), Right(), Top(), Height(80))
        actionButton.easy.layout(Leading(24), Trailing(24), Bottom(24), Height(56))
        errorImageView.easy.layout(Center())

        activityIndicator.easy.layout(CenterX().to(contentView, .centerX), CenterY().to(contentView, .centerY))
    }
    private func createSnapView() -> UIImageView {
        let snapView = UIImageView()
        snapView.tag = snapIndex + snapViewTagIndicator

        // Delete if there is any snapview/videoview already present in that frame location.
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        
        scrollview.addSubview(snapView)
        snapView.easy.layout(Leading().to(scrollview, .leading).when {self.snapIndex == 0}, Top().to(scrollview.safeAreaLayoutGuide, .top), Width().like(scrollview, .width), Height().like(scrollview, .height), Bottom().to(scrollview.safeAreaLayoutGuide, .bottom))
        snapView.easy.layout(Leading(CGFloat(snapIndex)*scrollview.width).to(scrollview, .leading).when {self.snapIndex != 0})
        return snapView
    }
    private func getSnapview() -> UIImageView? {
        if let imageView = scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first as? UIImageView {
            return imageView
        }
        return nil
    }
    private func createVideoView() -> PlayerView {
        let videoView = PlayerView()
        videoView.tag = snapIndex + snapViewTagIndicator
        videoView.playerObserverDelegate = self
        
        // Delete if there is any snapview/videoview already present in that frame location.
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        
        scrollview.addSubview(videoView)
        videoView.easy.layout(Leading().to(scrollview, .leading).when {self.snapIndex == 0}, Top().to(scrollview.safeAreaLayoutGuide, .top), Width().like(scrollview, .width), Height().like(scrollview, .height), Bottom().to(scrollview.safeAreaLayoutGuide, .bottom))
        videoView.easy.layout(Leading(CGFloat(snapIndex)*scrollview.width).to(scrollview, .leading).when {self.snapIndex != 0})
        return videoView
    }
    private func getVideoView(with index: Int) -> PlayerView? {
        if let videoView = scrollview.subviews.filter({$0.tag == index + snapViewTagIndicator}).first as? PlayerView {
            return videoView
        }
        return nil
    }
    
    private func startRequest(snapView: UIImageView, with url: String, withHeaders headers: [String: String]) {
        errorImageView.isHidden = true
        startAnimating()
        snapView.setStoryImage(urlString: url, withHeaders: headers) {[weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.stopAnimating()
                switch result {
                case .success(_):
                    strongSelf.startProgressors()
                case .failure(_):
                    strongSelf.errorImageView.isHidden = false
                }
            }
        }
    }

    private func startPlayer(videoView: PlayerView, withRemoteURL url: String) {
        if scrollview.subviews.count > 0 {
            if story?.isCompletelyVisible == true {
                startAnimating()
                VideoCacheManager.shared.getFile(forURL: url, with: self.headers) { (result) in
                    self.stopAnimating()
                    switch result {
                    case .success(let url):
                        let videoResource = VideoResource(filePath: url.absoluteString)
                        videoView.play(with: videoResource, withHeaders: self.headers)
                    case .failure(let error):
                        self.errorImageView.isHidden = false
                        debugPrint("Video error: \(error)")
                    }
                }
            }
        }
    }

    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        longPressGestureState = sender.state
        if sender.state == .began ||  sender.state == .ended {
            if(sender.state == .began) {
                pauseEntireSnap()
            } else {
                resumeEntireSnap()
            }
        }
    }
    @objc private func didTapSnap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self.scrollview)
        
        if let snapCount = story?.snaps.count {
            var n = snapIndex
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */

            if !errorImageView.isHidden {
                errorImageView.isHidden = true
                fillupLastPlayedSnap(n)
            }

            if touchLocation.x < scrollview.contentOffset.x + (scrollview.frame.width/2) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    clearLastPlayedSnaps(n)
                    stopSnapProgressors(with: n)
                    n -= 1
                    resetSnapProgressors(with: n)
                    willMoveToPreviousOrNextSnap(n: n)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    stopSnapProgressors(with: n)
                    direction = .forward
                    n += 1
                    willMoveToPreviousOrNextSnap(n: n)
                }
            }
        }
    }
    @objc private func didEnterForeground() {
        if let snap = story?.snaps[snapIndex] {
            if snap.mediaType == .video {
                let videoView = getVideoView(with: snapIndex)
                startPlayer(videoView: videoView!, withRemoteURL: snap.mediaUrl(baseURL: baseURL))
            } else {
                startSnapProgress(with: snapIndex)
            }
        }

    }
    @objc private func didEnterBackground() {
        if let snap = story?.snaps[snapIndex] {
            if snap.mediaType == .video {
                stopPlayer()
            }
        }
        resetSnapProgressors(with: snapIndex)
    }
    private func willMoveToPreviousOrNextSnap(n: Int) {
        if let count = story?.snaps.count {
            if n < count {
                //Move to next or previous snap based on index n
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                snapIndex = n
            } else {
                delegate?.didCompletePreview()
            }
        }
    }
    @objc private func didCompleteProgress() {
        let n = snapIndex + 1
        if let count = story?.snaps.count {
            if n < count {
                //Move to next snap
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                direction = .forward
                snapIndex = n
            }else {
                stopPlayer()
                delegate?.didCompletePreview()
            }
        }
    }

    @objc private func handleActionButton() {
        if let link = actionButtonLink, let url = URL(string: link) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let safariController = SFSafariViewController(url: url, configuration: config)
            delegate?.present(safariController, animated: true)
        }
    }
    
    private func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for i in 0..<sIndex {
                snapIndex = i
            }
            let xValue = sIndex.toFloat * scrollview.frame.width
            scrollview.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    //Before progress view starts we have to fill the progressView
    private func fillupLastPlayedSnap(_ sIndex: Int) {
        if let snap = story?.snaps[sIndex], snap.mediaType == .video {
            videoSnapIndex = sIndex
            stopPlayer()
        }
        if let holderView = self.getProgressIndicatorView(with: sIndex),
           let progressView = self.getProgressView(with: sIndex){
            progressView.easy.layout(Width().like(holderView, .width))
        }
    }
    private func fillupLastPlayedSnaps(_ sIndex: Int) {
        //Coz, we are ignoring the first.snap
        if sIndex != 0 {
            for i in 0..<sIndex {
                if let holderView = self.getProgressIndicatorView(with: i),
                   let progressView = self.getProgressView(with: i){
                    progressView.easy.layout(Width().like(holderView, .width))
                }
            }
        }
    }
    private func clearLastPlayedSnaps(_ sIndex: Int) {
        if let _ = self.getProgressIndicatorView(with: sIndex),
           let progressView = self.getProgressView(with: sIndex) {
            progressView.easy.layout(Width(0))
        }
    }
    private func clearScrollViewGarbages() {
        scrollview.contentOffset = CGPoint(x: 0, y: 0)
        if scrollview.subviews.count > 0 {
            var i = 0 + snapViewTagIndicator
            var snapViews = [UIView]()
            scrollview.subviews.forEach({ (imageView) in
                if imageView.tag == i {
                    snapViews.append(imageView)
                    i += 1
                }
            })
            if snapViews.count > 0 {
                snapViews.forEach({ (view) in
                    view.removeFromSuperview()
                })
            }
        }
    }
    private func gearupTheProgressors(type: MediaType, playerView: PlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
           let progressView = getProgressView(with: snapIndex){
            progressView.story_identifier = String(self.story?.id ?? 0)
            progressView.snapIndex = snapIndex
            DispatchQueue.main.async {
                if type == .photo {
                    progressView.start(with: 5.0, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                        print("Completed snapindex: \(snapIndex)")
                        if isCancelledAbruptly == false {
                            self.didCompleteProgress()
                        }
                    })
                }else {
                    //Handled in delegate methods for videos
                }
            }
        }
    }
    
    //MARK:- Internal functions
    func startProgressors() {
        DispatchQueue.main.async {
            if self.scrollview.subviews.count > 0 {
                let imageView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? UIImageView
                if imageView?.image != nil && self.story?.isCompletelyVisible == true {
                    self.gearupTheProgressors(type: .photo)
                } else {
                    // Didend displaying will call this startProgressors method. After that only isCompletelyVisible get true. Then we have to start the video if that snap contains video.
                    if self.story?.isCompletelyVisible == true {
                        let videoView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? PlayerView
                        let snap = self.story?.snaps[self.snapIndex]
                        if let vv = videoView, self.story?.isCompletelyVisible == true {
                            self.startPlayer(videoView: vv, withRemoteURL: snap!.mediaUrl(baseURL: self.baseURL))
                        }
                    }
                }
            }
        }
    }
    func getProgressView(with index: Int) -> SnapProgressView? {
        let progressView = storyHeaderView.getProgressView
        if progressView.subviews.count > 0 {
            let pv = getProgressIndicatorView(with: index)?.subviews.first as? SnapProgressView
            guard let currentStory = self.story else {
                fatalError("story not found")
            }
            pv?.story = currentStory
            return pv
        }
        return nil
    }
    func getProgressIndicatorView(with index: Int) -> SnapProgressIndicatorView? {
        let progressView = storyHeaderView.getProgressView
        return progressView.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first as? SnapProgressIndicatorView ?? nil
    }

    func adjustPreviousSnapProgressorsWidth(with index: Int) {
        fillupLastPlayedSnaps(index)
    }

    //MARK: - Public functions
    public func willDisplayCellForZerothIndex(with sIndex: Int) {
        story?.isCompletelyVisible = true
        willDisplayCell(with: sIndex)
    }

    public func willDisplayCell(with sIndex: Int) {
        //Todo:Make sure to move filling part and creating at one place
        //Clear the progressor subviews before the creating new set of progressors.
        storyHeaderView.clearTheProgressorSubviews()
        storyHeaderView.createSnapProgressors()
        fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        snapIndex = sIndex
        
        //Remove the previous observors
        NotificationCenter.default.removeObserver(self)
        
        // Add the observer to handle application from background to foreground
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    public func startSnapProgress(with sIndex: Int) {
        if let indicatorView = getProgressIndicatorView(with: sIndex),
           let pv = getProgressView(with: sIndex) {
            pv.start(with: 5.0, holderView: indicatorView, completion: { (identifier, snapIndex, isCancelledAbruptly) in
                if isCancelledAbruptly == false {
                    self.didCompleteProgress()
                }
            })
        }
    }


    func startAnimating() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    public func pauseSnapProgressors(with sIndex: Int) {
        story?.isCompletelyVisible = false
        getProgressView(with: sIndex)?.pause()
    }
    public func stopSnapProgressors(with sIndex: Int) {
        getProgressView(with: sIndex)?.stop()
    }
    public func resetSnapProgressors(with sIndex: Int) {
        self.getProgressView(with: sIndex)?.reset()
    }
    public func pausePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.pause()
    }
    public func stopPlayer() {
        let videoView = getVideoView(with: videoSnapIndex)
        if videoView?.player?.timeControlStatus != .playing {
            getVideoView(with: videoSnapIndex)?.player?.replaceCurrentItem(with: nil)
        }
        videoView?.stop()
        //getVideoView(with: videoSnapIndex)?.player = nil
    }
    public func resumePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.play()
    }
    public func didEndDisplayingCell() {
        
    }
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    public func pauseEntireSnap() {
        let v = getProgressView(with: snapIndex)
        let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? PlayerView
        if videoView != nil {
            v?.pause()
            videoView?.pause()
        }else {
            v?.pause()
        }
    }
    public func resumeEntireSnap() {
        let v = getProgressView(with: snapIndex)
        let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? PlayerView
        if videoView != nil {
            v?.resume()
            videoView?.play()
        }else {
            v?.resume()
        }
    }

    private func configureActionButton(_ snap: Snap) {
        actionButton.isHidden = true
        actionButtonLink = nil
        let languagePrefix = Bundle.main.preferredLocalizations.first?.prefix(2)
        switch languagePrefix {
        case "az":
            actionButton.setTitle(snap.snapLanguage?.azerbaijani?.buttonText, for: .normal)
            actionButtonLink = snap.snapLanguage?.azerbaijani?.buttonLink
        case "ru":
            actionButton.setTitle(snap.snapLanguage?.russian?.buttonText, for: .normal)
            actionButtonLink = snap.snapLanguage?.russian?.buttonLink
        default:
            actionButton.setTitle(snap.snapLanguage?.english?.buttonText, for: .normal)
            actionButtonLink = snap.snapLanguage?.english?.buttonLink
        }
        if !(actionButton.title(for: .normal)?.isEmpty ?? true) {
            actionButton.isHidden = false
        }
    }
}

//MARK: - Extension|StoryPreviewHeaderProtocol
extension StoryPreviewCell: StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}

//MARK: - Extension|PlayerObserverDelegate
extension StoryPreviewCell: PlayerObserver {
    
    func didStartPlaying() {
        stopAnimating()
        if let videoView = getVideoView(with: snapIndex), videoView.currentTime <= 0 {
            if videoView.error == nil && (story?.isCompletelyVisible)! == true {
                if let holderView = getProgressIndicatorView(with: snapIndex),
                   let progressView = getProgressView(with: snapIndex) {
                    progressView.story_identifier = String(self.story?.id ?? 0)
                    progressView.snapIndex = snapIndex
                    if let duration = videoView.currentItem?.asset.duration {
                        if Float(duration.value) > 0 {
                            progressView.start(with: duration.seconds, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                                if isCancelledAbruptly == false {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                    self.didCompleteProgress()
                                } else {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                }
                            })
                        }else {
                            debugPrint("Player error: Unable to play the video")
                        }
                    }
                }
            }
        }
    }
    func didFailed(withError error: String, for url: URL?) {
        debugPrint("Failed with error: \(error)")
        errorImageView.isHidden = false
        stopAnimating()
    }
    func didCompletePlay() {
        //Video completed
    }
    
    func didTrack(progress: Float) {
        //Delegate already handled. If we just print progress, it will print the player current running time
    }
}

extension StoryPreviewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer is UISwipeGestureRecognizer) {
            return true
        }
        return false
    }
}
