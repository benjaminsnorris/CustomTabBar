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
    public let title: String
    public let image: UIImage?
    public let hideTitle: Bool
    public let identifier: String?
    
    /**
     Defines an object to provide rendering data for a `TabButton`
     
     - parameters:
        - title:        Text that will displayed if `hideTitle` is `false`, as well as used as the `accessibilityLabel` of the button
        - image:        An optional image to display in the button. Providing `nil` causes the button to display the title only
        - hideTitle:    A flag indicating whether to hide the text and show only the image. (Defaults to `false`)
        - identifier:   An optional string to be used as the `accessibilityIdentifier`, which can be stable across translations. (Defaults to `nil`)
     */
    public init(title: String, image: UIImage?, hideTitle: Bool = false, identifier: String? = nil) {
        self.title = title
        self.image = image
        self.hideTitle = hideTitle
        self.identifier = identifier
    }
}


// MARK: - Custom tab bar protocol and class

public protocol CustomTabBarDelegate {
    func tabBar(_ tabBar: CustomTabBar, didSelectTab tab: Int)
}

@IBDesignable open class CustomTabBar: UIView {
    
    // MARK: - Inspectable properties
    
    @IBInspectable open var selectedIndex: Int = 0 {
        didSet {
            updateTabs()
        }
    }
    
    @IBInspectable open var underlineHeight: CGFloat = 2.0 {
        didSet {
            underlineHeightConstraint?.constant = underlineHeight
        }
    }
    
    @IBInspectable open var internalMargin: CGFloat = 0.0 {
        didSet {
            for button in buttons {
                button.inset = internalMargin
            }
        }
    }
    
    @IBInspectable open var underlineTop: Bool = false {
        didSet {
            configureVerticalPositions()
        }
    }
    
    @IBInspectable open var shadowTop: Bool = true {
        didSet {
            configureVerticalPositions()
        }
    }
    
    @IBInspectable open var textColor: UIColor = UIColor.black {
        didSet {
            updateColors()
        }
    }
    
    /// Defaults to the tint color
    @IBInspectable open var selectedTextColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// Override this property if you need to set a specific font
    /// Defaults to 16 without an icon and 10 with
    open var titleFont: UIFont? = nil {
        didSet {
            updateTabs()
        }
    }
    
    @IBInspectable open var lightBackground: Bool = true {
        didSet {
            updateBackground()
        }
    }
    
    /// Set true for either a light or dark translucent tabBar, false for an opaque tabBar that uses the tabBar's backgroundColor property
    @IBInspectable open var translucentBackground: Bool = true {
        didSet {
            updateBackground()
        }
    }
    
    /// Set *true* for a quick left to right entry animation when the tab bar appears
    @IBInspectable open var animatesIn: Bool = false
    
    
    // MARK: - Public properties
    
    open var dataObjects: [TabDataObject] = [TabDataObject(title: "one", image: nil), TabDataObject(title: "two", image: nil)] {
        didSet {
            configureTabs()
        }
    }
    open var delegate: CustomTabBarDelegate?
    
    
    // MARK: - Private properties
    
    fileprivate var lightBackgroundBlur: UIVisualEffectView!
    fileprivate var darkBackgroundBlur: UIVisualEffectView!
    fileprivate let stackView = UIStackView()
    fileprivate var buttons = [TabButton]()
    
    fileprivate let underline = UIView()
    fileprivate var underlineHeightConstraint: NSLayoutConstraint?
    fileprivate var underlineWidthConstraint: NSLayoutConstraint?
    fileprivate var underlinePositionContraint: NSLayoutConstraint?
    fileprivate var underlineTopConstraint: NSLayoutConstraint?
    fileprivate var underlineBottomConstraint: NSLayoutConstraint?
    
    
    // MARK: - Method overrides
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateTabs(animated: animatesIn)
    }
    
    open override func tintColorDidChange() {
        updateColors()
    }
    
}


// MARK: - Tab button delegate implementation

extension CustomTabBar: TabButtonDelegate {
    
    func tabButtonTouched(_ index: Int) {
        selectedIndex = index
        delegate?.tabBar(self, didSelectTab: index)
    }
    
}


// MARK: - Private functions

private extension CustomTabBar {
    
    func setupViews() {
        let lightStyle = UIBlurEffectStyle.extraLight
        let lightBlurEffect = UIBlurEffect(style: lightStyle)
        lightBackgroundBlur = UIVisualEffectView(effect: lightBlurEffect)
        setupFullSize(lightBackgroundBlur)
        
        let darkStyle = UIBlurEffectStyle.dark
        let darkBlurEffect = UIBlurEffect(style: darkStyle)
        darkBackgroundBlur = UIVisualEffectView(effect: darkBlurEffect)
        setupFullSize(darkBackgroundBlur)
        
        stackView.distribution = .fillEqually
        setupFullSize(stackView)
        
        underline.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underline)
        underlineBottomConstraint = underline.bottomAnchor.constraint(equalTo: bottomAnchor)
        underlineBottomConstraint?.isActive = true
        underlineTopConstraint = underline.topAnchor.constraint(equalTo: topAnchor)
        underlineHeightConstraint = underline.heightAnchor.constraint(equalToConstant: underlineHeight)
        underlineHeightConstraint?.isActive = true
        underlinePositionContraint = underline.leadingAnchor.constraint(equalTo: leadingAnchor)
        underlinePositionContraint?.isActive = true
        
        configureTabs()
        configureVerticalPositions()
        updateColors()
        if selectedIndex < buttons.count {
            let button = buttons[selectedIndex]
            button.selected = true
        }
        updateBackground()
    }
    
    func setupFullSize(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func configureTabs() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll()
        
        for (index, dataObject) in dataObjects.enumerated() {
            let button = createButton(dataObject, atIndex: index)
            button.selected = button.index == selectedIndex
        }
        
        configureUnderlineWidth()
//        accessibilityElements = buttons
    }
    
    func createButton(_ dataObject: TabDataObject, atIndex index: Int) -> TabButton {
        let button = TabButton(index: index, dataObject: dataObject)
        button.delegate = self
        button.selectedColor = selectedTextColor ?? tintColor
        button.unselectedColor = textColor
        button.titleFont = titleFont
        stackView.addArrangedSubview(button)
        buttons.append(button)
        return button
    }
    
    func configureUnderlineWidth() {
        if let underlineWidthConstraint = underlineWidthConstraint {
            underlineWidthConstraint.isActive = false
        }
        underlineWidthConstraint = underline.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / CGFloat(buttons.count))
        underlineWidthConstraint?.isActive = true
    }
    
    func configureVerticalPositions() {
        if underlineTop {
            underlineBottomConstraint?.isActive = false
            underlineTopConstraint?.isActive = true
        } else {
            underlineBottomConstraint?.isActive = true
            underlineTopConstraint?.isActive = false
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
        layer.shadowColor = UIColor.black.cgColor
    }
    
    func updateColors() {
        underline.backgroundColor = tintColor
        for button in buttons {
            button.unselectedColor = textColor
            button.selectedColor = selectedTextColor ?? tintColor
        }
    }
    
    func updateTabs(animated: Bool = true) {
        for button in buttons {
            button.selected = button.index == selectedIndex
            if button.selected {
                button.accessibilityTraits |= UIAccessibilityTraitSelected
            } else if button.accessibilityTraits | UIAccessibilityTraitSelected == button.accessibilityTraits {
                button.accessibilityTraits ^= UIAccessibilityTraitSelected
            }
            button.titleFont = titleFont
        }
        
        let position = frame.size.width / CGFloat(buttons.count) * CGFloat(selectedIndex)
        self.underlinePositionContraint?.constant = position
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.layoutIfNeeded()
        }
    }
    
    func updateBackground() {
        lightBackgroundBlur.isHidden = !lightBackground || !translucentBackground
        darkBackgroundBlur.isHidden = lightBackground || !translucentBackground
    }
    
}
