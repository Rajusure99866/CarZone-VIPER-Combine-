//
//  CZCommonListTableViewCell.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 25/08/21.
//

import UIKit

class CZCommonListTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundContentView: UIView!
    @IBOutlet weak var brandTitle: UILabel!
    @IBOutlet weak var disclosureIndicater: UIImageView!
    
    static let nibName = "CZCommonListTableViewCell"
    static let reuseIdentifer = "homeCommonListTableViewCell"
    
    private var currentSelectionColor:UIColor?
    private var setupShadowDone: Bool = false
    private var manufacturer: Model?

    private func setupShadow() {
        if setupShadowDone { return }
        self.backgroundContentView.layer.cornerRadius = 8
        self.backgroundContentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.backgroundContentView.layer.shadowRadius = 2
        self.backgroundContentView.layer.shadowOpacity = 0.3
        self.backgroundContentView.layer.shadowColor = UIColor.black.cgColor
        self.backgroundContentView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 5, width: self.frame.size.width - 20, height: self.frame.size.height - 15), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.backgroundContentView.layer.shouldRasterize = true
        self.backgroundContentView.layer.rasterizationScale = UIScreen.main.scale
        
        setupShadowDone = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShadow()
    }
    
    override func prepareForReuse() {
        self.backgroundContentView.backgroundColor = UIColor.clear
        self.currentSelectionColor = nil
        super.prepareForReuse()
    }
    
    func configure(with model: Model?) {
        guard let model = model else {
            return
        }
        self.manufacturer = model
        self.brandTitle.text = self.manufacturer?.name
    }
    
    // Custom highlight color for cell
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundContentView.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.9)
        }
        else {
            if let currentSelectionColor = currentSelectionColor {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.backgroundContentView.backgroundColor = currentSelectionColor
                }
            }
            
        }
    }
    
    // Setting Colour for alternating cells
    func setColor(_ color:UIColor) {
        currentSelectionColor = color
        self.backgroundContentView.backgroundColor = color
    }
    
}

