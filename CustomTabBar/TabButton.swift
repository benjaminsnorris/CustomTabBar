//
//  TabButton.swift
//  CustomTabBar
//
//  Created by Ben Norris on 2/11/16.
//  Copyright © 2016 BSN Design. All rights reserved.
//

import UIKit

protocol TabButtonDelegate {
    func tabButtonTouched(index: Int)
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
    var inset: CGFloat = 0.0 {
        didSet {
            updateInsets()
        }
    }
    var titleFont: UIFont? = nil {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    
    // MARK: - Private properties
    
    private let stackView = UIStackView()
    private let imageButton = UIButton()
    private let titleLabel = UILabel()
    private let button = UIButton()
    
    
    // MARK: - Constants
    
    private static let margin: CGFloat = 4.0
    
    
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
            stackView.addArrangedSubview(imageButton)
            imageButton.setImage(image, forState: .Normal)
            imageButton.imageView?.contentMode = .ScaleAspectFit
            titleLabel.font = UIFont.systemFontOfSize(10)
        }
        if let title = dataObject.title {
            stackView.addArrangedSubview(titleLabel)
            titleLabel.text = title
            titleLabel.textAlignment = .Center
            titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        }
        if let titleFont = titleFont {
            titleLabel.font = titleFont
        }
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.9
        
        button.addTarget(self, action: #selector(buttonTouched), forControlEvents: .TouchUpInside)
        addFullSize(button)
        updateColors()
    }
    
    func updateColors() {
        titleLabel.textColor = selected ? selectedColor : unselectedColor
        imageButton.tintColor = selected ? selectedColor : unselectedColor
    }
    
    func addFullSize(view: UIView, withMargin margin: Bool = false) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: margin ? TabButton.margin : 0).active = true
        view.topAnchor.constraintEqualToAnchor(topAnchor, constant: margin ? TabButton.margin : 0).active = true
        view.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: margin ? -TabButton.margin : 0).active = true
        view.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: margin ? -TabButton.margin : 0).active = true
    }
    
    func updateInsets() {
        imageButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
    }
    
}
