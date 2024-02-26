//
//  ChooseCalendarViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/27.
//

import UIKit
import FSCalendar;

class ChooseCalendarViewController: UIViewController {
    let dateFormatter = DateFormatter()
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var closeBackgroundView: UIView!
    var selectedDate : String = "";
    var delegate : ChooseViewControllerProtocal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    @IBAction func insertDate(_ sender: Any) {
        delegate?.dismissSecondViewController(date: selectedDate)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeCalendar(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
   
    
}


extension ChooseCalendarViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 선택됨")
        selectedDate = dateFormatter.string(from: date);
        
    }
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        print(dateFormatter.string(from: date) + " 해제됨")
        selectedDate = "";
    }
}

