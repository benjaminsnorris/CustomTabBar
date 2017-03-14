//
//  TabButton.swift
//  CustomTabBar
//
//  Created by Ben Norris on 2/11/16.
//  Copyright © 2016 BSN Design. All rights reserved.
//

import UIKit

protocol TabButtonDelegate {
    func tabButtonTouched(_ index: Int)
}

class TabButton: UIView {
    
    // MARK: - Internal properties
    
    var delegate: TabButtonDelegate?
    let index: Int
    let dataObject: TabDataObject
    
    var selected = false {
        didSet {
            updateColors()
        }
    }
    var unselectedColor: UIColor = .black {
        didSet {
            updateColors()
        }
    }
    var selectedColor: UIColor = .blue {
        didSet {
            updateColors()
        }
    }
    var badgeColor: UIColor = .red {
        didSet {
            updateBadge()
        }
    }
    var badgeTextColor: UIColor = .white {
        didSet {
            updateBadge()
        }
    }
    var inset: CGFloat = 0.0 {
        didSet {
            updateInsets()
        }
    }
    var titleFont: UIFont? = nil {
        didSet {
            updateFont()
        }
    }
    var badgeFont: UIFont? = nil {
        didSet {
            updateBadge()
        }
    }

    
    // MARK: - Private properties
    
    fileprivate let stackView = UIStackView()
    fileprivate let imageButton = UIButton()
    fileprivate let titleLabel = UILabel()
    fileprivate let button = UIButton()
    fileprivate let badgeLabel = UILabel()
    
    
    // MARK: - Constants
    
    fileprivate static let margin: CGFloat = 4.0
    fileprivate static var badgeMargin: CGFloat { return margin / 2 }
    
    
    // MARK: - Initializers
    
    init(index: Int, dataObject: TabDataObject) {
        self.index = index
        self.dataObject = dataObject
        super.init(frame: CGRect.zero)
        setupViews()
        setupAccessibilityInformation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("TabButton should not be initialized with decoder\(aDecoder)")
    }
    
    
    // MARK: - Internal functions
    
    func highlightButton() {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
            self.stackView.alpha = 0.2
        }, completion: nil)
    }
    
    func resetButton() {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
            self.stackView.alpha = 1.0
        }, completion: nil)
    }
    
    func buttonTouched() {
        delegate?.tabButtonTouched(index)
        resetButton()
    }
    
}


// MARK: - Private TabButton functions

private extension TabButton {
    
    func setupAccessibilityInformation() {
        isAccessibilityElement = true
        accessibilityLabel = dataObject.title.capitalized
        accessibilityIdentifier = dataObject.identifier
        accessibilityTraits = UIAccessibilityTraitButton
        imageButton.isAccessibilityElement = false
        button.isAccessibilityElement = false
    }
    
    func setupViews() {
        backgroundColor = .clear
        
        stackView.axis = .vertical
        addFullSize(stackView, withMargin: true)
        stackView.spacing = 1.0
        
        if let image = dataObject.image {
            stackView.addArrangedSubview(imageButton)
            imageButton.setImage(image, for: UIControlState())
            imageButton.imageView?.contentMode = .scaleAspectFit
        }
        if !dataObject.hideTitle {
            stackView.addArrangedSubview(titleLabel)
            titleLabel.text = dataObject.title
            titleLabel.textAlignment = .center
            titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        }
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.9
        
        button.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
        button.addTarget(self, action: #selector(highlightButton), for: .touchDown)
        button.addTarget(self, action: #selector(resetButton), for: .touchDragExit)

        updateColors()
        updateFont()
        updateBadge()
        addFullSize(button)
    }
    
    func updateColors() {
        titleLabel.textColor = selected ? selectedColor : unselectedColor
        imageButton.tintColor = selected ? selectedColor : unselectedColor
    }
    
    func updateFont() {
        if let titleFont = titleFont {
            titleLabel.font = titleFont
        } else if dataObject.image != nil {
            titleLabel.font = UIFont.systemFont(ofSize: 10)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 16)
        }
    }

    func updateBadge() {
        guard let value = dataObject.badgeValue else { badgeLabel.removeFromSuperview(); return }
        badgeLabel.text = value
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = badgeColor
        if let badgeFont = badgeFont {
            badgeLabel.font = badgeFont
        } else {
            badgeLabel.font = UIFont.boldSystemFont(ofSize: 12)
        }
        badgeLabel.textColor = badgeTextColor
        addBadgeLabel()
    }

    func addFullSize(_ view: UIView, withMargin margin: Bool = false) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin ? TabButton.margin : 0).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor, constant: margin ? TabButton.margin : 0).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margin ? -TabButton.margin : 0).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margin ? -TabButton.margin : 0).isActive = true
    }

    func addBadgeLabel() {
        guard badgeLabel.superview == nil else { return }
        addSubview(badgeLabel)
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        if let imageAnchor = imageButton.imageView?.trailingAnchor {
            badgeLabel.centerXAnchor.constraint(equalTo: imageAnchor, constant: TabButton.badgeMargin).isActive = true
        } else {
            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -TabButton.badgeMargin).isActive = true
        }
        badgeLabel.topAnchor.constraint(equalTo: topAnchor, constant: TabButton.badgeMargin).isActive = true
        let badgeHeight = badgeLabel.intrinsicContentSize.height * 1.1
        let badgeWidth = badgeLabel.intrinsicContentSize.width + badgeHeight / 2
        badgeLabel.heightAnchor.constraint(equalToConstant: badgeHeight).isActive = true
        badgeLabel.widthAnchor.constraint(equalToConstant: badgeWidth).isActive = true
        badgeLabel.layer.cornerRadius = badgeHeight / 2
        badgeLabel.clipsToBounds = true
    }
    
    func updateInsets() {
        imageButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
    }
    
}
