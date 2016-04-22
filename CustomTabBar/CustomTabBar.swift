//
//  CustomTabBar.swift
//  CustomTabBar
//
//  Created by Ben Norris on 1/18/16.
//  Copyright © 2016 BSN Design. All rights reserved.
//

import UIKit

// MARK: - Data object struct

public struct TabDataObject {
    public let title: String?
    public let imageName: String?
    
    public init(title: String?, imageName: String?) {
        self.title = title
        self.imageName = imageName
    }
}


// MARK: - Custom tab bar protocol and class

public protocol CustomTabBarDelegate {
    func tabBar(tabBar: CustomTabBar, didSelectTab tab: Int)
}

@IBDesignable public class CustomTabBar: UIView {
    
    // MARK: - Inspectable properties
    
    @IBInspectable public var selectedIndex: Int = 0 {
        didSet {
            updateTabs()
        }
    }
    
    @IBInspectable public var underlineHeight: CGFloat = 2.0 {
        didSet {
            underlineHeightConstraint?.constant = underlineHeight
        }
    }
    
    @IBInspectable public var internalMargin: CGFloat = 0.0 {
        didSet {
            for button in buttons {
                button.inset = internalMargin
            }
        }
    }
    
    @IBInspectable public var underlineTop: Bool = false {
        didSet {
            configureVerticalPositions()
        }
    }
    
    @IBInspectable public var shadowTop: Bool = true {
        didSet {
            configureVerticalPositions()
        }
    }
    
    @IBInspectable public var textColor: UIColor = UIColor.blackColor() {
        didSet {
            updateColors()
        }
    }
    
    /// Override this property if you need to set a specific font
    /// Defaults to 16 without an icon and 10 with
    public var titleFont: UIFont? = nil {
        didSet {
            updateTabs()
        }
    }
    
    @IBInspectable public var lightBackground: Bool = true {
        didSet {
            updateBackground()
        }
    }
    
    /// Set true for either a light or dark translucent tabBar, false for an opaque tabBar that uses the tabBar's backgroundColor property
    @IBInspectable public var translucentBackground: Bool = true {
        didSet {
            updateBackground()
        }
    }
    
    
    // MARK: - Public properties
    
    public var dataObjects: [TabDataObject] = [TabDataObject(title: "one", imageName: nil), TabDataObject(title: "two", imageName: nil)] {
        didSet {
            configureTabs()
        }
    }
    public var delegate: CustomTabBarDelegate?
    
    
    // MARK: - Private properties
    
    private var lightBackgroundBlur: UIVisualEffectView!
    private var darkBackgroundBlur: UIVisualEffectView!
    private let stackView = UIStackView()
    private var buttons = [TabButton]()
    
    private let underline = UIView()
    private var underlineHeightConstraint: NSLayoutConstraint?
    private var underlineWidthConstraint: NSLayoutConstraint?
    private var underlinePositionContraint: NSLayoutConstraint?
    private var underlineTopConstraint: NSLayoutConstraint?
    private var underlineBottomConstraint: NSLayoutConstraint?
    
    
    // MARK: - Method overrides
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateTabs()
    }
    
    public override func tintColorDidChange() {
        updateColors()
    }
    
}


// MARK: - Tab button delegate implementation

extension CustomTabBar: TabButtonDelegate {
    
    func tabButtonTouched(index: Int) {
        selectedIndex = index
        delegate?.tabBar(self, didSelectTab: index)
    }
    
}


// MARK: - Private functions

private extension CustomTabBar {
    
    func setupViews() {
        backgroundColor = nil
        
        let lightStyle = UIBlurEffectStyle.ExtraLight
        let lightBlurEffect = UIBlurEffect(style: lightStyle)
        lightBackgroundBlur = UIVisualEffectView(effect: lightBlurEffect)
        setupFullSize(lightBackgroundBlur)
        
        let darkStyle = UIBlurEffectStyle.Dark
        let darkBlurEffect = UIBlurEffect(style: darkStyle)
        darkBackgroundBlur = UIVisualEffectView(effect: darkBlurEffect)
        setupFullSize(darkBackgroundBlur)
        
        stackView.distribution = .FillEqually
        setupFullSize(stackView)
        
        underline.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underline)
        underlineBottomConstraint = underline.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
        underlineBottomConstraint?.active = true
        underlineTopConstraint = underline.topAnchor.constraintEqualToAnchor(topAnchor)
        underlineHeightConstraint = underline.heightAnchor.constraintEqualToConstant(underlineHeight)
        underlineHeightConstraint?.active = true
        underlinePositionContraint = underline.leadingAnchor.constraintEqualToAnchor(leadingAnchor)
        underlinePositionContraint?.active = true
        
        configureTabs()
        configureVerticalPositions()
        updateColors()
        if selectedIndex < buttons.count {
            let button = buttons[selectedIndex]
            button.selected = true
        }
        updateBackground()
    }
    
    func setupFullSize(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        view.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        view.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        view.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
    }
    
    func configureTabs() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll()
        
        for (index, dataObject) in dataObjects.enumerate() {
            createButton(dataObject, atIndex: index)
        }
        
        configureUnderlineWidth()
        
        if !(selectedIndex < buttons.count) {
            fatalError("Invalid selection for buttons: \(selectedIndex)")
        }
        let selectedButton = buttons[selectedIndex]
        selectedButton.selected = true
    }
    
    func createButton(dataObject: TabDataObject, atIndex index: Int) {
        let button = TabButton(index: index, dataObject: dataObject)
        button.delegate = self
        button.selectedColor = tintColor
        button.unselectedColor = textColor
        button.titleFont = titleFont
        stackView.addArrangedSubview(button)
        buttons.append(button)
    }
    
    func configureUnderlineWidth() {
        if let underlineWidthConstraint = underlineWidthConstraint {
            underlineWidthConstraint.active = false
        }
        underlineWidthConstraint = underline.widthAnchor.constraintEqualToAnchor(widthAnchor, multiplier: 1 / CGFloat(buttons.count))
        underlineWidthConstraint?.active = true
    }
    
    func configureVerticalPositions() {
        if underlineTop {
            underlineBottomConstraint?.active = false
            underlineTopConstraint?.active = true
        } else {
            underlineBottomConstraint?.active = true
            underlineTopConstraint?.active = false
        }
        
        let shadowHeight = 0.5
        let shadowWidth = 0.0

        let shadowOffset: CGSize
        if shadowTop {
            shadowOffset = CGSize(width: shadowWidth, height: -shadowHeight)
        } else {
            shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
        }
        
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 0.0
        layer.shadowColor = UIColor.blackColor().CGColor
    }
    
    func updateColors() {
        underline.backgroundColor = tintColor
        for button in buttons {
            button.unselectedColor = textColor
            button.selectedColor = tintColor
        }
    }
    
    func updateTabs() {
        if !(selectedIndex < buttons.count) {
            fatalError("Invalid index for buttons—selectedIndex: \(selectedIndex)")
        }
        for button in buttons {
            button.selected = button.index == selectedIndex
        }
        
        let position = frame.size.width / CGFloat(buttons.count) * CGFloat(selectedIndex)
        self.underlinePositionContraint?.constant = position
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion: nil)
    }
    
    func updateBackground() {
        lightBackgroundBlur.hidden = !lightBackground || !translucentBackground
        darkBackgroundBlur.hidden = lightBackground || !translucentBackground
    }
    
}
