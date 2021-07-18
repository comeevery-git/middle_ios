//
//  ComposeViewController.swift
//  middle_todo
//
//  Created by suhee❤️ on 2021/07/15.
//

import UIKit

class ComposeViewController: UIViewController, UITextFieldDelegate {

    // 수정버튼 클릭 시
    var editTarget: Memo?
    // 수정 이전 메모
    var originalMemoContent: String?
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var memoTextView2: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func save(_ sender: Any) {
        guard let memo = memoTextView.text, memo.count > 0 else {
            alert(message: "메모를 입력하세요.")
            return
        }

//        let newMemo = Memo(content: memo)
//        Memo.dummnyMemoList.append(newMemo)
        
        // editTarget에 메모가 저장되어있다면
        if let target = editTarget {
            target.content = memo
            DataManager.shared.saveContext()
            
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil)
            
        } else {
            DataManager.shared.addNewMemo(memo)
            
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        }

        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // editTarget에 메모가 저장되어있다면
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
        } else {
            navigationItem.title = "새 메모"
            memoTextView.text = ""
        }
        
        memoTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        navigationController?.presentationController?.delegate = nil
    }
    
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        
        // ios 13 이상
        // isModalInPresentation
        // 원본과 다르다면 추가
        if let original = originalMemoContent, let edited = textView.text {
            isModalInPresentation = original != edited
        }
    
    }
}

extension ComposeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) {
            [weak self] (action) in
            self?.save(action)
        }
        
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            [weak self] (action) in
            self?.close(action)
        }
        alert.addAction(cancelAction)
    
        present(alert, animated: true, completion: nil)
    }
}

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
