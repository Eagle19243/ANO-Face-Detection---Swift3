//
//  EventVibeViewController.swift
//  ANO
//
//  Created by Jacob May on 1/4/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit
import SVProgressHUD

class EventVibeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EventVibeTableViewCellDelegate, UITextFieldDelegate {

    @IBOutlet weak var m_tblVibes: UITableView!
    @IBOutlet weak var m_txtVibe: UITextField!
    
    weak open var delegate: EventVibeViewControllerDelegate?
    var m_selectedEvent: EventObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let objEvent = GlobalService.sharedInstance().g_objLiveEvent {
            m_selectedEvent = objEvent
        }
        
        // Do any additional setup after loading the view.
        m_tblVibes.rowHeight = UITableViewAutomaticDimension
        m_tblVibes.estimatedRowHeight = 44.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_selectedEvent?.event_vibes!.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objVibe = m_selectedEvent?.event_vibes?[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventVibeTableViewCell.self)) as! EventVibeTableViewCell
        cell.delegate = self
        cell.setViewsWithVibe(objVibe!)
        
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // EventVibeTableViewCellDelegate
    func onClickBtnVibeLike(EventVibe: VibeObj) {
        if EventVibe.vibe_is_vote {
            self.view.makeToast("You already voted this vibe before", duration: 1.5, position: .center)
        } else {
            EventVibe.vibe_likes = EventVibe.vibe_likes + 1
            voteVibe(EventVibe: EventVibe, IsLike: true)
        }
    }
    
    func onClickBtnVibeDislike(EventVibe: VibeObj) {
        if EventVibe.vibe_is_vote {
            self.view.makeToast("You already voted this vibe before", duration: 1.5, position: .center)
        } else {
            EventVibe.vibe_dislikes = EventVibe.vibe_dislikes + 1
            voteVibe(EventVibe: EventVibe, IsLike: false)
        }
    }

    func voteVibe(EventVibe: VibeObj, IsLike: Bool) {
        m_tblVibes.reloadData()
        EventVibe.vibe_is_vote = true
        
        WebService.sharedInstance().voteVibe(VibeId: EventVibe.vibe_id!,
                                             IsLike: IsLike)
        { (response, error) in
            if let error = error {
                print(error)
            } else {
                print(response!)
            }
        }
    }
    
    @IBAction func onClickBtnAdd(_ sender: Any) {
        self.m_txtVibe.resignFirstResponder()
        
        if (m_txtVibe.text?.characters.count)! > 0 {
            SVProgressHUD.show(withStatus: "Please wait...")
            WebService.sharedInstance().addVibe(EventId: (m_selectedEvent?.event_id)!,
                                                Text: m_txtVibe.text!)
            { (objVibe, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error)
                } else {
                    SVProgressHUD.dismiss()
                    self.m_selectedEvent?.event_vibes?.insert(objVibe!, at: 0)
                    self.m_tblVibes.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .fade)
                    
                    self.m_txtVibe.text = ""
                }
            }
        }
    }
    
    @IBAction func onClickBtnClose(_ sender: Any) {
        delegate?.onClickBtnClose()
    }
    
    //UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 {
            return true
        }
        
        if textField.text?.characters.count == Constants.Numbers.VIBE_MAX_LENGTH {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.m_txtVibe.resignFirstResponder()
        
        return true
    }
}

protocol EventVibeViewControllerDelegate: NSObjectProtocol {
    func onClickBtnClose()
}
