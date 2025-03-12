//
//  StoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import EasyPeasy

protocol StoryPreviewHeaderProtocol: AnyObject { func didTapCloseButton() }

fileprivate let maxSnaps = 30

//Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

final class StoryPreviewHeaderView: UIView {
    
    //MARK: - iVars
    public weak var delegate: StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory: Int = 0
    public var story: StoryStateModel? {
        didSet {
            snapsPerStory  = (story?.snaps.count)! < maxSnaps ? (story?.snaps.count)! : maxSnaps
        }
    }
    fileprivate var progressView: UIView?

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "btnClose", in: Bundle.module, with: nil)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        button.easy.layout(Size(80))
        return button
    }()
    public var getProgressView: UIView {
        if let progressView = self.progressView {
            return progressView
        }
        let v = UIView()
        self.progressView = v
        self.addSubview(self.getProgressView)
        return v
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func loadUIElements(){
//        backgroundColor = .clearr
        addSubview(getProgressView)
        addSubview(closeButton)
    }
    private func installLayoutConstraints() {
        let pv = getProgressView
        pv.easy.layout(Left().to(self.safeAreaLayoutGuide, .left), Right().to(self.safeAreaLayoutGuide, .right), Top(8).to(self.safeAreaLayoutGuide, .top), Height(10))
        closeButton.easy.layout(CenterY().to(self.safeAreaLayoutGuide, .centerY), Right().to(self.safeAreaLayoutGuide, .right))
    }

    private func applyProperties<T: UIView>(_ view: T, with tag: Int? = nil, alpha: CGFloat = 1.0) -> T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        if let tagValue = tag {
            view.tag = tagValue
        }
        return view
    }
    
    //MARK: - Selectors
    @objc func didTapClose(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }
    
    //MARK: - Public functions
    public func clearTheProgressorSubviews() {
        getProgressView.subviews.forEach { v in
            v.subviews.forEach{v in (v as! SnapProgressView).stop()}
            v.removeFromSuperview()
        }
    }
    public func clearAllProgressors() {
        clearTheProgressorSubviews()
        getProgressView.removeFromSuperview()
        self.progressView = nil
    }
    public func clearSnapProgressor(at index:Int) {
        getProgressView.subviews[index].removeFromSuperview()
    }
    public func createSnapProgressors(){
        print("Progressor count: \(getProgressView.subviews.count)")
        let padding: CGFloat = 8 //GUI-Padding
        let height: CGFloat = 3
        var pvIndicatorArray: [SnapProgressIndicatorView] = []
        var pvArray: [SnapProgressView] = []
        
        // Adding all ProgressView Indicator and ProgressView to seperate arrays
        for i in 0..<snapsPerStory{
            let pvIndicator = SnapProgressIndicatorView()
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag, alpha:0.2))
            pvIndicatorArray.append(pvIndicator)
            
            let pv = SnapProgressView()
            pvIndicator.addSubview(applyProperties(pv))
            pvArray.append(pv)
        }
        // Setting Constraints for all progressView indicators
        for index in 0..<pvIndicatorArray.count {
            let pvIndicator = pvIndicatorArray[index]
            if index == 0 {
                pvIndicator.easy.layout(Left(padding).to(self.getProgressView.safeAreaLayoutGuide, .left), CenterY().to(getProgressView.safeAreaLayoutGuide, .centerY), Height(height), Right(padding).to(getProgressView.safeAreaLayoutGuide, .right).when { pvIndicatorArray.count == 1 })
            } else {
                let prePVIndicator = pvIndicatorArray[index-1]
                pvIndicator.easy.layout(Width().like(prePVIndicator, .width), Left(padding).to(prePVIndicator.safeAreaLayoutGuide, .right), CenterY().to(prePVIndicator.safeAreaLayoutGuide, .centerY), Height(height))
                pvIndicator.easy.layout(Right(padding).to(self.safeAreaLayoutGuide, .right).when { index == pvIndicatorArray.count - 1 })
            }
        }
        // Setting Constraints for all progressViews
        for index in 0..<pvArray.count {
            let pv = pvArray[index]
            let pvIndicator = pvIndicatorArray[index]
            pv.easy.layout(Width(0), Left().to(pvIndicator.safeAreaLayoutGuide, .left), Height().like(pvIndicator, .height), Top().to(pvIndicator.safeAreaLayoutGuide, .top))
        }
    }
}
