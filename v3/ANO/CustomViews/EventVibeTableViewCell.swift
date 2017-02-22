//
//  EventVibeTableViewCell.swift
//  ANO
//
//  Created by Jacob May on 1/5/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit

class EventVibeTableViewCell: UITableViewCell {

    @IBOutlet weak var m_lblText: UILabel!
    @IBOutlet weak var m_btnLike: UIButton!
    @IBOutlet weak var m_btnDislike: UIButton!
    
    weak open var delegate: EventVibeTableViewCellDelegate?
    
    var m_objVibe: VibeObj?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setViewsWithVibe(_ EventVibe: VibeObj) {
        m_objVibe = EventVibe
        
        m_lblText.text = m_objVibe?.vibe_text
        m_btnLike.setTitle("🔥 \(m_objVibe!.vibe_likes)", for: .normal)
        m_btnDislike.setTitle("💀 \(m_objVibe!.vibe_dislikes)", for: .normal)
    }

    @IBAction func onClickBtnVibeLike(_ sender: Any) {
        delegate?.onClickBtnVibeLike(EventVibe: m_objVibe!)
    }
    
    @IBAction func onClickBtnVibeDislike(_ sender: Any) {
        delegate?.onClickBtnVibeDislike(EventVibe: m_objVibe!)
    }
}

protocol EventVibeTableViewCellDelegate: NSObjectProtocol {
    func onClickBtnVibeLike(EventVibe: VibeObj)
    func onClickBtnVibeDislike(EventVibe: VibeObj)
}
