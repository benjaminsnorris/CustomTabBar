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
}


// MARK: - Custom tab bar protocol and class

public protocol CustomTabBarDelegate {
    func tabBar(tabBar: CustomTabBar, didSelectTab tab: Int)
}

@IBDesignable public class CustomTabBar: UIView {
    
    // MARK: - Inspectable properties
    
    @IBInspectable public var underlineHeight: CGFloat = 2.0 {
        didSet {
            underlineHeightConstraint?.constant = underlineHeight
        }
    }
    
    @IBInspectable public var underlineOnBottom: Bool = true {
        didSet {
            configureVerticalPositions()
        }
    }
    
    @IBInspectable public var selectedIndex: Int = 0 {
        didSet {
            updateTabs()
        }
    }
    
    @IBInspectable public var accentColor: UIColor = UIColor.blueColor() {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable public var defaultTitleColor: UIColor = UIColor.blackColor() {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable public var lightBackground: Bool = true {
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
    
}


// MARK: - Tab button delegate implementation

extension CustomTabBar: TabButtonDelegate {
    
    func tabButtonTouched(index: Int) {
        selectedIndex = index
        delegate?.tabBar(self, didSelectTab: index)
    }
    
}


// MARK: - Private methods

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
        let shadowHeight = 0.5
        let shadowWidth = 0.0

        let shadowOffset: CGSize
        if underlineOnBottom {
            underlineBottomConstraint?.active = true
            underlineTopConstraint?.active = false
            shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
        } else {
            underlineBottomConstraint?.active = false
            underlineTopConstraint?.active = true
            shadowOffset = CGSize(width: shadowWidth, height: -shadowHeight)
        }
        
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 0.0
        layer.shadowColor = UIColor.blackColor().CGColor
    }
    
    func updateColors() {
        underline.backgroundColor = accentColor
        for button in buttons {
            button.unselectedColor = defaultTitleColor
            button.selectedColor = accentColor
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
        lightBackgroundBlur.hidden = !lightBackground
        darkBackgroundBlur.hidden = lightBackground
    }
    
}


// MARK: - Custom tab button

protocol TabButtonDelegate {
    func tabButtonTouched(index: Int)
}

class TabButton: UIView {
    
    // MARK: - Public properties
    
    var delegate: TabButtonDelegate?
    let index: Int
    let dataObject: TabDataObject
    
    var selected = false {
        didSet {
            updateColors()
        }
    }
    var unselectedColor: UIColor = .blackColor() {
        didSet {
            updateColors()
        }
    }
    var selectedColor: UIColor = .blueColor() {
        didSet {
            updateColors()
        }
    }
    
    
    // MARK: - Private properties
    
    let stackView = UIStackView()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let button = UIButton()
    
    
    // MARK: - Constants
    
    static let margin: CGFloat = 4.0
    
    
    // MARK: - Initializers
    
    init(index: Int, dataObject: TabDataObject) {
        self.index = index
        self.dataObject = dataObject
        super.init(frame: CGRectZero)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("TabButton should not be initialized with decoder\(aDecoder)")
    }
    
    
    // MARK: - Button touched
    
    func buttonTouched() {
        delegate?.tabButtonTouched(index)
    }
    
}


// MARK: - Private TabButton functions

private extension TabButton {
    
    func setupViews() {
        backgroundColor = .clearColor()
        
        stackView.axis = .Vertical
        addFullSize(stackView, withMargin: true)
        stackView.spacing = 1.0
        
        if let imageName = dataObject.imageName, image = UIImage(named: imageName) {
            stackView.addArrangedSubview(imageView)
            imageView.image = image
            imageView.contentMode = .ScaleAspectFit
            titleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        }
        if let title = dataObject.title {
            stackView.addArrangedSubview(titleLabel)
            titleLabel.text = title
            titleLabel.textAlignment = .Center
            titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        }
        
        button.addTarget(self, action: "buttonTouched", forControlEvents: .TouchUpInside)
        addFullSize(button)
        updateColors()
    }
    
    func updateColors() {
        titleLabel.textColor = selected ? selectedColor : unselectedColor
        imageView.tintColor = selected ? selectedColor : unselectedColor
    }
    
    func addFullSize(view: UIView, withMargin margin: Bool = false) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: margin ? TabButton.margin : 0).active = true
        view.topAnchor.constraintEqualToAnchor(topAnchor, constant: margin ? TabButton.margin : 0).active = true
        view.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: margin ? -TabButton.margin : 0).active = true
        view.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: margin ? -TabButton.margin : 0).active = true
    }
    
}
