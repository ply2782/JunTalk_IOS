//
//  ChattingRoomMenuDialogViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/07/03.
//

import UIKit
import StompClientLib



class ChattingRoomMenuDialogViewController: UIViewController {
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var welcomButton: UIButton!
    var roomModel :Dictionary<String,Any> = [:];
    var userId : String? = "";
    
    weak var exitDelegate : ExitChattingRoom?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTranstion();
    }
    
    private func setupTranstion() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        self.view.endEditing(true)
        self.dismiss(animated: true);
    }
    
    @objc func dismissView(){
        dismiss(animated: true , completion: nil)
    }
    
    @IBAction func welcomButton(_ sender: Any) {
        
        guard let inviteDialogViewController = self.storyboard?.instantiateViewController(withIdentifier: "InViteDialogViewController") as? InViteDialogViewController else {
            return
        }
        inviteDialogViewController.modalPresentationStyle = .custom
        inviteDialogViewController.transitioningDelegate = self
        inviteDialogViewController.room_Uuid = roomModel["room_Uuid"] as? String        
        inviteDialogViewController.room_Index = roomModel["room_Index"] as? Int
        inviteDialogViewController.userId = userId;
        
        self.present(inviteDialogViewController, animated: true, completion: nil)
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        self.exitDelegate?.exitChattingRoom(itemModel: roomModel);
        self.dismissView();        
        
    }
    
    
    
}



extension ChattingRoomMenuDialogViewController: UIViewControllerTransitioningDelegate {
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
